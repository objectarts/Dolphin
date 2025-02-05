﻿"Filed out from Dolphin Smalltalk"!

External.FinalizableStructure
	subclass: #'OS.COM.MULTI_QI'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'_MULTI_QI_Size' -> 16rC.
			'_OffsetOf_hr' -> 16r8.
			'_OffsetOf_pIID' -> 16r0.
			'_OffsetOf_pItf' -> 16r4
		}!

OS.COM.MULTI_QI guid: (Core.GUID fromString: '{87b4c5c2-026e-11d3-9fd7-00a0cc3e4a32}')!

OS.COM.MULTI_QI comment: '`OS.COM.MULTI_QI` is an `External.Structure` class to represent the Win32 COM MULTI_QI structure.

Arrays of MULTI_QI structures can be used to query multiple interface pointers in a single request. This is only really important for DCOM as it helps to minimize the number of network round-trips that are performed.'!

!OS.COM.MULTI_QI categoriesForClass!External-Data-Structured-COM! !

!OS.COM.MULTI_QI methodsFor!

hr
	"Answer the <Integer> value of the receiver's 'hr' field."

	^bytes int32AtOffset: _OffsetOf_hr!

hr: anInteger
	"Set the receiver's 'hr' field to the value of the argument, anInteger"

	bytes int32AtOffset: _OffsetOf_hr put: anInteger!

pIID
	"Answer the <IID> value of the receiver's 'pIID' field."

	^IID fromAddress: (bytes intPtrAtOffset: _OffsetOf_pIID)!

pIID: anIID
	"Set the receiver's 'pIID' field to the value of the argument, anIID"

	bytes uintPtrAtOffset: _OffsetOf_pIID put: anIID yourAddress!

pItf
	"Answer the <IUnknown> value of the receiver's 'pItf' field."

	^IUnknown fromAddress: (bytes intPtrAtOffset: _OffsetOf_pItf)!

pItf: anIUnknown
	"Set the receiver's 'pItf' field to the value of the argument, anIUnknown"

	bytes uintPtrAtOffset: _OffsetOf_pItf put: anIUnknown yourAddress! !

!OS.COM.MULTI_QI categoriesForMethods!
hr!**compiled accessors**!public! !
hr:!**compiled accessors**!public! !
pIID!**compiled accessors**!public! !
pIID:!**compiled accessors**!public! !
pItf!**compiled accessors**!public! !
pItf:!**compiled accessors**!public! !
!

!OS.COM.MULTI_QI class methodsFor!

byteSize
	^_MULTI_QI_Size!

clear: addressOrBytes
	"Free external resources referenced by the structure
	of the receiver's element type at the specified address."

	| pi |
	pi := addressOrBytes int32AtOffset: 4.
	pi notNull ifTrue: [(IUnknown attach: pi) free]!

defineFields
	"Define the fields of the MULTI_QI structure.

		MULTI_QI compileDefinition.

		struct  MULTI_QI
		{
			const IID*	pIID;
			IUnknown*	pItf;
			HRESULT		hr;
		};

	"

	self
		defineField: #pIID type: (PointerField type: IID);
		defineField: #pItf type: (PointerField type: IUnknown);
		defineField: #hr type: Int32Field new!

getFieldNames
	^#(#pIID #pItf #hr)! !

!OS.COM.MULTI_QI class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
clear:!public!realizing/unrealizing! !
defineFields!public!template definition! !
getFieldNames!**compiled accessors**!constants!private! !
!

