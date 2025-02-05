﻿"Filed out from Dolphin Smalltalk"!

External.Structure
	subclass: #'OS.COM.TLIBATTR'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #(#{OS.COM.AutomationConstants})
	classInstanceVariableNames: ''
	classConstants: {
			'_OffsetOf_guid' -> 16r0.
			'_OffsetOf_lcid' -> 16r10.
			'_OffsetOf_syskind' -> 16r14.
			'_OffsetOf_wLibFlags' -> 16r1C.
			'_OffsetOf_wMajorVerNum' -> 16r18.
			'_OffsetOf_wMinorVerNum' -> 16r1A.
			'_TLIBATTR_Size' -> 16r20
		}!

OS.COM.TLIBATTR guid: (Core.GUID fromString: '{c06f3b71-0868-11d3-93af-00a024ca708a}')!

OS.COM.TLIBATTR comment: 'TLIBATTR is an ExternalStructure class to represent the OLE Automation TLIBATTR structure.

TLIBATTR is a simple structure containing basic descriptive details about a type library, namely:
	its LIBID		(#guid)
	its locale id	(#lcid)
	its target OS id	(#syskind)
	is version		(#wMajorVerName and #wMinorVerNum)
	and some flags	(#wLibFlags)

TLIBATTR is probably only of interest for the purposes of browsing type libraries and is of no obvious use in applications.'!

!OS.COM.TLIBATTR categoriesForClass!External-Data-Structured-COM! !

!OS.COM.TLIBATTR methodsFor!

comparisonSize
	"Private - Answer the number of bytes of the receiver to use in comparisons.
	We exclude the flags and 2-bytes of padding used to pack to an 8-byte boundary.
	The former are not material to the comparison, and the latter could include any 
	old junk and therefore make the comparison fail."

	^28!

guid
	"Answer the <GUID> value of the receiver's 'guid' field."

	^GUID fromAddress: bytes yourAddress!

hasDiskImage
	"Answer whether the receiver describes a type library loaded
	from a disk image."

	^self wLibFlags anyMask: LIBFLAG_FHASDISKIMAGE!

isControl
	"Answer whether the receiver describes a type library which in turn
	describes controls. Such type libraries should only not be displayed
	in contexts where non-visual objects are required."

	^self wLibFlags anyMask: LIBFLAG_FCONTROL!

isHidden
	"Answer whether the receiver describes a hidden type library, not intended for
	display to users."

	^self wLibFlags anyMask: LIBFLAG_FHIDDEN!

isRestricted
	"Answer whether the receiver describes a type library whose use
	is restricted, and which should not, therefore, be displayed ot users."

	^self wLibFlags anyMask: LIBFLAG_FRESTRICTED!

lcid
	"Answer the <Integer> value of the receiver's 'lcid' field."

	^bytes uint32AtOffset: _OffsetOf_lcid!

syskind
	^VMConstants.IsWin64 ifTrue: [SYS_WIN64] ifFalse: [SYS_WIN32]!

unregister
	AdvApi32 isRunningElevated
		ifTrue: 
			["Unregister machine wide if admin privileges available"
			OleAut32
				unRegisterTypeLib: self guid
				wVerMajor: self wMajorVerNum
				wVerMinor: self wMinorVerNum
				lcid: self lcid
				syskind: self syskind]
		ifFalse: 
			["Unregister for the current user only"
			OleAut32
				unRegisterTypeLibForUser: self guid
				wMajorVerNum: self wMajorVerNum
				wMinorVerNum: self wMinorVerNum
				lcid: self lcid
				syskind: self syskind]!

version
	"Answer an N.N version string for the receiver."

	^self wMajorVerNum displayString, '.', self wMinorVerNum displayString!

wLibFlags
	"Answer the <Integer> value of the receiver's 'wLibFlags' field."

	^bytes uint16AtOffset: _OffsetOf_wLibFlags!

wMajorVerNum
	"Answer the <Integer> value of the receiver's 'wMajorVerNum' field."

	^bytes uint16AtOffset: _OffsetOf_wMajorVerNum!

wMajorVerNum: anInteger
	"Set the receiver's 'wMajorVerNum' field to the value of the argument, anInteger"

	bytes uint16AtOffset: _OffsetOf_wMajorVerNum put: anInteger!

wMinorVerNum
	"Answer the <Integer> value of the receiver's 'wMinorVerNum' field."

	^bytes uint16AtOffset: _OffsetOf_wMinorVerNum!

wMinorVerNum: anInteger
	"Set the receiver's 'wMinorVerNum' field to the value of the argument, anInteger"

	bytes uint16AtOffset: _OffsetOf_wMinorVerNum put: anInteger! !

!OS.COM.TLIBATTR categoriesForMethods!
comparisonSize!accessing!private! !
guid!**compiled accessors**!public! !
hasDiskImage!public!testing! !
isControl!public!testing! !
isHidden!public!testing! !
isRestricted!public!testing! !
lcid!**compiled accessors**!public! !
syskind!constants!public! !
unregister!operations!public! !
version!accessing-version!public! !
wLibFlags!**compiled accessors**!public! !
wMajorVerNum!**compiled accessors**!public! !
wMajorVerNum:!**compiled accessors**!public! !
wMinorVerNum!**compiled accessors**!public! !
wMinorVerNum:!**compiled accessors**!public! !
!

!OS.COM.TLIBATTR class methodsFor!

byteSize
	^_TLIBATTR_Size!

defineFields
	"Define the fields of the TLIBATTR structure.

		TLIBATTR compileDefinition.

		struct  TLIBATTR
		{
			GUID guid;
			LCID lcid;
			SYSKIND syskind;
			WORD wMajorVerNum;
			WORD wMinorVerNum;
			WORD wLibFlags;
		};

		enum SYSKIND {
			SYS_WIN16	= 0,
			SYS_WIN32	= SYS_WIN16 + 1,
			SYS_MAC		= SYS_WIN32 + 1
		}	SYSKIND;

		enum LIBFLAGS	{
			LIBFLAG_FRESTRICTED		= 0x1,
			LIBFLAG_FCONTROL		= 0x2,
			LIBFLAG_FHIDDEN		= 0x4,
			LIBFLAG_FHASDISKIMAGE	= 0x8
		};

	"

	self
		defineField: #guid			type: (StructureField type: GUID) beReadOnly;
		defineField: #lcid				type: UInt32Field readOnly;
		defineField: #syskind			type: Int32Field filler;		"Always Win32"
		defineField: #wMajorVerNum	type: UInt16Field new;
		defineField: #wMinorVerNum	type: UInt16Field new;
		defineField: #wLibFlags		type: UInt16Field readOnly!

getFieldNames
	^#(#guid #lcid #wMajorVerNum #wMinorVerNum #wLibFlags)! !

!OS.COM.TLIBATTR class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
defineFields!public!template definition! !
getFieldNames!**compiled accessors**!constants!private! !
!

