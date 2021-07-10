/******************************************************************************

	File: Alloc.cpp

	Description:

	Object Memory management allocation/coping routines

******************************************************************************/

#include "Ist.h"

#pragma code_seg(MEM_SEG)

#include "ObjMem.h"
#include "ObjMemPriv.inl"
#include "Interprt.h"
#include "VirtualMemoryStats.h"

#ifdef DOWNLOADABLE
#include "downloadableresource.h"
#else
#include "rc_vm.h"
#endif

#ifdef MEMSTATS
	extern size_t m_nLargeAllocated;
	extern size_t m_nSmallAllocated;
#endif

// Smalltalk classes
#include "STVirtualObject.h"
#include "STByteArray.h"

// No auto-inlining in this module please
#pragma auto_inline(off)

ObjectMemory::FixedSizePool	ObjectMemory::m_pools[MaxPools];
ObjectMemory::FixedSizePool::Link* ObjectMemory::FixedSizePool::m_pFreePages;
void** ObjectMemory::FixedSizePool::m_pAllocations;
size_t ObjectMemory::FixedSizePool::m_nAllocations;

///////////////////////////////////////////////////////////////////////////////
// Public object allocation routines

// Rarely used, so don't inline it
POBJECT ObjectMemory::allocLargeObject(size_t objectSize, OTE*& ote)
{
#ifdef MEMSTATS
	++m_nLargeAllocated;
#endif

	POBJECT pObj = static_cast<POBJECT>(allocChunk(_ROUND2(objectSize, sizeof(Oop))));

	// allocateOop expects crit section to be used
	ote = allocateOop(pObj);
	ote->setSize(objectSize);
	ote->m_flags.m_space = static_cast<space_t>(Spaces::Normal);
	return pObj;
}

inline POBJECT ObjectMemory::allocObject(size_t objectSize, OTE*& ote)
{
	// Callers are expected to round requests to Oop granularity
	if (objectSize <= MaxSmallObjectSize)
	{
		// Smallblock heap already has space for object size at start of obj which includes
		// heap overhead,etc, and is rounded to a paragraph size
		// Why not alloc. four bytes less, overwrite this size with our object size, and then
		// move back the object body pointer by four. On delete need to reapply the object
		// size back into the object? - No wouldn't work because of the way heap accesses
		// adjoining objects when freeing!

		POBJECT pObj = static_cast<POBJECT>(allocSmallChunk(objectSize));
		ote = allocateOop(pObj);
		ote->setSize(objectSize);
		ASSERT(ote->heapSpace() == Spaces::Pools);
		return pObj;
	}
	else
	{
		return allocLargeObject(objectSize, ote);
	}
}


///////////////////////////////////////////////////////////////////////////////
// Object copying (mostly allocation)


PointersOTE* __fastcall ObjectMemory::shallowCopy(PointersOTE* ote)
{
	ASSERT(!ote->isBytes());

	// A pointer object is a bit more tricky to copy (but not much)
	VariantObject* obj = ote->m_location;
	BehaviorOTE* classPointer = ote->m_oteClass;

	PointersOTE* copyPointer;
	size_t size;

	if (ote->heapSpace() != Spaces::Virtual)
	{
		size = ote->pointersSize();
		copyPointer = newPointerObject(classPointer, size);
	}
	else
	{
		Interpreter::resizeActiveProcess();

		size = ote->pointersSize();

		VirtualObject* pVObj = reinterpret_cast<VirtualObject*>(obj);
		VirtualObjectHeader* pBase = pVObj->getHeader();
		size_t maxByteSize = pBase->getMaxAllocation();
		size_t currentTotalByteSize = pBase->getCurrentAllocation();

		VirtualOTE* virtualCopy = ObjectMemory::newVirtualObject(classPointer,
			currentTotalByteSize / sizeof(Oop),
			maxByteSize / sizeof(Oop));
		if (virtualCopy)
		{
			pVObj = virtualCopy->m_location;
			pBase = pVObj->getHeader();
			ASSERT(pBase->getMaxAllocation() == maxByteSize);
			ASSERT(pBase->getCurrentAllocation() == currentTotalByteSize);
			virtualCopy->setSize(ote->getSize());

			copyPointer = reinterpret_cast<PointersOTE*>(virtualCopy);
		}
		else
		{
			return nullptr;
		}
	}

	// Now copy over all the fields
	VariantObject* copy = copyPointer->m_location;
	ASSERT(copyPointer->pointersSize() == size);
	for (auto i = 0u; i<size; i++)
	{
		copy->m_fields[i] = obj->m_fields[i];
		countUp(obj->m_fields[i]);
	}
	return copyPointer;
}

Oop* __fastcall Interpreter::primitiveShallowCopy(Oop* const sp, primargcount_t)
{
	OTE* receiver = reinterpret_cast<OTE*>(*sp);
	ASSERT(!isIntegerObject(receiver));

	OTE* copy = receiver->m_flags.m_pointer
		? (OTE*)ObjectMemory::shallowCopy(reinterpret_cast<PointersOTE*>(receiver))
		: (OTE*)ObjectMemory::shallowCopy(reinterpret_cast<BytesOTE*>(receiver));
	*sp = (Oop)copy;
	ObjectMemory::AddToZct(copy);
	return sp;
}

