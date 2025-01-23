"Filed out from Dolphin Smalltalk"!

Core.Object
	subclass: #'UI.DisplayMonitor'
	instanceVariableNames: 'handle info devices dpi metrics defaultWindowExtent lastWindowPosition cascadeOffset workArea deviceName isPrimary rectangle'
	classVariableNames: 'Instances'
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {
			'MDT_ANGULAR_DPI' -> 16r1.
			'MDT_DEFAULT' -> 16r0.
			'MDT_EFFECTIVE_DPI' -> 16r0.
			'MDT_RAW_DPI' -> 16r2.
			'MONITOR_DEFAULTTONEAREST' -> 16r2.
			'MONITOR_DEFAULTTONULL' -> 16r0.
			'MONITOR_DEFAULTTOPRIMARY' -> 16r1
		}!

UI.DisplayMonitor guid: (Core.GUID fromString: '{2ab65289-2a77-4c76-9ab2-82178699a48c}')!

UI.DisplayMonitor comment: '`UI.DisplayMonitor` is a simple abstraction over the Windows Multiple Display Monitors API. It allows one to enumerate the attached monitors, and to identify:
  - the primary monitor;
  - the monitor on which a point in desktop co-ordinates is displayed; 
  - the monitors that intersect a rectangular region of the desktop, and/or a device context.

Having identified a `DisplayMonitor`, one can then query the desktop co-ordinates of the its display and work areas.

## Instance Variables:
  `handle`		`External.ExternalHandle`. The Windows HMONITOR handle for the monitor.
  `info`		`OS.MONITORINFO`

'!

!UI.DisplayMonitor categoriesForClass!Kernel-Objects! !

!UI.DisplayMonitor methodsFor!

= anObject
	^self == anObject
		or: [anObject species == self species and: [anObject deviceName = self deviceName]]!

adjustPosition: originPoint forExtent: extentPoint
	"Answer the nearest `Point` to originPoint that allows a rectangle with extent, extentPoint, to fit within the receiver's work area.
	If the extent is larger than the work area, then answer the work area's own origin."

	| area |
	area := self effectiveWorkArea.
	^(originPoint min: area bottomRight - extentPoint) max: area topLeft!

adjustWindowRect: aRectangle
	"Adjust the window rectangle that is the argument to fit within the receiver's work area. The rectangle is assumed to be scaled to the receiver's DPI.
	At present the extent is not changed, just the position. If the extent is larger than the work area, then the rectangle is positioned to the work area's own origin."

	| area |
	area := self effectiveWorkArea.
	^aRectangle
		position: ((aRectangle topLeft min: area bottomRight - aRectangle extent) max: area topLeft);
		yourself!

cacheInfo
	| monitorInfo |
	monitorInfo := MONITORINFOEXW newBuffer.
	(UserLibrary dpiAwareness inContextDo: [
		dpi := self effectiveDpi.
		UserLibrary default getMonitorInfo: handle lpmi: monitorInfo])
		ifFalse: [Win32Error signal].
	workArea := monitorInfo workArea.
	rectangle := monitorInfo rectangle.
	deviceName := monitorInfo szDevice.
	isPrimary := monitorInfo isPrimary!

cascadeOffset
	"Private - Answer the offset of a new default window position from the last. This should neatly cascade the windows in a diagonal down from a starting point inset from the top corner by one such offset.
	The caption of the previously opened window on the monitor should not be occluded by the new window, unless the position needs to wrap back to the starting point. A window with default extent should not be positioned below the point at which its corner would be within one offset of the corner of the work area in either dimension. If that would occur, the cascade is wrapped back around to the starting point."

	^cascadeOffset
		ifNil: 
			[| captionHeight |
			captionHeight := self metrics captionHeight.
			cascadeOffset := captionHeight @ captionHeight + metrics sizingFrameExtent]!

