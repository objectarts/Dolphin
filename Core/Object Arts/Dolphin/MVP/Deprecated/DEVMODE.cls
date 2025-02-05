﻿"Filed out from Dolphin Smalltalk"!

ExternalStructure subclass: #DEVMODE
	instanceVariableNames: ''
	classVariableNames: '_DEVMODE_Size _OffsetOf_dmBitsPerPel _OffsetOf_dmCollate _OffsetOf_dmColor _OffsetOf_dmCopies _OffsetOf_dmDefaultSource _OffsetOf_dmDeviceName _OffsetOf_dmDisplayFlags _OffsetOf_dmDisplayFrequency _OffsetOf_dmDitherType _OffsetOf_dmDriverExtra _OffsetOf_dmDriverVersion _OffsetOf_dmDuplex _OffsetOf_dmFields _OffsetOf_dmFormName _OffsetOf_dmICMIntent _OffsetOf_dmICMMethod _OffsetOf_dmLogPixels _OffsetOf_dmMediaType _OffsetOf_dmOrientation _OffsetOf_dmPaperLength _OffsetOf_dmPaperSize _OffsetOf_dmPaperWidth _OffsetOf_dmPelsHeight _OffsetOf_dmPelsWidth _OffsetOf_dmPrintQuality _OffsetOf_dmReserved1 _OffsetOf_dmReserved2 _OffsetOf_dmScale _OffsetOf_dmSize _OffsetOf_dmSpecVersion _OffsetOf_dmTTOption _OffsetOf_dmYResolution'
	poolDictionaries: ''
	classInstanceVariableNames: ''!

DEVMODE guid: (GUID fromString: '{62ad7874-bbbf-4852-99d9-8040855ecb49}')!

DEVMODE addClassConstant: '_DEVMODE_Size' value: 16r94!
DEVMODE addClassConstant: '_OffsetOf_dmBitsPerPel' value: 16r68!
DEVMODE addClassConstant: '_OffsetOf_dmCollate' value: 16r44!
DEVMODE addClassConstant: '_OffsetOf_dmColor' value: 16r3C!
DEVMODE addClassConstant: '_OffsetOf_dmCopies' value: 16r36!
DEVMODE addClassConstant: '_OffsetOf_dmDefaultSource' value: 16r38!
DEVMODE addClassConstant: '_OffsetOf_dmDeviceName' value: 16r0!
DEVMODE addClassConstant: '_OffsetOf_dmDisplayFlags' value: 16r74!
DEVMODE addClassConstant: '_OffsetOf_dmDisplayFrequency' value: 16r78!
DEVMODE addClassConstant: '_OffsetOf_dmDitherType' value: 16r88!
DEVMODE addClassConstant: '_OffsetOf_dmDriverExtra' value: 16r26!
DEVMODE addClassConstant: '_OffsetOf_dmDriverVersion' value: 16r22!
DEVMODE addClassConstant: '_OffsetOf_dmDuplex' value: 16r3E!
DEVMODE addClassConstant: '_OffsetOf_dmFields' value: 16r28!
DEVMODE addClassConstant: '_OffsetOf_dmFormName' value: 16r46!
DEVMODE addClassConstant: '_OffsetOf_dmICMIntent' value: 16r80!
DEVMODE addClassConstant: '_OffsetOf_dmICMMethod' value: 16r7C!
DEVMODE addClassConstant: '_OffsetOf_dmLogPixels' value: 16r66!
DEVMODE addClassConstant: '_OffsetOf_dmMediaType' value: 16r84!
DEVMODE addClassConstant: '_OffsetOf_dmOrientation' value: 16r2C!
DEVMODE addClassConstant: '_OffsetOf_dmPaperLength' value: 16r30!
DEVMODE addClassConstant: '_OffsetOf_dmPaperSize' value: 16r2E!
DEVMODE addClassConstant: '_OffsetOf_dmPaperWidth' value: 16r32!
DEVMODE addClassConstant: '_OffsetOf_dmPelsHeight' value: 16r70!
DEVMODE addClassConstant: '_OffsetOf_dmPelsWidth' value: 16r6C!
DEVMODE addClassConstant: '_OffsetOf_dmPrintQuality' value: 16r3A!
DEVMODE addClassConstant: '_OffsetOf_dmReserved1' value: 16r8C!
DEVMODE addClassConstant: '_OffsetOf_dmReserved2' value: 16r90!
DEVMODE addClassConstant: '_OffsetOf_dmScale' value: 16r34!
DEVMODE addClassConstant: '_OffsetOf_dmSize' value: 16r24!
DEVMODE addClassConstant: '_OffsetOf_dmSpecVersion' value: 16r20!
DEVMODE addClassConstant: '_OffsetOf_dmTTOption' value: 16r42!
DEVMODE addClassConstant: '_OffsetOf_dmYResolution' value: 16r40!
DEVMODE comment: '<DEVMODE> is an <ExternalStructure> class to wrap the struct ''Win32.DEVMODE'' from type information in the ''Win32 API (ANSI). Derived from Bruce McKinney´s Hardcore Visual Basic Type Library'' library.

The type library contains no documentation for this struct

Warning: This comment was automatically generated from the struct''s type information, but any changes made here will not be overwritten if the wrapper class is regenerated.

