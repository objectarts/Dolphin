﻿"Filed out from Dolphin Smalltalk"!

Graphics.VirtualColor
	subclass: #'Graphics.ThemeColor'
	instanceVariableNames: 'name actualColor'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Graphics.ThemeColor guid: (Core.GUID fromString: '{5016060e-ec13-4e73-be45-ed636d352614}')!

Graphics.ThemeColor comment: '`ThemeColor` is a class of `VirtualColor`s that provide a named indirection to a real `Color`. They are useful for simple theming purposes, allowing view resources to be created that refer to named `ThemeColor`s which can then be changed to configure the desired actual colour later.

## Instance Variables:
  `name`		`Symbol`; the name of the colour in the logical scheme.
  `actualColor`	`Color`; the colour to which the instance currently resolves when used




'!

!Graphics.ThemeColor categoriesForClass!Drawing! !

!Graphics.ThemeColor methodsFor!

actualColor
	^(actualColor ?? Window) actualColor!

actualColor: aColor
	actualColor := aColor!

basicActualColor
	^actualColor!

name
	^name!

printOn: aPuttableStream
	"Append, to the <puttableStream>, target, a string whose characters are a description of the
	receiver as a developer would want to see it."

	| named |
	aPuttableStream nextPut: $(.
	named := NamedColors lookup: self name.
	named == self
		ifTrue: 
			[aPuttableStream
				print: Color;
				space;
				display: #named:;
				space;
				print: self name]
		ifFalse: 
			[aPuttableStream
				print: self class;
				nextPutAll: ' name: ';
				print: self name;
				nextPutAll: ' actualColor: ';
				print: self actualColor].
	aPuttableStream nextPut: $)!

setName: aSymbol actualColor: aColor
	name := aSymbol.
	actualColor := aColor!

shallowCopy
	"The receiver's instances are unique for each named value."

	^self!

stbSaveOn: anSTBOutFiler
	"Output the singleton receiver to anSTBOutFiler."

	anSTBOutFiler
		saveSingleton: self
		class: self basicClass
		name: self name! !

!Graphics.ThemeColor categoriesForMethods!
actualColor!accessing!public! !
actualColor:!accessing!public! !
basicActualColor!accessing!private! !
name!printing!public! !
printOn:!printing!public! !
setName:actualColor:!initializing!private! !
shallowCopy!copying!public! !
stbSaveOn:!binary filing!public! !
!

!Graphics.ThemeColor class methodsFor!

addNamed: aSymbol color: aColor
	| wrapper |
	wrapper := self name: aSymbol actualColor: aColor.
	^super addNamed: aSymbol color: wrapper!

initialize
	self addNamed: #dialog color: Face3d!

name: aSymbol actualColor: aColor
	<primitive: 157>
	^self basicNew setName: aSymbol actualColor: aColor!

stbReadFrom: anSTBInFiler format: anSTBClassConversion size: anInteger
	"Read an instance of the receiver from the binary filer, aSTBInFiler."

	"Implementation Note: Overridden in order to maintain unique instances without using a STBSingletonProxy."

	| answer ref colorName |
	ref := anSTBInFiler register: nil.
	colorName := anSTBInFiler basicNext.
	answer := NamedColors at: colorName
				ifAbsent: 
					["If the theme colour is not defined, return a colour that will make the fault obvious"
					self name: colorName actualColor: Color magenta].
	anSTBInFiler fixup: ref to: answer.
	^answer!

uninitialize
	NamedColors
		removeAllKeys: ((NamedColors select: [:each | each isKindOf: self]) collect: [:each | each name])! !

!Graphics.ThemeColor class categoriesForMethods!
addNamed:color:!instance creation!named colors!public! !
initialize!class initialization!development!public! !
name:actualColor:!instance creation!public! !
stbReadFrom:format:size:!binary filing!public! !
uninitialize!class hierarchy-removing!private! !
!

