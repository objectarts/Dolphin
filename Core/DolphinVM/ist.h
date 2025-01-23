/******************************************************************************

	File: Ist.h

	Description:

	Dolphin Smalltalk precompiled header file

******************************************************************************/
#pragma once

#if defined(USE_VM_DLL) && defined(TO_GO)
	#error("Project config is incompatible (ToGo apps do not use the VM DLL)")
#endif

#ifdef VMDLL
	// Building main Dolphin VM

	#if defined(TO_GO) || defined(INPROC) || defined(_CONSOLE) || defined(LAUNCHER)
		#error("Project config is incompatible (VMDLL is incompatible with building deployment stubs/launcher)")
	#endif

	#define CANSAVEIMAGE 1
	#define VMINITFLAGS VmInitFlags::VmInitIsDevSys
#else
	#ifdef _CONSOLE
		// Building console stub
		#ifdef INPROC
			#error("Project config is incompatible (Inproc stubs are for console and GUI use)")
		#endif

		#ifdef TO_GO
			#define VMINITFLAGS (VmInitFlags::VmInitIsConsole | VmInitFlags::VmInitIsToGo)
		#else
			#define USE_VM_DLL 1
			#define VMINITFLAGS VmInitFlags::VmInitIsConsole
		#endif
	#else
		#ifdef INPROC
			// Building in-proc stub
			#ifdef TO_GO
				#define VMINITFLAGS (VmInitFlags::VmInitIsInProc | VmInitFlags::VmInitIsToGo)
			#else
				#define USE_VM_DLL 1
				#define VMINITFLAGS VmInitFlags::VmInitIsInProc
			#endif
		#else
			#ifdef LAUNCHER
				#ifdef TO_GO
					#error("Project config is incompatible (Development launcher is not a To Go stub)")
				#endif
				#define USE_VM_DLL 1
				#define	VMINITFLAGS VmInitFlags::VmInitIsDevSys
			#else
				// Building GUI stub
				#ifdef TO_GO
					#define VMINITFLAGS VmInitFlags::VmInitIsToGo
				#else
					#define USE_VM_DLL 1
					#define VMINITFLAGS VmInitFlags::VmInitNone
				#endif
			#endif
		#endif
	#endif
#endif

// Enable templated overloads for secure version of old-style CRT functions that manipulate buffers but take no size arguments

#undef _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES
#define _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES 1
#undef _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES
#define _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES 1 

// Prevent redefinition of QWORD type in <windns.h>
#define _WINDNS_INCLUDED_

#include <float.h>
#include <io.h>
#include <string.h>
#include <stdlib.h>

#include "heap.h"

#pragma warning(disable:4711)	// Function selected for automatic inline expansion
#pragma warning(disable:4786)	// Browser identifier truncated to 255 characters

#pragma warning(push,3)
// Disable warning about exception handling (we compile with exception handling disabled)
#pragma warning (disable:4530)
#include <ppl.h>
#include <iomanip>
#pragma warning(pop)

#define UMDF_USING_NTSTATUS
#ifndef _NTDEF_
	typedef _Return_type_success_(return >= 0) int32_t NTSTATUS;
	#define NTSTATUS_DEFINED
	#define _NTDEF_
#endif

#include "Environ.h"

class ObjectMemory;
class Interpreter;

/*
 * Macros to round numbers (borrowed from CRT)
 *
 * _ROUND2 = rounds a number up to a power of 2
 * _ROUND = rounds a number up to any other numer
 *
 * n = number to be rounded
 * pow2 = must be a power of two value
 * r = any number
 */

#define _ROUND2(n,pow2) \
        ( ( (n) + (pow2) - 1) & ~((pow2) - 1) )

#define _ROUND(n,r) \
        ( ( ((n)/(r)) + (((n)%(r))?1:0) ) * (r))

HMODULE __stdcall GetResLibHandle();
HINSTANCE GetApplicationInstance();
void DolphinExitInstance();

#include "CritSect.h"
extern CMonitor traceMonitor;

#define TRACELOCK()	CAutoLock<tracestream> lock(TRACESTREAM)

std::wstring __stdcall GetErrorText(DWORD win32ErrorCode);
std::wstring __stdcall GetLastErrorText();
LPCWSTR GetResourceString(HMODULE hMod, int resId, int& length);
int __cdecl DolphinMessageBox(int idPrompt, UINT flags, ...);
void __cdecl trace(const wchar_t* szFormat, ...);
void __cdecl trace(int nPrompt, ...);
void __cdecl DebugCrashDump(const wchar_t* szFormat, ...);
void __cdecl DebugDump(const wchar_t* szFormat, ...);
void CrashDump(const LPEXCEPTION_POINTERS pExInfo, const wchar_t* achImagePath);
HRESULT __cdecl ReportError(int nPrompt, ...);
HRESULT __cdecl ReportWin32Error(int nPrompt, DWORD errorCode, LPCWSTR arg = NULL);
__declspec(noreturn) void __cdecl RaiseFatalError(int nCode, int nArgs, ...);
__declspec(noreturn) void __stdcall FatalException(const EXCEPTION_RECORD& exRec);
__declspec(noreturn) void __stdcall FatalSystemException(const LPEXCEPTION_POINTERS exInfo);
__declspec(noreturn) void __stdcall FatalError(int exitCode, ...);
__declspec(noreturn) void __stdcall DolphinFatalExit(int exitCode, const wchar_t* msg);
__declspec(noreturn) void __stdcall DolphinExit(int nExitCode);
extern wchar_t achLogPath[_MAX_PATH + 1];
extern wchar_t achImagePath[_MAX_PATH + 1];
HMODULE GetVMModule();
BOOL __stdcall GetVersionInfo(VS_FIXEDFILEINFO* lpInfoOut);

#include <unknwn.h>
#include "segdefs.h"

#pragma warning(push,3)
#include <icu.h>
#include <intrin.h>
#include <fpieee.h>
#include <wtypes.h>
#pragma warning(pop)

// TODO: This actuall seems to have no effect in VS2017, and maybe earlier. The result is slow indirect calls when using /MD as we do for the VM.
#pragma intrinsic(memcpy,memset,strlen)

#if defined(_DEBUG)
#include <crtdbg.h>
#endif

// determine number of elements in an array (not bytes)
#ifndef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#endif

#ifdef _M_X64
#define OOPSIZE 8
#define PORT64(s) #error(s)
#else
#define OOPSIZE 4
#define PORT64(s)
#endif