centerExtent: aPoint
	"Answer the best origin `Point` for a view rectangle expected to be centred over the receiver of the specified extent."

	^self adjustPosition: self effectiveWorkArea center - (aPoint // 2) forExtent: aPoint!

defaultWindowExtent
	^defaultWindowExtent
		ifNil: 
			[| maxExtent width aspectRatio |
			maxExtent := self workArea extent.
			width := maxExtent x.
			aspectRatio := maxExtent y / width.
			width := width * 3 / 4.
			defaultWindowExtent := (width @ (width * aspectRatio - self metrics captionHeight)) truncated
						isImmutable: true;
						yourself]!

deviceName
	"Answer the Window's device name for the monitor that the receiver represents."

	deviceName ifNil: [self cacheInfo].
	^deviceName!

devices
	^devices
		ifNil: 
			[| stream device i |
			stream := Array writeStream: 1.
			i := 0.
			device := DISPLAY_DEVICEW newBuffer.
			
			[User32
				enumDisplayDevices: self deviceName
				iDevNum: i
				lpDisplayDevice: device
				dwFlags: 0]
					whileTrue: 
						[stream nextPut: device copy.
						i := i + 1].
			devices := stream grabContents]!

dpi
	"Answer the logical DPI for this monitor. Note that this may not be the same as the physical DPI, depending on the DPI awareness of the application and the OS magnification setting. When DPI unaware, this is always 96. When system DPI aware it is the system-wide DPI, even if different than this monitor's DPI. When per-monitor DPI aware, it is the effective DPI of the monitor (i.e. the monitors's DPI at the configured magnification)."

	dpi ifNil: [self cacheInfo].
	^dpi!

effectiveDpi
	"Answer the logical DPI of this monitor as measured in the current thread DPI awareness context. This may be different to #dpi, which is the DPI at the process wide (default) context."

	^self getDpi: MDT_DEFAULT!

effectiveWorkArea
	"Answer a <rectangle> which is the desktop area displayed by this monitor, excluding any areas used by the window manager, such as the taskbar. This area is measured in the current active DPI awareness context, so may be a virtualized rectangle. Note that the origin can be negative for displays other than the primary that are organised to be right of the primary."

	^self info workArea!

getDpi: anInteger
	"Private - Query the specified DPI setting for this monitor. The documentation for GetDpiForMonitor states explicitly that the x and y values will always be the same, so we only bother to retrieve and store one."

	| buf |
	buf := ByteArray newFixed: 4.
	SHCore
		getDpiForMonitor: handle
		dpiType: anInteger
		dpiX: buf
		dpiY: buf.
	^buf uint32AtOffset: 0!

handle
	^handle!

handle: anObject
	handle := anObject!

hash
	^self deviceName hash!

info
	info ifNil: [info := MONITORINFOEXW newBuffer].
	(User32 getMonitorInfo: handle lpmi: info) ifFalse: [Win32Error signal].
	^info!

infoWithDpiAwareness: aDpiAwareness
	| buf |
	buf := MONITORINFOEXW newBuffer.
	(aDpiAwareness inContextDo: [UserLibrary default getMonitorInfo: handle lpmi: buf])
		ifFalse: [Win32Error signal].
	^buf!

isAttachedToDesktop
	"Answer whether the receiver has any displays attached to the desktop."

	^self devices anySatisfy: [:each | each isAttachedToDesktop]!

isPrimary
	"Answer whether the receiver represents the primary/main monitor."

	isPrimary ifNil: [self cacheInfo].
	^isPrimary!

metrics
	"Answer a <SystemMetrics> that can be used to obtain metrics at the receiver's scale/DPI."

	^metrics ifNil: [metrics := SystemMetrics forDpi: self dpi]!

nextWindowPosition
	"Answer the next default position for a new window on this monitor. Note that this is measured in the default DPI awareness context for the session."

	lastWindowPosition
		ifNotNil: 
			[lastWindowPosition := lastWindowPosition + self cascadeOffset.
			self workArea corner - (lastWindowPosition + self defaultWindowExtent) > cascadeOffset
				ifTrue: [^lastWindowPosition]].
	^lastWindowPosition := self workArea origin + self cascadeOffset!

origin
	"Answer a `Point` specifying the origin (top-left corner) of the display represented by the object."

	^self rectangle origin!

printOn: aStream
	super printOn: aStream.
	aStream nextPut: $(.
	self isPrimary ifTrue: [aStream nextPutAll: 'primary: '].
	aStream
		print: self deviceName;
		nextPut: $)!

rawDpi
	"Answer the physical DPI of this monitor. This is the raw DPI of the device, and does not take account of scaling."

	^self getDpi: MDT_RAW_DPI!

rectangle
	"Answer a `Rectangle` which is the desktop area displayed by this monitor. This is in desktop co-ordinates. Note that the origin can be negative for displays other than the primary that are organised to be right of the primary."

	rectangle ifNil: [self cacheInfo].
	^rectangle!

resolution
	"Answer the logical resolution for this monitor. Note that this may not be the same as the physical resolution, depending on the DPI awareness of the application and the OS magnification setting. When DPI unaware, this is always 96@96. When system DPI aware it is the system-wide DPI, even if different than this monitor's DPI. When per-monitor DPI aware, it is the effective DPI of the monitor (i.e. the monitors's DPI at the configured magnification)."

	^self dpi @ dpi!

scaleFactor
	"Answer the scale factor for this monitor."

	^self scalePercentage / 100!

scalePercentage
	"Answer the scale factor for this monitor. This is the percentage scaling, so for example 125 indicates 1.25x scalling or 120-dpi."

	| factor |
	#highDpiToDo.	"What does this return for custom scale factors?"
	factor := ByteArray newFixed: 4.
	SHCore getScaleFactorForMonitor: handle pScale: factor.
	^factor int32AtOffset: 0!

workArea
	"Answer a <rectangle> which is the desktop area displayed by this monitor, excluding any areas used by the window manager, such as the taskbar. Note that the origin can be negative for displays other than the primary that are organised to be right of the primary."

	workArea ifNil: [self cacheInfo].
	^workArea!

workAreaOffset
	"Answer a <Point> which is the offset of the receiver's work area from the receiver's origin. This is always in the measurement system of the current DPI awareness context."

	| monitorInfo |
	monitorInfo := self info.
	^monitorInfo workArea topLeft - self origin! !

!UI.DisplayMonitor categoriesForMethods!
=!comparing!public! !
adjustPosition:forExtent:!geometry!public! !
adjustWindowRect:!geometry!public! !
cacheInfo!initializing!private! !
cascadeOffset!accessing!private! !
centerExtent:!geometry!public! !
defaultWindowExtent!accessing!public! !
deviceName!accessing!public! !
devices!accessing!private! !
dpi!accessing!public! !
effectiveDpi!accessing!public! !
effectiveWorkArea!accessing!public! !
getDpi:!accessing!private! !
handle!accessing!private! !
handle:!accessing!private! !
hash!comparing!public! !
info!accessing!private! !
infoWithDpiAwareness:!enquiries!private! !
isAttachedToDesktop!public!testing! !
isPrimary!public!testing! !
metrics!accessing!public! !
nextWindowPosition!geometry!public! !
origin!accessing!public! !
printOn:!printing!public! !
rawDpi!accessing!public! !
rectangle!accessing!public! !
resolution!accessing!public! !
scaleFactor!accessing!public! !
scalePercentage!accessing!public! !
workArea!accessing!public! !
workAreaOffset!accessing!public! !
!

!UI.DisplayMonitor class methodsFor!

active
	"Answer an instance of the receiver representing the monitor that is most likely to be the one the user might consider active. There is no completely reliable way to determine this, so we use the heuristic that the monitor of the foreground window is to be used if that is a Dolphin window, otherwise the monitor over which the cursor is hovering. The reason for making this distinction is that the foreground window may be some part of the Windows shell if the user clicked on the desktop background or the taskbar, which are always considered as being on the primary monitor only. Up until Windows 11 it was possible to detect this case reasonably well by detecting that the window with focus was the 'Program Manager', but this no longer holds in Windows 11. Therefore we just go for the simpler option of tracking the cursor when the active window is not a Dolphin window."

	^View active
		ifNil: [self containingPoint: Cursor position]
		ifNotNil: [:hWnd | self nearestView: hWnd]!

allIntersecting: aRectangle
	"Answer a `<collection>` containing instances of the receiver describing all the display monitors with display areas that intersect the specified virtual screen area (i.e. desktop area)."

	^self forCanvas: nil intersecting: aRectangle!

allMonitors
	"Answer a `<collection>` containing instances of the receiver describing all the connected display monitors."

	^self forCanvas: nil intersecting: nil!

containingPoint: aPoint
	"Answer an instance of the receiver describing the monitor on which the specified 'Point' in the screen co-ordinate space would appear. If the View is outside the display area of any of the connected monitors, answer nil.
	Note that there may be areas of the virtual screen area that are not visible, depending on the relative sizes and positioning of the monitors in the Windows display settings, i.e. a Point within the virtual screen area may not actually be displayed on any monitor."

	^(User32 monitorFromPoint: aPoint asParameter dwFlags: MONITOR_DEFAULTTONULL)
		ifNotNil: [:hMonitor | self fromHandle: hMonitor]!

desktopMonitors
	"Answer a `<collection>` containing instances of the receiver describing all the connected display monitors."

	^self allMonitors select: [:each | each isAttachedToDesktop]!

displayingView: aViewOrHandle
	"Answer an instance of the receiver describing the monitor on which the specified `View`/window is (at least mostly) displayed. Note that for the desktop window, the primary monitor will be returned.
	If the window is outside the visible display area, answer nil."

	^(User32 monitorFromWindow: aViewOrHandle asParameter dwFlags: MONITOR_DEFAULTTONULL)
		ifNotNil: [:hMonitor | self fromHandle: hMonitor]!

forCanvas: aCanvas intersecting: aRectangle
	"Answer a `<collection>` containing instances of the receiver describing all the display monitors that are displaying the specified virtual screen area (i.e. desktop area) of the specified device context. The rectangle and device context can be nil.
		aCanvas isNil & aRectangle isNil		- matches all display monitors
		aCanvas isNil & aRectangle notNil		- matches all display monitors that intersect the virtual screen area specified by aRectangle
		aCanvas notNil & aRecangle isNil		- matches all display monitors that intersect the visibile region of aCanvas
		aCanvas notNil & aRectangle notNil 	- all display monitors that intersect the visibile region of aCanvas and the virtual screen area specified by aRectangle"

	| monitors |
	monitors := Array writeStream: 1.
	self
		forCanvas: aCanvas
		intersecting: aRectangle
		do: [:each | monitors nextPut: each].
	^monitors grabContents!

forCanvas: aCanvas intersecting: aRectangle do: aMonadicValuable
	| callback answer |
	callback := External.Callback block: 
					[:hMonitor :hdc :lprect :lparam |
					aMonadicValuable value: (DisplayMonitor fromHandle: hMonitor).
					true]
				descriptor: ##(External.FunctionDescriptor returnType: 'bool'
						argumentTypes: 'handle handle <1p>* uint32' << RECTL).
	answer := User32
				enumDisplayMonitors: aCanvas asParameter
				lprcClip: aRectangle asParameter
				lpfnEnum: callback asParameter
				dwData: 0.
	callback free.
	^answer!

