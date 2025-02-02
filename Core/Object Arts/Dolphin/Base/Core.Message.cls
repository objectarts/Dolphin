"Filed out from Dolphin Smalltalk"!

Core.Object
	subclass: #'Core.Message'
	instanceVariableNames: 'selector args'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Core.Message guid: (Core.GUID fromString: '{87b4c49e-026e-11d3-9fd7-00a0cc3e4a32}')!

Core.Message comment: ''!

!Core.Message categoriesForClass!Kernel-Methods! !

!Core.Message methodsFor!

= aMessage
	"Answer true if the receiver and aMessage are equal.
	Since we override = we also override hash."

	^self == aMessage or: [
		self species == aMessage species and: [
			self selector == aMessage selector and: [self arguments = aMessage arguments]]]!

argument
	"Answer the single argument to the message. Raise an error if it does not take one argument."

	^args single!

argumentCount
	"Answer the <integer> number of arguments in the receiver's message."

	^args size!

arguments
	"Answer a <sequencedReadableCollection> containing the receiver's
	arguments."

	^args!

arguments: anArray
	"Set the argument list of the receiver to anArray.
	Answer the receiver."

	args := anArray
!

asSymbol
	"Answer the receiver's <selector>."

	^selector!

cull: anObject 
	^self value: anObject!

cull: arg1 cull: arg2 
	^self argumentCount == 0 ifTrue: [self cull: arg1] ifFalse: [self value: arg1 value: arg2]!

forwardTo: anObject
	"Send the receiver Message to anObject for evaluation, 
	answering the result"

	^anObject perform: selector withArguments: args!

forwardTo: anObject with: aParameter
	"Private - Send the receiver Message to anObject for evaluation with aParameter, 
	answering the result"

	^anObject perform: selector with: aParameter

!

forwardTo: anObject withArguments: anArray
	"Private - Send the receiver Message to anObject for evaluation with anArray of arguments, 
	answering the result"

	^anObject perform: selector withArguments: anArray
!

hash
	"Since we implement = we must also implement hash to match"
	
	^selector hash + args hash!

isSelfEvaluating
	^self class == ##(self) and: [args isSelfEvaluating]!

messages
	"Answer a <collection> of the messages sent by the receiver."

	^{self selector}!

numArgs
	^self argumentCount!

printOn: aPuttableStream
	"Append a short textual description of the receiver to the <puttableStream>, target, in the form a developer might want to see it, preferring an evaluable representation if available."

	| argCount |
	self isSelfEvaluating
		ifTrue: 
			[aPuttableStream
				nextPutAll: self class name;
				nextPutAll: ' selector: ';
				print: selector.
			argCount := args size.
			argCount > 0
				ifTrue: 
					[argCount == 1
						ifTrue: 
							[aPuttableStream
								nextPutAll: ' argument: ';
								print: args first]
						ifFalse: 
							[aPuttableStream
								nextPutAll: ' arguments: ';
								print: args]]]
		ifFalse: 
			[| keywords |
			aPuttableStream
				basicPrint: self;
				nextPut: $(.
			keywords := selector keywords.
			1 to: keywords size
				do: 
					[:i |
					i == 1 ifFalse: [aPuttableStream space].
					aPuttableStream
						nextPutAll: (keywords at: i);
						space;
						print: (args at: i)].
			aPuttableStream nextPut: $)]!

selector
	"Answer the receiver's <selector>"

	^selector!

selector: aSymbol
	"Set the <selector> for the receiver to the argument."

	selector := aSymbol.!

selector: aSymbol arguments: argArray
	"Private - Initialize the receiver's instance variables."

	selector := aSymbol.
	args := argArray!

value: anObject
	"Answer the result of sending the receiver to the object, anObject.
	Implementation Note: By implementing this selector from the monadic valuable protocol, we enable the substitution of Messages for a large number of parameterization cases where blocks would otherwise be required."

	^anObject perform: selector withArguments: args!

value: receiver value: argument
	"Answer the result of sending the receiving message to the object, receiver, with the argument, argument.
	Implementation Note: By implementing this selector from the dyadic valuable protocol, we enable the substitution of Messages for a further set of parameterization cases where blocks would otherwise be required."

	^receiver perform: selector with: argument!

value: receiver value: arg1 value: arg2
	"Answer the result of sending the receiving message to the object, receiver, with the arguments, arg1, and arg2."

	^receiver perform: selector with: arg1 with: arg2!

value: receiver value: arg1 value: arg2 value: arg3
	"Answer the result of sending the receiving message to the object, receiver, with the arguments, arg1, arg2 and arg3."

	^receiver
		perform: selector
		with: arg1
		with: arg2
		with: arg3!

valueWithArguments: argArray
	"Evaluate the receiver with an <Array> of arguments in argArray"

	^self forwardTo: argArray first withArguments: (argArray copyFrom: 2)! !

!Core.Message categoriesForMethods!
=!comparing!public! !
argument!accessing!public! !
argumentCount!accessing!public! !
arguments!accessing!public! !
arguments:!accessing!public! !
asSymbol!converting!public! !
cull:!evaluating!public! !
cull:cull:!evaluating!public! !
forwardTo:!operations!public! !
forwardTo:with:!operations!private! !
forwardTo:withArguments:!operations!private! !
hash!comparing!public! !
isSelfEvaluating!private!testing! !
messages!enquiries!public! !
numArgs!accessing!public! !
printOn:!printing!public! !
selector!accessing!public! !
selector:!accessing!public! !
selector:arguments:!initializing!private! !
value:!evaluating!public! !
value:value:!evaluating!public! !
value:value:value:!evaluating!public! !
value:value:value:value:!evaluating!public! !
valueWithArguments:!evaluating!public! !
!

Core.Message methodProtocol: #commandMessage attributes: #(#readOnly) selectors: #(#asSymbol #forwardTo:)!
Core.Message methodProtocol: #dyadicValuable attributes: #(#readOnly) selectors: #(#argumentCount #value:value: #valueWithArguments:)!
Core.Message methodProtocol: #failedMessage attributes: #(#ansi #readOnly) selectors: #(#arguments #selector)!
Core.Message methodProtocol: #message attributes: #() selectors: #(#argumentCount #forwardTo: #value: #value:value: #valueWithArguments:)!
Core.Message methodProtocol: #messageSender attributes: #(#readOnly) selectors: #(#messages)!
Core.Message methodProtocol: #monadicValuable attributes: #(#readOnly) selectors: #(#argumentCount #value: #valueWithArguments:)!

!Core.Message class methodsFor!

selector: aSymbol 
	"Answer a new instance of the receiver with the selector, aSymbol"

	^self selector: aSymbol arguments: #()!

selector: aSymbol argument: anObject
	"Answer a new instance of the receiver with selector, aSymbol, and argument, 
	anObject"

	^self selector: aSymbol arguments: {anObject}!

selector: aSymbol arguments: anArray 
	"Answer a new instance of the receiver with selector, aSymbol, and arguments, anArray"

	<primitive: 157>
	^self new selector: aSymbol arguments: anArray! !

!Core.Message class categoriesForMethods!
selector:!instance creation!public! !
selector:argument:!instance creation!public! !
selector:arguments:!instance creation!public! !
!