///////////////////////////////////////////////////////////////////////////////
// Public object Instantiation (see also Objmem.h)
//
// These methods return Oops rather than OTE*'s because we want the type to be
// opaque to external users, and to be interchangeable with uinptr_ts.
//

Oop* __fastcall Interpreter::primitiveNewFromStack(Oop* const stackPointer, primargcount_t)
{
	BehaviorOTE* oteClass = reinterpret_cast<BehaviorOTE*>(*(stackPointer - 1));

	Oop oopArg = (*stackPointer);
	SmallInteger count;
	if (isIntegerObject(oopArg) && (count = ObjectMemoryIntegerValueOf(oopArg)) >= 0)
	{
		// Note that instantiateClassWithPointers counts up the class,
		PointersOTE* oteObj = ObjectMemory::newUninitializedPointerObject(oteClass, count);
		VariantObject* obj = oteObj->m_location;

		Oop* sp = stackPointer;
		sp = sp - count - 1;
		while (--count >= 0)
		{
			oopArg = *(sp + count);
			ObjectMemory::countUp(oopArg);
			obj->m_fields[count] = oopArg;
		}

		// Save down SP in case ZCT is reconciled on adding result
		m_registers.m_stackPointer = sp;
		*sp = reinterpret_cast<Oop>(oteObj);
		ObjectMemory::AddToZct((OTE*)oteObj);
		return sp;
	}
	else
	{
		return primitiveFailure(_PrimitiveFailureCode::InvalidParameter1);
	}
}

Oop* __fastcall Interpreter::primitiveNewInitializedObject(Oop* sp, primargcount_t argCount)
{
	Oop oopReceiver = *(sp - argCount);
	BehaviorOTE* oteClass = reinterpret_cast<BehaviorOTE*>(oopReceiver);
	InstanceSpecification instSpec = oteClass->m_location->m_instanceSpec;

	if ((instSpec.m_value & (InstanceSpecification::PointersMask | InstanceSpecification::NonInstantiableMask)) == InstanceSpecification::PointersMask)
	{
		size_t minSize = instSpec.m_fixedFields;
		size_t i;
		if (instSpec.m_indexable)
		{
			i = max(minSize, argCount);
		}
		else
		{
			if (argCount > minSize)
			{
				// Not indexable, and too many fields
				return primitiveFailure(_PrimitiveFailureCode::WrongNumberOfArgs);
			}
			i = minSize;
		}

		// Note that instantiateClassWithPointers counts up the class,
		PointersOTE* oteObj = ObjectMemory::newUninitializedPointerObject(oteClass, i);
		VariantObject* obj = oteObj->m_location;

		// nil out any extra fields
		const Oop nil = reinterpret_cast<Oop>(Pointers.Nil);
		while (i > argCount)
		{
			obj->m_fields[--i] = nil;
		}

		while (i != 0)
		{
			i--;
			Oop oopArg = *sp--;
			ObjectMemory::countUp(oopArg);
			obj->m_fields[i] = oopArg;
		}

		// Save down SP in case ZCT is reconciled on adding result, allowing unref'd args to be reclaimed
		m_registers.m_stackPointer = sp;
		*sp = reinterpret_cast<Oop>(oteObj);
		ObjectMemory::AddToZct((OTE*)oteObj);
		return sp;
	}
	else
	{
		return primitiveFailure(instSpec.m_nonInstantiable ? _PrimitiveFailureCode::NonInstantiable : _PrimitiveFailureCode::ObjectTypeMismatch);
	}
}

Oop* __fastcall Interpreter::primitiveNew(Oop* const sp, primargcount_t)
{
	// This form of C code results in something very close to the hand-coded assembler original for primitiveNew

	BehaviorOTE* oteClass = reinterpret_cast<BehaviorOTE*>(*sp);
	InstanceSpecification instSpec = oteClass->m_location->m_instanceSpec;
	if (!(instSpec.m_indexable || instSpec.m_nonInstantiable))
	{
		PointersOTE* newObj = ObjectMemory::newPointerObject(oteClass, instSpec.m_fixedFields);
		*sp = reinterpret_cast<Oop>(newObj);
		ObjectMemory::AddToZct((OTE*)newObj);
		return sp;
	}
	else
	{
		return primitiveFailure(instSpec.m_nonInstantiable ? _PrimitiveFailureCode::NonInstantiable : _PrimitiveFailureCode::ObjectTypeMismatch);
	}
}