fromHandle: anExternalHandle
	^Instances at: anExternalHandle
		ifAbsentPut: 
			[self new
				handle: anExternalHandle;
				yourself]!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

initialize
	SessionManager current
		when: #settingChanged:
		send: #onSettingChanged:
		to: self!

intersecting: aRectangle
	"Answer an instance of the receiver describing the monitor which has the largest intersection with the specified `Rectangle` of the screen co-ordinate space, or nil if there is no intersection."

	^(User32 monitorFromRect: aRectangle asParameter dwFlags: MONITOR_DEFAULTTONULL)
		ifNotNil: [:hMonitor | self fromHandle: hMonitor]!

nearestPoint: aPoint
	"Answer an instance of the receiver describing the monitor to which the specified `Point` (expressing a position in the screen co-ordinate space) is nearest."

	^(User32 monitorFromPoint: aPoint asParameter dwFlags: MONITOR_DEFAULTTONEAREST)
		ifNotNil: [:hMonitor | self fromHandle: hMonitor]
		ifNil: [Win32Error signal]!

nearestRectangle: aRectangle
	"Answer an instance of the receiver describing the monitor that has the largest intersection with the <rectangle> argument."

	^(User32 monitorFromRect: (RECT marshal: aRectangle) dwFlags: MONITOR_DEFAULTTONEAREST)
		ifNotNil: [:hMonitor | self fromHandle: hMonitor]
		ifNil: [Win32Error signal]!

