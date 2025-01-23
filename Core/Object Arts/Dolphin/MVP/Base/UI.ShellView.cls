"Filed out from Dolphin Smalltalk"!

UI.ContainerView
	subclass: #'UI.ShellView'
	instanceVariableNames: 'menuBar acceleratorTable combinedAcceleratorTable lastFocus defaultButton largeIcon smallIcon maxExtent minExtent actualIcons svFlags dpi'
	classVariableNames: 'DialogMessageMap'
	imports: #(#{OS.ButtonConstants})
	classInstanceVariableNames: ''
	classConstants: { 'DefaultButtonIndex' -> 16r14. 'TransientMask' -> 16r1 }!

UI.ShellView guid: (Core.GUID fromString: '{87b4c71a-026e-11d3-9fd7-00a0cc3e4a32}')!

UI.ShellView comment: '`ShellView` implements the `<topView>` protocol for top-level windows whose parent is the desktop. `ShellView` is also a `<topPresenter>` so that it is able to stand in as a `Shell` when there is no associated presenter.

Instance Variables:
  menuBar					`MenuBar` or `nil`, that is the menu bar for the window.
  acceleratorTable			`AcceleratorTable` or `nil` that is the local accelerator table.
  combinedAcceleratorTable	`AcceleratorTable` that is the cached actual accelerator table.
  lastFocus					`<view>` or `nil`, which is the last view within the local hierarchy to have focus.
  defaultButton				`PushButton` or `nil`, which is the default button within the window
  largeIcon				`Icon` or `nil`, which is a specific large icon to use.
  smallIcon				`Icon` or `nil`, which is a specific small icon to use.
  maxExtent				`Point` or `nil`, specifying the maximum extent when resizing.
  minExtent				`Point or `nil`, specifying the minimum extent when resizing.
  flashes					`<integer>`. Temporary used to count down the number of flashes.
  svFlags					`<integer>`. Various flags

Class Variables:
	DialogMessageMap		`LookupTable` of Windows messages to `<selector>`s
	TransientMask			`<integer>` 
	CreateHookBlock		`nil` or `<dyadicValuable>`
	DefaultButtonIndex		`<integer>`
	DefaultExtentBlock		`<BlockClosure>`



'!

!UI.ShellView categoriesForClass!MVP-Views! !

!UI.ShellView methodsFor!

acceleratorTable
	"Answer the AcceleratorTable if any defined by user."

	^acceleratorTable!

acceleratorTable: accelerators
	"Set the receiver's accelerator table inst var."

	acceleratorTable := accelerators.
	self releaseAccelerators
!

activateLastPopup
	| popup |
	popup := self getLastActivePopup.
	^popup notNil and: 
			[popup isForeground not 
				and: [popup isEnabled and: 
							[popup beForeground.
							true]]]!

addCommandHistory: aCommand
	"Private - Provided for protocol compatiblity with Shell presenters.
	ShellViews do not support command history so do nothing."!

allAdditionalAccelerators
	^#()!

allAdditionalKeyBindings
	^#()!

basicMenu: aMenuBarOrNil
	"Private - Set the menu bar for this window to aMenuBarOrNil."

	User32 setMenu: handle hMenu: aMenuBarOrNil asParameter!

buildCombinedAcceleratorTable
	combinedAcceleratorTable := acceleratorTable
				ifNil: [AcceleratorTable new]
				ifNotNil: [acceleratorTable copy].
	menuBar ifNotNil: [menuBar registerAcceleratorKeyIn: combinedAcceleratorTable].
	self presenter allAdditionalKeyBindings
		do: [:each | each registerAcceleratorKeyIn: combinedAcceleratorTable]!

buttonRemoved: aPushButton
	"Private - Informs the receiver that aPushButton has been removed from the child hierachy.
	We check to see if this was cached as the default button and clear this if necessary"

	self defaultButtonId = aPushButton id ifTrue: [self resetDefaultButton]!

caption
	"Answers the caption for the receiver"

	^self text!

caption: aString
	"Set the caption for the receiver. Usually sent by a Presenter
	that wishes to display a caption in it's associated view"

	self text: aString.
	self trigger: #captionChanged!

centerNear: aPoint atDpi: anInteger
	"Private - Centre the receiver's client area over the specified screen co-ordinate as nearly as possible without causing the receiver to be off-screen or overlap monitors. If it is not possible to achieve this, perhaps because the receiver is too large for the display, favour keeping the receiver's top-left corner visible."

	| extent |
	extent := self clientExtent * anInteger // self dpi.
	self
		positionNear: (self calcRectangleFromClientRectangle: (aPoint - (extent // 2) extent: extent)
				atDpi: anInteger) origin!

close
	"Asks the receiver to close itself, answering whether it is closed."

	self sendMessage: WM_CLOSE wParam: 0 lParam: 0.
	^self isOpen not!

combinedAcceleratorTable
	"Private - Answer the <AcceleratorTable> which combines the user set acceleratorTable and
	those accelerator keys registered in the current menu bar. This is the table sent to
	windows."

	^combinedAcceleratorTable
		ifNil: 
			[
			self buildCombinedAcceleratorTable.
			combinedAcceleratorTable]!

commandPolicyClass
	"Answers the class of <commandPolicy> to use for routing commands originating
	in the receiver or one of its sub-presenters."

	^CommandPolicy defaultClass!

commandPolicyWithSource: sourceView
	"Answers a <CommandPolicy> object for routing commands originating
	from the <View>, source. 
	This can be overridden by subclasses which wish to use a different routing policy, 
	although to substitute a specialized <commandPolicy> one should override 
	#commandPolicyClass."

	^self commandPolicyClass
		commandSource: sourceView!

commandSource
	"Answer the <View> starting point for command routing if a UI
	command  is received by the receiver. ShellViews will typically only receive
	command from the menubar or toolbar, and these should be routed as if sourced
	from the <View> with focus, or the receiver if no sub-view has the focus."

	| shell source |
	shell := self topShell view.
	source := shell isForeground 
			ifTrue: [self class focus]
			ifFalse: [shell lastFocus].
	source isNil ifTrue: [source := self].
	^source!

createWindow: aCreateWindow
	"Private - Create the View window ensuring it has the VM window procedure. Answer the receiver."

	"For shells we delegate to the parent (usually, but not always, the desktop), as it may want to adjust placement, styles, etc. We also have to clear any cached DPI as if being recreated, e.g. on restoring a saved image, the DPI may have changed."

	creationParent createShellWindow: self withFunction: aCreateWindow!

defaultButtonId
	"Private - Answer the id of the default PushButton for the receiver or nil
	if there is none"

	^defaultButton!

defaultButtonId: anInteger
	"Private - Set the default PushButton for the receiver from the id.
	Implementation Note: #getItem:ifAbsent: would return a View whether one 
	is registered or not, but it may not be of the correct PushButton class."

	(defaultButton := anInteger) isNull ifTrue: [
		"Windows confusingly attempts to maintain a default default button 
		in dialogs if none is set (IDOK), so do the same."
		self resetDefaultButton]!

defaultExtent
	"Private - Answer the default size of the receiver in device-independent pixels (aka DIPs, i.e. 96-dpi). This is used only to determine the size of a view when it is first created (although after scaling DIPs to the monitor DPI). Thereafter preferredExtent is used when the desired size of a view is requested."

	^CreateWindow.UseDefaultGeometry!

defaultPosition
	"Private - Answer the default position for the receiver in device-independent pixels (aka DIPs, i.e. 96-dpi). Normally this is unspecified, so we want to open the new window at the next cascade position for the monitor."

	^CreateWindow.UseDefaultGeometry!

defaultShowStyle
	^self isMaximized ifTrue: [SW_SHOWMAXIMIZED] ifFalse: [SW_SHOWNORMAL]!

defaultWindowStyle
	"Private - Answer the default basic window creation style"

	^##(WS_THICKFRAME | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)!

dialogMessageMap
	^##(IdentityDictionary withAll: {
				DM_GETDEFID - WM_USER -> #dmGetDefId:wParam:lParam:.
				DM_SETDEFID - WM_USER -> #dmSetDefId:wParam:lParam: 
			})!

dispatchUser: userId wParam: wParam lParam: lParam
	"Private - Dispatch the WM_USER+userId message which was sent to the receiver.
	To be overridden by subclasses which implement WM_USER+N messages in an appropriate 
	manner (e.g. by a secondary message map, or, if few in number, by conditional tests)"

	^self
		dispatchUser: userId
		wParam: wParam
		lParam: lParam
		map: self dialogMessageMap!

displayOnMonitor: aMonitor
	"Move the receiver so it is displayed on the specified `DisplayMonitor`, but attempting to maintain the same position relative to the display origin.
	This can be used, for example, to position a dialog on the same monitor as its owner."

	| currentMonitor |
	currentMonitor := self monitor.
	currentMonitor = aMonitor
		ifFalse: [self positionNear: aMonitor origin + (self position - currentMonitor origin)]!

dmGetDefId: message wParam: wParam lParam: lParam
	"Private - Default handler for a DM_GETDEFID message sent to request the id of any default
	push button in the receiver.
	Implementation Note: As we are trying to simulate the useful keyboard interface behaviour
	of Dialogs in normal shells, we must implement this message for the benefit of IsDialogMessage()."

	| buttonId |
	buttonId := self defaultButtonId.
	^buttonId notNull ifTrue: [(DC_HASDEFID bitShift: 16) bitOr: buttonId] ifFalse: [0]!

dmSetDefId: message wParam: wParam lParam: lParam 
	"Private - Default handler for a DM_SETDEFID message sent to request that the id of any default
	push button be changed in the receiver.
	Implementation Note: As we are trying to simulate the useful keyboard interface behaviour
	of Dialogs in normal shells, we must implement this message for the benefit of IsDialogMessage().
	Note also that we expect to execute the default processing too (which is essential for dialogs)."

	| def |
	def := self defaultButtonId.
	def isNull ifFalse: [self setButtonId: def style: BS_PUSHBUTTON].
	self defaultButtonId: wParam.
	"We must set the cached default button before sending #beDefaultButtonStyle as
	that would otherwise cause a recursive invocation of this method."
	def := self defaultButtonId.
	def isNull ifFalse: [self setButtonId: def style: BS_DEFPUSHBUTTON].
	^0!

dpi
	"Answer the logical pixels per inch for the receiver; i.e. the screen's logical pixels per inch"

	^dpi ifNil: [dpi := super dpi]!

dpi: anInteger
	dpi := anInteger!

drawMenuBar
	"Draw the receiver's menu bar, either when initially set or after it has been updated.
	Answer whether the request succeeded."

	^User32 drawMenuBar: handle!

ensureLayoutValid
	"If the receiver's layout is invalid, then validate the layout from this point. Answer whether any layout was performed."

	self isLayoutValid ifTrue: [^false].
	self validateLayout.
	^true!

ensureSubViewVisible: aSubView 
	"Terminate the recursion as making a sub-view visible should not change the z-order of the Windows on the desktop (or indeed in an idea space).
	Sending #ensureVisible to a ShellView that is a direct child of the desktop will bring it to the top of the z-order, however sending #ensureVisible to one of its direct or indirect children will not."
	!

exit
	"Asks the receiver to close itself, answering whether it is closed."

	^self close
!

filerProxyIn: anSTxOutFiler
	| proxy |
	proxy := super filerProxyIn: anSTxOutFiler.
	proxy instVars
		at: ##(self indexOfInstVar: 'lastFocus') put: nil;
		at: ##(self indexOfInstVar: 'combinedAcceleratorTable') put: nil;
		at: ##(self indexOfInstVar: 'defaultButton') put: 0;
		at: ##(self indexOfInstVar: 'actualIcons') put: nil.
	^proxy!

flash: anInteger
	"Flash the receiver in a manner so as to attract the user's attention, anInteger times."

	self flash: anInteger flags: FLASHW_ALL!

flash: flashCountInteger flags: flagsInteger
	"Flash the receiver the number of times specified by the <integer> argument, flashCountInteger,
	configured by the FLASHWINFO flags in the <integer>, flagsInteger.
	Answer a <boolean> indicating whether the window caption was drawn as active before the call."

	| params |
	params := FLASHWINFO new.
	params
		hwnd: handle;
		uCount: flashCountInteger;
		dwFlags: flagsInteger.
	^(User32 flashWindowEx: params) ~= 0!

getDefId
	"Private - Answer the ID of any default push button in the receiver, or 0 if none."

	| lresult |
	lresult := self sendMessage: DM_GETDEFID.
	^lresult highWord = DC_HASDEFID
		ifTrue: [lresult lowWord]
		ifFalse: [0]!

getDpi
	"Private - Answer the logical dots-per-inch for this Window."

	^User32 getDpiForWindow: handle!

getLastActivePopup
	"Private - Answers the last popup window that had activation, or nil if there is no popup."

	^self getLastActivePopupHandle ifNotNil: [:hWnd | View fromHandle: hWnd]!

getLastActivePopupHandle
	"Private - Answers the last popup window that had activation, or nil
	if there is no popup."

	| hWnd |
	hWnd := User32 getLastActivePopup: handle.
	^hWnd ~= handle ifTrue: [hWnd]!

hasCaption
	"Answers true if the receiver has a caption bar. i.e. it has the WS_CAPTION style"

	^self baseStyleAllMask: WS_CAPTION!

hasCaption: aBoolean 
	"Sets the receiver to have a caption bar if aBoolean is true. This is the WS_CAPTION style.
	Note that removing the caption will also remove the window frame entirely if #isResizable is
	false."

	(self 
		baseStyleMask: WS_CAPTION
		set: aBoolean
		recreateIfChanged: false) ifTrue: [self frameChanged]!

hasDarkWindowFrame
	^Dwmapi hasDarkWindowFrame: self!

hasDarkWindowFrame: aBoolean
	Dwmapi hasDarkWindowFrame: self set: aBoolean!

hasMaximize
	"Answers true if the receiver has a maximize button. i.e. it has the WS_MAXIMIZEBOX style"

	^self baseStyleAllMask: WS_MAXIMIZEBOX!

hasMaximize: aBoolean 
	"Sets the receiver to have a maximize box if aBoolean is true. This is the WS_MAXIMIZEBOX
	style. Note than on a themed XP system the button is not added/removed, just
	enabled/disabled."

	(self 
		baseStyleMask: WS_MAXIMIZEBOX
		set: aBoolean
		recreateIfChanged: false) ifTrue: [self frameChanged]!

hasMenu
	"Private - Answer true if the receiver has a visible menu bar."

	^self isTopView and: [self menuBar notNil]!

hasMinimize
	"Answers true if the receiver has a minimize button. i.e. it has the WS_MINIMIZEBOX style"

	^self baseStyleAllMask: WS_MINIMIZEBOX!

hasMinimize: aBoolean 
	"Sets the receiver to have a minimize box if aBoolean is true. This is the WS_MINIMIZEBOX
	style. Note than on a themed XP system the button is not added/removed, just
	enabled/disabled."

	(self 
		baseStyleMask: WS_MINIMIZEBOX
		set: aBoolean
		recreateIfChanged: false) ifTrue: [self frameChanged]!

hasSysMenu
	"Answers true if the receiver has a system menu, i.e. it has the WS_SYSMENU style"

	^self baseStyleAllMask: WS_SYSMENU!

hasSysMenu: aBoolean 
	"Sets the receiver to have a system menu if aBoolean is true. This is the WS_SYSMENU style.
	Note than removing the system menu also removes the minimize/maximize and close buttons."

	(self 
		baseStyleMask: WS_SYSMENU
		set: aBoolean
		recreateIfChanged: false) ifTrue: [self frameChanged]!

hasTaskbarIcon
	^self extendedStyle noMask: WS_EX_NOACTIVATE!

hasTaskbarIcon: aBoolean 
	"Set whether or not the receiver is activated and appears in the task bar on creation (i.e. it 
	set/remove the WS_EX_NOACTIVATE style)."

	self exStyleMask: WS_EX_NOACTIVATE set: aBoolean not!

hasVisibleStyle: aBoolean 
	"Set or clear the receiever's WS_VISIBLE style flag.
	Answer whether the receiver's window was previously visible."

	^self showWithStyle: (aBoolean ifTrue: [SW_SHOWNA] ifFalse: [SW_HIDE])!

initialize
	"Private - Initialise the receiver. Register with SessionManager events."

	super initialize. 
	self parentView: self class desktop!

invalidateUserInterface
	"Invalidates the user interface of the receiver indicating that it needs
	to be requeried using #validateUserInterface (usually at idle time)"

	flags := flags bitAnd: ##(UIValidMask bitInvert).
	SessionManager.Current inputState prod!

isInitiallyCentered
	"Private - Answer whether the receiver should be centered within its parent when created."

	^flags anyMask: CreateCenteredMask!

isInitiallyCentered: aBoolean
	"Set or reset whether the receiver will be centered within its parent on creation."

	flags := flags mask: CreateCenteredMask set: aBoolean!

isLayeredWindow
	"Answers true if the receiver is a layered window. 
	i.e. it has the WS_EX_LAYERED style"

	^self extendedStyle allMask: WS_EX_LAYERED!

isLayeredWindow: aBoolean 
	"Sets the receiver to be a tool window if aBoolean is true.
	This is the WS_EX_LAYERED style"

	self 
		exStyleMask: WS_EX_LAYERED
		set: aBoolean
		recreateIfChanged: false!

isMaximized
	"Answer whether the receiver is currently maximized."

	^User32 isZoomed: handle!

isMinimized
	"Answer whether the receiver is currently minimized."

	^flags anyMask: MinimizedMask!

isMinimized: aBoolean
	"Private - Set or reset the receiver's isMinimized flag"

	flags := flags mask: MinimizedMask set: aBoolean!

isPersistentlyDisabled
	"Private - Answer whether the receiver is disabled in a way that should be persisted.
	So, for example, if the receiver has been disabled by a non-Dolphin dialog window
	that cannot itself be persisted, it does not make sense to persist the disabled state either.
	Implementation Note: In the case of ShellView's, they are considered persistently
	disabled iff disabled by a popup which is itself persistent."

	^self isEnabled not and: 
			[| popup |
			(popup := self getLastActivePopup) notNil and: [popup isPersistentView]]!

isPersistentView
	"Answer whether the receiver has persistent state which can and should
	be persistent in the image (i.e. top-level windows which answer true
	to this will be sent #state and #state: messages by the 
	SessionManager before the image is saved, and on session startup, respectively)."

	^self isDolphinWindow and: [self svFlags noMask: TransientMask]!

isPersistentView: aBoolean 
	"Set whether the receiver has persistent state which can and should be persisted in the
	image. This is ignored for non-Dolphin windows, which are never persisted."

	svFlags := self svFlags mask: TransientMask set: aBoolean not!

isToolWindow
	"Answers true if the receiver is a tool window. A tool window has a title bar that is shorter than 
	a normal title bar, and the window title is drawn using a smaller font. 
	i.e. it has the WS_EX_TOOLWINDOW style"

	^self extendedStyle allMask: WS_EX_TOOLWINDOW!

isToolWindow: aBoolean 
	"Sets the receiver to be a tool window if aBoolean is true.
	This is the WS_EX_TOOLWINDOW style"

	(self 
		exStyleMask: WS_EX_TOOLWINDOW
		set: aBoolean
		recreateIfChanged: false) ifTrue: [self frameChanged]!

isUserInterfaceValid
	"Answer true if the user interface of the receiver is currently valid"

	^flags allMask: UIValidMask.!

keyboardCommands
	"Answer a collection of <CommandDescription>s for all the commands in the receiver and its
	subviews which have a keyboard binding."

	^self combinedAcceleratorTable ifNil: [super keyboardCommands] ifNotNil: [:accel | accel commands]!

largeIcon
	"Answer the receiver's large (and possibly small if there isn't one already) icon."

	^largeIcon!

largeIcon: anIcon
	"Set the receiver's large (and possibly small if there isn't one already) icon
	to anIcon."

	largeIcon := anIcon.
	self updateIcons!

lastFocus
	"Private - Answer the view that last had focus within the receiver"

	^lastFocus!

lastFocus: aView
	"Private - Remember that the view with focus is aView"

	lastFocus := aView!

maxExtent
	"Answers the maximum extent for the receiver at its current resolution (i.e. in device pixels) or nil if there is no constraint."

	^maxExtent!

maxExtent: aPointOrNil 
	"Set the maximum extent for the receiver at its current resolution to aPointOrNil. If nil	this implies no constraint"

	maxExtent := aPointOrNil.
	maxExtent isNil ifTrue: [^self].
	minExtent notNil ifTrue: [maxExtent := maxExtent max: minExtent].
	self extent: (maxExtent min: self extent)!

menuBar
	"Answers the menu bar for the receiver"

	^menuBar
!

menuBar: aMenuBarOrNil 
	"Set the menu bar for this window to aMenuBarOrNil"

	aMenuBarOrNil notNil 
		ifTrue: 
			[menuBar := aMenuBarOrNil.
			self updateMenuBar]
		ifFalse: 
			[self
				releaseMenu;
				releaseAccelerators.
			menuBar := nil].
	self invalidateLayout!

minExtent
	"Answers the minimum extent for the receiver at its current resolution (i.e. in device pixels) or nil if there is no constraint."

	^minExtent!

minExtent: aPointOrNil
	"Set the minimum extent for the receiver at its current resolution to aPointOrNil. If nil this implies no constraint"

	minExtent := aPointOrNil.
	maxExtent ifNil: [^self].
	minExtent ifNotNil: [minExtent := self maxExtent min: minExtent].
	self extent: (self maxExtent min: self extent)!

minimize
	"Show the receiver in a minimized state"

	self showWithStyle: SW_MINIMIZE!

onAboutToDisplaySystemMenu: hMenu
	"The system menu with <integer> handle, hMenu, is about to be displayed.
	This is our opportunity to update it, e.g. to add our own items.
	Note: A single system menu is shared across all ShellViews open in
	the application, and any changes made will therefore be inherited by
	all other shell's system menus."

"	| menu cmd |
	menu := Menu fromHandle: hMenu.
	cmd := CommandDescription command: #minimizeAll.
	cmd description: 'Minimize All'.
	menu addItem: (CommandMenuItem commandDescription: cmd)."
	self presenter trigger: #aboutToDisplaySystemMenu: with: hMenu.
	^0!

onCloseRequested
	"Answer whether if it is ok to close the receiver."

	"The default is to trigger an event off our presenter to enquire of its observers whether
	the close is permisible. Those observers which wish to block the close must set the value of
	the passed boolean <value> to false."

	self queryClose
		ifTrue: 
			[Processor isActiveMain ifTrue: [self destroy] ifFalse: [[self destroy] postToInputQueue].
			^true].
	^false!

onDpiChanged: aDpiChangedEvent
	| newDpi |
	newDpi := aDpiChangedEvent newDpi.
	self resolutionScaledBy: newDpi / self resolution.
	dpi := newDpi.
	self rectangle: aDpiChangedEvent proposedRect.
	"We must recreate the menubar to ensure it paints correctly at the new resolution"
	self recreateMenuBar.
	self presenter trigger: #dpiChanged: with: aDpiChangedEvent.
	"Docs state that 0 should be returned if handled. It is stated that there is no implementation in the DefWindowProc anyway, but there definitely is one in DefDlgProc, and we normally want to suppress that because our dialogs are normally built from an empty template and then populated."
	^0!

onDrawMenuItem: aDRAWITEMSTRUCT 
	| menu |
	(menuBar isNil or: [(menu := menuBar menuFromHandle: aDRAWITEMSTRUCT hwndItem) isNil]) 
		ifTrue: [^super onDrawMenuItem: aDRAWITEMSTRUCT].
	menu onDrawItem: aDRAWITEMSTRUCT.
	^TRUE!

onGetCursor: aSymbol
	"The named area of the window associated with the receiver has been hit.
	Answer the appropriate mouse cursor, or nil to accept the default."

	^aSymbol == #error
		ifTrue: 
			["Display the wait cursor, if no popup"
			(self getLastActivePopupHandle isNil and: [self isEnabled not]) ifTrue: [Cursor wait]]
		ifFalse: [super onGetCursor: aSymbol]!

onIdleEntered
	"There are no messages in the input queue and the input state is
	about to go idle. Perform any idle processing. Received only by top level
	windows"

	self isUserInterfaceValid ifFalse: [
		self presenter validateUserInterface ].
	^true!

onPositionChanged: aPositionEvent
	"Default handler for window position change (move or resize).
	Implementation Note: The superclass implementation considers that any
	position change invalidates the layout, but moving a top-level window
	does not, so we override to invalidate only on resize. This is also a suitable
	time to revalidate too."

	self isTopView ifFalse: 
			["May be embedded in some sort of MDI shell, e.g. the Idea Space. If so we do not want to perform the shell-level processing such as revalidating the layout."
			^super onPositionChanged: aPositionEvent].
	aPositionEvent isClientAreaChanged ifTrue: [self invalidateLayoutDeeply].
	(aPositionEvent isHideWindow not and: [self isWindowVisible])
		ifTrue: 
			["We can't rely on revalidating in paint, as repainting may not be needed when the shell is shrunk"
			self validateLayout].
	self presenter trigger: #positionChanged: with: aPositionEvent!

onSettingChanged: aSettingsChangeEvent
	SessionManager current onSettingChanged: aSettingsChangeEvent.
	self presenter trigger: #settingChanged: with: aSettingsChangeEvent.
	self settingChanged: aSettingsChangeEvent.
	^aSettingsChangeEvent lResult!

onStateRestored
	self isTopView ifFalse: [^self].
	menuBar ifNotNil: [self updateMenuBar].
	self setDefId: defaultButton.
	self invalidateUserInterface!

onSubViewRemoved: aView 
	(self lastFocus notNil and: [self lastFocus allParents includes: aView]) 
		ifTrue: [self lastFocus: self].
	super onSubViewRemoved: aView!

onTimeChanged: aWindowsEvent
	SessionManager current onTimeChanged: aWindowsEvent.
	self presenter trigger: #timeChanged: with: aWindowsEvent.
	^aWindowsEvent lResult!

onViewActivated: anEvent 
	"Default handler for window activation. Reset focus to the last view
	that had it within the receiver, unless that view has been closed, in which
	case focus is reset to its initial state in the receiver when newly opened.
	Implementation Note: We must maintain focus whenever activated, otherwise
	we may run into the Windows bug whereby a call to IsDialogMessage() goes
	into an infinite loop. We also need focus to keep keyboard menu shortcut keys
	operational."

	self isEnabled 
		ifTrue: 
			[| focus |
			((focus := self lastFocus) isNil or: [focus isOpen not]) 
				ifTrue: [self presenter setInitialFocus]
				ifFalse: [focus setFocus]].
	[self trigger: #viewActivated] postToMessageQueue.
	^0!

onViewCreated
	"The receiver has just been fully created. This is a suitable place to perform
	initialization of the window from the receiver's instance variables."

	self updateIcons!

onViewDeactivated: anEvent
	"Handler for de-activation. Remember the last focus within the receiver
	so that it can be restored on re-activation"

	| focus |
	focus := self class focusHandle.
	(focus notNil and: [User32 isChild: handle hWnd: focus])
		ifTrue: [self lastFocus: (View fromHandle: focus)].
	self trigger: #viewDeactivated.
	^0!

onViewMinimized: aSizeEvent
	"Default handler for window minimize. Trigger a #viewMinimized event off the presenter.
	Accept the default processing."

	self presenter trigger: #viewMinimized.
	^aSizeEvent defaultWindowProcessing!

onViewNcActivated: anEvent 
	"Default handler for window frame activation

	BE CAREFUL overriding this method. See comment in ShellView>>wmNcActivate:wparam:lParam:
	"

	^nil!

onViewNcDeactivated: anEvent 
	"Default handler for window frame deactivation.

	BE CAREFUL overriding this method. See comment in ShellView>>wmNcActivate:wparam:lParam:
	"

	^nil!

onViewRestored: aSizeEvent
	"Default handler for window restored. Trigger a #viewRestored event off the presenter.
	Accept the default processing."

	self presenter trigger: #viewRestored.
	^aSizeEvent defaultWindowProcessing!

parentView: aView
	"Private - Sets the parent of the receiver to aView. Can only be used when the receiver is not yet realized since Windows has a bug when reparenting"

	creationParent := aView.
	creationStyles at: 1
		put: (self baseStyle mask: WS_CHILD set: (aView isNil or: [aView isDesktop]) not)!

performCommand: aCommand
	"Perform the <Command> argument, assumed to have been initiated from the receiver or one of its sub-views, and answer the result. Can be overridden by subclasses that wish, for example, to add some generic undo/redo ability for all commands."

	"Note that the shell can be disabled for the duration of the command if the <Command> is marked as modal, which can be done statically by setting the #isModalCommand flag on the <CommandDescription>, or dynamically
	by setting the flag on the <CommandQuery>."

	^aCommand isModalCommand
		ifTrue: 
			[self disable.
			"In cases of mixed-mode DPI awareness the command may be initiated from a view that has a different DPI awareness to the receiver. To avoid propagating specialised DPI awareness modes from individual views, we must perform the command in our own DPI awareness context."
			[self inDpiAwarenessContextDo: [aCommand value]] ensure: [self enable]]
		ifFalse: [self inDpiAwarenessContextDo: [aCommand value]]!

positionNear: aPoint
	"Attempt to position the receiver at the origin, aPoint, in screen co-ordinates, but ensuring that the receiver's window will be entirely visible if possible, or if not so that at least the top-left corner is visible."

	self position: (creationParent
				mapScreenToClient: ((DisplayMonitor nearestPoint: aPoint) adjustPosition: aPoint
						forExtent: self extent))!

preTranslateKeyboardInput: aMSG 
	"Answer whether the receiver would like to consume the argument aMSG, which is a keyboard
	message."

	"Implementation Note: VK_ESCAPE is not passed to IsDialogMessage()) because this would be
	interpreted as a request to close the window, not desirable for normal shell views."

	^self isTopView and: 
			[(self translateAccelerator: aMSG) or: 
			["... and dialog messages excluding the ESCape key (which cancels dialogs)"
			| vKey |
			vKey := aMSG wParam.
			"Do not pass ESC as don't want shell to close"
			(vKey ~= VK_ESCAPE and: 
					["Do not pass VK_RETURN if no default button either"
					vKey ~= VK_RETURN or: [self defaultButtonId notNull]]) 
						and: [self isDialogMessage: aMSG]]]!

preTranslateMouseInput: aMSG
	"Answer whether the receiver would like to consume the argument aMSG."

	^(self isTopView and: [self isDialogMessage: aMSG]) or: [super preTranslateMouseInput: aMSG]!

queryClose
	"The view is about to be closed. Query whether this acceptable and answer true if it is, false if it is not"

	| okValue |
	okValue := self -> true.
	self presenter trigger: #closeRequested: with: okValue.
	^okValue value!

recreateMenuBar
	self menuBar
		ifNotNil: 
			[:menu |
			self releaseMenu.
			menuBar := menu.
			self updateMenuBar]!

recreationRectangle
	"Private - Answer a <rectangle> that specifies the position and extent at which the receiver should be recreated."

	"If the receiver is minimized, then its window rectangle will be positioned off screen and have the minimal extent of an old-style window tile (if you minimize a dialog and put the taskbar into auto-hide, you'll still see such a tile for the minimized dialog). Therefore we need to use the rectangle retrieved by GetWindowPlacement, adjusting it to account for any work area offset."

	| placement |
	placement := self placement.
	^placement rcNormalPosition translatedBy: self monitor workAreaOffset!

releaseAccelerators
	"Private - Unrealize self created accelerators."

	combinedAcceleratorTable free.
	combinedAcceleratorTable := nil!

releaseMenu
	"Private - Release the menu."

	menuBar
		ifNotNil: 
			[self basicMenu: nil.
			menuBar free]!

resetDefaultButton
	"Private - No default button has been explicitly specified for the receiver, so attempt
	to reproduce the Windows behaviour, which is to fall back on IDOK if there is such a button."

	defaultButton := IDOK.
	self findItemHandle: defaultButton ifAbsent: [defaultButton := 0]!

resolutionScaledBy: aPoint
	"Private - The receiver is being loaded and it has been determined that the pixel resolution has changed since the point at which the view was saved. Scale any internal pixels by the <Point> argument. "

	super resolutionScaledBy: aPoint.
	minExtent ifNotNil: [minExtent := (minExtent * aPoint) truncated].
	maxExtent ifNotNil: [maxExtent := (maxExtent * aPoint) truncated]!

restore: anInteger resolution: aPoint
	"Private - Restore the placement for the receiver to aWINDOWPLACEMENT which was measured at a screen resolution of aPointResolution. If the current resolution is different then the placement rectangle will have to be scaled appropriately. Note that this is only used when restoring from an STBViewProxy (i.e. reconstituting a view from binary-filed form), such as when creating a view instance from a view resource."

	creationParent adjustPlacementOfShell: self forResolution: aPoint.
	anInteger ifNotNil: [self basicShowWithStyle: anInteger]!

setButtonId: id style: style
	"Private - Set the style of the child of the receiver with <integer> identifier, id, to the 
	specified <integer> push button style (i.e. default or normal). Assumes that the controls
	with that id is actually a push button. If there is no such child, then ignored."

	| hWndButton |
	hWndButton := self findItemHandle: id ifAbsent: [^self].
	User32
		sendMessage: hWndButton
		msg: BM_SETSTYLE
		wParam: style
		lParam: 1	"force redraw"!

setDefaultButton: button state: setDefault 
	"Private - Set aPushButton as being the default button within the receiver according 
	to aBoolean.
	Implementation Note: In order to provide a suitable implementation of DM_GETDEFID even
	for non-dialog shells, we hang on to the default button id."

	| id isDefault |
	id := button id.

	"Workaround a Win16 bug whereby an untrappable GPF occurs in User.EXE if DM_SETDEFID is sent to the
	 default dialog proc. while the window is being restored, but presumably before it has reached some stable state."
	self isStateRestoring 
		ifTrue: 
			[defaultButton := setDefault ifTrue: [id] ifFalse: [0].
			^self].
	isDefault := id = self getDefId.
	setDefault 
		ifTrue: 
			["We MUST not send #setDefId: if already the default, as infinite recursion may result."
			isDefault ifFalse: [self setDefId: id]]
		ifFalse: [isDefault ifTrue: [self setDefId: 0]]!

setDefId: anInteger
	"Private - Set the ID of any default push button in the receiver, or 0 if none."

	^self sendMessage: DM_SETDEFID wParam: anInteger!

setInitialFocus
	"Set the initial keyboard focus to the first view in the tab sequence.
	Can be overidden by subclasses that find this behaviour 
	does not meed their needs.
	Received when the receiver's view is first opened if it is its own presenter,
	and by default from the Shell presenter."

	self validateUserInterface; tabFirst!

showMaximized
	"Show the receiver in a maximised state"

	self showWithStyle: SW_SHOWMAXIMIZED!

showMinimized
	"Show the receiver in a minimized state without activating"

	self showWithStyle: SW_SHOWMINIMIZED!

showMinimizedNoActivate
	"Show the receiver in a minimized state without activating"

	self showWithStyle: SW_SHOWMINNOACTIVE!

showShell
	"Private - Show the receiver within a shell"

	self create show!

smallIcon
	"Answer the receiver's small icon"

	^smallIcon!

smallIcon: anIcon
	"Set the receiver's small icon to anIcon."

	smallIcon := anIcon.
	self updateIcons
!

svFlags
	^svFlags ?? 0!

topShell
	"Answer the eventual top shell located in the parent chain of the receiver."

	^self isTopView ifTrue: [self presenter] ifFalse: [super topShell]!

translateAccelerator: aMSG
	"Private - Inform Windows of the accelerator table associated with self. This in turn
	sends a WM_COMMAND if any of our accelerator keys matches."

	| hAccel |
	hAccel := self combinedAcceleratorTable asParameter.
	^hAccel isNull not and: 
			[(User32
				translateAccelerator: handle
				haccl: hAccel
				lpmsg: aMSG) ~~ false]	"useful on image restart of debugged process"!

updateCaption
	"The receiver has changed in such a way that the caption may need to be refreshed.
	Overidden in subclasses that need to provide a dynamic caption that changes
	according to the state of the receiver"

	!

updateIcons
	"Private - Update the large and small icons of the receiver"

	| large small |
	self isTopView ifFalse: [^self].
	large := (largeIcon ifNil: [self presenter icon]) withExtent: self metrics largeIconExtent.
	self
		sendMessage: WM_SETICON
		wParam: ICON_BIG
		lParam: large asParameter.
	"Ensure that the small icon is rendered at the right size"
	small := smallIcon ?? large withExtent: self metrics smallIconExtent.
	self
		sendMessage: WM_SETICON
		wParam: ICON_SMALL
		lParam: small asParameter.
	"We hold onto the actual icons just to prevent them being GC'd while associated with the Window"
	actualIcons := { large. small }!

updateMenuBar
	self isStateRestoring ifTrue: [^self].
	self releaseAccelerators.
	menuBar ifNotNil: [menuBar metrics: self metrics].
	self
		basicMenu: menuBar;
		drawMenuBar!

validateUserInterface
	"Validates the user interface for the receiver. Usually performed at idle time
	when the  UI has been flagged as being invalid"

	flags := flags maskSet: UIValidMask.
	super validateUserInterface

	!

winFinalize
	"Private - Handler for view final view destruction. This is sent on receipt of WM_NCDESTROY,
	and is expected to be the last communication from Windows. There is nothing
	more we can do to save the patient. No event is triggered."

	| wasStateRestoring |
	wasStateRestoring := self isStateRestoring.
	
	["Prevent reaction to resize of frame that occurs when menu removed"
	self setStateRestoring.
	self releaseMenu]
			ensure: [wasStateRestoring ifFalse: [self clearStateRestoring]].
	self releaseAccelerators.
	^super winFinalize!

wmActivate: message wParam: wParam lParam: lParam
	"Private - Sent when the receiver is being activated or deactivated. 
	This message is sent first to the Shell being deactivated, and
	the to the Shell being activated. 
  
		wParam lowWord				activation flag (WA_INACTIVE/WA_ACTIVE/WA_CLICKACTIVE)
		wParam highWord asBoolean	specifies whether or not receiver is iconic
		lParam					handle of other frame window (being activated/deactivated)."

	| event |
	event := WindowsEvent
				window: self
				message: message
				wParam: wParam
				lParam: lParam.
	^wParam lowWord == WA_INACTIVE
		ifTrue: [self presenter onViewDeactivated: event]
		ifFalse: [self presenter onViewActivated: event	"send onActivate for WA_ACTIVE and WA_CLICKACTIVE"]!

wmDpiChangedBeforeParent: message wParam: wParam lParam: lParam
	"Private - Handles a WM_DPICHANGED_BEFOREPARENT message. This is only sent to child windows, bottom-up, before the top-level window receives a WM_DPICHANGED."

	"N.B. We only expect to receive this message when embedded as a child, e.g. in an Idea Space. As a child, we will not receive a WM_DPICHANGED, so we need to clear the cached DPI here."

	dpi := nil.
	super
		wmDpiChangedBeforeParent: message
		wParam: wParam
		lParam: lParam.
	^nil!

wmGetMinMaxInfo: message wParam: wParam lParam: lParam
	| min max |
	((min := self minExtent) notNil or: [(max := self maxExtent) notNil])
		ifTrue: 
			[| minmax |
			minmax := MINMAXINFO fromAddress: lParam.
			min ifNotNil: [minmax ptMinTrackSize: min asParameter].
			max ifNotNil: [minmax ptMaxTrackSize: max asParameter]].
	^0!

wmInitMenu: message wParam: wParam lParam: lParam
	"Private - The receiver's menu bar is about to be activated.
	N.B. This is sent only for the top-level menu bar itself, not for sub-menus,
	for which a WM_INITMENUPOPUP is sent."

	| focusWindow |
	((focusWindow := self class focus) notNil and: [menuBar notNil])
		ifTrue: [
			menuBar queryAllFromView: focusWindow.
			"Redraw the menu bar in case any items were covertly deleted since last activated"
			self drawMenuBar].

	^0 "prevent further processing"!

wmInitMenuPopup: message wParam: wParam lParam: lParam
	"Private - A sub-menu from the receiver's menu bar is about to be popped. Direct the popup menu indicated, which should be connected to menuBar, to update its items current state for our view."

	| popup |
	lParam highWord ~~ 0 ifTrue: [^self onAboutToDisplaySystemMenu: wParam].
	(menuBar isNil or: [(popup := menuBar menuFromHandle: wParam) isNil])
		ifTrue: 
			[^super
				wmInitMenuPopup: message
				wParam: wParam
				lParam: lParam].

	"Starting with the focus window, query the command route for the menu and its items, and enable/disable as appropriate. The menu may also be dynamically updated by the command target, which is sent a #onAboutToDisplayMenu: event"
	popup queryAllFromView: self class focus ?? self.
	"Handled"
	^0!

wmNcActivate: message wParam: wParam lParam: lParam
	"Private - Sent when the receiver frame is being activated or deactivated.

	wParam 
		TRUE if activation, FALSE otherwise 
	lParam 
		handle of update region in non-client area but only available if the window is not under the 
		control of a visual style. -1 indicates that no paint is required.

	Be careful, don't put a breakpoint in this methods (or called methods) or cause a walkback. Any sort of change of NC activation
	here will go recursive and result in an image collapse. Also don't write to the Transcript either, since this causes a window frame flash
	which will again go recursive.

	NOTE: I considered wrapping the presenter calls to trap and ignore errors in an exception block but, as yet, haven't deemed this necessary.
	"

	| event |
	event := WindowsEvent
				window: self
				message: message
				wParam: wParam
				lParam: lParam.
	^wParam = 0
		ifTrue: [self presenter onViewNcDeactivated: event]
		ifFalse: [self presenter onViewNcActivated: event]!

wmNcCreate: message wParam: wParam lParam: lParam
	"Private - Default handler for a WM_NCCREATE. "

	User32 enableNonClientDpiScalingIfNecessary: handle.
	^nil!

wmSetCursor: message wParam: wParam lParam: lParam
	"Private - Handle the Win32 WM_SETCURSOR message. 
	Note the special handling for HTERROR on mouse clicks - this is to bring a modal
	dialog to the foreground if its disabled parent is clicked over. To quote from an MSDN
	article 'This works around the Windows bug where clicking on the owner of a modal dialog 
	box doesn't activate the dialog box instead.'
	We also display the wait cursor for disabled shells that have no active popup. This lets the
	user know the window is disabled without requiring the application programmer to explicitly 
	set and maintain the global wait cursor."

	lParam lowPartSigned == HTERROR 
		ifTrue: 
			[| msg |
			msg := lParam highWord.
			(msg == WM_LBUTTONDOWN or: [msg == WM_RBUTTONDOWN]) 
				ifTrue: [self activateLastPopup ifTrue: [^true	"suppress default processing (no bell)"]]].
	^super 
		wmSetCursor: message
		wParam: wParam
		lParam: lParam!

wmSettingChange: message wParam: wParam lParam: lParam
	"Private - Handle the Win32 WM_SETTINGCHANGE message."

	^self presenter onSettingChanged: (SettingsChangeEvent 
				window: self
				message: message
				wParam: wParam
				lParam: lParam)!

wmSize: message wParam: wParam lParam: lParam
	"Private - Default handler for a WM_SIZE (window resized) message."

	"While we're restoring state it's not a good idea to propagate this event"

	self isStateRestoring ifTrue: [^self].
	#todo.	"Work out how we can do this from #wmPositionChanged:etc instead"
	wParam == SIZE_MINIMIZED
		ifTrue: 
			[self isMinimized: true.
			^self presenter onViewMinimized: (SizeEvent
						window: self
						message: message
						wParam: wParam
						lParam: lParam)].
	(wParam == SIZE_RESTORED and: [self isMinimized])
		ifTrue: 
			[self isMinimized: false.
			^self presenter onViewRestored: (SizeEvent
						window: self
						message: message
						wParam: wParam
						lParam: lParam)].
	^nil!

wmTimeChange: message wParam: wParam lParam: lParam
	"Private - Handle the Win32 WM_TIMECHANGE message."

	^self presenter onTimeChanged: (WindowsEvent
				window: self
				message: message
				wParam: wParam
				lParam: lParam)!

wmWindowPosChanged: message wParam: wParam lParam: lParam
	"Private - The position of the receiver is about to change in some manner.
	The superclass doesn't invoke default window processing in order to suppress
	the old WM_SIZE and WM_MOVE events which mostly aren't needed by Dolphin 3.0,
	however ShellViews want to know when they are minimzed and restored, and the easiest
	way to tell is by examing the flag passed with a WM_SIZE. If we can work out how
	to determine this from the SWP_xxx flags (as the default window proc. is doing) then 
	we can get rid of WM_SIZE altogether."

	super wmWindowPosChanged: message wParam: wParam lParam: lParam.
	^nil	"Accept default processing"
! !

!UI.ShellView categoriesForMethods!
acceleratorTable!accelerator!public! !
acceleratorTable:!accelerator!public! !
activateLastPopup!helpers!private! !
addCommandHistory:!accessing!private! !
allAdditionalAccelerators!accessing!public! !
allAdditionalKeyBindings!accessing!public! !
basicMenu:!menus!private! !
buildCombinedAcceleratorTable!private!realizing/unrealizing! !
buttonRemoved:!default button!private! !
caption!accessing!public! !
caption:!accessing!public! !
centerNear:atDpi:!geometry!private! !
close!public!realizing/unrealizing! !
combinedAcceleratorTable!accelerator!accessing!private! !
commandPolicyClass!commands!constants!public! !
commandPolicyWithSource:!commands!public! !
commandSource!accessing!public! !
createWindow:!private!realizing/unrealizing! !
defaultButtonId!accessing!default button!private! !
defaultButtonId:!accessing!default button!private! !
defaultExtent!constants!private! !
defaultPosition!geometry!private!realizing/unrealizing! !
defaultShowStyle!constants!private! !
defaultWindowStyle!constants!private! !
dialogMessageMap!constants!private! !
dispatchUser:wParam:lParam:!dispatching!private! !
displayOnMonitor:!geometry!helpers!public! !
dmGetDefId:wParam:lParam:!default button!event handling-win32!private! !
dmSetDefId:wParam:lParam:!default button!event handling-win32!private! !
dpi!accessing!high DPI!public! !
dpi:!accessing!private! !
drawMenuBar!menus!public! !
ensureLayoutValid!geometry!public! !
ensureSubViewVisible:!public!sub views! !
exit!commands!public! !
filerProxyIn:!binary filing!private! !
flash:!operations!public! !
flash:flags:!operations!public! !
getDefId!default button!private! !
getDpi!high DPI!private! !
getLastActivePopup!hierarchy!private! !
getLastActivePopupHandle!hierarchy!private! !
hasCaption!accessing-styles!public! !
hasCaption:!accessing-styles!public! !
hasDarkWindowFrame!public!testing! !
hasDarkWindowFrame:!accessing!public! !
hasMaximize!accessing-styles!public! !
hasMaximize:!accessing-styles!public! !
hasMenu!accessing!private! !
hasMinimize!accessing-styles!public! !
hasMinimize:!accessing-styles!public! !
hasSysMenu!accessing-styles!public! !
hasSysMenu:!accessing-styles!public! !
hasTaskbarIcon!accessing-styles!public! !
hasTaskbarIcon:!accessing-styles!public! !
hasVisibleStyle:!public!testing! !
initialize!initializing!private! !
invalidateUserInterface!accessing!public! !
isInitiallyCentered!dispatching!private! !
isInitiallyCentered:!accessing!public! !
isLayeredWindow!accessing!public! !
isLayeredWindow:!accessing!public! !
isMaximized!public!testing! !
isMinimized!public!testing! !
isMinimized:!private!testing! !
isPersistentlyDisabled!private!testing! !
isPersistentView!public!testing! !
isPersistentView:!public!testing! !
isToolWindow!accessing!public! !
isToolWindow:!accessing!public! !
isUserInterfaceValid!public!testing! !
keyboardCommands!accessing!public! !
largeIcon!accessing!public! !
largeIcon:!accessing!public! !
lastFocus!accessing!private! !
lastFocus:!accessing!private! !
maxExtent!accessing!public! !
maxExtent:!accessing!public! !
menuBar!menus!public! !
menuBar:!menus!public! !
minExtent!accessing!public! !
minExtent:!accessing!public! !
minimize!operations!public! !
onAboutToDisplaySystemMenu:!event handling!public! !
onCloseRequested!event handling!public! !
onDpiChanged:!event handling-win32!public! !
onDrawMenuItem:!event handling-win32!public! !
onGetCursor:!event handling!public! !
onIdleEntered!event handling!public! !
onPositionChanged:!event handling!public! !
onSettingChanged:!event handling-win32!public! !
onStateRestored!event handling!private! !
onSubViewRemoved:!event handling!public! !
onTimeChanged:!event handling-win32!public! !
onViewActivated:!event handling!public! !
onViewCreated!event handling!public! !
onViewDeactivated:!event handling!public! !
onViewMinimized:!event handling!public! !
onViewNcActivated:!event handling!public! !
onViewNcDeactivated:!event handling!public! !
onViewRestored:!event handling!public! !
parentView:!hierarchy!private! !
performCommand:!commands!public! !
positionNear:!geometry!public! !
preTranslateKeyboardInput:!dispatching!public! !
preTranslateMouseInput:!dispatching!public! !
queryClose!event handling!public! !
recreateMenuBar!event handling-win32!public! !
recreationRectangle!geometry!private!realizing/unrealizing! !
releaseAccelerators!private!realizing/unrealizing! !
releaseMenu!private!realizing/unrealizing! !
resetDefaultButton!accessing!default button!private! !
resolutionScaledBy:!geometry!private! !
restore:resolution:!geometry!private!realizing/unrealizing! !
setButtonId:style:!accessing!default button!private! !
setDefaultButton:state:!accessing!default button!private! !
setDefId:!default button!private! !
setInitialFocus!operations!public! !
showMaximized!operations!public! !
showMinimized!operations!public! !
showMinimizedNoActivate!operations!public! !
showShell!operations!private! !
smallIcon!accessing!public! !
smallIcon:!accessing!public! !
svFlags!accessing!private! !
topShell!hierarchy!public! !
translateAccelerator:!accelerator!private! !
updateCaption!public!updating! !
updateIcons!accessing!private! !
updateMenuBar!menus!public! !
validateUserInterface!operations!public! !
winFinalize!event handling!private! !
wmActivate:wParam:lParam:!event handling-win32!private! !
wmDpiChangedBeforeParent:wParam:lParam:!event handling-win32!private! !
wmGetMinMaxInfo:wParam:lParam:!event handling-win32!private! !
wmInitMenu:wParam:lParam:!event handling-win32!private! !
wmInitMenuPopup:wParam:lParam:!event handling-win32!private! !
wmNcActivate:wParam:lParam:!event handling-win32!private! !
wmNcCreate:wParam:lParam:!event handling-win32!private! !
wmSetCursor:wParam:lParam:!event handling-win32!private! !
wmSettingChange:wParam:lParam:!event handling-win32!private! !
wmSize:wParam:lParam:!event handling!event handling-win32!private! !
wmTimeChange:wParam:lParam:!event handling-win32!private! !
wmWindowPosChanged:wParam:lParam:!event handling-win32!private! !
!

UI.ShellView methodProtocol: #topPresenter attributes: #(#readOnly) selectors: #(#caption #caption: #commandPolicyWithSource: #ensureVisible #invalidateUserInterface #onAboutToDisplayMenu: #onAboutToDisplaySystemMenu: #onActionPerformed #onCloseRequested #onIdleEntered #onInputMaskRequired: #onKeyPressed: #onKeyReleased: #onKeyTyped: #onKillFocus #onLeftButtonDoubleClicked: #onLeftButtonPressed: #onLeftButtonReleased: #onMouseMoved: #onPositionChanged: #onPositionChanging: #onRightButtonDoubleClicked: #onRightButtonPressed: #onRightButtonReleased: #onSetFocus #onTipTextRequired: #onViewActivated: #onViewClosed #onViewDeactivated: #onViewMinimized: #onViewOpened #onViewRestored: #parentPresenter #performAction #performCommand: #setFocus #show #topShell #updateCaption #view)!
UI.ShellView methodProtocol: #topView attributes: #(#readOnly) selectors: #(#acceleratorTable #acceleratorTable: #beActive #beForeground #beNotTopMost #bePopupFor: #beTopMost #buttonRemoved: #caption #caption: #exit #flash: #frameWidths #hasCaption #hasCaption: #hasMaximize #hasMaximize: #hasMinimize #hasMinimize: #hasSysMenu #hasSysMenu: #isActive #isForeground #isInitiallyCentered: #isMinimized #isResizable #isResizable: #isToolWindow #isToolWindow: #largeIcon #largeIcon: #maxExtent #menuBar #menuBar: #minExtent #onAboutToDisplaySystemMenu: #onCloseRequested #onViewMinimized: #onViewRestored: #showMaximized #showMinimized #smallIcon #smallIcon:)!

!UI.ShellView class methodsFor!

asSessionManagerClass
	^DefaultShellSessionManager!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self defaultIcon)!

initialize
	View registerMessageMappings: self messageMappings!

installNew
	^(self asSessionManagerClass basicNew mainShellClass: self) install!

messageMappings
	^{WM_ACTIVATE -> #wmActivate:wParam:lParam:.
		WM_ACTIVATEAPP -> #wmActivateApp:wParam:lParam:.
		WM_NCACTIVATE -> #wmNcActivate:wParam:lParam:.
		WM_GETMINMAXINFO -> #wmGetMinMaxInfo:wParam:lParam:.
		WM_SETTINGCHANGE -> #wmSettingChange:wParam:lParam:.
		WM_TIMECHANGE -> #wmTimeChange:wParam:lParam:}!

shutdownOnExit
	"Answer whether a runtime session should be shutdown when an instance of the receiver is closed."

	"Implementation Note: For backwards compatibility, this is currently false, although this
	does mean most applications will need to override for their main shell window."

	^false!

stbConvertFromVersion0: anArray
	"Private - Perform an STB conversion from a version 0 <View> to version 1 (Dolphin 2.0). i.e. insert largeIcon/smallIcon inst vars, initially nil."

	| data size |
	data := super stbConvertFromVersion0: anArray.
	size := data size + 2.
	^(Array new: size)
		replaceFrom: 1
			to: 18
			with: data
			startingAt: 1;
		replaceFrom: 21
			to: size
			with: data
			startingAt: 19;
		yourself!

stbConvertFromVersion4: anArray
	"Private - Perform an STB conversion from a version 4 (or earlier) <View> to version 5,
	i.e. insert maxExtent/minExtent inst vars in ShellView and subclasses."

	| data size |
	data := super stbConvertFromVersion4: anArray.
	size := data size + 2.
	^(Array new: size)
		replaceFrom: 1
			to: 20
			with: data
			startingAt: 1;
		replaceFrom: 23
			to: size
			with: data
			startingAt: 21;
		yourself!

stbConvertFromVersion8: anArray
	"Private - Perform an STB conversion from a version 8 (or earlier) <View> to version 9,
	i.e. convert defaultButton inst. var. of <ShellView> and subclasses to integer id."

	"The defaultButtonId does not need to be persisted, as <PushButton>s remember and reset on creation"

	^(super stbConvertFromVersion8: anArray)
		at: DefaultButtonIndex put: 0;
		yourself!

stbConvertFromVersion9: anArray
	"Private - Perform an STB conversion from a version 9 (or earlier) <ShellView> to version 10,
	i.e. append 'flashes' and a couple of dummy instance variables."

	| data size |
	data := super stbConvertFromVersion9: anArray.
	size := data size + 3.	"3 instance variables were added"
	^(Array new: size)
		replaceFrom: 1
			to: 24
			with: data
			startingAt: 1;
		at: 25 put: 0;
		replaceFrom: 28
			to: size
			with: data
			startingAt: 25;
		yourself!

themePartName
	^'WINDOW'!

uninitialize
	View unregisterMessageMappings: (self messageMappings collect: [:each | each key]).
	"No point maintaining registrations for the settingChanged: event, as it will not be triggered when there are no ShellViews."
	SessionManager current events removeActionsForEvent: #settingChanged:! !

!UI.ShellView class categoriesForMethods!
asSessionManagerClass!converting!public!VM and session managerment! !
icon!constants!public! !
initialize!development!initializing!private! !
installNew!public! !
messageMappings!constants!must not strip!private! !
shutdownOnExit!public!testing! !
stbConvertFromVersion0:!binary filing!private! !
stbConvertFromVersion4:!binary filing!private! !
stbConvertFromVersion8:!binary filing!private! !
stbConvertFromVersion9:!binary filing!private! !
themePartName!constants!public!theming! !
uninitialize!class hierarchy-removing!private! !
!

