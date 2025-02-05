﻿"Filed out from Dolphin Smalltalk"!

Core.Object
	subclass: #'UI.CreateWindowFunction'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #(#{OS.Win32Constants})
	classInstanceVariableNames: ''
	classConstants: { 'UseDefaultGeometry' -> (-16r80000000 @ -16r80000000) }!

UI.CreateWindowFunction guid: (Core.GUID fromString: '{4452c723-d081-4053-b0bf-7660d58cbf74}')!

UI.CreateWindowFunction isNonInstantiable: true!

UI.CreateWindowFunction comment: ''!

!UI.CreateWindowFunction categoriesForClass!Kernel-Objects! !

!UI.CreateWindowFunction methodsFor!

create: aView
	"Create a native window for the <View> argument."

	^self subclassResponsibility!

createShellWindow: aShellView
	"Position and create the native Window for the <ShellView> argument."

	self subclassResponsibility!

dpi
	"Answer the <integer> logical dots-per-inch at which the <rectangle> of the receiver is measured."

	^self subclassResponsibility!

dpi: anInteger
	"Set the <integer> logical dots-per-inch at which the <rectangle> of the receiver is measured."

	self subclassResponsibility!

extent
	"Answer a <point> expressing the width and height of the window to be created. These are measured at the receiver's DPI."

	^self rectangle extent!

hasDefaultExtent
	"Answer whether the window should be created at the default extent determined by Windows, or if not a top-level window an extent yet to be determined."

	^self extent = UseDefaultGeometry!

position
	"Answer a <point> expressing the position (top-left corner) of the window to be created. The position is measured at the receiver's DPI."

	^self rectangle origin!

position: positionPoint extent: extentPoint dpi: anInteger
	"Set the position and extent of the window that will be created, and the dpi in which the pixel co-ordinates that it contains are measured."

	self subclassResponsibility!

rectangle
	"Answer the <rectangle> specifying the position and extent of the window that will be created."

	^self subclassResponsibility!

scaleToDpi: anInteger
	"Private - Scale the receiver in-place from it's current DPI to that specified by the <SmallInteger> argument."

	self subclassResponsibility!

scaleToDpiOf: aView
	"Scale the receiver in-place to the dpi of the <View> argument (which would normally be the parent). Note that the receiver should not be scaled multiple times, as rounding error may accumulate. The intent is that the receiver be scaled once for DPI, if required."

	aView scaleChildCreation: self! !

!UI.CreateWindowFunction categoriesForMethods!
create:!operations!public! !
createShellWindow:!operations!public! !
dpi!accessing!high DPI!public! !
dpi:!accessing!high DPI!public! !
extent!accessing!public! !
hasDefaultExtent!public!testing! !
position!accessing!public! !
position:extent:dpi:!initializing!public! !
rectangle!accessing!public! !
scaleToDpi:!helpers!high DPI!private! !
scaleToDpiOf:!high DPI!operations!public! !
!

!UI.CreateWindowFunction class methodsFor!

initialize
	self addClassConstant: 'UseDefaultGeometry' value: CW_USEDEFAULT @ CW_USEDEFAULT! !

!UI.CreateWindowFunction class categoriesForMethods!
initialize!class initialization!public! !
!

