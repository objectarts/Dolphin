"Filed out from Dolphin Smalltalk"!

Core.Tests.DolphinTest
	subclass: #'Core.Tests.MessageTest'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Core.Tests.MessageTest guid: (Core.GUID fromString: '{aaa1f3a5-03cb-48f2-b067-a1ec0392ad2b}')!

Core.Tests.MessageTest comment: ''!

!Core.Tests.MessageTest methodsFor!

testCull
	| subject |
	subject := Message selector: #key:value: arguments: #(123 456).
	self assert: (subject cull: Association) equals: 123 -> 456.
	subject := Message selector: #isNil.
	self deny: (subject cull: 1)!

testCullCull
	| subject |
	subject := Message selector: #key:value: arguments: #(123 456).
	self should: [subject cull: Association cull: 'abc'] raise: Error matching: [:ex | ex description = 'Incorrect number of arguments: 1, expected 2'].
	subject := Message selector: #isNil.
	self deny: (subject cull: 1 cull: nil)!

testPrintString
	self assert: (Message selector: #x:y: arguments: #(123 456)) printString
		equals: 'Message selector: #x:y: arguments: #(123 456)'.
	self assert: (Message selector: #namespace:class: arguments: {Core. Object}) printString
		equals: 'Message selector: #namespace:class: arguments: {Core. Object}'.
	self assert: (Message selector: #namespace: argument: Core) printString
		equals: 'Message selector: #namespace: argument: Core'.
	self assert: (Message selector: #x:y: arguments: {123. Object new}) printString
		equals: 'a Message(x: 123 y: an Object)'!

testSelectorArguments
	| msg1 msg2 originalMethod testMethod |
	msg1 := Message selector: #x:y: arguments: #(123 456).
	self assert: msg1 selector identicalTo: #x:y:.
	self assert: msg1 arguments equals: #(123 456).
	originalMethod := Message class compiledMethodAt: #selector:arguments:.
	testMethod := originalMethod copy.
	"Sanity check"
	self deny: testMethod == originalMethod.
	testMethod extraIndex: 0.
	"Invoke the method directly so we don't need to install it."
	msg2 := testMethod value: Message withArguments: #(#x:y: #(123 456)).
	self assert: msg2 equals: msg1!

testValueColon
	| subject |
	subject := Message selector: #key:value: arguments: #(123 456).
	self assert: (subject value: Association) equals: 123 -> 456.
	subject := Message selector: #isNil.
	self deny: (subject value: 1).
	self assert: (subject value: nil).!

testValueColon2
	| subject |
	subject := Message selector: #new: arguments: #(nil).
	self assert: (subject value: Array value: 2) equals: (Array new: 2).! !

!Core.Tests.MessageTest categoriesForMethods!
testCull!public!unit tests! !
testCullCull!public!unit tests! !
testPrintString!public!unit tests! !
testSelectorArguments!public!unit tests! !
testValueColon!public!unit tests! !
testValueColon2!public!unit tests! !
!

