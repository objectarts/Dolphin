﻿"Filed out from Dolphin Smalltalk"!

UI.ListControlView
	subclass: #'UI.IconicListAbstract'
	instanceVariableNames: 'getImageBlock imageManager stateImageManager getInfoTipBlock customDrawBlock largeIconExtent thumbnailsImageManager'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'ViewModes'
				-> (IdentityDictionary withAll: {
								#extraLargeIcons -> (16r100 @ 16r100).
								#largeIcons -> (16r20 @ 16r20).
								#mediumIcons -> (16r18 @ 16r18).
								#mediumSmallIcons -> (16r14 @ 16r14).
								#noIcons -> (16r0 @ 16r0).
								#smallIcons -> (16r10 @ 16r10).
								#thumbnails -> (16r40 @ 16r40).
								#tileIcons -> (16r30 @ 16r30)
							})
		}!

UI.IconicListAbstract guid: (Core.GUID fromString: '{87b4c728-026e-11d3-9fd7-00a0cc3e4a32}')!

UI.IconicListAbstract isNonInstantiable: true!

UI.IconicListAbstract comment: 'IconicListAbstract is an abstract class whose subclasses implement various Windows iconic list common controls.

Each of the subclasses of IconicListAbstract are capable of displaying the list items in an iconic form with associated descriptive text. The list determines the text for an item by mapping it via its #getTextBlock aspect. Similarly, the image for an item can be determined by setting an appropriate #getImageBlock. This is a <monadicValuable> which must map a particular item to an image index. The images are held in an <ImageManager> set into the #imageManager aspect.

Instance Variables:
	getTextBlock	<monadicValuable> for determining the text of the list items.
	getImageBlock	<monadicValuable> or nil, for determining the image index of list items.
	imageManager	<IconImageManager> or nil, for mapping image indices to images.
	stateImageManager	<IconImageManager>or nil, for mapping state image indices to images.
	getInfoTipBlock	<monadicValuable> for determining the tool tip text of the list items.
	customDrawBlock	<monadicValuable> evaluated with <customDrawContext> to set custom text attributes for a list item.
'!

!UI.IconicListAbstract categoriesForClass!MVP-Views! !

!UI.IconicListAbstract methodsFor!

applyImageLists
	"Private - Set the receiver's image lists from the image managers."

	^self subclassResponsibility
!

attachEditControl: hWnd
	^SessionManager.Current inputState windowAt: hWnd
		ifAbsent: 
			[| editView |
			editView := (#{TextEdit} valueOrNil ?? ControlView) new.	"Attach a Smalltalk window so that keyboard accelerator keys will work in the in-place edit
	view (#1243). The caller can use this for whatever other purpose they wish."
			editView parentView: self.
			"We don't subclass the edit control, so we won't receive any messages for it, however inserting it into our windows collection is sufficient for Ctrl+C, etc, but we need to remember to remove it when we are done as we won't know when it is destroyed."
			editView attachHandle: hWnd asExternalHandle.
			editView]!

basicEditItemLabel: anIntegerOrHandle 
	"Private - Begin inline editing of the item with one-based <integer> index, itemIndex."

	^self error: 'In-place label editing not supported'!

basicItemFromPoint: aPoint 
	"Private - Answer a hit-test structure of the object in the control under the <Point>
	argument, or nil if none."

	^self subclassResponsibility!

beLargeIcons
	"Set the receiver's image extent to that for large icons."

	self viewMode: #largeIcons!

beNoIcons
	"Set the receiver to display text only (no images)."

	self viewMode: #noIcons!

beSmallIcons
	"Set the receiver's image extent to that for small icons."

	self viewMode: #smallIcons!

buildViewsPopup: aMenu
	self class viewModeNames do: 
			[:each |
			| pair |
			pair := ##(IdentityDictionary withAll: {
								#noIcons -> #(#beNoIcons '&No Icons').
								#list -> #(#listMode '&List').
								#report -> #(#reportMode '&Details').
								#smallIcons -> #(#smallIconMode '&Small Icons').
								#mediumSmallIcons -> #(#mediumSmallIconMode 'M&edium-small Icons').
								#mediumIcons -> #(#mediumIconMode '&Medium Icons').
								#largeIcons -> #(#largeIconMode '&Icons').
								#tileIcons -> #(#tileIconMode '&Tiles').
								#thumbnails -> #(#thumbnailsMode 'Thum&bnails').
								#extraLargeIcons -> #(#extraLargeIconMode '&Extra-large Icons')
							})
						at: each.
			(aMenu addCommand: pair first description: pair second) isRadioButtonStyle: true]!

canEditLabels
	"Answer whether the receiver's labels can be edited in-place."

	^self baseStyleAllMask: self editLabelStyle!

canEditLabels: aBoolean
	"Set whether the receiver's labels can be edited in-place.
	Can be changed dynamically without recreating the control."

	^self baseStyleMask: self editLabelStyle set: aBoolean recreateIfChanged: false!