Oop* __fastcall Interpreter::primitiveNewWithArg(Oop* const sp, primargcount_t)
{
	BehaviorOTE* oteClass = reinterpret_cast<BehaviorOTE*>(*(sp - 1));
	Oop oopArg = (*sp);
	// Unfortunately the compiler can't be persuaded to perform this using just the sar and conditional jumps on no-carry and signed;
	// it generates both the bit test and the shift.
	SmallInteger size;
	if (isIntegerObject(oopArg) && (size = ObjectMemoryIntegerValueOf(oopArg)) >= 0)
	{
		InstanceSpecification instSpec = oteClass->m_location->m_instanceSpec;
		if ((instSpec.m_value & (InstanceSpecification::IndexableMask | InstanceSpecification::NonInstantiableMask)) == InstanceSpecification::IndexableMask)
		{
			if (instSpec.m_pointers)
			{
				PointersOTE* newObj = ObjectMemory::newPointerObject(oteClass, size + instSpec.m_fixedFields);
				*(sp - 1) = reinterpret_cast<Oop>(newObj);
				ObjectMemory::AddToZct(reinterpret_cast<OTE*>(newObj));
				return sp - 1;
			}
			else
			{
				BytesOTE* newObj = ObjectMemory::newByteObject<true, true>(oteClass, size);
				*(sp - 1) = reinterpret_cast<Oop>(newObj);
				ObjectMemory::AddToZct(reinterpret_cast<OTE*>(newObj));
				return sp - 1;
			}
		}
		else
		{
			// Not indexable, or non-instantiable
			return primitiveFailure(instSpec.m_nonInstantiable ? _PrimitiveFailureCode::NonInstantiable : _PrimitiveFailureCode::ObjectTypeMismatch);
		}
	}
	else
	{
		return primitiveFailure(_PrimitiveFailureCode::InvalidParameter1);	// Size must be positive SmallInteger
	}
}

PointersOTE* __fastcall ObjectMemory::newPointerObject(BehaviorOTE* classPointer)
{
	ASSERT(isBehavior(Oop(classPointer)));
	return newPointerObject(classPointer, classPointer->m_location->fixedFields());
}

PointersOTE* __fastcall ObjectMemory::newPointerObject(BehaviorOTE* classPointer, size_t oops)
{
	PointersOTE* ote = newUninitializedPointerObject(classPointer, oops);

	// Initialise the fields to nils
	const Oop nil = Oop(Pointers.Nil);		// Loop invariant (otherwise compiler reloads each time)
	VariantObject* pLocation = ote->m_location;
	const size_t loopEnd = oops;
	for (size_t i = 0; i<loopEnd; i++)
		pLocation->m_fields[i] = nil;

	ASSERT(ote->isPointers());

	return reinterpret_cast<PointersOTE*>(ote);
}

PointersOTE* __fastcall ObjectMemory::newUninitializedPointerObject(BehaviorOTE* classPointer, size_t oops)
{
	ASSERT(isBehavior((Oop)classPointer) && classPointer->isPointers());

	// Don't worry, compiler will not really use multiply instruction here
	size_t objectSize = SizeOfPointers(oops);
	OTE* ote;
	allocObject(objectSize, ote);
	ASSERT((objectSize > MaxSizeOfPoolObject && ote->heapSpace() == Spaces::Normal)
			|| ote->heapSpace() == Spaces::Pools);

	// These are stored in the object itself
	ASSERT(ote->getSize() == objectSize);
	classPointer->countUp();
	ote->m_oteClass = classPointer;

	// DO NOT Initialise the fields to nils

	ASSERT(ote->isPointers());
	
	return reinterpret_cast<PointersOTE*>(ote);
}

template <bool MaybeZ, bool Initialized> BytesOTE* ObjectMemory::newByteObject(BehaviorOTE* classPointer, size_t elementCount)
{
	Behavior& byteClass = *classPointer->m_location;
	OTE* ote;

	if (!MaybeZ || !byteClass.m_instanceSpec.m_nullTerminated)
	{
		ASSERT(!classPointer->m_location->m_instanceSpec.m_nullTerminated);

		VariantByteObject* newBytes = static_cast<VariantByteObject*>(allocObject(elementCount + SizeOfPointers(0), ote));
		ASSERT((elementCount > MaxSizeOfPoolObject && ote->heapSpace() == Spaces::Normal)
			|| ote->heapSpace() == Spaces::Pools);

		ASSERT(ote->getSize() == elementCount + SizeOfPointers(0));

		if (Initialized)
		{
			// Byte objects are initialized to zeros (but not the header)
			// Note that we round up to initialize to the next machine word
			ZeroMemory(newBytes->m_fields, _ROUND2(elementCount, sizeof(Oop)));
			classPointer->countUp();
		}

		ote->m_oteClass = classPointer;
		ote->beBytes();
	}
	else
	{
		ASSERT(classPointer->m_location->m_instanceSpec.m_nullTerminated);

		size_t objectSize;

		switch (reinterpret_cast<const StringClass&>(byteClass).Encoding)
		{
		case StringEncoding::Ansi:
		case StringEncoding::Utf8:
			objectSize = elementCount * sizeof(AnsiString::CU);
			break;
		case StringEncoding::Utf16:
			objectSize = elementCount * sizeof(Utf16String::CU);
			break;
		case StringEncoding::Utf32:
			objectSize = elementCount * sizeof(Utf32String::CU);
			break;
		default:
			__assume(false);
			break;
		}

		// TODO: Allocate the correct number of null term bytes based on the encoding
		objectSize += NULLTERMSIZE;

		VariantByteObject* newBytes = static_cast<VariantByteObject*>(allocObject(objectSize + SizeOfPointers(0), ote));
		ASSERT((objectSize > MaxSizeOfPoolObject && ote->heapSpace() == Spaces::Normal)
			|| ote->heapSpace() == Spaces::Pools);

		ASSERT(ote->getSize() == objectSize + SizeOfPointers(0));

		if (Initialized)
		{
			// Byte objects are initialized to zeros (but not the header)
			// Note that we round up to initialize to the next machine word
			ZeroMemory(newBytes->m_fields, _ROUND2(objectSize, sizeof(Oop)));
			classPointer->countUp();
		}
		else
		{
			// We still want to ensure the null terminator is set, even if not initializing the rest of the object
			*reinterpret_cast<NULLTERMTYPE*>(&newBytes->m_fields[objectSize - NULLTERMSIZE]) = 0;
		}

		ote->m_oteClass = classPointer;
		ote->beNullTerminated();
		HARDASSERT(ote->isBytes());
	}

	return reinterpret_cast<BytesOTE*>(ote);
}