nearestView: aView
	"Answer an instance of the receiver describing the monitor on which the specified `View` is either mostly displayed, or, if off-screen, to which it is nearest."

	^(User32 monitorFromWindow: aView asParameter dwFlags: MONITOR_DEFAULTTONEAREST)
		ifNotNil: [:hMonitor | self fromHandle: hMonitor]
		ifNil: [Win32Error signal]!

onSettingChanged: anArray
	"Private - Respond to an OS settings change. Here we are only interested in a change of the monitor setup, which appears as a work area change. When received, we discard the cached instances."

	anArray = ##({'All'. Win32Constants.SPI_SETWORKAREA}) ifTrue: [self reset]!

primary
	"Answer an instance of the receiver describing the primary display monitor."

	^(User32 monitorFromWindow: nil dwFlags: MONITOR_DEFAULTTOPRIMARY)
		ifNil: [Win32Error signal]
		ifNotNil: [:hMonitor | self fromHandle: hMonitor]!

reset
	Instances := SharedLookupTable new! !

!UI.DisplayMonitor class categoriesForMethods!
active!instance creation!public! !
allIntersecting:!instance creation!public! !
allMonitors!enumerating!public! !
containingPoint:!instance creation!public! !
desktopMonitors!enumerating!public! !
displayingView:!instance creation!public! !
forCanvas:intersecting:!enumerating!public! !
forCanvas:intersecting:do:!enumerating!private! !
fromHandle:!instance creation!private! !
icon!constants!public! !
initialize!class initialization!public! !
intersecting:!instance creation!public! !
nearestPoint:!instance creation!public! !
nearestRectangle:!instance creation!public! !
nearestView:!instance creation!public! !
onSettingChanged:!event handling-win32!private! !
primary!instance creation!public! !
reset!initializing!public! !
!