customDrawBlock 
	"Answer the <monadicValuable> used to set custom draw text attributes or nil if custom drawing is
	not employed."

	^customDrawBlock!

customDrawBlock: operation
	"Set the <monadicValuable> used for custom drawing.
	When evaluated the valuable is passed an instance of the #customDrawContextClass associated with the subclass.
	This object provides methods for setting text attributes such as the font and foreground and background
	colours. In cases where total control over the visual appearance of the item is required the canvas associated
	with the custom drawing context can be used, and the operation should answer true to inform the View that
	all default drawing should be disabled."

	customDrawBlock := operation!

customDrawContextClass
	"Private - Answer the class of <customDrawContext> associated with the receiver.
	This is the type of object passed to the customDrawBlock. and provides access to
	all the contextual information to implement partial or complete custom drawing."

	^NMCUSTOMDRAW!

customDrawItem: context 
	"Private - Custom draw the 'item' identified in the <customDrawContext>, context.
	Answer the custom draw return code (an integer from the CDRF_XXXX enumeration) 
	to be returned to the control."

	context view: self.
	^context evaluateDrawBlock: self customDrawBlock!

customDrawSubItem: context
	"Private - Custom draw the sub-item identified in the <customDrawContext>, context.
	Answer the custom draw return code (an integer from the CDRF_XXXX enumeration) 
	to be returned	to the control."

	"At this level we don't implement sub-item custom draw"
	^CDRF_DODEFAULT
!

defaultExtent
	"Private - Answer the default size of the receiver in device-independent pixels (96-dpi DIPs). This is used only to determine the size of a view when it is created (although after scaling DIPs to the monitor DPI). Thereafter #preferredExtent is used when the desired size of a view is requested."

	^##(200 @ 350)!

defaultImageManager
	^IconImageManager current!

defaultWindowExStyle
	"Private - Answer the default extended window creation style.
	Use the client edge style for the standard Win95 look."

	^super defaultWindowExStyle bitOr: WS_EX_CLIENTEDGE
!

disableLabelEdit
	"Private - Disable label editing in the host control at the end of a programmatically
	initiated in-place label edit."

	self baseStyle: self baseStyle | self editLabelStyle.
	self canEditLabels: false!

dragLeave: session 
	"The drag operation described by the <DragDropSession>, session,
	has left the receiver's window."

	session hideCursorWhile: [self hideDropHighlight]!

dragOver: session
	"The drag operation described by the <DragDropSession>, session,
	 has moved to a new position over the receiver's window. 
	Implementation Note: Override in order to provide drop target highlighting
	and to suggest a reasonable drop target for most cases (the item under the
	cursor)."

	"Determine what, if anything, is under the drop position"

	| hit item target |
	hit := self basicItemFromPoint: (session dragPointInView: self).
	hit isItemHit
		ifTrue: 
			[item := hit handle.
			target := self objectFromHandle: item ifAbsent: nil].
	"Set up the suggested target and give observers a chance to set the drop operation"
	session suggestedTarget: target.
	super dragOver: session.

	"Finally highlight the drop target and show the appropriate drag cursor"
	self showDragDrop: session highlight: item!

drop: session 
	"The drag operation described by the <DragDropSession>, session, has 
	culminated in a drop over the receiver. Answer whether the drop was successful.
	Implementation Note: Override to remove the drop-target highlight."

	session hideCursorWhile: [self hideDropHighlight].
	^super drop: session!

dropHighlight
	"Private - Answers the current drop highlight for within the receiver or
	nil if there is none."

	^self propertyAt: #dropHighlight ifAbsent: nil!

