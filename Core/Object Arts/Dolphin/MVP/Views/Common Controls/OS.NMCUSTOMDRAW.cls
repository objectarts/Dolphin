"Filed out from Dolphin Smalltalk"!

OS.NMHDR
	subclass: #'OS.NMCUSTOMDRAW'
	instanceVariableNames: 'item view canvas font'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'_NMCUSTOMDRAW_Size' -> 16r30.
			'_OffsetOf_dwDrawStage' -> 16rC.
			'_OffsetOf_dwItemSpec' -> 16r24.
			'_OffsetOf_hdc' -> 16r10.
			'_OffsetOf_lParam' -> 16r2C.
			'_OffsetOf_rc' -> 16r14.
			'_OffsetOf_uItemState' -> 16r28
		}!

OS.NMCUSTOMDRAW guid: (Core.GUID fromString: '{1123e900-72b4-46d6-81b5-8122b9e2393f}')!

OS.NMCUSTOMDRAW comment: '`NMCUSTOMDRAW` is an `ExternalStructure` class to represent the Win32 structure of the same name.

`NMCUSTOMDRAW` structures are sent as parameter blocks along with certain WM_NOTIFY messages from Windows common controls such as the `ListView` and `TreeView` to request custom draw information for individual items (and optionally sub-items).

Some item states, such as whether items are considered selected, or hot, can be altered. Whether this has any effect depends on the control, and there is little consistency of interpretation. Specialized sub-structures for particular common controls provide fields which can be written to in order to pass custom draw settings back to that control (for example the foreground and background text colours). The DC associated with this structure can also be updated by changing the font, and so forth.

'!

!OS.NMCUSTOMDRAW categoriesForClass!External-Data-Structured-Win32! !

!OS.NMCUSTOMDRAW methodsFor!

applyFont
	"Private - Apply the new font (if changed) to the custom draw DC and answer whether
	a new font was indeed selected."

	^(font notNil and: [font basicHandle ~= self canvas fontHandle])
		ifTrue: 
			[#todo.	"It's definitely not a good idea to delete old font here (the default font will
			 probably get deleted, but we rely on the fact that finalization happens in
			 the background so that the font we supply in place is not deleted until
			 after the drawing cycle is complete. This seems dangerous."
			self canvas font: font.
			CDRF_NEWFONT]
		ifFalse: [CDRF_DODEFAULT]!

backcolor
	"Answer the background <Color>."

	^self canvas backcolor!

backcolor: aColor
	"Sets the background <Color>."

	self canvas backcolor: aColor!

boundingRectangle
	"Answer the <Rectangle> within which the item is being displayed (in the client co-ordinates
	of the view."

	^self rc asRectangle!

canvas
	"Answer the <Canvas> associated with the receiver (useful for custom modifications, but care is needed to avoid leaks)."

	^canvas ifNil: [canvas := Graphics.Canvas withNonOwnedDC: self hdc dpi: view dpi]!

dpi
	"Answer the DPI of the control being drawn."

	^view dpi!

dwDrawStage
	"Answer the <Integer> value of the receiver's 'dwDrawStage' field."

	^bytes uint32AtOffset: _OffsetOf_dwDrawStage!

dwItemSpec
	"Answer the <Integer> value of the receiver's 'dwItemSpec' field."

	^bytes uint32AtOffset: _OffsetOf_dwItemSpec!

evaluateDrawBlock: customDrawBlock
	"Private - Evaluate the <monadicValuable>, customDrawBlock, and answer the appropriate instruction
	 for a common control to complete the draw operation (or skip it if total control is taken)."

	^(customDrawBlock value: self) == true ifTrue: [CDRF_SKIPDEFAULT] ifFalse: [self applyFont]!

font
	"Answer the character font."

	"We assume the font is being accessed in order to be modified, so allocate a copy"

	^font ifNil: [font := self canvas font copy]!

font: aFont
	"Set the character font.
	Implementation Note: Don't update the DC with the new font yet."

	font := aFont!

forecolor
	"Answer the foreground text colour."

	^self canvas forecolor!

forecolor: aColor
	"Sets the foreground text <Color>."

	self canvas forecolor: aColor!