// Explicit instantiations
template BytesOTE* ObjectMemory::newByteObject<false, false>(BehaviorOTE*, size_t);
template BytesOTE* ObjectMemory::newByteObject<false, true>(BehaviorOTE*, size_t);
template BytesOTE* ObjectMemory::newByteObject<true, false>(BehaviorOTE*, size_t);
template BytesOTE* ObjectMemory::newByteObject<true, true>(BehaviorOTE*, size_t);

Oop* __fastcall Interpreter::primitiveNewPinned(Oop* const sp, primargcount_t)
{
	BehaviorOTE* oteClass = reinterpret_cast<BehaviorOTE*>(*(sp - 1));
	Oop oopArg = (*sp);
	if (isIntegerObject(oopArg))
	{
		SmallInteger size = ObjectMemoryIntegerValueOf(oopArg);
		if (size >= 0)
		{
			InstanceSpecification instSpec = oteClass->m_location->m_instanceSpec;
			if (!(instSpec.m_pointers || instSpec.m_nonInstantiable))
			{
				BytesOTE* newObj = ObjectMemory::newByteObject<true, true>(oteClass, size);
				*(sp - 1) = reinterpret_cast<Oop>(newObj);
				ObjectMemory::AddToZct(reinterpret_cast<OTE*>(newObj));
				return sp - 1;
			}
			else
			{
				// Not bytes, or non-instantiable
				return primitiveFailure(instSpec.m_nonInstantiable ? _PrimitiveFailureCode::NonInstantiable : _PrimitiveFailureCode::ObjectTypeMismatch);
			}
		}
	}

	return primitiveFailure(_PrimitiveFailureCode::InvalidParameter1);	// Size must be positive SmallInteger
}

OTE* ObjectMemory::CopyElements(OTE* oteObj, size_t startingAt, size_t count)
{
	// Note that startingAt is expected to be a zero-based index
	ASSERT(startingAt >= 0);
	OTE* oteSlice;

	if (oteObj->isBytes())
	{
		BytesOTE* oteBytes = reinterpret_cast<BytesOTE*>(oteObj);
		size_t elementSizeShift = static_cast<size_t>(ObjectMemory::GetBytesElementSize(oteBytes));

		if (count == 0 || (((startingAt + count) << elementSizeShift) <= oteBytes->bytesSize()))
		{
			size_t objectSize = count << elementSizeShift;

			if (oteBytes->m_flags.m_weakOrZ)
			{
				// TODO: Allocate the correct number of null term bytes based on the encoding
				auto newBytes = static_cast<VariantByteObject*>(allocObject(objectSize + NULLTERMSIZE, oteSlice));
				// When copying strings, the slices has the same string class
				(oteSlice->m_oteClass = oteBytes->m_oteClass)->countUp();
				memcpy(newBytes->m_fields, oteBytes->m_location->m_fields + (startingAt << elementSizeShift), objectSize);
				*reinterpret_cast<NULLTERMTYPE*>(&newBytes->m_fields[objectSize]) = 0;
				oteSlice->beNullTerminated();
				return oteSlice;
			}
			else
			{
				VariantByteObject* newBytes = static_cast<VariantByteObject*>(allocObject(objectSize, oteSlice));
				// When copying bytes, the slice is always a ByteArray
				oteSlice->m_oteClass = Pointers.ClassByteArray;
				oteSlice->beBytes();
				memcpy(newBytes->m_fields, oteBytes->m_location->m_fields + (startingAt << elementSizeShift), objectSize);
				return oteSlice;
			}
		}
	}
	else
	{
		// Pointers
		PointersOTE* otePointers = reinterpret_cast<PointersOTE*>(oteObj);
		BehaviorOTE* oteClass = otePointers->m_oteClass;
		InstanceSpecification instSpec = oteClass->m_location->m_instanceSpec;
		if (instSpec.m_indexable)
		{
			startingAt += instSpec.m_fixedFields;

			if (count == 0 || (startingAt + count) <= otePointers->pointersSize())
			{
				size_t objectSize = SizeOfPointers(count);
				auto pSlice = static_cast<VariantObject*>(allocObject(objectSize, oteSlice));
				// When copying pointers, the slice is always an Array
				oteSlice->m_oteClass = Pointers.ClassArray;
				VariantObject* pSrc = otePointers->m_location;
				for (size_t i = 0; i < count; i++)
				{
					countUp(pSlice->m_fields[i] = pSrc->m_fields[startingAt + i]);
				}
				return oteSlice;
			}
		}
	}

	return nullptr;
}