editItemLabel: hItem 
	"Private - Initiate in-place editing of the item with the specified handle. Answer the
	<TextEdit> wrapping the edit control created by the receiver's list control, or nil if the
	label edit was refused.

	Note that the <TextEdit> will only be valid for as long as the label edit is taking place
	since the list control will destroy it when the label edit is finished or cancelled. Since
	the underlying control is subclassed (in the Windows sense) the returned <TextEdit> object
	will see the destroy message in the normal way, and its handle will get nulled out as for
	any other view when it is closed."

	| hWnd |
	self setFocus.
	"Override label edit style for programmatic initiation"
	self canEditLabels ifFalse: [self enableLabelEdit].
	hWnd := self basicEditItemLabel: hItem.
	hWnd isNull 
		ifTrue: 
			["We won't get the '?VN_ENDLABELEDIT' notification, so must restore the
			 label edit style if we changed it."
			self canEditLabels ifFalse: [self disableLabelEdit].
			^nil].
	"Attach a Smalltalk window so that keyboard accelerator keys will work in the in-place edit
	view (#1243). The caller can use this for whatever other purpose they wish."
	^self attachEditControl: hWnd!

editLabelStyle
	"Private - Answer the <integer> style mask used to control whether label editing is enabled
	in the receiver's control."

	"Must be overridden by subclasses which support in-place label edits"
	^0!

editSelectionLabel
	"Initiate an in-place edit of the first selected label."

	| indices |
	indices := self selectionsByIndex.
	indices isEmpty ifTrue: [^self errorNoSelection].
	^self editItemLabel: indices first!

enableLabelEdit
	"Private - Enable programmatic label editing in the host control. In order to allow 
	programmatically initiated label editing when the #canEditLabels aspect is false
	(i.e. the control does not have the ?VS_LABELEDIT style), we must temporarily 
	add the style bit, which is then removed later on receipt of the NM_ENDLABELEDIT 
	notification. In order to allow us to restore the correct style bits on termination of 
	the label edit, we avoid updating our own style bit mask."

	| saved |
	saved := self baseStyle.
	self canEditLabels: true.
	self baseStyle: saved!

ensureItemVisible: anObject 
	"Ensure the item, anObject, is visible, scrolling it into view if necessary."

	self ensureVisible: (self handleFromObject: anObject)!

ensureSelectionVisible
	"Ensure the selected item is visible, scrolling it into view if necessary.
	Do nothing if there is no selection."

	| index |
	index := self primarySelectionIndex.
	index == 0 ifFalse: [self ensureVisible: index]!

ensureVisible: anIntegerOrHandle 
	"Ensure the item with the specified index is visible, scrolling it into view if necessary."

	^self subclassResponsibility!

errorInCommonControlCall: hItem
	"Private - Raise an appropriate exception in the event of a common control message failure
	in relation to the item with the 'handle', hItem."

	^self errorInCommonControlCall


!

extraLargeIconMode
	"Place the receiver in extra large icons mode"

	<commandQuery: #queryExtraLargeIconMode:>
	self viewMode: #extraLargeIcons!

getEditControl
	^self subclassResponsibility!

getImageBlock
	"Answer the block to use to find out the image index of an object that will
	be placed in the receiver"

	^getImageBlock
!

getImageBlock: aOneArgBlock
	"Set the block to use to find out the image index of an object that will
	be placed in the receiver"

	getImageBlock := aOneArgBlock.
	self updateAll
!

getInfoTipBlock
	"Answer the value of the receiver's 'getInfoTipBlock' instance variable."

	^getInfoTipBlock!

getInfoTipBlock: anObject
	"Set the value of the receiver's 'getInfoTipBlock' instance variable to the argument, anObject."

	getInfoTipBlock := anObject!

hasGridLines
	"Answer whether the receiver is displaying gridlines."

	^false!

hasGridLines: aBoolean
	"If supported, turn on or off the display of grid lines in the receiver depending on the
	value of the argument, aBoolean"

	"Only supported by some subclasses"

	!

hasHotTracking
	"Answer whether the receiver's selection will track the mouse as it hovers over items in the list."

	^self subclassResponsibility!

hasHotTracking: aBoolean 
	"Set whether the receiver's selection will track the mouse as it hovers over items in the list."

	^self subclassResponsibility!

hasIcons
	"Answer true if the receiver wants to show icons."

	^self viewMode ~~ #noIcons
!

hasSubItemCustomDraw
	"Private - Answer whether the receiver wants NM_CUSTOMDRAW notifications at the
	sub-item (e.g. column) level."

	^false!

hideDropHighlight
	"Private - Hides any drop highlight within the receiver."

	self removePropertyAt: #dropHighlight ifAbsent: nil!

imageExtent
	"Private - Answer the device-independent (96-dpi) extent of images to use based on the current view mode"

	^self class viewModes at: self viewMode!

imageManager
	"Private - Answer the receiver's normal image manager."

	^imageManager!

imageManager: anImageManager
	"Set the receiver's normal image manager."

	imageManager := anImageManager.
	self applyImageLists!

initialize
	"Private - Initialize the receiver"

	super initialize.
	getImageBlock := self class defaultGetImageBlock.
	imageManager := self defaultImageManager!

itemFromPoint: aPoint 
	"Private - Answer the handle of the object in the control under the <Point> argument,
	or nil if none."

	| ht |
	ht := self basicItemFromPoint: aPoint.
	^ht isItemHit ifTrue: [ht handle]!

itemRect: anInteger 
	"Answers the rectangle surrounding the item with anIntegerIndex within the receiver"

	^self itemRect: anInteger textOnly: false!

itemRect: itemHandle textOnly: aBoolean
	"Answers the rectangle surrounding the item with anIntegerIndex within
	the receiver, optionally for the text label only."

	^self subclassResponsibility!

itemStructure
	^self subclassResponsibility!

largeIconExtent
	"Answer image extent measured in device-independent (96-dpi) pixels for a large icon mode. This will be scaled to the receiver's resolution."

	^largeIconExtent ifNil: [SystemMetrics default largeIconExtent]!

largeIconExtent: aPointOrNil
	"Set the image extent for the large icons mode."

	largeIconExtent := aPointOrNil.
	self applyImageLists
!

largeIconMode
	"Place the receiver in large icons mode"

	<commandQuery: #queryLargeIconMode:>
	self viewMode: #largeIcons!

mediumIconMode
	"Place the receiver in medium icons mode"

	<commandQuery: #queryMediumIconMode:>
	self viewMode: #mediumIcons!

mediumSmallIconMode
	"Place the receiver in medium-small icons mode"

	<commandQuery: #queryMediumSmallIconMode:>
	self viewMode: #mediumSmallIcons!

newSelectionsFromEvent: aMouseEvent
	"Private - Answer a collection of the <integer> selections that would occur if the `MouseEvent` argument was passed to the control.
	This method encodes the selection behaviour of `ListView` in response to mouse clicks, and is used there to predict what it will do in order to generate `selectionChanging:` events that the control itself does not provide (or at least not in virtual mode). The method is also used to implement right-click selection for `ListBox`, but note that it does not precisely replicate the listbox control's native left-click selection behaviour."

	| itemClicked anyKeysDown newSelections anchorIndex shiftRange anchorIsSelected |
	itemClicked := self itemFromPoint: aMouseEvent position.
	"In single-select mode, the new selection is always the item clicked, or nothing if the click is outside all items."
	self isMultiSelect
		ifFalse: 
			[^aMouseEvent isSelectionButtonDown
				ifTrue: [itemClicked ifNil: [#()] ifNotNil: [{itemClicked}]]
				ifFalse: 
					["Other buttons have no effect on the selection"
					self selectionsByIndex]].
	newSelections := self getSelectionsByIndex.
	anyKeysDown := aMouseEvent isModifierDown.
	"If the click is outside all items, and ctrl or shift is down, nothing changes."
	(itemClicked isNil and: [anyKeysDown]) ifTrue: [^newSelections].
	"A right or middle click on an already-selected item also does not change the selection,
	otherwise it would be very frustrating to open the context menu with multiple items selected.
	The control also chooses to leave the selection alone if modifiers are held during a right/middle click."
	(aMouseEvent button ~= #left and: [anyKeysDown or: [newSelections includes: itemClicked]])
		ifTrue: [^newSelections].
	"Having taken care of the above edge cases, if no keys are down, the behavior is equivalent to the single-select case."
	anyKeysDown ifFalse: [^itemClicked ifNil: [#()] ifNotNil: [{itemClicked}]].
	"Only Ctrl is down, so we flip the selection state of the clicked item."
	aMouseEvent isShiftDown
		ifFalse: 
			[newSelections := newSelections asSortedCollection.
			(newSelections remove: itemClicked ifAbsent: nil) ifNil: [newSelections add: itemClicked].
			^newSelections asArray].
	"At least Shift is down, so we must start examining the 'anchor'. This is the last item
	that was clicked with no modifiers, only ctrl, or ctrl + shift (shift-clicks do *not* move the
	anchor). It acts as the 'start point' for operations where shift is held--they affect
	the range of items from the anchor to the click point, inclusive. Initially it is zero,
	i.e. out-of-bounds, in which case holding shift essentially has no effect, and we act only on
	the item actually clicked."
	anchorIndex := self anchorIndex.
	shiftRange := anchorIndex == 0
				ifTrue: [itemClicked to: itemClicked]
				ifFalse: [(anchorIndex min: itemClicked) to: (anchorIndex max: itemClicked)].
	"Only shift is down, not ctrl, so the current selection will be entirely replaced by the marked range."
	aMouseEvent isCtrlDown ifFalse: [^shiftRange asArray].
	"Both ctrl and shift are down, so we set the selection state of the affected range to that of the
	anchor itself. Note that this ignores the selection state of the item actually clicked
	and everything in between it and the anchor."
	newSelections := newSelections asSet.
	anchorIsSelected := newSelections includes: anchorIndex.
	shiftRange do: (anchorIsSelected
				ifTrue: [[:i | newSelections add: i]]
				ifFalse: [[:i | newSelections remove: i ifAbsent: nil]]).
	"For some reason, the item clicked is always left selected, even if we are deselecting the rest
	of the marked range. This is not true in e.g. Windows Explorer--why is it in Dolphin?"
	newSelections add: itemClicked.
	^newSelections asSortedCollection asArray!

nmBeginDrag: pNMHDR
	"Private - Default handler for the ?VN_BEGINDRAG notification message.
	If the receiver is configured to be a drag source, then initiate a drag,
	otherwise answer nil to accept the default processing.
	N.B. This notification is not necessarily sent by all subclasses."

	| nm |
	nm := self notificationClass fromAddress: pNMHDR.
	self isDragSource
		ifTrue: 
			[(self objectFromHandle: nm itemHandle ifAbsent: nil)
				ifNotNil: [:dragee | self onBegin: #left drag: dragee]].
	^nil!

nmBeginLabelEdit: pNMHDR
	"Private - Default handler for the ?VN_BEGINLABELEDITW notification message.
	N.B. This notification is not necessarily sent by all subclasses."

	| item event |
	item := self itemStructure fromAddress: pNMHDR asInteger + NMHDR._NMHDR_Size.
	event := LabelEditingEvent forSource: self.
	event
		item: item;
		object: (self objectFromHandle: item handle).
	self presenter onAboutToEditLabel: event.
	event cancel
		ifFalse: 
			[| editor |
			editor := self attachEditControl: self getEditControl.
			event text ~= item text ifTrue: [editor plainText: event text].
			event font ifNotNil: [editor font: event font].
			event forecolor ifNotNil: [editor forecolor: event forecolor]].
	^event cancel!

nmBeginRDrag: pNMHDR
	"Private - Default handler for the ??N_BEGINRDRAG notification message.
	Answer nil to accept default processing.
	N.B. This notification is not necessarily sent by all subclasses."

	| nm |
	nm := self notificationClass fromAddress: pNMHDR.
	self isDragSource ifTrue: [self onBegin: #right drag: (self objectFromHandle: nm itemHandle)].
	^nil!

nmCustomDraw: pNMHDR
	"Private - Handle a NM_CUSTOMDRAW notification message."

	"Implementation Note: Defer creating the header struct as long as possible to avoid impacting 
	draw speed too much as this message can be sent several times per sub-item."

	| drawStage context item |
	(drawStage := pNMHDR uint32AtOffset: NMCUSTOMDRAW._OffsetOf_dwDrawStage) == CDDS_PREPAINT
		ifTrue: 
			["Before any painting"
			^(self wantCustomDrawItemNotifications: pNMHDR)
				ifTrue: [CDRF_NOTIFYITEMDRAW]
				ifFalse: [CDRF_DODEFAULT]].
	"Before painting item"
	(drawStage allMask: CDDS_ITEMPREPAINT) ifFalse: [^nil].
	context := self customDrawContextClass fromAddress: pNMHDR.
	item := self objectFromHandle: context itemHandle ifAbsent: nil.
	item isNil
		ifTrue: 
			["The control attempts to draw stuff that isn't there on occassion"
			^CDRF_DODEFAULT].
	context
		item: item;
		view: self.
	^(drawStage allMask: CDDS_SUBITEM)
		ifTrue: [self customDrawSubItem: context]
		ifFalse: 
			["If item pre-paint stage and we want sub-item, notify the control accordingly"
			self hasSubItemCustomDraw ifTrue: [CDRF_NOTIFYSUBITEMDRAW] ifFalse: [self customDrawItem: context]]!

nmDeleteItem: pNMHDR
	"Private - Default handler for the ??N_DELETEITEM notification message.
	Answer nil to accept the default processing.
	N.B. This notification is not necessarily sent by all subclasses."

	^nil!

nmEndLabelEdit: pNMHDR
	"Private - Default handler for the ?VN_ENDLABELEDIT notification message. Note that we don't
	forward the event to the presenter if the edit was cancelled, or if the text wasn't actually
	changed. N.B. This notification is not necessarily sent by all subclasses."

	| item object text |
	SessionManager.Current inputState removeWindowAt: self getEditControl.
	item := self itemStructure fromAddress: pNMHDR asInteger + NMHDR._NMHDR_Size.
	text := item pszText.
	self canEditLabels ifFalse: [self disableLabelEdit].
	text isNil
		ifTrue: 
			["Edit cancelled"
			^nil].
	text := text asUtf8String.
	object := self objectFromHandle: item handle.
	^text = (self getTextBlock value: object) displayString
		ifFalse: [self presenter onLabelOf: object editedTo: text]!

nmGetDispInfoW: pNMHDR
	"Private - Handler for a ?VN_GETDISPINFO notification message.
	N.B. This notification is not necessarily sent by all subclasses."

	^self
		onDisplayDetailsRequired: (self itemStructure fromAddress: pNMHDR asInteger + NMHDR._NMHDR_Size)!

nmSelChanged: anExternalAddress 
	"Private - Default handler for the ??N_SELCHANGED notification message.
	N.B. This notification is not necessarily sent by all subclasses."

	^self onSelChanged: self getSelectionsByIndex!

nmSetDispInfoW: pNMHDR
	"Private - Default handler for the ?VN_SETDISPINFO notification message.
	Forward as an onDisplayDetailsChanged: event."

	^self
		onDisplayDetailsChanged: (self itemStructure fromAddress: pNMHDR asInteger + NMHDR._NMHDR_Size)!

notificationClass
	"Private - Answer the class of NMHDR associated with certain notifications sent
	by the receiver's associated Windows control."

	^NMHDR!

onAboutToEditLabel: aLabelEditingEvent
	"The receiver's element, anObject, is about to have its label edited in the receiver."

	| accept |
	"Fire the event that allows registered handlers to override the label that is edited."
	self presenter trigger: #aboutToEditLabel: with: aLabelEditingEvent.
	"Also trigger the legacy event"
	accept := aLabelEditingEvent cancel not asValue.
	self presenter
		trigger: #aboutToEditLabel:accept:
		with: aLabelEditingEvent object
		with: accept.
	aLabelEditingEvent cancel: accept value not!

onDisplayDetailsChanged: item
	"Private - Set the display info for the requested item.
	By default do nothing except answer 0 to prevent default processing...."

	^0!

onDisplayDetailsRequired: aCCITEM
	"Private - Get the display info for the requested item."

	^0!

onItem: anObject removedAtIndex: anInteger 
	"Event received when the <Object>, anObject, has been removed from the receiver's
	model at the <integer> index, anInteger. Remove the appropriate object from the list,
	and trigger a selection changed event if the removed item was previously selected."

	| wasSelected |
	wasSelected := self selectionsByIndex identityIncludes: anInteger.
	self basicRemoveAtIndex: anInteger.
	wasSelected ifTrue: [self onSelRemoved]!

onKeyTyped: aKeyEvent
	"Default handler for the receiver's view receiving a key entry."

	| answer |
	answer := super onKeyTyped: aKeyEvent.
	aKeyEvent code==VK_RETURN ifTrue: [
		self presenter performAction ].
	^answer!

onLabelOf: anObject editedTo: text
	"The receiver's element, anObject, has had its label edited in the receiver to the 
	specified text. Answer whether to accept the edited text.
	Implementation Note: We fire off an event to let the observers determine whether to
	accept the label edit. If the label edit is accepted, we let rename proceed, and then 
	subsequently notify the observers again that the label has been changed. This is necessary
	because we can't mess around with the item until the control has finished with it, e.g.
	deleting the item before returning from this method can cause the TreeView to crash.
	Thus the rename protocol consists of events, namely:
		aboutToEditLabel:accept:	      -	Rename request received (user clicked over selected label again)
								Set 'accept' value holder to false to deny rename request.
		labelOf:editedTo:accept:	      -	Edit completed, set accept value holder to false to reject new name.
		labelOf:changedTo:		      - New name accepted and applied.
	"

	| accept accepted |
	accept := false asValue.
	self presenter trigger: #labelOf:editedTo:accept: withArguments: {anObject. text. accept}.
	accepted := accept value.
	accepted
		ifTrue: 
			[
			[self presenter
				trigger: #labelOf:changedTo:
				with: anObject
				with: text]
					postToMessageQueue].
	^accepted!

onLeftButtonDoubleClicked: aMouseEvent
	"Default handler for a mouse left button double-click event."

	| answer |
	answer := super onLeftButtonDoubleClicked: aMouseEvent.
	self presenter performAction.
	^answer!

onSelRemoved
	"Private - The selected item has been removed. Update the receiver's selection
	state to account."

	"Implementation Note: When the selected item is removed the selection change 
	cannot be prevented, so we do not generate a selection changING event."

	self
		basicResetSelection;
		onSelChanged!

onViewCreated
	"The receiver window has been created. Finish the job and apply the image lists"

	"#222: Request version 5 control behaviour which supposedly fixes bug of control ignoring 
	CDRF_NEWFONT bit returned from custom draw. This should be done first."

	self ccmSetVersion: 6.
	super onViewCreated.
	self applyImageLists.
	self beDefaultThemed!

positionForKeyboardContextMenu
	"Answer the desired position for a context menu requested from the keyboard.
	This should be based on the 'current selection', whatever that means in the context of the
	receiver."

	| selections |
	selections := self selectionsByIndex.
	^selections isEmpty
		ifTrue: [super positionForKeyboardContextMenu]
		ifFalse: [self mapPointToScreen: (self itemRect: selections first textOnly: true) bottomLeft]!

queryExtraLargeIconMode: aCommandQuery
	self queryViewMode: aCommandQuery name: #extraLargeIcons!

queryLargeIconMode: aCommandQuery
	self queryViewMode: aCommandQuery name: #largeIcons!

queryMediumIconMode: aCommandQuery
	self queryViewMode: aCommandQuery name: #mediumIcons!

queryMediumSmallIconMode: aCommandQuery
	self queryViewMode: aCommandQuery name: #mediumSmallIcons!

queryRenameIt: aCommandQuery
	aCommandQuery isEnabled: (self canEditLabels and: [self hasSelection])!

querySmallIconMode: aCommandQuery
	self queryViewMode: aCommandQuery name: #smallIcons!

queryThumbnailsMode: aCommandQuery
	self queryViewMode: aCommandQuery name: #thumbnails!

queryTileIconMode: aCommandQuery
	self queryViewMode: aCommandQuery name: #tileIcons!

queryViewMode: aCommandQuery name: aSymbol
	aCommandQuery
		beEnabled;
		isChecked: self viewMode == aSymbol!

renameIt
	<commandQuery: #queryRenameIt:>
	self canEditLabels ifTrue: [self editSelectionLabel]!

scaledImageExtent
	"Private - Answer the extent of images to use based on the current view mode and resolution."

	^Icon standardSizeFor: (self imageExtent * self dpi // USER_DEFAULT_SCREEN_DPI)!

setViewMode: aSymbol 
	^self subclassResponsibility!

showDragDrop: session highlight: item 
	item = self dropHighlight ifTrue: [^self].	"Finally highlight the drop target and show the appropriate drag cursor"
	session hideCursorWhile: 
			[self hideDropHighlight.
			item isNil ifFalse: [self showDropHighlight: item]]!

showDropHighlight: anItem
	"Private - Shows a drop highlight for anItem within the receiver."

	self propertyAt: #dropHighlight put: anItem.

!

smallIconExtent
	"Answer device-independent (96-dpi) pixel extent for the small icons mode. This will need to be scaled to the receiver's resolution to generate the actual small image extent."

	^SystemMetrics default smallIconExtent!

smallIconMode
	"Place the receiver in small icons mode"

	<commandQuery: #querySmallIconMode:>
	self viewMode: #smallIcons!

stateImageManager
	"Answers the receiver's state image manager."

	^stateImageManager
!

stateImageManager: anImageManager
	"Set the receiver's state image manager."

	stateImageManager := anImageManager.
	self applyImageLists!

stbSaveOn: anSTBOutFiler
	"Don't save out the temporary cache of thumbnails - this can be rebuilt."

	anSTBOutFiler override: thumbnailsImageManager with: nil.
	^super stbSaveOn: anSTBOutFiler!

themeSubAppName
	^'explorer'!

thumbnailsMode
	"Place the receiver in thumbnails mode"

	<commandQuery: #queryThumbnailsMode:>
	self viewMode: #thumbnails!

tileIconMode
	"Place the receiver in tile icons mode"

	<commandQuery: #queryTileIconMode:>
	self viewMode: #tileIcons!

viewMode
	"Answer the symbolic name of the receiver's current view mode."

	^self subclassResponsibility!

viewMode: aSymbol 
	"Sets the view mode of the receiver to aSymbol.
	See the class side method #viewModes for the set of valid symbols."

	"Helps mutation between ListView and TreeView if we do something sensible with invalid viewMode"
	| modeSymbol |
	modeSymbol := (self class viewModes includesKey: aSymbol) ifTrue: [aSymbol] ifFalse: [#smallIcons].
	self viewMode == modeSymbol ifTrue: [^self].
	self setViewMode: modeSymbol.
	self viewModeChanged!

viewModeChanged
	self applyImageLists!

viewModeSelect
	"Toggle the view mode of the receiver"

	<menuPopulator: #buildViewsPopup:>
	| viewModes |
	viewModes := self class viewModeNames.
	self viewMode: (viewModes at: (viewModes indexOf: self viewMode) \\ viewModes size + 1)!

wantCustomDrawItemNotifications: pNMHDR
	^self customDrawBlock notNil!

wmDestroy: message wParam: wParam lParam: lParam 
	"Private - Due to an apparent bug in the common controls whereby they send repeated
	selection changed notifications when being destroyed, we need to disable further
	notifications to event clients which could otherwise cause very slow close down."

	self removeAllEventsTriggered.
	^super 
		wmDestroy: message
		wParam: wParam
		lParam: lParam!

wmDpiChangedAfterParent: message wParam: wParam lParam: lParam
	"Private - Handles a WM_DPICHANGED_AFTERPARENT message. This is only sent to child windows, bottom-up, before the top-level window receives a WM_DPICHANGED."

	super
		wmDpiChangedAfterParent: message
		wParam: wParam
		lParam: lParam.
	self applyImageLists.
	^nil! !

!UI.IconicListAbstract categoriesForMethods!
applyImageLists!image management!private! !
attachEditControl:!private! !
basicEditItemLabel:!operations!private! !
basicItemFromPoint:!enquiries!private! !
beLargeIcons!modes!public! !
beNoIcons!do copy!modes!public! !
beSmallIcons!modes!public! !
buildViewsPopup:!commands-menus!private! !
canEditLabels!accessing-styles!public!testing! !
canEditLabels:!accessing-styles!public! !
customDrawBlock!accessing!public! !
customDrawBlock:!accessing!public! !
customDrawContextClass!constants!private! !
customDrawItem:!event handling!private! !
customDrawSubItem:!event handling!private! !
defaultExtent!constants!private! !
defaultImageManager!initializing!private! !
defaultWindowExStyle!constants!private! !
disableLabelEdit!helpers!private! !
dragLeave:!drag & drop!event handling!public! !
dragOver:!drag & drop!event handling!public! !
drop:!drag & drop!event handling!public! !
dropHighlight!accessing!private! !
editItemLabel:!operations!private! !
editLabelStyle!constants!private! !
editSelectionLabel!operations!public! !
enableLabelEdit!helpers!private! !
ensureItemVisible:!operations!public! !
ensureSelectionVisible!public!selection! !
ensureVisible:!operations!public! !
errorInCommonControlCall:!exceptions!private! !
extraLargeIconMode!commands-actions!public! !
getEditControl!accessing!private! !
getImageBlock!adapters!public! !
getImageBlock:!adapters!public! !
getInfoTipBlock!accessing!public! !
getInfoTipBlock:!accessing!public! !
hasGridLines!accessing-styles!public! !
hasGridLines:!accessing-styles!public! !
hasHotTracking!accessing-styles!public! !
hasHotTracking:!accessing-styles!public! !
hasIcons!public!testing! !
hasSubItemCustomDraw!private!testing! !
hideDropHighlight!drag & drop!private! !
imageExtent!accessing!private! !
imageManager!image management!private! !
imageManager:!image management!public! !
initialize!initializing!private! !
itemFromPoint:!enquiries!private! !
itemRect:!accessing!public! !
itemRect:textOnly:!enquiries!public! !
itemStructure!constants!private! !
largeIconExtent!constants!public! !
largeIconExtent:!constants!public! !
largeIconMode!commands-actions!public! !
mediumIconMode!commands-actions!public! !
mediumSmallIconMode!commands-actions!public! !
newSelectionsFromEvent:!event handling!private! !
nmBeginDrag:!event handling-win32!private! !
nmBeginLabelEdit:!event handling-win32!private! !
nmBeginRDrag:!event handling-win32!private! !
nmCustomDraw:!event handling-win32!private! !
nmDeleteItem:!event handling-win32!private! !
nmEndLabelEdit:!event handling-win32!private! !
nmGetDispInfoW:!event handling-win32!private! !
nmSelChanged:!event handling-win32!private! !
nmSetDispInfoW:!event handling-win32!private! !
notificationClass!constants!private! !
onAboutToEditLabel:!event handling!public! !
onDisplayDetailsChanged:!event handling!private! !
onDisplayDetailsRequired:!event handling!private! !
onItem:removedAtIndex:!event handling!public! !
onKeyTyped:!event handling!public! !
onLabelOf:editedTo:!event handling!public! !
onLeftButtonDoubleClicked:!event handling!public! !
onSelRemoved!public!selection! !
onViewCreated!event handling!public! !
positionForKeyboardContextMenu!enquiries!public! !
queryExtraLargeIconMode:!commands-queries!private! !
queryLargeIconMode:!commands-queries!private! !
queryMediumIconMode:!commands-queries!private! !
queryMediumSmallIconMode:!commands-queries!private! !
queryRenameIt:!commands-queries!private! !
querySmallIconMode:!commands-queries!private! !
queryThumbnailsMode:!commands-queries!private! !
queryTileIconMode:!commands-queries!private! !
queryViewMode:name:!commands-queries!private! !
renameIt!commands-actions!public! !
scaledImageExtent!accessing!private! !
setViewMode:!accessing!private! !
showDragDrop:highlight:!drag & drop!event handling!public! !
showDropHighlight:!drag & drop!private! !
smallIconExtent!constants!public! !
smallIconMode!commands-actions!public! !
stateImageManager!image management!public! !
stateImageManager:!image management!public! !
stbSaveOn:!binary filing!public! !
themeSubAppName!constants!private! !
thumbnailsMode!commands-actions!public! !
tileIconMode!commands-actions!public! !
viewMode!accessing!public! !
viewMode:!accessing!public! !
viewModeChanged!helpers!private! !
viewModeSelect!commands-actions!commands-menus!public! !
wantCustomDrawItemNotifications:!event handling-win32!private! !
wmDestroy:wParam:lParam:!event handling-win32!private! !
wmDpiChangedAfterParent:wParam:lParam:!event handling-win32!private! !
!

!UI.IconicListAbstract class methodsFor!

stbConvertFromVersion3: anArray
	"Private - Perform an STB conversion from a version 3 (or earlier) <View> to version 4, 
	i.e. add getInfoTipBlock inst var in IconicListAbstract and subclasses."

	| size array |
	array := super stbConvertFromVersion3: anArray.
	size := array size + 1.
	^(Array new: size)
		replaceFrom: 1
			to: 16
			with: array
			startingAt: 1;
		replaceFrom: 18
			to: size
			with: array
			startingAt: 17;
		yourself!

stbConvertFromVersion9: anArray
	"Private - Perform an STB conversion from a version 9 (or earlier) <View> to version 10,
	i.e. append getTextFormat and a couple of dummy instance variables."

	| size array |
	array := super stbConvertFromVersion9: anArray.
	size := array size + 3.	"3 instance variables were added"
	^(Array new: size)
		replaceFrom: 1
			to: 19
			with: array
			startingAt: 1;
		replaceFrom: 23
			to: size
			with: array
			startingAt: 20;
		yourself!

value: anObject
	"Private - Implement this message from the monadic valuable to support the default
	'get image' functionality for an iconic list.  By default we assume icons can be used
	for images."

	"Implementation Note: This can often remove the need to store a block down into a 
	view resource, and can thus save a considerable amount of space. It is also more 
	efficient to perform a normal message send than a block evaluation."

	^anObject iconImageIndex!

viewModeNames
	^#(#noIcons #list #report #smallIcons #mediumSmallIcons #mediumIcons #largeIcons #tileIcons #thumbnails #extraLargeIcons)
		intersection: self viewModes keys!

viewModes
	^ViewModes! !

!UI.IconicListAbstract class categoriesForMethods!
stbConvertFromVersion3:!binary filing!private! !
stbConvertFromVersion9:!binary filing!private! !
value:!evaluating!private! !
viewModeNames!constants!public! !
viewModes!constants!public! !
!

