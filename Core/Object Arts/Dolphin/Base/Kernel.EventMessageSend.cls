"Filed out from Dolphin Smalltalk"!

Core.MessageSendAbstract
	variableSubclass: #'Kernel.EventMessageSend'
	instanceVariableNames: 'expectedArgCount'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Kernel.EventMessageSend guid: (Core.GUID fromString: '{87b4c663-026e-11d3-9fd7-00a0cc3e4a32}')!

Kernel.EventMessageSend comment: 'An EventMessageSend is a fully closed <Message>, including receiver object, the message selector, and an array of sufficient arguments, however the receiver is referenced weakly.

When evaluate with extra arguments, an EventMessageSend merges its own argument with those supplied at evaluation time with the latter taking precedence from the left. For example if the message requires two arguments, and one is supplied at evaluation time, then the first argument sent will be that one, and the second the second of the arguments stored in the EventMessageSend itself.'!

!Kernel.EventMessageSend categoriesForClass!System-Support! !

!Kernel.EventMessageSend methodsFor!

argumentCount
	"Answer the <integer> number of arguments in the receiver's message."

	^expectedArgCount!

asMessageSend
	^MessageSend
		receiver: self receiver
		selector: selector
		arguments: ((Array new: expectedArgCount)
				replaceFrom: 1
					to: (expectedArgCount min: args basicSize)
					with: args
					startingAt: 1;
				yourself)!

forwardTo: anObject withArguments: triggerArguments
	"Private - Send the receiver Message to the <Object>, anObject, with the <Array> of arguments, anArray.	
	If insufficient arguments are supplied then these are substituted with arguments supplied at the 	
	time the event handler was registered, or nils if there are still insufficient. If the combined number 
	of arguments is greater than that required, then the arguments supplied at trigger time take precedence."

	^anObject perform: selector
		withArguments: (expectedArgCount == triggerArguments basicSize 
				ifTrue: [triggerArguments]
				ifFalse: [self mergeArguments: triggerArguments])!

mergeArguments: triggerArguments
	| actualArgs |
	actualArgs := Array new: expectedArgCount.
	actualArgs
		replaceFrom: 1
			to: (expectedArgCount min: args basicSize)
			with: args
			startingAt: 1;
		replaceFrom: 1
			to: (expectedArgCount min: triggerArguments basicSize)
			with: triggerArguments
			startingAt: 1.
	^actualArgs!

postCopy
	self beWeak.
	^self!

receiver
	^self basicAt: 1!

receiver: anObject selector: aSymbol arguments: argArray
	"Private - Initialize the receiver's instance variables."

	self basicAt: 1 put: anObject.
	selector := aSymbol.
	expectedArgCount := aSymbol argumentCount.
	args := argArray!

selector: aSelector
	"Sets the selector for the receiver to aSelector. Also
	computes the expected argument count that will be required
	when the selector is sent."

	super selector: aSelector.
	expectedArgCount := aSelector argumentCount.
	args := #()!

value
	"Evaluates the receiver send the message identified by the 
	receiver's selector to the receiver's receiver, with the 
	receiver's arguments, and answers the result."

	^expectedArgCount == 0
		ifTrue: [self receiver perform: selector]
		ifFalse: 
			[self receiver perform: selector
				withArguments: (expectedArgCount == args size ifTrue: [args] ifFalse: [self mergeArguments: #()])]! !

!Kernel.EventMessageSend categoriesForMethods!
argumentCount!accessing!public! !
asMessageSend!converting!public! !
forwardTo:withArguments:!evaluating!private! !
mergeArguments:!evaluating!private! !
postCopy!copying!public! !
receiver!accessing!debugger-step over!public! !
receiver:selector:arguments:!initializing!private! !
selector:!accessing!public! !
value!evaluating!public! !
!

!Kernel.EventMessageSend class methodsFor!

new
	^(self new: 1) beWeak; yourself! !

!Kernel.EventMessageSend class categoriesForMethods!
new!instance creation!public! !
!

