﻿"Filed out from Dolphin Smalltalk"!

OS.COM.IUnknown
	subclass: #'OS.COM.ILockBytes'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #(#{OS.COM.StorageConstants})
	classInstanceVariableNames: ''
	classConstants: {}!

OS.COM.ILockBytes guid: (OS.COM.IID fromString: '{0000000a-0000-0000-c000-000000000046}')!

OS.COM.ILockBytes comment: 'ILockBytes is a COMInterface class to wrap the standard COM interface of the same name.

ILockBytes is an abstraction of a simple byte-oriented block-mode device for reading, writing and locking (though this is typically not implemented) blocks of storage. Typically we will be using an ILockBytes on a device implemented externally to Dolphin, but see the OLELockBytes class for an example of an ILockBytes implemented in Dolphin over a ByteArray. ILockBytes is the "device" interface underlying OLEs Structured Storage mechanism. The relationship between IStorage/IStreams and ILockBytes is somewhat similar to that between PositionableStreams and SequenceableCollections.

We are mainly interested in ILockBytes in order to test out our own implementations of it easily from within Smalltalk. It is an unusual occurrence that one would actually need to call ILockBytes methods oneself.

Example:
	"Open an ILockBytes on a global memory block"
	i := ILockBytes onHGLOBAL.
	i replaceFrom: 1 to: 5 with: #[72 101 108 108 111] startingAt: 1.
	(i copyFrom: 1 to: 5) asString.
	i free'!

!OS.COM.ILockBytes categoriesForClass!COM-Interfaces! !

!OS.COM.ILockBytes methodsFor!

at: index 
	"Answer the byte at the specified index in the receiver."

	^(self readAt: index - 1 count: 1) at: 1!

at: index put: byte 
	"Set the byte at the specified index in the receiver."

	self 
		writeAt: index - 1
		bytes: (ByteArray with: byte)
		count: 1.
	^byte!

copyFrom: start to: stop 
	"Copy and answer the specified range of bytes from the receiver."

	^self readAt: start - 1 count: stop - start + 1!

flush
	"Flush any buffered data to the receiver's 'device'."

	self Flush!

Flush
	"Invoke the Flush() method of the object wrapped by the receiver.
	
		HRESULT __stdcall Flush();

	"

	<virtual stdcall: hresult 6>
	^self invalidCall: _failureCode!

handle
	"Answer the global memory handle used for the receiver's
	underlying storage (only valid if the receiver was created
	with CreateILockBytesOnHGlobal())."

	| hglobal |
	hglobal := External.Handle new.
	Ole32 getHGlobalFromILockBytes: self phglobal: hglobal.
	^hglobal!

LockRegion: libOffset cb: cb dwLockType: dwLockType
	"Invoke the LockRegion() method of the object wrapped by the receiver.
	
		HRESULT __stdcall LockRegion(
			[in] ULARGE_INTEGER libOffset,
			[in] ULARGE_INTEGER cb,
			[in] unsigned long dwLockType);

	"

	<virtual stdcall: hresult 8 uint64 uint64 uint32>
	^self invalidCall: _failureCode!

readAt: offset bytes: data count: count
	"Read the specified number of bytes into the supplied buffer (a byte object
	or an address) from the specified offset. Answer the number of bytes actually read.
	Raise a subscript bounds exception if the number of bytes read does not equal the number
	requested."

	| bytesRead |
	bytesRead := ByteArray newFixed: 4.
	self
		ReadAt: offset
		pv: data
		cb: count
		pcbRead: bytesRead.
	bytesRead := bytesRead uint32AtOffset: 0.
	^bytesRead == count ifTrue: [data] ifFalse: [self errorSubscriptBounds: offset + bytesRead + 1]!

readAt: offset count: count 
	"Read and answer the specified number of bytes from the specified offset."

	| buffer |
	buffer := ByteArray new: count.
	^self 
		readAt: offset
		bytes: buffer
		count: count!

ReadAt: ulOffset pv: pv cb: cb pcbRead: pcbRead
	"Invoke the ReadAt() method of the object wrapped by the receiver.
	
		HRESULT __stdcall ReadAt(
			[in] ULARGE_INTEGER ulOffset,
			[out] byte* pv,
			[in] unsigned long cb,
			[out] unsigned long* pcbRead);

	"

	<virtual stdcall: hresult 4 uint64 int8* uint32 uint32*>
	^self invalidCall: _failureCode!

replaceFrom: start to: stop with: replacementBytes startingAt: startAt 
	"Perform a standard Smalltalk replacement operation against the receiver.
	Note that the receiver's underlying storage will be grown if the replacement
	interval is off the end of the existing storage."

	| intervalSize |
	intervalSize := stop - start + 1.
	replacementBytes size == (startAt + intervalSize - 1) 
		ifFalse: [^replacementBytes errorSubscriptBounds: startAt + intervalSize - 1].
	self 
		writeAt: start - 1
		bytes: replacementBytes yourAddress + startAt - 1
		count: intervalSize!

setSize: anInteger 
	"Preallocate a specific amount of space in the underlying 'device'."

	self SetSize: anInteger!

