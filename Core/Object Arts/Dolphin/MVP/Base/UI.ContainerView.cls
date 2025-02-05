﻿"Filed out from Dolphin Smalltalk"!

UI.View
	subclass: #'UI.ContainerView'
	instanceVariableNames: 'layoutManager names insets'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

UI.ContainerView guid: (Core.GUID fromString: '{87b4c70c-026e-11d3-9fd7-00a0cc3e4a32}')!

UI.ContainerView comment: 'ContainerView is an abstract class which implements the <compositeView> protocol for its subclasses. This protocol allows for <compositeView>s to contain sub-views which may be managed by the container.

Instance Variables:
	layoutManager		<layoutManager> responsible for the geometry of any sub-views.
	names				<IdentityDictionary> mapping the names of sub-views to the instances.
	insets				<Rectangle> or nil. Insets for the receiver''s sub-views (i.e. the margin sizes).



'!

!UI.ContainerView categoriesForClass!MVP-Resources-Containers!MVP-Views! !

!UI.ContainerView methodsFor!

actualInsets: aLayoutContext 
	"Private - Answer a <Rectangle> whose edges specify the actual inset (in pixels) by which
	the sub views are positioned away from the bordered of the receiver. This rectangle is
	computed from the configured insets (#inset aspect) and any implicit insets managed by the
	receiver"

	^self insets translateBy: (self implicitInsets: aLayoutContext)!

actualPreferredExtent: aLayoutContext 
	"Private - Answer the preferred extent of the receiver given the suggested extent specifed
	by the <Point> argument. A preferred extent can be forced by setting the #preferredExtent
	aspect otherwise we see if one can be offered by any installed layout manager (which allows
	the container to resize to fit its children), and failing that try calculating an extent."

	^self preferredExtent 
		ifNil: 
			[self layoutManager 
				ifNotNil: 
					[:manager | 
					self calcExtentFromClientExtent: (manager preferredLayoutExtentOf: self context: aLayoutContext)]
				ifNil: [self calculateExtent: aLayoutContext]]!

addSubView: aView name: aNameString
	"Adds aView to the receiver's collection of managed sub-views and
	gives it aNameString. Answers aView"

	self name: (self addSubView: aView) as: aNameString.
	^aView!

adjustPlacementOfShell: aShellView forResolution: aPoint
	"Private - The <ShellView> first argument is being restored from an STBViewProxy (e.g. instantiated from a view resource) as a child of this container (i.e. the shell will not be a top-level view). Adjust the placement of the window to an appropriate position and/or extent, also scaling any internal measurements to the target monitor's DPI from the original resolution specified by the <point> last argument."

	| scale |
	scale := self dpi / aPoint.
	scale = 1 ifFalse: [aShellView resolutionScaledBy: scale].
	aShellView isInitiallyCentered
		ifTrue: [aShellView rectangle: (self centerExtent: aShellView extent)]!

arrangementOf: aView 
	"Answer the arrangement parameter for aView in the receiver's 
	layout manager. If no parameter has been explicitly set, or if the
	receiver has no layout manager then answer nil"

	^self layoutManager ifNotNil: [:manager | manager arrangementOf: aView]!

arrangementOf: aView put: anObject 
	"Set the arrangement parameter for aView in the receiver  
	layout manager to be anObject. If the parent has no layout manager 
	then a walkback will result"

	self layoutManager isNil ifTrue: [^self].
	self layoutManager arrangementOf: aView put: anObject.
	self invalidateLayout!

canAcceptSubViews
	"Answer true if the receiver can accept aView sub viewss"

	^true!

createShellWindow: aShellView withFunction: aCreateWindow
	| extent targetDpi |
	targetDpi := self dpi.
	extent := aCreateWindow hasDefaultExtent
				ifTrue: [self defaultExtentOf: aShellView]
				ifFalse: [aCreateWindow extent * targetDpi // aCreateWindow dpi].
	aCreateWindow
		position: (aShellView isInitiallyCentered ifTrue: [self centerExtent: extent] ifFalse: [Point.Zero])
		extent: extent
		dpi: targetDpi.
	aShellView
		dpi: targetDpi;
		basicCreateWindow: aCreateWindow!

defaultButtonId
	^0!

defaultExtent
	"Private - Answer the default size of the receiver in device-independent pixels (96-dpi DIPs). This is used only to determine the size of a view when it is created (although after scaling DIPs to the monitor DPI). Thereafter #preferredExtent is used when the desired size of a view is requested."

	^##(350 @ 250)!

defaultExtentOf: aShellView 
	"Answer the extent to use as the default for a shell that will be created within the
	receiver."

	^self extent // 1.1!

defaultLayoutManager
	"Private - Answer a default LayoutManager to use."

	^nil!

defaultWindowExStyle
	"Private - Answer the default extended window creation style.
	We use the WS_EX_CONTROLPARENT style for ContainerViews, otherwise tabs only
	work between siblings in a single level."

	^super defaultWindowExStyle bitOr: WS_EX_CONTROLPARENT!

errorDuplicateName: aString 
	"Report that aString is already in use as the name of a sub-view of the receiver."

	^self error: 'duplicate name: ' , aString!

filerProxyIn: anSTxOutFiler
	"Private - Answer a filer proxy that represents the receiver for use with the <STxOutFiler> argument."

	(anSTxOutFiler isStable and: [names notEmpty])
		ifTrue: 
			["We override the names lookup table with a proxy in order that we can sort by the names to get a stable order."
			anSTxOutFiler override: names
				with: (STBIdentityDictionaryProxy class: names class
						associations: (names associations asSortedArray: [:a :b | a value <= b value]))].
	^super filerProxyIn: anSTxOutFiler!

implicitInsets: aLayoutContext
	"Private - Answer a <Rectangle> whose edges specify the implicit distance (in pixels) by
	which the sub views have to be inset from the border of the receiver. This method should be
	overridden by subclasses where the container cannot allow the sub views access to the entire
	client area."

	^Rectangle.Empty!

initialize
	"Private - Initialize the receiver"

	super initialize.
	names := IdentityDictionary new.
	self layoutManager: self defaultLayoutManager!

insets
	"Answer the <Rectangle> whose edges specify the distance (in pixels) by which the sub views
	are inset from the border of the receiver."

	^insets ifNil: [Rectangle new]!

insets: aRectangleOrPointOrNil
	"Set the <Rectangle> whose edges specify the distance (in pixels) by which the sub views are
	inset from the border of the receiver."

	| newInsets |
	newInsets := (aRectangleOrPointOrNil isKindOf: Number)
				ifTrue: [aRectangleOrPointOrNil asPoint corner: aRectangleOrPointOrNil asPoint]
				ifFalse: 
					[(aRectangleOrPointOrNil isKindOf: Point)
						ifTrue: [aRectangleOrPointOrNil corner: aRectangleOrPointOrNil]
						ifFalse: [aRectangleOrPointOrNil]].
	newInsets = Rectangle.Empty ifTrue: [newInsets := nil].
	newInsets = insets ifTrue: [^self].
	insets := newInsets.
	self invalidateLayout!

isControlParent
	"Answer whether the receiver can contain controls which may be tabbed to."

	^self extendedStyle allMask: WS_EX_CONTROLPARENT!

isControlParent: aBoolean 
	"Set whether the receiver can contain controls which may be tabbed to."

	"N.B. Do not disable this for containers that contain controls, otherwise you may find that
	Windows goes into an infinite loop in IsDialogMessage()."

	^self exStyleMask: WS_EX_CONTROLPARENT set: aBoolean!

layout: aLayoutContext 
	"Private - Recalculate the geometry of the receiver"

	#todo.	"If using calculated extent (usePreferredExtent = true & preferredExtent = nil),
		then ask the layout manager for the layoutExtent: of the container (i.e. the extent
		required to contain the child views at their preferred extents. In order to support
		this change we must convert existing shell views which use the above logic test to
		determine whether or not to let Windows provide the shell's initial size."
	self layoutManager ifNotNil: [:manager | manager layoutContainer: self context: aLayoutContext].!

layoutManager
	"Answer the receiver's <LayoutManager>."

	^layoutManager!

layoutManager: aLayoutManager 
	"Set the receiver's <LayoutManager>. The layout manager is responsible for controlling the
	position and extent of the receiver's sub-views."

	layoutManager := aLayoutManager.
	self basicInvalidateLayout!

name: aView as: aNameStringOrNil
	"Sets the name of aView within the receiver to be aNameStringOrNil"

	| exists |
	"Redirect name request to the immediate parent of aView
	if we are not that parent"
	aView parentView == self ifFalse: [^aView parentView name: aView as: aNameStringOrNil].

	"Check that aView is one of our sub-views"
	"self assert: [self subViews includes: aView]."
	(aNameStringOrNil isNil or: [aNameStringOrNil isEmpty])
		ifTrue: 
			["Request to remove name for aView"
			^names removeKey: aView ifAbsent: nil].

	"Check that the operation isn't null"
	aView name = aNameStringOrNil ifTrue: [^self].

	"Otherwise name is specified so check that it is unique"
	exists := names detect: [:each | each = aNameStringOrNil] ifNone: nil.
	(exists isNil or: [exists == self])
		ifTrue: [names at: aView put: aNameStringOrNil]
		ifFalse: [self errorDuplicateName: aNameStringOrNil]!

nameOf: aView
	"Answer the name of aView within the receiver or nil
	if it has not been assigned a name"

	"Redirect request to the immediate parent of aView
	if we are not that parent"

	aView parentView == self ifFalse: [^aView parentView nameOf: aView].
	^names lookup: aView!

onSubViewAdded: aView
	"Received when aView has been added to the receiver.
	Can be overridden by subclasses to perform necessary housekeeping regarding the
	new contents of the receiver"

	super onSubViewAdded: aView.
	self invalidateLayout

	!

onSubViewRemoved: aView
	"Private - Received when aView has been removed from the receiver.
	Can be overridden by subclasses to perform necessary housekeeping regarding the
	new contents of the receiver"

	self invalidateLayout.
	super onSubViewRemoved: aView.!

onZOrderChanged
	"Received when the Zorder of the subviews within the receiver has been
	directly changed. Can be overridden by subclasses to perform necessary 
	housekeeping regarding the new Zorder."

	self invalidateLayout.
	super onZOrderChanged!

removeSubView: aView
	"Removes aView as a managed subview of the receiver. 
	If aView is indeed a subview of the receiver then it is destroyed. If not,
	it continues to live."

	super removeSubView: aView.
	self hasLayoutManager ifTrue: [self layoutManager removeSubView: aView].
	names removeKey: aView ifAbsent: nil.
	^aView!

resolutionScaledBy: aPoint
	"Private - The receiver is being loaded and it has been determined that the pixel resolution has changed since the point at which the view was saved. Scale any internal pixels by the <Point> argument."

	super resolutionScaledBy: aPoint.
	self layoutManager ifNotNil: [:lm | lm resolutionScaledBy: aPoint].
	insets
		ifNotNil: [insets := (insets origin * aPoint) truncated corner: (insets corner * aPoint) truncated]!

tabFirst
	"Set focus to the first subview with a tab stop (if any). Answers the view tabbed
	to or nil"

	| firstTabView |
	firstTabView := self tabNextSiblingFrom: nil forward: true.
	firstTabView notNil ifTrue: [ firstTabView tabFocus ].
	^firstTabView!

validateSubViewLayouts: aLayoutContext 
	"Private - Validate the layout of the visible sub-views of the receiver."

	self managedSubViewsDo: [:each | each validateLayout: aLayoutContext]!

validateUserInterface
	"Validates the user interface for the receiver. Usually performed at idle time
	when the  UI has been flagged as being invalid"

	self subViewsDo: [:each | each presenter validateUserInterface].
	super validateUserInterface.!

viewNamed: aString ifNone: aNiladicValuable
	"Answer the sub-view within the receiver's hierarchy with aString as its name. Evaluates the <niladicValuable>, aNiladicValuable, if no matching named view exists."

	^(names keyAtEqualValue: aString ifAbsent: nil)
		ifNil: 
			[(self subViewsFind: [:each | each isManaged ifTrue: [each viewNamed: aString ifNone: nil]])
				ifNil: [aNiladicValuable value]]! !

!UI.ContainerView categoriesForMethods!
actualInsets:!accessing!private! !
actualPreferredExtent:!geometry!private! !
addSubView:name:!hierarchy!public!sub views! !
adjustPlacementOfShell:forResolution:!geometry!private! !
arrangementOf:!accessing!public! !
arrangementOf:put:!accessing!public! !
canAcceptSubViews!hierarchy!public!sub views! !
createShellWindow:withFunction:!operations!public! !
defaultButtonId!accessing!default button!private! !
defaultExtent!constants!private! !
defaultExtentOf:!geometry!public! !
defaultLayoutManager!constants!private! !
defaultWindowExStyle!constants!private! !
errorDuplicateName:!exceptions!public! !
filerProxyIn:!binary filing!private! !
implicitInsets:!accessing!private! !
initialize!initializing!private! !
insets!accessing!public! !
insets:!accessing!public! !
isControlParent!accessing-styles!public! !
isControlParent:!accessing-styles!public! !
layout:!geometry!private! !
layoutManager!geometry!public! !
layoutManager:!geometry!public! !
name:as:!hierarchy!public!sub views! !
nameOf:!hierarchy!public!sub views! !
onSubViewAdded:!event handling!public! !
onSubViewRemoved:!event handling!private! !
onZOrderChanged!event handling!public! !
removeSubView:!hierarchy!public!sub views! !
resolutionScaledBy:!geometry!private! !
tabFirst!public!tabbing! !
validateSubViewLayouts:!geometry!private! !
validateUserInterface!operations!public! !
viewNamed:ifNone:!hierarchy!public!sub views! !
!

UI.ContainerView methodProtocol: #compositeView attributes: #(#readOnly) selectors: #(#addSubView: #allParents #allSubViews #arrangement #arrangement: #backcolor #backcolor: #canAcceptSubViews #canvas #clientExtent #clientHeight #clientRectangle #clientWidth #close #contextMenu #contextMenu: #cursor #cursorPosition #destroy #disable #disableRedraw #enable #enableRedraw #ensureLayoutValid #ensureRectangleVisible: #ensureSubView:rectangleVisible: #ensureSubViewVisible: #ensureVisible #extent #extent: #firstSubView #font #font: #forecolor #forecolor: #hasBorder #hasBorder: #hasClientEdge #hasClientEdge: #hasFocus #hasLayoutManager #hasStaticEdge #hasStaticEdge: #hasVisibleStyle #hasVisibleStyle: #height #height: #hide #invalidate #invalidateCalculatedExtent #invalidateLayout #invalidateRect: #invalidateRect:erase: #invalidateRgn: #invalidateUserInterface #isEnabled: #isGroupStop #isGroupStop: #isLayoutValid #isManaged #isManaged: #isTabStop #isTabStop: #isTopView #isTransparent #isTransparent: #isWindowVisible #layout #layoutExtent: #layoutManager #layoutManager: #managedSubViews #mapPoint:to: #mapRectangle:to: #model #model: #name #name: #nameOf: #needsValidateLayout #nextSiblingView #nonClientCanvas #onAboutToCreate #onBegin:drag: #onCommand: #onCreated: #onDestroyed #onEraseRequired: #onHScroll: #onModelChanged #onPaintRequired: #onSubViewAdded: #onSubViewRemoved: #onViewCreated #onVScroll: #onZOrderChanged #parentView #placement #placement: #plainText #position #position: #preferredExtent #preferredExtent: #presenter #presenter: #presenterConnectionPoint #preTranslateKeyboardInput: #preTranslateMessage: #preTranslateMouseInput: #previousSiblingView #queryContextMenu #recreate #rectangle #rectangle: #refreshContents #removeSubView: #resolution #screenRectangle #screenRectangle: #scrollBy:clip: #scrollBy:scroll:clip: #setCapture #styles #subViewFromPoint: #subViewFromPoint:flags: #subViews #tabFirst #tabNext #text #text: #topView #update #updateModel #usePreferredExtent #usePreferredExtent: #validate #validateLayout #validateRect: #validateUserInterface #viewNamed: #viewNamed:ifNone: #width #width: #withAllParents #withAllSubViews #x #x: #y #y: #zOrderAfter: #zOrderAfter:withFlags: #zOrderBottom #zOrderTop)!

!UI.ContainerView class methodsFor!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ContainerView} 38 #{Core.Array} 15 nil nil 50 2 8 1140850688 131073 32 nil nil nil 5 nil nil nil 32 nil 550 #{Core.IdentityDictionary} 0 nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[255 14 0 0 10 0 0 0 93 16 0 0 4 1 0 0] 193 80 8 '' 32 3 8 #() 518 #{Graphics.Point} 193 193 nil 27)! !

!UI.ContainerView class categoriesForMethods!
icon!constants!public! !
resource_Default_view!public!resources-views! !
!

