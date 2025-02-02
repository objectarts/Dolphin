"Filed out from Dolphin Smalltalk"!

Core.Tests.DolphinTest
	subclass: #'Kernel.Tests.EventMessageSendTest'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Kernel.Tests.EventMessageSendTest guid: (Core.GUID fromString: '{d55436fd-a2dc-4d79-a1c1-c8b5351a6ef1}')!

Kernel.Tests.EventMessageSendTest comment: ''!

!Kernel.Tests.EventMessageSendTest categoriesForClass!Tests-Kernel-Objects! !

!Kernel.Tests.EventMessageSendTest methodsFor!

testAsMessageSend
	| subject |
	subject := EventMessageSend receiver: 1 selector: #yourself.
	self assert: subject asMessageSend equals: (MessageSend receiver: 1 selector: #yourself).
	subject := EventMessageSend receiver: Array selector: #with:.
	self assert: subject asMessageSend
		equals: (MessageSend
				receiver: Array
				selector: #with:
				argument: nil).
	subject := EventMessageSend receiver: Array selector: #with:with:.
	self assert: subject asMessageSend
		equals: (MessageSend
				receiver: Array
				selector: #with:with:
				arguments: #(nil nil))!

testNoArguments
	| subject |
	subject := EventMessageSend receiver: 1 selector: #yourself.
	self assert: subject value equals: 1.
	self assert: (subject valueWithArguments: #()) equals: 1.
	self assert: (subject value: 2) equals: 1.
	self assert: (subject valueWithArguments: #(2)) equals: 1.
	self assert: (subject value: 2 value: 3) equals: 1.
	self assert: (subject valueWithArguments: #(2 3)) equals: 1.
	self assert: (subject cull: 2) equals: 1.
	self assert: (subject cull: 2 cull: 3) equals: 1.
	self assert: (subject cull: 2 cull: 3 cull: 4) equals: 1.
!

testOneArgument
	| subject |
	subject := EventMessageSend
				receiver: Array
				selector: #with:
				argument: 1.
	MemoryManager current collectGarbage.
	self assert: subject value equals: #(1).
	self assert: (subject valueWithArguments: #()) equals: #(1).
	self assert: (subject value: 2) equals: #(2).
	self assert: (subject valueWithArguments: #(2)) equals: #(2).
	self assert: (subject value: 2 value: 3) equals: #(2).
	self assert: (subject valueWithArguments: #(2 3)) equals: #(2).
	self assert: (subject cull: 2) equals: #(2).
	self assert: (subject cull: 2 cull: 3) equals: #(2).
	self assert: (subject cull: 2 cull: 3 cull: 4) equals: #(2).!

testOneArgumentWithGC
	| subject |
	subject := EventMessageSend
				receiver: OrderedCollection new
				selector: #addAll:
				arguments: {Object new}.
	MemoryManager current collectGarbage.
	self should: [subject value] raise: MessageNotUnderstood!

testReceiverWithGC
	| subject |
	subject := EventMessageSend receiver: Object new selector: #yourself.
	MemoryManager current collectGarbage.
	self assert: subject value equals: DeadObject current!

testTwoArguments
	| subject |
	subject := EventMessageSend
				receiver: Array
				selector: #with:with:
				arguments: #(1 2).
	MemoryManager current collectGarbage.
	self assert: subject value equals: #(1 2).
	self assert: (subject value: 3) equals: #(3 2).
	self assert: (subject valueWithArguments: #(3)) equals: #(3 2).
	self assert: (subject valueWithArguments: #(3 4)) equals: #(3 4).
	self assert: (subject valueWithArguments: #(3 4 5)) equals: #(3 4).
	self assert: (subject cull: 4) equals: #(4 2).
	self assert: (subject cull: 4 cull: 5) equals: #(4 5).
	self assert: (subject cull: 4 cull: 5 cull: 6) equals: #(4 5).
	subject := EventMessageSend
				receiver: Array
				selector: #with:with:
				arguments: #(1).
	self assert: subject value equals: #(1 nil).
	self assert: (subject valueWithArguments: #()) equals: #(1 nil).
	self assert: (subject value: 2) equals: #(2 nil).
	self assert: (subject valueWithArguments: #(2)) equals: #(2 nil).
	self assert: (subject value: 2 value: 3) equals: #(2 3).
	self assert: (subject valueWithArguments: #(2 3)) equals: #(2 3).
	self assert: (subject
				value: 2
				value: 3
				value: 4)
		equals: #(2 3).
	self assert: (subject valueWithArguments: #(2 3 4)) equals: #(2 3).
	self assert: (subject cull: 4) equals: #(4 nil).
	self assert: (subject cull: 4 cull: 5) equals: #(4 5).
	self assert: (subject cull: 4 cull: 5 cull: 6) equals: #(4 5).
	subject := EventMessageSend
				receiver: Array
				selector: #with:with:
				arguments: #().
	self assert: subject value equals: #(nil nil).
	self assert: (subject valueWithArguments: #()) equals: #(nil nil).
	self assert: (subject value: 2) equals: #(2 nil).
	self assert: (subject valueWithArguments: #(2)) equals: #(2 nil).
	self assert: (subject value: 2 value: 3) equals: #(2 3).
	self assert: (subject valueWithArguments: #(2 3)) equals: #(2 3).
	self assert: (subject
				value: 2
				value: 3
				value: 4)
		equals: #(2 3).
	self assert: (subject valueWithArguments: #(2 3 4)) equals: #(2 3).
	self assert: (subject cull: 2) equals: #(2 nil).
	self assert: (subject cull: 2 cull: 3) equals: #(2 3).
	self assert: (subject cull: 2 cull: 3 cull: 4) equals: #(2 3).! !

!Kernel.Tests.EventMessageSendTest categoriesForMethods!
testAsMessageSend!public!testing! !
testNoArguments!public!testing! !
testOneArgument!public!testing! !
testOneArgumentWithGC!public!testing! !
testReceiverWithGC!public!testing! !
testTwoArguments!public!testing! !
!