Oop* Interpreter::primitiveCopyFromTo(Oop* const sp, primargcount_t)
{
	Oop oopToArg = *sp;
	Oop oopFromArg = *(sp - 1);
	OTE* oteReceiver = reinterpret_cast<OTE*>(*(sp - 2));
	if (ObjectMemoryIsIntegerObject(oopToArg))
	{
		if (ObjectMemoryIsIntegerObject(oopFromArg))
		{
			SmallInteger from = ObjectMemoryIntegerValueOf(oopFromArg);
			SmallInteger to = ObjectMemoryIntegerValueOf(oopToArg);

			if (from > 0)
			{
				SmallInteger count = to - from + 1;
				if (count >= 0)
				{
					OTE* oteAnswer = ObjectMemory::CopyElements(oteReceiver, from - 1, count);
					if (oteAnswer != nullptr)
					{
						*(sp - 2) = (Oop)oteAnswer;
						ObjectMemory::AddToZct(oteAnswer);
						return sp - 2;
					}
				}
			}

			// Bounds error
			return primitiveFailure(_PrimitiveFailureCode::OutOfBounds);
		}
		else
		{
			// Non positive SmallInteger 'from'
			return primitiveFailure(_PrimitiveFailureCode::InvalidParameter1);
		}
	}
	else
	{
		// Non positive SmallInteger 'to'
		return primitiveFailure(_PrimitiveFailureCode::InvalidParameter2);
	}
}

BytesOTE* __fastcall ObjectMemory::shallowCopy(BytesOTE* ote)
{
	ASSERT(ote->isBytes());

	// Copying byte objects is simple and fast
	VariantByteObject& bytes = *ote->m_location;
	BehaviorOTE* classPointer = ote->m_oteClass;
	size_t objectSize = ote->sizeOf();

	OTE* copyPointer;
	// Allocate an uninitialized object ...
	VariantByteObject* pLocation = static_cast<VariantByteObject*>(allocObject(objectSize, copyPointer));
	ASSERT((objectSize > MaxSizeOfPoolObject && copyPointer->heapSpace() == Spaces::Normal)
		|| copyPointer->heapSpace() == Spaces::Pools);

	ASSERT(copyPointer->getSize() == objectSize);
	// This set does not want to copy over the immutability bit - i.e. even if the original was immutable, the 
	// copy will never be.
	copyPointer->setSize(ote->getSize());
	copyPointer->m_flagsWord = (copyPointer->m_flagsWord & ~OTEFlags::WeakMask) | (ote->m_flagsWord & OTEFlags::WeakMask);
	ASSERT(copyPointer->isBytes());
	copyPointer->m_oteClass = classPointer;
	classPointer->countUp();

	// Copy the entire object over the other one, including any null terminator and object header
	memcpy(pLocation, &bytes, objectSize);

	return reinterpret_cast<BytesOTE*>(copyPointer);
}


///////////////////////////////////////////////////////////////////////////////
// Virtual object space allocation

// Answer a new process with an initial stack size specified by the first argument, and a maximum
// stack size specified by the second argument.
Oop* __fastcall Interpreter::primitiveNewVirtual(Oop* const sp, primargcount_t)
{
	Oop maxArg = *sp;
	SmallInteger maxSize;
	if (ObjectMemoryIsIntegerObject(maxArg) && (maxSize = ObjectMemoryIntegerValueOf(maxArg)) >= 0)
	{
		Oop initArg = *(sp - 1);
		SmallInteger initialSize;
		if (ObjectMemoryIsIntegerObject(initArg) && (initialSize = ObjectMemoryIntegerValueOf(initArg)) >= 0)
		{
			BehaviorOTE* receiverClass = reinterpret_cast<BehaviorOTE*>(*(sp - 2));
			InstanceSpecification instSpec = receiverClass->m_location->m_instanceSpec;
			if (instSpec.m_indexable && !instSpec.m_nonInstantiable)
			{
				auto fixedFields = instSpec.m_fixedFields;
				VirtualOTE* newObject = ObjectMemory::newVirtualObject(receiverClass, initialSize + fixedFields, maxSize);
				if (newObject)
				{
					*(sp - 2) = reinterpret_cast<Oop>(newObject);
						// No point saving down SP before potential Zct reconcile as the init & max args must be SmallIntegers
						ObjectMemory::AddToZct((OTE*)newObject);
					return sp - 2;
				}
				else
				{
					return primitiveFailure(_PrimitiveFailureCode::NoMemory);	// OOM
				}
			}
			else
			{
				return primitiveFailure(instSpec.m_nonInstantiable ? _PrimitiveFailureCode::NonInstantiable : _PrimitiveFailureCode::ObjectTypeMismatch);	// Non-indexable or abstract class
			}
		}
		else
		{
			return primitiveFailure(_PrimitiveFailureCode::InvalidParameter1);	// initialSize is not a positive SmallInteger
		}
	}
	else
	{
		return primitiveFailure(_PrimitiveFailureCode::InvalidParameter2);	// maxsize is not a positive SmallInteger
	}
}

