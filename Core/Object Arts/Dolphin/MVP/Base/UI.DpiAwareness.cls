"Filed out from Dolphin Smalltalk"!

Core.Object
	subclass: #'UI.DpiAwareness'
	instanceVariableNames: 'handle name'
	classVariableNames: 'Awarenesses GdiScaled PerMonitor PerMonitorV1 System Unaware'
	imports: #(#{OS.Win32Constants})
	classInstanceVariableNames: ''
	classConstants: {
			'AwarenessLevelNames' -> #(#invalid #unaware #system #perMonitor).
			'ContextNames' -> #(#unaware #system #perMonitorV1 #perMonitor #gdiScaled)
		}!

UI.DpiAwareness guid: (Core.GUID fromString: '{2794a15c-906e-4973-a798-47d8efcc1d6a}')!

UI.DpiAwareness comment: '`DpiAwareness` is an abstraction over the Windows concept of a DPI awareness context. The DPI awareness context of a window determines how it is measured, displayed and scaled.

High DPI awareness is a surprisingly complex topic, but is reasonably well explained in the [Microsoft documentation](https://learn.microsoft.com/en-us/windows/win32/api/_hidpi/). In particular see the [programming guidance](https://learn.microsoft.com/en-us/windows/win32/hidpi/high-dpi-desktop-application-development-on-windows).

High dpi support does result in some breaking changes, but this can be avoided for older applications by setting the awareness back to ''unaware'', which will restore the virtualised 96-dpi pixel co-ordinates with OS bitmap scaling. This will of course restore the former blurriness too. The ''gdi scaled'' mode offers some improvement, as the OS is able to scale GDI output directly, e.g. of text, so this can be crisper. Note that this does not improve text in a ScintillaView when using DirectDraw for rendering text, which is normally the case. However if the drawingTechnology aspect of a ScintillaView is set to #default, then GDI will be used and the text quality will improve. Images such as toolbar and class icons will still be bitmap scaled, however, so the overall effect is not as good as at the ''system'' level (at primary monitor dpi), or ''per monitor'' (at any monitor DPI). In ''system'' mode, the application is in effect locked to the DPI of the primary monitor. Text and icons will be scaled at source, so should render without blurriness. This will give good results with matched monitors, but where this is not the case (or where the scaling is changed while the application is running), the OS will again intervene to scale from the primary DPI to any other DPIs, resulting in more blurry windows. The ''per monitor'' mode yields the best results, as everything is scaled on the fly to match the target monitor. Should windows be moved to monitors at different DPIs, or the system DPI (scale factor) is changed, then Dolphin will rescale everything to suit, changing window, font and icon sizes to match the new scale. This mode is particularly likely to show compability issues. In any DPI aware mode the use of bitmaps for images may yield poor results as these will have to be stretched appropriately. Ideally it is necessary to have renderings of the bitmap at different scales and choose the most appropriate for the DPI/scale factor. Dolphin''s frameworks will do this automatically for many uses of icons, but you are on your own with individual bitmap images. If you are directly rendering into Canvases with drawing commands specifying pixel sizes, you will probably need to modify your code to scale the co-ordinates. Fonts are automatically scaled to maintain the origin point size.

It is possible to have windows operating with different DPI awareness levels, even to the extent of having child windows within a shell view that have differing awareness of DPI. The latter is known as ''mixed mode'', and is particularly complex, so not recommended except in very special circumstances. One such circumstance is in editing view resources. To achieve consistent results independent of the scaling that happens to be current during an editing session, the View Composer edits and saves all resources at 96-dpi. This is achieved by the arena operating in ''unaware gdi scaled'' mode, and similarly the edited views are opened off screen in this mode. All pixel extent aspects are then measured at 96-dpi, and generally these will be scaled when the views are instantiated for application use. The automatic scaling works well in most cases, even for completely fixed layouts, but there may be occassions where the layout design does not scale well, e.g. text is clipped, and modifications to the views may be required to correct this.

## Instance Variables:
  `handle`		`<integer>` DPI awareness context value
  `name`		`<symbol>` name of the context

## Class Variables:
  `Awarenesses`			`<Array>` of standard instances
  `AwarenessLevelNames`	`<Array>` of the names of the broad categories of awareness
  `ContextNames`			`<Array>` of the names of the standard instances
  `GdiScaled`				`DpiAwareness` instance for DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED
  `PerMonitor`				`DpiAwareness` instance for DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
  `PerMonitorV1`			`DpiAwareness` instance for DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE
  `System`					`DpiAwareness` instance for DPI_AWARENESS_CONTEXT_SYSTEM_AWARE
  `Unaware`				`DpiAwareness` instance for DPI_AWARENESS_CONTEXT_UNAWARE

'!

!UI.DpiAwareness categoriesForClass!Kernel-Objects! !

!UI.DpiAwareness methodsFor!

= anObject
	^anObject == self or: [anObject species == self species and: [self name = anObject name]]!

awarenessLevel
	"Answer the old-style DPI awareness level into which broader category this context fits. This is one of DPI_AWARENESS_UNAWARE (0), DPI_AWARENESS_SYSTEM_AWARE (1), or DPI_AWARENESS_PER_MONITOR_AWARE (2)."

	^User32 getAwarenessFromDpiAwarenessContext: handle!

determineName
	| level |
	level := self awarenessLevel.
	level == DPI_AWARENESS_UNAWARE
		ifTrue: 
			[^(self isEqualToDpiAwarenessContext: DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED)
				ifTrue: [#gdiScaled]
				ifFalse: [#unaware]].
	level == DPI_AWARENESS_PER_MONITOR_AWARE
		ifTrue: 
			[^(self isEqualToDpiAwarenessContext: DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
				ifTrue: [#perMonitor]
				ifFalse: [#perMonitorV1]].
	^AwarenessLevelNames at: level + 2!

dpi
	"Answer the DPI applicable in this DPI awareness context. Note that this will only yield an actual DPI result for unaware or system contexts. For per-monitor contexts, the answer is 0, since there is no one DPI. In that case the DPI has o be established in the context of a particular window or monitor."

	^User32 getDpiFromDpiAwarenessContext: handle!

handle
	^handle!

handle: anInteger
	handle := anInteger!

hash
	^self name hash!

inContextDo: aNiladicValuable
	^self isCurrent
		ifTrue: [aNiladicValuable value]
		ifFalse: 
			[| currentContext |
			currentContext := User32 setThreadDpiAwarenessContext: handle.
			aNiladicValuable ensure: [User32 setThreadDpiAwarenessContext: currentContext]]!

isCurrent
	"Answer whether the receiver is the live DPI awareness context."

	^User32 areDpiAwarenessContextsEqual: User32 getThreadDpiAwarenessContext dpiContextB: handle!

isEqualToDpiAwarenessContext: anInteger
	^User32 areDpiAwarenessContextsEqual: handle dpiContextB: anInteger!

isPerMonitor
	^self awarenessLevel == DPI_AWARENESS_PER_MONITOR_AWARE!

isSystemAware
	"Answer whether the receiver represents the 'system aware' DPI awareness context (i.e. DPI_AWARENESS_CONTEXT_SYSTEM_AWARE)."

	^self = System!

isUnaware
	"Answer whether the receiver is one of the DPI unaware modes"

	^self awarenessLevel == 0!

isValid
	"Answer whether the receiver represents a valid DPI awareness context."

	^User32 isValidDpiAwarenessContext: handle!

name
	"Answer the symbolic name of this awareness level: One of #unaware, #gdiScaled, #perMonitor, #perMonitorV1, or #invalid."

	"There is no API providing a direct mapping from an awareness context handle to one of the well known contexts, so determining the name is not as cheap as would be desirable given that we need this for comparison purposes. Therefore we cache it in an instance variable."

	^name ifNil: [name := self determineName]!

printOn: aPuttableStream
	aPuttableStream
		print: self class;
		space;
		display: self name! !

!UI.DpiAwareness categoriesForMethods!
=!comparing!public! !
awarenessLevel!accessing!public! !
determineName!helpers!private! !
dpi!accessing!public! !
handle!accessing!private! !
handle:!accessing!private! !
hash!comparing!public! !
inContextDo:!operations!public! !
isCurrent!public!testing! !
isEqualToDpiAwarenessContext:!comparing!public! !
isPerMonitor!public!testing! !
isSystemAware!public!testing! !
isUnaware!public!testing! !
isValid!public!testing! !
name!accessing!public! !
printOn:!printing!public! !
!

!UI.DpiAwareness class methodsFor!

current
	"Answer the current active context."

	^self fromHandle: User32 getThreadDpiAwarenessContext!

fromHandle: anInteger
	^(Awarenesses lookup: anInteger asInteger negated) ifNil: [self new handle: anInteger]!

gdiScaled
	^GdiScaled!

initialize
	self addClassConstant: 'Awarenesses'
		value: ({
				'Unaware' -> DPI_AWARENESS_CONTEXT_UNAWARE.
				'System' -> DPI_AWARENESS_CONTEXT_SYSTEM_AWARE.
				'PerMonitorV1' -> DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE.
				'PerMonitor' -> DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2.
				'GdiScaled' -> DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED
			} collect: 
						[:each |
						| inst |
						inst := self new handle: each value.
						inst name.
						self addClassConstant: each key value: inst.
						inst])!

invalid
	^self fromHandle: 0!

named: aSymbol
	^self fromHandle: (ContextNames identityIndexOf: aSymbol) negated!

ofWindow: aView
	^self fromHandle: (User32 getWindowDpiAwarenessContext: aView asParameter)!

perMonitor
	^PerMonitor!

perMonitorV1
	^PerMonitorV1!

system
	^System!

unaware
	^Unaware! !

!UI.DpiAwareness class categoriesForMethods!
current!instance creation!public! !
fromHandle:!instance creation!public! !
gdiScaled!instance creation!public! !
initialize!class initialization!public! !
invalid!instance creation!public! !
named:!instance creation!public! !
ofWindow:!instance creation!public! !
perMonitor!instance creation!public! !
perMonitorV1!instance creation!public! !
system!instance creation!public! !
unaware!instance creation!public! !
!

