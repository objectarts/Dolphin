﻿"Filed out from Dolphin Smalltalk"!

Core.Tests.DolphinTest
	subclass: #'OS.Tests.AbstractIN_ADDRTest'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

OS.Tests.AbstractIN_ADDRTest guid: (Core.GUID fromString: '{3ee8e123-5c5b-41c7-9cab-ce7297da123b}')!

OS.Tests.AbstractIN_ADDRTest isNonInstantiable: true!

OS.Tests.AbstractIN_ADDRTest comment: ''!

!OS.Tests.AbstractIN_ADDRTest methodsFor!

canonicalInstance
	^self subclassResponsibility!

testDisplayOn
	self subclassResponsibility!

testPrintOn
	| subject |
	subject := self canonicalInstance.
	self assert: subject printString equals: 'an <p>(<s>)' << {subject class. subject displayString}! !

!OS.Tests.AbstractIN_ADDRTest categoriesForMethods!
canonicalInstance!helpers!private! !
testDisplayOn!public!unit tests! !
testPrintOn!public!unit tests! !
!