/*
	Allocate a new virtual object from virtual space, which can grow up to maxBytes (including the
	virtual allocation overhead) but which has an initial size of initialBytes (NOT including the
	virtual allocation overhead). Should the allocation request fail, then a memory exception is 
	generated.
*/
Oop* __stdcall AllocateVirtualSpace(size_t maxBytes, size_t initialBytes)
{
	size_t reserveBytes = _ROUND2(maxBytes + dwPageSize, dwAllocationGranularity);
	ASSERT(reserveBytes % dwAllocationGranularity == 0);
	void* pReservation = ::VirtualAlloc(NULL, reserveBytes, MEM_RESERVE, PAGE_NOACCESS);
	if (pReservation)
	{

#ifdef _DEBUG
		// Let's see whether we got the rounding correct!
		MEMORY_BASIC_INFORMATION mbi;
		VERIFY(::VirtualQuery(pReservation, &mbi, sizeof(mbi)) == sizeof(mbi));
		ASSERT(mbi.AllocationBase == pReservation);
		ASSERT(mbi.BaseAddress == pReservation);
		ASSERT(mbi.AllocationProtect == PAGE_NOACCESS);
		//	ASSERT(mbi.Protect == PAGE_NOACCESS);
		ASSERT(mbi.RegionSize == reserveBytes);
		ASSERT(mbi.State == MEM_RESERVE);
		ASSERT(mbi.Type == MEM_PRIVATE);
#endif

		// We expect the initial byte size to be a integral number of pages, and it must also take account
		// of the virtual allocation overhead (currently 4 bytes)
		initialBytes = _ROUND2(initialBytes + sizeof(VirtualObjectHeader), dwPageSize);
		ASSERT(initialBytes % dwPageSize == 0);

		// Note that VirtualAlloc initializes the committed memory to zeroes.
		VirtualObjectHeader* pLocation = static_cast<VirtualObjectHeader*>(::VirtualAlloc(pReservation, initialBytes, MEM_COMMIT, PAGE_READWRITE));
		if (pLocation)
		{

#ifdef _DEBUG
			// Let's see whether we got the rounding correct!
			VERIFY(::VirtualQuery(pLocation, &mbi, sizeof(mbi)) == sizeof(mbi));
			ASSERT(mbi.AllocationBase == pLocation);
			ASSERT(mbi.BaseAddress == pLocation);
			ASSERT(mbi.AllocationProtect == PAGE_NOACCESS);
			ASSERT(mbi.Protect == PAGE_READWRITE);
			ASSERT(mbi.RegionSize == initialBytes);
			ASSERT(mbi.State == MEM_COMMIT);
			ASSERT(mbi.Type == MEM_PRIVATE);
#endif

			// Use first slot to hold the maximum size for the object
			pLocation->setMaxAllocation(maxBytes);
			return reinterpret_cast<Oop*>(pLocation + 1);
		}
	}

	::RaiseException(STATUS_NO_MEMORY, 0, 0, nullptr);
	return nullptr;
}

// N.B. Like the other instantiate methods in ObjectMemory, this method for instantiating
// objects in virtual space (used for allocating Processes, for example), does not adjust
// the ref. count of the class, because this is often unecessary, and does not adjust the
// sizes to allow for fixed fields - callers must do this
VirtualOTE* ObjectMemory::newVirtualObject(BehaviorOTE* classPointer, size_t initialSize, size_t maxSize)
{
	#ifdef _DEBUG
	{
		ASSERT(isBehavior(Oop(classPointer)));
		Behavior& behavior = *classPointer->m_location;
		ASSERT(behavior.isIndexable());
	}
	#endif

	// Trim the sizes to acceptable bounds
	if (initialSize <= dwOopsPerPage)
		initialSize = dwOopsPerPage;
	else
		initialSize = _ROUND2(initialSize, dwOopsPerPage);

	if (maxSize < initialSize)
		maxSize = initialSize;
	else
		maxSize = _ROUND2(maxSize, dwOopsPerPage);

	// We have to allow for the virtual allocation overhead. The allocation function will add in
	// space for this. The maximum size should include this, the initial size should not
	initialSize -= sizeof(VirtualObjectHeader)/sizeof(Oop);

	size_t byteSize = initialSize*sizeof(Oop);
	VariantObject* pLocation = reinterpret_cast<VariantObject*>(AllocateVirtualSpace(maxSize * sizeof(Oop), byteSize));
	if (pLocation)
	{
		// No need to alter ref. count of process class, as it is sticky

		// Fill space with nils for initial values
		const Oop nil = Oop(Pointers.Nil);
		const size_t loopEnd = initialSize;
		for (size_t i = 0; i < loopEnd; i++)
			pLocation->m_fields[i] = nil;

		OTE* ote = ObjectMemory::allocateOop(static_cast<POBJECT>(pLocation));
		ote->setSize(byteSize);
		ote->m_oteClass = classPointer;
		classPointer->countUp();
		ote->m_flags = m_spaceOTEBits[static_cast<space_t>(Spaces::Virtual)];
		ASSERT(ote->isPointers());

		return reinterpret_cast<VirtualOTE*>(ote);
	}

	return nullptr;
}