IDL definition follows:

typedef [uuid(62AD7874-BBBF-4852-99D9-8040855ECB49)]
struct tagDEVMODE {
	CHAR dmDeviceName[32];
	WORD dmSpecVersion;
	WORD dmDriverVersion;
	WORD dmSize;
	WORD dmDriverExtra;
	DWORD dmFields;
	short dmOrientation;
	short dmPaperSize;
	short dmPaperLength;
	short dmPaperWidth;
	short dmScale;
	short dmCopies;
	short dmDefaultSource;
	short dmPrintQuality;
	short dmColor;
	short dmDuplex;
	short dmYResolution;
	short dmTTOption;
	short dmCollate;
	CHAR dmFormName[32];
	WORD dmLogPixels;
	DWORD dmBitsPerPel;
	DWORD dmPelsWidth;
	DWORD dmPelsHeight;
	DWORD dmDisplayFlags;
	DWORD dmDisplayFrequency;
	DWORD dmICMMethod;
	DWORD dmICMIntent;
	DWORD dmMediaType;
	DWORD dmDitherType;
	DWORD dmReserved1;
	DWORD dmReserved2;
} DEVMODE;
'!

!DEVMODE categoriesForClass!Deprecated! !

!DEVMODE class methodsFor!

byteSize
	^_DEVMODE_Size!

defineFields
	"Define the fields of the DEVMODE structure.

	DEVMODE  compileDefinition

		typedef [uuid(62AD7874-BBBF-4852-99D9-8040855ECB49)]
		struct tagDEVMODE {
			CHAR dmDeviceName[32];
			WORD dmSpecVersion;
			WORD dmDriverVersion;
			WORD dmSize;
			WORD dmDriverExtra;
			DWORD dmFields;
			short dmOrientation;
			short dmPaperSize;
			short dmPaperLength;
			short dmPaperWidth;
			short dmScale;
			short dmCopies;
			short dmDefaultSource;
			short dmPrintQuality;
			short dmColor;
			short dmDuplex;
			short dmYResolution;
			short dmTTOption;
			short dmCollate;
			CHAR dmFormName[32];
			WORD dmLogPixels;
			DWORD dmBitsPerPel;
			DWORD dmPelsWidth;
			DWORD dmPelsHeight;
			DWORD dmDisplayFlags;
			DWORD dmDisplayFrequency;
			DWORD dmICMMethod;
			DWORD dmICMIntent;
			DWORD dmMediaType;
			DWORD dmDitherType;
			DWORD dmReserved1;
			DWORD dmReserved2;
		} DEVMODE;
"

	self
		beUncompiled;
		defineField: #dmDeviceName type: (ArrayField type: ByteArray length: 32);
		defineField: #dmSpecVersion type: UInt16Field new;
		defineField: #dmDriverVersion type: UInt16Field new;
		defineField: #dmSize type: UInt16Field new;
		defineField: #dmDriverExtra type: UInt16Field new;
		defineField: #dmFields type: UInt32Field new;
		defineField: #dmOrientation type: Int16Field new;
		defineField: #dmPaperSize type: Int16Field new;
		defineField: #dmPaperLength type: Int16Field new;
		defineField: #dmPaperWidth type: Int16Field new;
		defineField: #dmScale type: Int16Field new;
		defineField: #dmCopies type: Int16Field new;
		defineField: #dmDefaultSource type: Int16Field new;
		defineField: #dmPrintQuality type: Int16Field new;
		defineField: #dmColor type: Int16Field new;
		defineField: #dmDuplex type: Int16Field new;
		defineField: #dmYResolution type: Int16Field new;
		defineField: #dmTTOption type: Int16Field new;
		defineField: #dmCollate type: Int16Field new;
		defineField: #dmFormName type: (ArrayField type: ByteArray length: 32);
		defineField: #dmLogPixels type: UInt16Field new;
		defineField: #dmBitsPerPel type: UInt32Field new;
		defineField: #dmPelsWidth type: UInt32Field new;
		defineField: #dmPelsHeight type: UInt32Field new;
		defineField: #dmDisplayFlags type: UInt32Field new;
		defineField: #dmDisplayFrequency type: UInt32Field new;
		defineField: #dmICMMethod type: UInt32Field new;
		defineField: #dmICMIntent type: UInt32Field new;
		defineField: #dmMediaType type: UInt32Field new;
		defineField: #dmDitherType type: UInt32Field new;
		defineField: #dmReserved1 type: UInt32Field filler;
		defineField: #dmReserved2 type: UInt32Field filler!

getFieldNames
	^#(#dmDeviceName #dmSpecVersion #dmDriverVersion #dmSize #dmDriverExtra #dmFields #dmOrientation #dmPaperSize #dmPaperLength #dmPaperWidth #dmScale #dmCopies #dmDefaultSource #dmPrintQuality #dmColor #dmDuplex #dmYResolution #dmTTOption #dmCollate #dmFormName #dmLogPixels #dmBitsPerPel #dmPelsWidth #dmPelsHeight #dmDisplayFlags #dmDisplayFrequency #dmICMMethod #dmICMIntent #dmMediaType #dmDitherType)! !

!DEVMODE class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
defineFields!public!template definition! !
getFieldNames!**compiled accessors**!constants!private! !
!