SetSize: cb
	"Invoke the SetSize() method of the object wrapped by the receiver.
	
		HRESULT __stdcall SetSize(
			[in] ULARGE_INTEGER cb);

	"

	<virtual stdcall: hresult 7 uint64>
	^self invalidCall: _failureCode!

stat
	"Answer a STATSTG for the receiver."

	| answer |
	answer := STATSTG new.
	self Stat: answer grfStatFlag: STATFLAG_DEFAULT.
	^answer!

Stat: pstatstg grfStatFlag: grfStatFlag
	"Invoke the Stat() method of the object wrapped by the receiver.
	
		HRESULT __stdcall Stat(
			[out] STATSTG* pstatstg,
			[in] unsigned long grfStatFlag);

	"

	<virtual stdcall: hresult 10 STATSTG* uint32>
	^self invalidCall: _failureCode!

UnlockRegion: libOffset cb: cb dwLockType: dwLockType
	"Invoke the UnlockRegion() method of the object wrapped by the receiver.
	
		HRESULT __stdcall UnlockRegion(
			[in] ULARGE_INTEGER libOffset,
			[in] ULARGE_INTEGER cb,
			[in] unsigned long dwLockType);

	"

	<virtual stdcall: hresult 9 uint64 uint64 uint32>
	^self invalidCall: _failureCode!

writeAt: offset bytes: data count: count
	"Write the specified number of bytes from the supplied data (a byte object
	or an address) at the specified offset. Answer the number of bytes actually written."

	| bytesWritten |
	bytesWritten := ByteArray newFixed: 4.
	self
		WriteAt: offset
		pv: data
		cb: count
		pcbWritten: bytesWritten.
	^bytesWritten uint32AtOffset: 0!

WriteAt: ulOffset pv: pv cb: cb pcbWritten: pcbWritten
	"Invoke the WriteAt() method of the object wrapped by the receiver.
	
		HRESULT __stdcall WriteAt(
			[in] ULARGE_INTEGER ulOffset,
			[in] byte* pv,
			[in] unsigned long cb,
			[out] unsigned long* pcbWritten);

	"

	<virtual stdcall: hresult 5 uint64 int8* uint32 uint32*>
	^self invalidCall: _failureCode! !

!OS.COM.ILockBytes categoriesForMethods!
at:!accessing!public! !
at:put:!accessing!public! !
copyFrom:to:!copying!public! !
flush!operations!public! !
Flush!**auto generated**!COM Interfaces-OBJIDL.ILockBytes!primitives!public! !
handle!accessing!public! !
LockRegion:cb:dwLockType:!**auto generated**!COM Interfaces-OBJIDL.ILockBytes!primitives!public! !
readAt:bytes:count:!accessing!public! !
readAt:count:!accessing!public! !
ReadAt:pv:cb:pcbRead:!**auto generated**!COM Interfaces-OBJIDL.ILockBytes!primitives!public! !
replaceFrom:to:with:startingAt:!public!replacing! !
setSize:!accessing!public! !
SetSize:!**auto generated**!COM Interfaces-OBJIDL.ILockBytes!primitives!public! !
stat!accessing!public! !
Stat:grfStatFlag:!**auto generated**!COM Interfaces-OBJIDL.ILockBytes!primitives!public! !
UnlockRegion:cb:dwLockType:!**auto generated**!COM Interfaces-OBJIDL.ILockBytes!primitives!public! !
writeAt:bytes:count:!accessing!public! !
WriteAt:pv:cb:pcbWritten:!**auto generated**!COM Interfaces-OBJIDL.ILockBytes!primitives!public! !
!

!OS.COM.ILockBytes class methodsFor!

defineFunctions
	"Declare the virtual function table for the COM interface 'OBJIDL.ILockBytes'
		ILockBytes defineTemplate
	"

	self
		defineFunction: #ReadAt:pv:cb:pcbRead: argumentTypes: 'qword sbyte* dword dword*';
		defineFunction: #WriteAt:pv:cb:pcbWritten: argumentTypes: 'qword sbyte* dword dword*';
		defineFunction: #Flush;
		defineFunction: #SetSize: argumentTypes: 'qword';
		defineFunction: #LockRegion:cb:dwLockType: argumentTypes: 'qword qword dword';
		defineFunction: #UnlockRegion:cb:dwLockType: argumentTypes: 'qword qword dword';
		defineFunction: #Stat:grfStatFlag: argumentTypes: 'STATSTG* dword'!

onHGLOBAL
	"Answer an ILockBytes on a zero sized block of global memory."

	^self onHGLOBAL: nil!

onHGLOBAL: hGlobal
	"Answer an ILockBytes on a block of global memory identified by the argument, hGlobal."

	| answer |
	answer := self newPointer.
	Ole32
		createILockBytesOnHGlobal: hGlobal
		fDeleteOnRelease: true
		pplkbyt: answer.
	^answer! !

!OS.COM.ILockBytes class categoriesForMethods!
defineFunctions!**auto generated**!initializing!public!template definition! !
onHGLOBAL!instance creation!public! !
onHGLOBAL:!instance creation!public! !
!