///////////////////////////////////////////////////////////////////////////////
// Low-level memory chunk (not object) management routines
//
void ObjectMemory::FixedSizePool::morePages()
{
	const size_t nPages = dwAllocationGranularity / dwPageSize;
	UNREFERENCED_PARAMETER(nPages);
	ASSERT(dwPageSize*nPages == dwAllocationGranularity);

	uint8_t* pStart = static_cast<uint8_t*>(::VirtualAlloc(NULL, dwAllocationGranularity, MEM_COMMIT, PAGE_READWRITE));
	if (pStart)
	{
#ifdef _DEBUG
		{
			tracelock lock(TRACESTREAM);
			TRACESTREAM << L"FixedSizePool: new pages @ " << LPVOID(pStart) << std::endl;
		}
#endif

		// Put the allocation (64k) into the allocation list so we can free it later
		{
			m_nAllocations++;
			m_pAllocations = static_cast<void**>(realloc(m_pAllocations, m_nAllocations * sizeof(void*)));
			m_pAllocations[m_nAllocations - 1] = pStart;
		}

		// We don't know whether the chunks are to contain zeros or nils, so we don't bother to init the space
#ifdef _DEBUG
		memset(pStart, 0xCD, dwAllocationGranularity);
#endif

		uint8_t* pLast = pStart + dwAllocationGranularity - dwPageSize;

#ifdef _DEBUG
		// ASSERT that pLast is correct by causing a GPF if it isn't!
		memset(reinterpret_cast<uint8_t*>(pLast), 0xCD, dwPageSize);
#endif

		for (uint8_t* p = pStart; p < pLast; p += dwPageSize)
			reinterpret_cast<Link*>(p)->next = reinterpret_cast<Link*>(p + dwPageSize);

		reinterpret_cast<Link*>(pLast)->next = 0;
		m_pFreePages = reinterpret_cast<Link*>(pStart);

#ifdef _DEBUG
		//		m_nPages++;
#endif
	}
	else
	{
		::RaiseException(STATUS_NO_MEMORY, EXCEPTION_NONCONTINUABLE, 0, NULL);	// Fatal - we must exit Dolphin
	}
}

inline uint8_t* ObjectMemory::FixedSizePool::allocatePage()
{
	if (!m_pFreePages)
	{
		morePages();
		ASSERT(m_pFreePages);
	}

	Link* pPage = m_pFreePages;
	m_pFreePages = pPage->next;
	
	return reinterpret_cast<uint8_t*>(pPage);
}

// Allocate another page for a fixed size pool
void ObjectMemory::FixedSizePool::moreChunks()
{
	constexpr size_t nOverhead = 0;//12;
	constexpr size_t nBlockSize = dwPageSize - nOverhead;
	const size_t nChunks = nBlockSize / m_nChunkSize;

	uint8_t* pStart = allocatePage();

	#ifdef _DEBUG
		if (abs(Interpreter::executionTrace) > 0)
		{
			tracelock lock(TRACESTREAM);
			TRACESTREAM<< L"FixedSizePool(" << this 
				<< L" new page @ " << pStart 
				<< L" (" << m_nPages<< L" pages of " 
				<< nChunks <<" chunks of "
				<< m_nChunkSize <<" bytes, total waste "
				<< m_nPages*(nBlockSize-(nChunks*m_nChunkSize)) << L')' << std::endl;
		}
		memset(pStart, 0xCD, nBlockSize);
	#else
		// We don't know whether the chunks are to contain zeros or nils, so we don't bother to init the space
	#endif

	uint8_t* pLast = &pStart[(nChunks-1) * m_nChunkSize];

	#ifdef _DEBUG
		// ASSERT that pLast is correct by causing a GPF if it isn't!
		memset(static_cast<uint8_t*>(pLast), 0xCD, m_nChunkSize);
	#endif

	const size_t chunkSize = m_nChunkSize;			// Loop invariant
	for (uint8_t* p = pStart; p < pLast; p += chunkSize)
		reinterpret_cast<Link*>(p)->next = reinterpret_cast<Link*>(p + chunkSize);

	reinterpret_cast<Link*>(pLast)->next = 0;
	m_pFreeChunks = reinterpret_cast<Link*>(pStart);

	#ifdef _DEBUG
		m_nPages++;
		m_pages = static_cast<void**>(realloc(m_pages, m_nPages*sizeof(void*)));
		m_pages[m_nPages-1] = pStart;
	#endif
}

void ObjectMemory::FixedSizePool::setSize(size_t nChunkSize)
{
	m_nChunkSize = nChunkSize;
// Must be on 4 byte boundaries
	ASSERT(m_nChunkSize % PoolGranularity == 0);
	ASSERT(m_nChunkSize >= MinObjectSize);
//	m_dwPageUsed = (dwPageSize / m_nChunkSize) * m_nChunkSize;
}

inline ObjectMemory::FixedSizePool::FixedSizePool(size_t nChunkSize) : m_pFreeChunks(0)
#ifdef _DEBUG
	, m_pages(0), m_nPages(0)
#endif
{
	setSize(nChunkSize);
}

//#ifdef NDEBUG
//	#pragma auto_inline(on)
//#endif

