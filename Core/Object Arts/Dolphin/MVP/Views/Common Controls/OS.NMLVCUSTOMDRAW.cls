"Filed out from Dolphin Smalltalk"!

OS.NMCUSTOMDRAW
	subclass: #'OS.NMLVCUSTOMDRAW'
	instanceVariableNames: 'column subItem'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'_NMLVCUSTOMDRAW_Size' -> 16r3C.
			'_OffsetOf_clrText' -> 16r30.
			'_OffsetOf_clrTextBk' -> 16r34.
			'_OffsetOf_iSubItem' -> 16r38
		}!

OS.NMLVCUSTOMDRAW guid: (Core.GUID fromString: '{7fbf7515-c756-4b0e-8d4f-01debafa1178}')!

OS.NMLVCUSTOMDRAW comment: '`NMLVCUSTOMDRAW` is an `ExternalStructure` class to represent the Win32 structure of the same name.

`NMLVCUSTOMDRAW` is sent by `ListView` controls to request custom draw information for the text of individual items (and optionally sub-items). We implement the `customDrawContext` protocol against it in order that it can be passed directly to the views customDrawBlock.'!

!OS.NMLVCUSTOMDRAW categoriesForClass!External-Data-Structured-Win32! !

!OS.NMLVCUSTOMDRAW methodsFor!

applyFont
	"If a font has not been set, install the view's font to ensure any font change from a previous column is reset"

	font isNil ifTrue: [font := self viewFont].
	^super applyFont!

backcolor
	"Answer the background <Color>."

	| clrTextBk |
	clrTextBk := self clrTextBk.
	^clrTextBk isDefault ifTrue: [Graphics.Color window] ifFalse: [clrTextBk]!

backcolor: aColor
	"Sets the background <Color>."

	self clrTextBk: aColor!

clrText
	"Answer the <Graphics.Color> value of the receiver's 'clrText' field."

	^Graphics.Color fromCOLORREF: (bytes uint32AtOffset: _OffsetOf_clrText)!

clrText: aColor
	"Set the receiver's 'clrText' field to the value of the argument, aColor"

	bytes uint32AtOffset: _OffsetOf_clrText put: aColor asCOLORREF!

clrTextBk
	"Answer the <Graphics.Color> value of the receiver's 'clrTextBk' field."

	^Graphics.Color fromCOLORREF: (bytes uint32AtOffset: _OffsetOf_clrTextBk)!

clrTextBk: aColor
	"Set the receiver's 'clrTextBk' field to the value of the argument, aColor"

	bytes uint32AtOffset: _OffsetOf_clrTextBk put: aColor asCOLORREF!

column
	"Answer the <ListViewColumn> associated with the sub-item if this is a sub-item
	draw, otherwise nil."

	^column!

column: aListViewColumn
	"Private -"
	column := aListViewColumn!

forecolor
	"Answer the foreground text colour."

	| clrText |
	clrText := self clrText.
	^clrText isDefault ifTrue: [Graphics.Color windowText] ifFalse: [clrText]!

forecolor: aColor
	"Sets the text foreground <Color>."

	self clrText: aColor!

getSubItem
	| row |
	row := self item.
	self column ifNotNil: [:col | col getContentsBlock ifNotNil: [:getblock | ^getblock value: row]].
	^row!

iSubItem
	"Answer the <Integer> value of the receiver's 'iSubItem' field."

	^bytes int32AtOffset: _OffsetOf_iSubItem!

itemHandle
	"Answer the 'handle' of the receiver's item."

	^self dwItemSpec + 1!

reset
	"Reset the canvas to default settings."

	self forecolor: self view forecolor ?? Graphics.Color.WindowText!

subItem
	"Answer the object that is being displayed in the list view column associated with this custom draw attributes request."

	^subItem ifNil: [subItem := self getSubItem]! !

!OS.NMLVCUSTOMDRAW categoriesForMethods!
applyFont!operations!private! !
backcolor!accessing!public! !
backcolor:!accessing!public! !
clrText!**compiled accessors**!public! !
clrText:!**compiled accessors**!public! !
clrTextBk!**compiled accessors**!public! !
clrTextBk:!**compiled accessors**!public! !
column!accessing!public! !
column:!accessing!private! !
forecolor!accessing!public! !
forecolor:!accessing!public! !
getSubItem!helpers!private! !
iSubItem!**compiled accessors**!public! !
itemHandle!accessing!private! !
reset!public! !
subItem!accessing!public! !
!

!OS.NMLVCUSTOMDRAW class methodsFor!

byteSize
	^_NMLVCUSTOMDRAW_Size!

defineFields
	"Define the structure template for Win32 NMLVCUSTOMDRAW structure.
		self compileDefinition
	"

	super defineFields.
	self
		defineField: #clrText type: COLORREFField new;
		defineField: #clrTextBk type: COLORREFField new;
		defineField: #iSubItem type: Int32Field readOnly!

getFieldNames
	^#(#hwndFrom #idFrom #code #dwDrawStage #hdc #rc #dwItemSpec #uItemState #lParam #clrText #clrTextBk #iSubItem)! !

!OS.NMLVCUSTOMDRAW class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
defineFields!public!template definition! !
getFieldNames!**compiled accessors**!constants!private! !
!

