﻿"Filed out from Dolphin Smalltalk"!

OS.SizedStructure
	subclass: #'OS.COM.FONTDESC'
	instanceVariableNames: 'name'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'_FONTDESC_Size' -> 16r20.
			'_OffsetOf_cySize' -> 16r8.
			'_OffsetOf_fItalic' -> 16r14.
			'_OffsetOf_fStrikethrough' -> 16r1C.
			'_OffsetOf_fUnderline' -> 16r18.
			'_OffsetOf_lpstrName' -> 16r4.
			'_OffsetOf_sCharset' -> 16r12.
			'_OffsetOf_sWeight' -> 16r10
		}!

OS.COM.FONTDESC guid: (Core.GUID fromString: '{73f5f101-a4da-11d3-b376-080046056106}')!

OS.COM.FONTDESC comment: 'FONTDESC is an <ExternalStructure> class to represent the OLE structure of the same name.

FONTDESC is similar to a LOGFONT in that it represents a logical description of a Font, although in this case an OLE Font object (see IFont and IFontDisp). FONTDESC is simpler than LOGFONT, however.'!

!OS.COM.FONTDESC categoriesForClass!External-Data-Structured-COM! !

!OS.COM.FONTDESC methodsFor!

cySize
	"Answer the <Integer> value of the receiver's 'cySize' field."

	^bytes int64AtOffset: _OffsetOf_cySize!

cySize: anInteger
	"Set the receiver's 'cySize' field to the value of the argument, anInteger"

	bytes int64AtOffset: _OffsetOf_cySize put: anInteger!

faceName
	"Answer the font name."

	^self lpstrName asString!

faceName: fontName
	"Set the font name stored in the receiver."

	name := fontName asUtf16String.
	self lpstrName: name!

fItalic
	"Answer the <Boolean> value of the receiver's 'fItalic' field."

	^(bytes uint32AtOffset: _OffsetOf_fItalic) asBoolean!

fItalic: aBoolean
	"Set the receiver's 'fItalic' field to the value of the argument, aBoolean"

	bytes uint32AtOffset: _OffsetOf_fItalic put: aBoolean asParameter!

fStrikethrough
	"Answer the <Boolean> value of the receiver's 'fStrikethrough' field."

	^(bytes uint32AtOffset: _OffsetOf_fStrikethrough) asBoolean!

fStrikethrough: aBoolean
	"Set the receiver's 'fStrikethrough' field to the value of the argument, aBoolean"

	bytes uint32AtOffset: _OffsetOf_fStrikethrough put: aBoolean asParameter!

fUnderline
	"Answer the <Boolean> value of the receiver's 'fUnderline' field."

	^(bytes uint32AtOffset: _OffsetOf_fUnderline) asBoolean!

fUnderline: aBoolean
	"Set the receiver's 'fUnderline' field to the value of the argument, aBoolean"

	bytes uint32AtOffset: _OffsetOf_fUnderline put: aBoolean asParameter!

lpstrName
	"Answer the <Utf16String> value of the receiver's 'lpstrName' field."

	^Utf16String fromAddress: (bytes intPtrAtOffset: _OffsetOf_lpstrName)!

lpstrName: anUtf16String
	"Set the receiver's 'lpstrName' field to the value of the argument, anUtf16String"

	bytes uintPtrAtOffset: _OffsetOf_lpstrName put: anUtf16String yourAddress!

pointSize
	"Answer the point size of the font described by the receiver."

	^(self cySize / 10000) asScaledDecimal: 4!

pointSize: points
	"Set the point size of the font described by the receiver."

	self cySize: (points * 10000) asInteger!

sCharset
	"Answer the <Integer> value of the receiver's 'sCharset' field."

	^bytes int16AtOffset: _OffsetOf_sCharset!

sCharset: anInteger
	"Set the receiver's 'sCharset' field to the value of the argument, anInteger"

	bytes int16AtOffset: _OffsetOf_sCharset put: anInteger!

sWeight
	"Answer the <Integer> value of the receiver's 'sWeight' field."

	^bytes int16AtOffset: _OffsetOf_sWeight!

sWeight: anInteger
	"Set the receiver's 'sWeight' field to the value of the argument, anInteger"

	bytes int16AtOffset: _OffsetOf_sWeight put: anInteger! !

!OS.COM.FONTDESC categoriesForMethods!
cySize!**compiled accessors**!public! !
cySize:!**compiled accessors**!public! !
faceName!accessing!public! !
faceName:!accessing!public! !
fItalic!**compiled accessors**!public! !
fItalic:!**compiled accessors**!public! !
fStrikethrough!**compiled accessors**!public! !
fStrikethrough:!**compiled accessors**!public! !
fUnderline!**compiled accessors**!public! !
fUnderline:!**compiled accessors**!public! !
lpstrName!**compiled accessors**!public! !
lpstrName:!**compiled accessors**!public! !
pointSize!accessing!public! !
pointSize:!accessing!public! !
sCharset!**compiled accessors**!public! !
sCharset:!**compiled accessors**!public! !
sWeight!**compiled accessors**!public! !
sWeight:!**compiled accessors**!public! !
!

!OS.COM.FONTDESC class methodsFor!

byteSize
	^_FONTDESC_Size!

defineFields
	"Define the fields of the FONTDESC structure.

		FONTDESC compileDefinition.

		typedef struct tagFONTDESC
		{
			UINT cbSizeofstruct;
			LPOLESTR lpstrName;
			CY cySize;
			SHORT sWeight;
			SHORT sCharset;
			BOOL fItalic;
			BOOL fUnderline;
			BOOL fStrikethrough;
		} FONTDESC, FAR* LPFONTDESC;
	"

	super defineFields.
	self
		defineField: #lpstrName type: (PointerField type: Utf16String);
		defineField: #cySize type:  Int64Field new;
		defineField: #sWeight type: Int16Field new;
		defineField: #sCharset type: Int16Field new;
		defineField: #fItalic type: BOOLField new;
		defineField: #fUnderline type: BOOLField new;
		defineField: #fStrikethrough type: BOOLField new
!

fromFont: font
	"Answer a new instance of the receiver populated with details from the <Font>, font."

	| lf fd |
	lf := font logFont.
	fd := self new.
	fd faceName: lf faceName.
	fd sWeight: lf lfWeight.
	fd sCharset: lf lfCharSet.
	fd fItalic: lf lfItalic.
	fd fUnderline: lf lfUnderline.
	fd fStrikethrough: lf lfStrikeOut.
	fd pointSize: font pointSize.
	^fd!

getFieldNames
	^#(#dwSize #lpstrName #cySize #sWeight #sCharset #fItalic #fUnderline #fStrikethrough)! !

!OS.COM.FONTDESC class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
defineFields!public!template definition! !
fromFont:!instance creation!public! !
getFieldNames!**compiled accessors**!constants!private! !
!

