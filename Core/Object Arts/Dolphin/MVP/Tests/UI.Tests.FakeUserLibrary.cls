"Filed out from Dolphin Smalltalk"!

OS.UserLibrary
	subclass: #'UI.Tests.FakeUserLibrary'
	instanceVariableNames: 'user32 process getForegroundWindowBlock getActiveWindowBlock getCursorPosBlock messages'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

UI.Tests.FakeUserLibrary guid: (Core.GUID fromString: '{bbf4bdc3-fddb-4f49-8884-67abd17b5abf}')!

UI.Tests.FakeUserLibrary comment: ''!

!UI.Tests.FakeUserLibrary categoriesForClass!External-Libraries-Win32! !

!UI.Tests.FakeUserLibrary methodsFor!

close
	user32
		ifNotNil: 
			[:original |
			handle := user32 := nil.
			UserLibrary setDefault: original]!

getActiveWindow
	^(getActiveWindowBlock notNil and: [Processor activeProcess == process])
		ifTrue: [getActiveWindowBlock value]
		ifFalse: [super getActiveWindow]!

getActiveWindowBlock: aNiladicValuable
	getActiveWindowBlock := aNiladicValuable!

getCursorPos: aPOINT
	^(getCursorPosBlock notNil and: [Processor activeProcess == process])
		ifTrue: [getCursorPosBlock value: aPOINT]
		ifFalse: [super getCursorPos: aPOINT]!

getCursorPosBlock: aMonadicValuable
	getCursorPosBlock := aMonadicValuable!

getForegroundWindow
	"Answer the handle of the window with which the user is currently working.
		HWND GetForegroundWindow(VOID)"

	^(getForegroundWindowBlock notNil and: [Processor activeProcess == process])
		ifTrue: [getForegroundWindowBlock value]
		ifFalse: [super getForegroundWindow]!

getForegroundWindowBlock: aNiladicValuable
	getForegroundWindowBlock := aNiladicValuable!

initializeForDesktopActive
	getForegroundWindowBlock := [self findWindow: 'Progman' lpWindowName: nil].
	getActiveWindowBlock := []!

invalidCall: anInteger
	| frame |
	frame := Processor activeProcess topFrame sender.
	messages add: (Message selector: frame method selector arguments: frame arguments).
	^0!

messages
	^messages!

open
	process := Processor activeProcess.
	user32 := User32.
	handle := user32 handle.
	self beFinalizable.
	UserLibrary setDefault: self.
	messages := OrderedCollection new! !

!UI.Tests.FakeUserLibrary categoriesForMethods!
close!public!realizing/unrealizing! !
getActiveWindow!public!win32 functions-keyboard input! !
getActiveWindowBlock:!initializing!private! !
getCursorPos:!public!win32 functions-cursor! !
getCursorPosBlock:!initializing!private! !
getForegroundWindow!public!win32 functions-keyboard input! !
getForegroundWindowBlock:!initializing!private! !
initializeForDesktopActive!initializing!public! !
invalidCall:!exceptions!private! !
messages!accessing!public! !
open!public!realizing/unrealizing! !
!

!UI.Tests.FakeUserLibrary class methodsFor!

clear
	"Private - Clear down cached external function addresses and any default 
	instances of the receiver from previous runs. etc."

	"Nothing to do"!

sharedVariableName
	^nil! !

!UI.Tests.FakeUserLibrary class categoriesForMethods!
clear!initializing!private! !
sharedVariableName!constants!private! !
!