hasFocus
	"Answer whether the item being drawn has focus."

	^self uItemState allMask: CDIS_FOCUS!

hasFocus: aBoolean
	"Set whether the item should be drawn with focus indications."

	"Changing this setting affects the drawing of focus rectangles around items in both list and tree views, although only if the control actually has focus. Disabled items are never drawn with focus in TreeViews."

	self stateMask: CDIS_FOCUS set: aBoolean!

hdc
	"Answer the `External.Handle` value of the receiver's 'hdc' field."

	^(bytes uintPtrAtOffset: _OffsetOf_hdc) asExternalHandle!

isChecked
	"Answer whether the item being draw is 'checked' (i.e. in a list with checkboxes it is ticked)."

	^self uItemState allMask: CDIS_CHECKED!

isChecked: aBoolean
	"Set whether the item should be drawn as checked (i.e. in a list with checkboxes, it's box is ticked)."

	self stateMask: CDIS_CHECKED set: aBoolean!

isDefault
	"Answer whether the item being drawn is the default."

	^self uItemState allMask: CDIS_DEFAULT!

isDefault: aBoolean
	"Set whether the item being drawn is the default."

	"Presumably this relates to button-like controls."

	self stateMask: CDIS_DEFAULT set: aBoolean!

isDisabled
	"Answer whether the item being drawn is disabled."

	^self uItemState allMask: CDIS_DISABLED!

isDisabled: aBoolean
	"Set whether the item being drawn should be drawn with disabled appearnce."

	"Changing this setting does have an effect in a TreeView, when true the text and icon are greyed. Disabled items are also not highlighted for hot tracking or selection. The setting appears to have no effect in a ListView."

	self stateMask: CDIS_DISABLED set: aBoolean!

isGrayed
	"Answer whether the item being drawn is greyed out."

	"Changing this setting has no apparent effect in the ListView or TreeView."

	^self uItemState allMask: CDIS_GRAYED!

isGrayed: aBoolean
	"Set whether the item being drawn should be greyed out.  Changing the setting has no observable effect in TreeViews or ListViews, but may do in others."

	self stateMask: CDIS_GRAYED set: aBoolean!

isHot
	"Answer whether the item being drawn is hot (i.e. under the cursor when hot tracking is enabled)."

	^self uItemState allMask: CDIS_HOT!

isHot: aBoolean
	"Set whether the item should be drawn with hot-highlights, e.g. when under the cursor in a view with hot tracking enabled."

	"Changing this setting does have an effect in a TreeView in and affects the background hot-highlight being drawn when the mouse is over an item, but there is no effect apparent in a ListView."

	self stateMask: CDIS_HOT set: aBoolean!

isIndeterminate
	"Answer whether the item being drawn is an indeterminate state."

	^self uItemState allMask: CDIS_INDETERMINATE  !

isIndeterminate: aBoolean
	"Set whether the item being drawn is an indeterminate state."

	"Presumably this is for use with 3-state checkboxes."

	self stateMask: CDIS_INDETERMINATE set: aBoolean!

isMarked
	"Answer whether the item being drawn is marked (whatever that means)."

	^self uItemState allMask: CDIS_MARKED!

isMarked: aBoolean
	"Set whether the item being drawn is marked (whatever that means)."

	self stateMask: CDIS_MARKED set: aBoolean!

isSelected
	"Answer whether the item being drawn is selected."

	^self uItemState allMask: CDIS_SELECTED!

isSelected: aBoolean
	"Set whether the item should be drawn as selected."

	self stateMask: CDIS_SELECTED set: aBoolean!

item
	"Answer the object from the view's model that is being drawn (the item, which is pre-cached)."

	^item!

item: anObject
	"Private - Private -Record the item being drawn."

	item := anObject!

itemHandle
	"Private - Answer the 'handle' of the receiver's node."

	^self dwItemSpec!

lParam
	"Answer the <Integer> value of the receiver's 'lParam' field."

	^bytes uintPtrAtOffset: _OffsetOf_lParam!

metrics
	"Answer the <SystemMetrics> applicable in this custom drawing context."

	^view metrics!

