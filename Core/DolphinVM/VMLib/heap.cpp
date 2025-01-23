///////////////////////////////////////////////////////////////////////////////
// Low-level memory chunk (not object) management routines
//
// These map directly onto a heap

#define UMDF_USING_NTSTATUS

#include <stdio.h>
#include <intrin.h>
#include <wtypes.h>
#include "objmem.h"

#ifdef WIN32_HEAP
#define _CRTBLD
#include "winheap.h"
#undef _CRTBLD

HANDLE ObjectMemory::m_hHeap;
extern "C" { HANDLE _crtheap; }
#else

// Use mimalloc
#include "mimalloc.h"
#include "mimalloc-new-delete.h"

static mi_heap_t* objectHeap;

#endif

#ifdef MEMSTATS
extern size_t m_nAllocated;
extern size_t m_nFreed;
#endif

///////////////////////////////////////////////////////////////////////////////

void* ObjMemCall ObjectMemory::allocChunk(size_t chunkSize)
{
#ifdef WIN32_HEAP
	void* pChunk = ::HeapAlloc(m_hHeap, 0, chunkSize);
#else
	void* pChunk = mi_heap_malloc(objectHeap, chunkSize);
#endif

#ifdef _DEBUG
	memset(pChunk, 0xCD, chunkSize);
#endif

	return pChunk;
}

void* ObjMemCall ObjectMemory::allocSmallChunk(size_t chunkSize)
{
#ifdef WIN32_HEAP
	return allocChunk(chunkSize);
#else
	ASSUME(chunkSize <= MI_SMALL_SIZE_MAX);
	void* pChunk = mi_heap_malloc_small(objectHeap, chunkSize);
#endif

#ifdef _DEBUG
	memset(pChunk, 0xCD, chunkSize);
#endif

	return pChunk;
}

void ObjMemCall ObjectMemory::freeChunk(void* pChunk)
{
#ifdef MEMSTATS
	++m_nFreed;
#endif

#ifdef WIN32_HEAP
	::HeapFree(m_hHeap, 0, pChunk);
#else
	mi_free(pChunk);
#endif
}

void* ObjMemCall ObjectMemory::reallocChunk(void* pChunk, size_t newChunkSize)
{
#ifdef WIN32_HEAP
	return ::HeapReAlloc(m_hHeap, 0, pChunk, newChunkSize);
#else
	return mi_heap_reallocf(objectHeap, pChunk, newChunkSize);
#endif
}

// Compact any object memory heaps to minimize working set
void ObjectMemory::HeapCompact()
{
	// Minimize space occuppied by the heap
#ifdef WIN32_HEAP
	::HeapCompact(m_hHeap, 0);
	_heapmin();
#else
	mi_heap_collect(objectHeap, true);
#endif
}

#ifndef WIN32_HEAP

// Translate mimalloc heap errors to Win32 exceptions
static void heapError(int err, void* arg)
{
	ULONG_PTR args[1];
	args[0] = errno;

	switch (err)
	{
	// Potentially continuable errors in heap calls
	case EOVERFLOW: // Too large a request, for example in mi_calloc(), the count and size parameters are too large.
	case EINVAL: // Trying to free or re - allocate an invalid pointer.
		::RaiseException(static_cast<DWORD>(VMExceptions::CrtFault), 0, 1, (CONST ULONG_PTR*)args);
		break;
		
	case ENOMEM:	// Not enough memory available to satisfy the request.
		::RaiseException(STATUS_NO_MEMORY, 0, 0, nullptr);
		break;

	// Non-continuable errors, e.g. heap corruption
	case EFAULT: // Corrupted free list or meta - data was detected(only in debug and secure mode).
	case EAGAIN: // Double free was detected(only in debug and secure mode).
	default:
		::RaiseException(static_cast<DWORD>(VMExceptions::CrtFault), EXCEPTION_NONCONTINUABLE, 1, (CONST ULONG_PTR*)args);
		break;
	}
}

static void heapOutput(const char* msg, void* arg)
{
	// Dump directly to debug output as mimalloc sends large messages with newlines
	// This will also work even when the app is shutting down
	OutputDebugStringA(msg);
}

#endif

void ObjectMemory::InitializeHeap()
{
#ifdef WIN32_HEAP
	if (!m_hHeap)
	{
		// Reinitialize the heaps each time through as gets deleted on terminate
		m_hHeap = ::HeapCreate(HEAP_NO_SERIALIZE | HEAP_GENERATE_EXCEPTIONS, HEAPINITPAGES * dwPageSize, 0);
		if (!m_hHeap)
			::RaiseException(STATUS_NO_MEMORY, EXCEPTION_NONCONTINUABLE, 0, NULL);
		_crtheap = m_hHeap;
	}
#else
	if (!objectHeap)
	{
		mi_register_error(heapError, nullptr);
		mi_register_output(heapOutput, nullptr);
		objectHeap = mi_heap_new();
		if (!objectHeap)
			::RaiseException(STATUS_NO_MEMORY, EXCEPTION_NONCONTINUABLE, 0, NULL);

		#ifdef DEBUG
		{
			mi_option_enable(mi_option_show_errors);
			mi_option_enable(mi_option_show_stats);
			mi_option_enable(mi_option_verbose);
		}
		#endif
	}
#endif
}

void ObjectMemory::UninitializeHeap()
{
	DumpStats(L"UnitializeHeap");

#ifdef WIN32_HEAP
	// Leave heap around for use next time?
	//	::HeapDestroy(m_hHeap);
	//	m_hHeap = 0;
	//	_crtheap = 0;
#else
	mi_heap_destroy(objectHeap);
	mi_register_error(nullptr, nullptr);
	mi_register_output(nullptr, nullptr);
	objectHeap = nullptr;
#endif
}

#ifdef _DEBUG

size_t __cdecl ObjectMemory::chunkSize(void* pChunk)
{
#ifdef WIN32_HEAP
	return ::HeapSize(m_hHeap, 0, pChunk);
#else
	return mi_usable_size(pChunk);
#endif
}

void ObjectMemory::checkPools()
{
#ifndef WIN32_HEAP
	const size_t loopEnd = m_nOTSize;
	for (size_t i = OTBase; i < loopEnd; i++)
	{
		OTE& ote = m_pOT[i];
		if (!ote.isFree())
		{
			Spaces space = ote.heapSpace();
			if (space == Spaces::Normal)
			{
				HARDASSERT(mi_heap_check_owned(objectHeap, ote.m_location));
			}
		}
	}
#endif
}

#endif

#ifdef _DEBUG
#include <iomanip>

void ObjectMemory::OTEPool::DumpStats()
{
	tracelock lock(TRACESTREAM);
	TRACESTREAM << L"OTEPool(" << this << L"): total " << std::dec << m_nAllocated << ", free " << m_nFree << std::endl;
}

#endif

void ObjectMemory::DumpStats(const wchar_t* stage)
{
#ifdef _DEBUG
	tracelock lock(TRACESTREAM);

	TRACESTREAM << std::endl << L"Object Memory Statistics " << stage << L":" << std::endl
		<< L"------------------------------" << std::endl;
#endif

#ifdef WIN32_HEAP
	static _CrtMemState CRTMemState;
	_CrtMemCheckpoint(&CRTMemState);
	_CrtMemDumpStatistics(&CRTMemState);
#else
	mi_stats_print_out(heapOutput, nullptr);
#endif
}