inline POBJECT ObjectMemory::reallocChunk(POBJECT pChunk, size_t newChunkSize)
{
	#ifdef PRIVATE_HEAP
		return static_cast<POBJECT>(::HeapReAlloc(m_hHeap, 0, pChunk, newChunkSize));
	#else
		void *oldPointer = pChunk;
		void *newPointer = realloc(pChunk, newChunkSize);
		_ASSERT(newPointer);
		if (NULL == newPointer)
			free(oldPointer);
		return newPointer;
	#endif
}


#ifdef MEMSTATS
	void ObjectMemory::OTEPool::DumpStats()
	{
		tracelock lock(TRACESTREAM);
		TRACESTREAM<< L"OTEPool(" << this<< L"): total " << std::dec << m_nAllocated <<", free " << m_nFree << std::endl;
	}

	static _CrtMemState CRTMemState;
	void ObjectMemory::DumpStats()
	{
		tracelock lock(TRACESTREAM);

		TRACESTREAM << std::endl<< L"Object Memory Statistics:" << std::endl
			<< L"------------------------------" << std::endl;

		CheckPoint();
		_CrtMemDumpStatistics(&CRTMemState);

#ifdef _DEBUG
		checkPools();
#endif

		TRACESTREAM << std::endl<< L"Pool Statistics:" << std::endl
			 << L"------------------" << std::endl << std::dec
			  << NumPools<< L" pools in the interval ("
			  << m_pools[0].getSize()<< L" to: "
			  << m_pools[NumPools-1].getSize()<< L" by: "
			  << PoolGranularity << L')' << std::endl << std::endl;

		size_t pageWaste=0;
		size_t totalPages=0;
		size_t totalFreeBytes=0;
		size_t totalChunks=0;
		size_t totalFreeChunks=0;
		for (auto i=0;i<NumPools;i++)
		{
			size_t nSize = m_pools[i].getSize();
			size_t perPage = dwPageSize/nSize;
			size_t wastePerPage = dwPageSize - (perPage*nSize);
			size_t nPages = m_pools[i].getPages();
			size_t nChunks = perPage*nPages;
			size_t waste = nPages*wastePerPage;
			size_t nFree = m_pools[i].getFree();
			TRACE(L"%d: size %d, %d objects on %d pgs (%d per pg, %d free), waste %d (%d per page)\n",
				i, nSize, nChunks-nFree, nPages, perPage, nFree, waste, wastePerPage);
			totalChunks += nChunks;
			pageWaste += waste;
			totalPages += nPages;
			totalFreeBytes += nFree*nSize;
			totalFreeChunks += nFree;
		}

		size_t objectWaste = 0;
		size_t totalObjects = 0;
		const OTE* pEnd = m_pOT+m_nOTSize;
		for (OTE* ote=m_pOT; ote < pEnd; ote++)
		{
			if (!ote->isFree())
			{
				totalObjects++;
				if (ote->heapSpace() == Spaces::Pools)
				{
					size_t size = ote->sizeOf();
					size_t chunkSize = _ROUND2(size, PoolGranularity);
					objectWaste += chunkSize - size;
				}
			}
		}

		size_t wastePercentage = (totalChunks - totalFreeChunks) == 0 
								? 0 
								: size_t(double(objectWaste)/
										double(totalChunks-totalFreeChunks)*100.0);

		TRACESTREAM<< L"===============================================" << std::endl;
		TRACE(L"Total objects	= %d\n"
			  "Total pool objs	= %d\n"
			  "Total chunks		= %d\n"
			  "Total Pages		= %d\n"
			  "Total Allocs		= %d\n"
			  "Total allocated	= %d\n"
			  "Page Waste		= %d bytes\n"
			  "Object Waste		= %d bytes (avg 0.%d)\n"
			  "Total Waste		= %d\n"
			  "Total free chks	= %d\n"
			  "Total Free		= %d bytes\n",
				totalObjects,
				totalChunks-totalFreeChunks,
				totalChunks,
				totalPages, 
				FixedSizePool::m_nAllocations,
				totalPages*dwPageSize, 
				pageWaste, 
				objectWaste, wastePercentage,
				pageWaste+objectWaste,
				totalFreeChunks,
				totalFreeBytes);
	}

	void ObjectMemory::CheckPoint()
	{
		_CrtMemCheckpoint(&CRTMemState);
	}

	size_t ObjectMemory::FixedSizePool::getFree()
	{
		Link* pChunk = m_pFreeChunks; 
		size_t tally = 0;
		while (pChunk)
		{
			tally++;
			pChunk = pChunk->next;
		}
		return tally;
	}
#endif

#if defined(_DEBUG)

	bool ObjectMemory::FixedSizePool::isMyChunk(void* pChunk)
	{
		const size_t loopEnd = m_nPages;
		for (size_t i=0;i<loopEnd;i++)
		{
			void* pPage = m_pages[i];
			if (pChunk >= pPage && static_cast<uint8_t*>(pChunk) <= (static_cast<uint8_t*>(pPage)+dwPageSize))
				return true;
		}
		return false;
	}

	bool ObjectMemory::FixedSizePool::isValid()
	{
		Link* pChunk = m_pFreeChunks; 
		while (pChunk)
		{
			if (!isMyChunk(pChunk))
				return false;
			pChunk = pChunk->next;
		}
		return true;
	}

#endif

