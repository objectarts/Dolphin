﻿"Filed out from Dolphin Smalltalk"!

External.Structure
	subclass: #'OS.COM.PROPBAG2'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'_OffsetOf_cfType' -> 16r6.
			'_OffsetOf_clsid' -> 16r10.
			'_OffsetOf_dwHint' -> 16r8.
			'_OffsetOf_dwType' -> 16r0.
			'_OffsetOf_pstrName' -> 16rC.
			'_OffsetOf_vt' -> 16r4.
			'_PROPBAG2_Size' -> 16r20
		}!

OS.COM.PROPBAG2 guid: (Core.GUID fromString: '{b5ebe54f-d5b4-4606-9447-90b11844193f}')!

OS.COM.PROPBAG2 comment: '`OS.COM.PROPBAG2` is an `External.Structure` class to wrap the struct ''OCIDL.PROPBAG2'' from type information in the ''OCIDL Library'' library.
'!

!OS.COM.PROPBAG2 categoriesForClass!OCIDL-Structs! !

!OS.COM.PROPBAG2 methodsFor!

cfType
	"Answer the <Integer> value of the receiver's 'cfType' field."

	^bytes uint16AtOffset: _OffsetOf_cfType!

cfType: anInteger
	"Set the receiver's 'cfType' field to the value of the argument, anInteger"

	bytes uint16AtOffset: _OffsetOf_cfType put: anInteger!

clsid
	"Answer the <GUID> value of the receiver's 'clsid' field."

	^GUID fromAddress: bytes yourAddress + _OffsetOf_clsid!

clsid: aGUID
	"Set the receiver's 'clsid' field to the value of the argument, aGUID"

	aGUID
		replaceBytesOf: bytes
		from: ##(_OffsetOf_clsid + 1)
		to: ##(_OffsetOf_clsid + GUID._GUID_Size)
		startingAt: 1!

dwHint
	"Answer the <Integer> value of the receiver's 'dwHint' field."

	^bytes uint32AtOffset: _OffsetOf_dwHint!

dwHint: anInteger
	"Set the receiver's 'dwHint' field to the value of the argument, anInteger"

	bytes uint32AtOffset: _OffsetOf_dwHint put: anInteger!

dwType
	"Answer the <Integer> value of the receiver's 'dwType' field."

	^bytes uint32AtOffset: _OffsetOf_dwType!

dwType: anInteger
	"Set the receiver's 'dwType' field to the value of the argument, anInteger"

	bytes uint32AtOffset: _OffsetOf_dwType put: anInteger!

pstrName
	"Answer the <Utf16String> value of the receiver's 'pstrName' field."

	^Utf16String fromAddress: (bytes intPtrAtOffset: _OffsetOf_pstrName)!

pstrName: anUtf16String
	"Set the receiver's 'pstrName' field to the value of the argument, anUtf16String"

	bytes uintPtrAtOffset: _OffsetOf_pstrName put: anUtf16String yourAddress!

vt
	"Answer the <Integer> value of the receiver's 'vt' field."

	^bytes uint16AtOffset: _OffsetOf_vt!

vt: anInteger
	"Set the receiver's 'vt' field to the value of the argument, anInteger"

	bytes uint16AtOffset: _OffsetOf_vt put: anInteger! !

!OS.COM.PROPBAG2 categoriesForMethods!
cfType!**compiled accessors**!public! !
cfType:!**compiled accessors**!public! !
clsid!**compiled accessors**!public! !
clsid:!**compiled accessors**!public! !
dwHint!**compiled accessors**!public! !
dwHint:!**compiled accessors**!public! !
dwType!**compiled accessors**!public! !
dwType:!**compiled accessors**!public! !
pstrName!**compiled accessors**!public! !
pstrName:!**compiled accessors**!public! !
vt!**compiled accessors**!public! !
vt:!**compiled accessors**!public! !
!

!OS.COM.PROPBAG2 class methodsFor!

byteSize
	^_PROPBAG2_Size!

defineFields
	"Define the fields of the PROPBAG2 structure.
		PROPBAG2 compileDefinition
	
		typedef 		struct tagPROPBAG2 {
			unsigned long dwType;
			unsigned short vt;
			CLIPFORMAT cfType;
			unsigned long dwHint;
			LPWSTR pstrName;
			GUID clsid;
		} PROPBAG2;

	"

	self
		defineField: #dwType type: UInt32Field new;
		defineField: #vt type: UInt16Field new;
		defineField: #cfType type: UInt16Field new;
		defineField: #dwHint type: UInt32Field new;
		defineField: #pstrName type: (PointerField type: Utf16String);
		defineField: #clsid type: (StructureField type: GUID)!

getFieldNames
	^#(#dwType #vt #cfType #dwHint #pstrName #clsid)! !

!OS.COM.PROPBAG2 class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
defineFields!public!template definition! !
getFieldNames!**compiled accessors**!constants!private! !
!

