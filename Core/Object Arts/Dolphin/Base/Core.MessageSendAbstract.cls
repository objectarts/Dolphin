"Filed out from Dolphin Smalltalk"!

Core.Message
	subclass: #'Core.MessageSendAbstract'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Core.MessageSendAbstract guid: (Core.GUID fromString: '{16bfd17c-2ce8-4b61-b09a-9d012256d971}')!

Core.MessageSendAbstract isNonInstantiable: true!

Core.MessageSendAbstract comment: 'A MessageSendAbstract is the abstract base class of fully closed <Message>s, that include a receiver object, a message selector, and an array of sufficient arguments. As a fully closed valuable, Message Sends can be evaluated by sending them the #value message, and they can frequently be employed where a <BlockClosure> might otherwise be used.

Athough Message Sends are complete in themselves, they also respond to the valuable messages which take arguments. The general principle is that the supplied arguments supplant those stored in the Message Send according to some algorithm determined by the particular subclass.'!

!Core.MessageSendAbstract categoriesForClass!Kernel-Methods! !

!Core.MessageSendAbstract methodsFor!

= aMessageSend
	"Answer true if the receiver and aMessage are equal.
	Since we override #= we also override hash."

	^super = aMessageSend and: [self receiver == aMessageSend receiver]!

cull: arg
	^self argumentCount == 0 ifTrue: [self value] ifFalse: [self value: arg]!

cull: arg1 cull: arg2 
	^self argumentCount < 2 ifTrue: [self cull: arg1] ifFalse: [self value: arg1 value: arg2]!

cull: arg1 cull: arg2 cull: arg3
	^self argumentCount < 3
		ifTrue: [self cull: arg1 cull: arg2]
		ifFalse: 
			[self
				value: arg1
				value: arg2
				value: arg3]!

cull: arg1 cull: arg2 cull: arg3 cull: arg4 
	^self argumentCount < 4 
		ifTrue: 
			[self 
				cull: arg1
				cull: arg2
				cull: arg3]
		ifFalse: 
			[self 
				value: arg1
				value: arg2
				value: arg3
				value: arg4]!

deferredValue
	"Answer a <niladicValuable> that begins evaluating the receiver asynchronously,
	and which when evaluated will synchronously supply the result."

	^self deferredValueAt: Processor activePriority!

deferredValueAt: priority
	"Answer a <niladicValuable> that begins evaluating the receiver asynchronously
	at the specified <Process> priority, and which when evaluated will synchronously 
	supply the result."

	^DeferredValue evaluate: self at: priority!

forwardTo: anObject
	"Send the receiver Message to anObject for evaluation, 
	answering the result"

	^self forwardTo: anObject withArguments: #()!

hash
	"Since we implement #= we must also implement hash to match."

	^selector hash + args hash + self receiver hash!

printOn: target 
	"Append a short textual description of the receiver to the <puttableStream>
	argument, target."

	target
		basicPrint: self;
		nextPut: $(;
		print: self receiver;
		nextPutAll: '>>';
		print: self selector.
	args notEmpty 
		ifTrue: 
			[target
				nextPutAll: ', ';
				print: args].
	target nextPut: $)!

receiver
	"Answer the receiver instance variable of the receiver (i.e the object which is 
	the current destination of the receiver should it be evaluated)"

	^self subclassResponsibility!

receiver: anObject selector: aSymbol arguments: argArray
	"Private - Initialize the receiver's instance variables."

	self subclassResponsibility!

selector: aSymbol arguments: argArray
	"Private - Initialize the receiver's instance variables."

	selector := aSymbol.
	args := argArray!

value
	"Evaluates the receiver send the message identified by the 
	receiver's selector to the receiver's receiver, with the 
	receiver's arguments, and answers the result."
	
	^self receiver perform: selector withArguments: args!

value: anObject
	"Answer the result of sending the receiver. 
	Implementation Note: By implementing this selector from the <monadicValuable>
	protocol, we enable the substitution of MessageSends for a
	large number of parameterization cases where blocks would otherwise
	be required."

	^self valueWithArguments: {anObject}!

value: arg1 value: arg2
	"Answer the result of sending the receiver.
	Implementation Note: By implementing this selector from the <dyadicValuable>
	 protocol, we enable the substitution of MessageSends for a
	large number of parameterization cases where blocks would otherwise
	be required. In any case we must override this because the superclass
	implementation is wrong for us."

	^self valueWithArguments: {arg1. arg2}!

value: arg1 value: arg2 value: arg3
	"Answer the result of sending the receiver with three arguments"

	^self valueWithArguments: {arg1. arg2. arg3}!

value: arg1 value: arg2 value: arg3 value: arg4
	"Answer the result of sending the receiver with four arguments"

	^self valueWithArguments: {arg1. arg2. arg3. arg4}!

valueWithArguments: triggerArguments
	"Executes the receiver with the specified <Array> of arguments. If insufficient arguments are
	supplied then these are substituted with arguments supplied at the time the event handler was
	registered, or nils if there are still insufficient. If the combined number of arguments is greater
	than that required, then the subclass determines which take precedence."

	^self forwardTo: self receiver withArguments: triggerArguments! !

!Core.MessageSendAbstract categoriesForMethods!
=!comparing!public! !
cull:!evaluating!public! !
cull:cull:!evaluating!public! !
cull:cull:cull:!evaluating!public! !
cull:cull:cull:cull:!evaluating!public! !
deferredValue!evaluating!public! !
deferredValueAt:!evaluating!public! !
forwardTo:!operations!public! !
hash!comparing!public! !
printOn:!printing!public! !
receiver!accessing!public! !
receiver:selector:arguments:!initializing!private! !
selector:arguments:!initializing!private! !
value!evaluating!public! !
value:!evaluating!public! !
value:value:!evaluating!public! !
value:value:value:!evaluating!public! !
value:value:value:value:!evaluating!public! !
valueWithArguments:!evaluating!public! !
!

Core.MessageSendAbstract methodProtocol: #niladicValuable attributes: #(#readOnly) selectors: #(#argumentCount #value #valueWithArguments:)!

!Core.MessageSendAbstract class methodsFor!

receiver: anObject selector: aSymbol
	"Answer a new instance of the receiver with the receiver, anObject, and selector, 
	aSymbol"

	^self 
		receiver: anObject
		selector: aSymbol
		arguments: #()!

receiver: anObject selector: aSymbol argument: aParameter
	"Answer a new instance of the receiver with the receiver, anObject, selector, 
	aSymbol, and argument, anObject"

	^self
		receiver: anObject
		selector: aSymbol
		arguments: {aParameter}!

receiver: anObject selector: aSymbol arguments: anArray 
	"Answer a new instance of the receiver with the receiver, anObject, selector, 
	aSymbol, and arguments, anArray"

	^(self new)
		receiver: anObject selector: aSymbol arguments: anArray;
		yourself!

selector: aSymbol arguments: anArray 
	"Answer a new instance of the receiver with selector, aSymbol, and arguments, anArray"

	^self 
		receiver: nil
		selector: aSymbol
		arguments: anArray! !

!Core.MessageSendAbstract class categoriesForMethods!
receiver:selector:!instance creation!public! !
receiver:selector:argument:!instance creation!public! !
receiver:selector:arguments:!instance creation!public! !
selector:arguments:!instance creation!public! !
!