rc
	"Answer the <RECTL> value of the receiver's 'rc' field."

	^RECTL fromAddress: bytes yourAddress + _OffsetOf_rc!

stateMask: anInteger set: aBoolean
	| itemState |
	itemState := bytes uint32AtOffset: _OffsetOf_uItemState.
	bytes uint32AtOffset: _OffsetOf_uItemState
		put: (aBoolean ifTrue: [itemState bitOr: anInteger] ifFalse: [itemState bitAnd: anInteger bitInvert])!

subItem
	^self item!

uItemState
	"Answer the <Integer> value of the receiver's 'uItemState' field."

	^bytes uint32AtOffset: _OffsetOf_uItemState!

uItemState: anInteger
	"Set the receiver's 'uItemState' field to the value of the argument, anInteger"

	bytes uint32AtOffset: _OffsetOf_uItemState put: anInteger!

view
	"Answer the sub-instance of <IconListAbstract> for which this is a <customDrawContext>."

	^view!

view: anIconListAbstract
	"Private -"
	view := anIconListAbstract!

viewFont
	^view actualFont atDpi: self dpi! !

!OS.NMCUSTOMDRAW categoriesForMethods!
applyFont!operations!private! !
backcolor!accessing!public! !
backcolor:!accessing!public! !
boundingRectangle!accessing!public! !
canvas!accessing!public! !
dpi!accessing!high DPI!public! !
dwDrawStage!**compiled accessors**!public! !
dwItemSpec!**compiled accessors**!public! !
evaluateDrawBlock:!operations!public! !
font!accessing!public! !
font:!accessing!public! !
forecolor!accessing!public! !
forecolor:!accessing!public! !
hasFocus!public!states-testing! !
hasFocus:!public!states-changing! !
hdc!**compiled accessors**!public! !
isChecked!public!states-testing! !
isChecked:!public!states-changing! !
isDefault!public!states-testing! !
isDefault:!public!states-changing! !
isDisabled!public!states-testing! !
isDisabled:!public!states-changing! !
isGrayed!public!states-testing! !
isGrayed:!public!states-changing! !
isHot!public!states-testing! !
isHot:!public!states-changing! !
isIndeterminate!public!states-testing! !
isIndeterminate:!public!states-changing! !
isMarked!public!states-testing! !
isMarked:!public!states-changing! !
isSelected!public!states-testing! !
isSelected:!public!states-changing! !
item!accessing!public! !
item:!accessing!private! !
itemHandle!accessing!private! !
lParam!**compiled accessors**!public! !
metrics!accessing!public! !
rc!**compiled accessors**!public! !
stateMask:set:!private!states-changing! !
subItem!accessing!public! !
uItemState!**compiled accessors**!public! !
uItemState:!**compiled accessors**!public! !
view!accessing!public! !
view:!accessing!private! !
viewFont!accessing!private! !
!

OS.NMCUSTOMDRAW methodProtocol: #customDrawContext attributes: #(#readOnly) selectors: #(#backcolor #backcolor: #boundingRectangle #canvas #font #font: #forecolor #forecolor: #hasFocus #isChecked #isDefault #isDisabled #isGrayed #isHot #isIndeterminate #isSelected #view)!

!OS.NMCUSTOMDRAW class methodsFor!

byteSize
	^_NMCUSTOMDRAW_Size!

defineFields
	"Define the structure template for Win32 NMCUSTOMDRAW structure.
		self compileDefinition
	"

	super defineFields.
	self
		defineField: #dwDrawStage type: UInt32Field readOnly;
		defineField: #hdc type: HANDLEField readOnly;
		defineField: #rc type: (StructureField type: RECTL) beReadOnly;
		defineField: #dwItemSpec type: UInt32Field readOnly;
		defineField: #uItemState type: UInt32Field new;
		defineField: #lParam type: UIntPtrField readOnly!

getFieldNames
	^#(#hwndFrom #idFrom #code #dwDrawStage #hdc #rc #dwItemSpec #uItemState #lParam)! !

!OS.NMCUSTOMDRAW class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
defineFields!public!template definition! !
getFieldNames!**compiled accessors**!constants!private! !
!

