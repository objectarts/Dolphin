﻿"Filed out from Dolphin Smalltalk"!

Core.Boolean
	subclass: #'Core.False'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Core.False guid: (Core.GUID fromString: '{87b4c4fd-026e-11d3-9fd7-00a0cc3e4a32}')!

Core.False comment: 'The False class implements the behaviour of the false (logical false) object.

False is a singleton whose sole instance is the object represented by the reserved word, false. (i.e. any reference to false will always answer true when compared with any other using the #== message).

False implement the ANSI protocols <Object> and <boolean>.'!

!Core.False categoriesForClass!Kernel-Objects! !

!Core.False methodsFor!

and: operand 
	"Answer whether the receiver and the result of evaluating the <niladicValuable>,
	 operand, are both true. The argument is only evaluated if the receiver is true."

	"Implementation Note:  The compiler inlines this message if the argument
	is a literal block. The compiler assumes that the receiver will be a boolean,
	so this message cannot be overridden."

	^self!

asInteger
	"Answer a sensible integer equivalent of the receiver."

	^0!

asParameter
	"Answer the value of the receiver in a form suitable for passing to an external function call."

	^OS.Win32Constants.FALSE!

ifFalse: operand 
	"Evaluate and answer the result of the evaluating the <niladicValuable>
	argument, operand, if the receiver is false, otherwise answer nil. "

	"Implementation Note:  The compiler inlines this message if the argument
	is a literal block. The compiler assumes that the receiver will be a boolean,
	so this message cannot be overridden."

	^operand value!

ifFalse: falseOperand ifTrue: trueOperand 
	"Evaluate, and answer the result, of the <niladicValuable>, falseOperand, if 
	the receiver is false, or the <niladicValuable>, trueOperand, if the receiver is 
	true."

	"Implementation Note:  The compiler inlines this message if the arguments
	are literal blocks. The compiler assumes that the receiver will be a boolean,
	so this message cannot be overridden."

	^falseOperand value!

ifTrue: operand 
	"Evaluate and answer the result of the evaluating the <niladicValuable>
	argument, operand, if the receiver is true, otherwise answer nil."

	"Implementation Note:  The compiler inlines this message if the argument
	is a literal block. The compiler assumes that the receiver will be a boolean,
	so this message cannot be overridden."

	^nil!

ifTrue: trueOperand ifFalse: falseOperand 
	"Evaluate, and answer the result, of the <niladicValuable>, falseOperand, if 
	the receiver is false, or the <niladicValuable>, trueOperand, if the receiver is 
	true."

	"Implementation Note:  The compiler inlines this message if the arguments
	are literal blocks. The compiler assumes that the receiver will be a boolean,
	so this message cannot be overridden."

	^falseOperand value!

not
	"Answer the logical inverse of the receiver."

	^true
!

or: operand 
	"Answer whether either the receiver or the result of evaluating the
	<niladicValuable> argument, operand, is true. The argument is only
	evaluated if the receiver is false."

	"Implementation Note:  The compiler inlines this message if the argument
	is a literal block. The compiler assumes that the receiver will be a boolean,
	so this message cannot be overridden."

	^operand value!

printString
	"Answer a <readableString> whose characters are a description of the receiver as a developer would want to see it."

	^'false'!

xor: operand
	"Answer whether either the receiver or the boolean argument <operand> is true, but not both.
	Since the receiver is false, the answer depends entirely on the argument."

	^operand! !

!Core.False categoriesForMethods!
and:!control flow!public! !
asInteger!converting!public! !
asParameter!converting!public! !
ifFalse:!control flow!public! !
ifFalse:ifTrue:!control flow!public! !
ifTrue:!control flow!public! !
ifTrue:ifFalse:!control flow!public! !
not!logical operations!public! !
or:!control flow!public! !
printString!printing!public! !
xor:!logical operations!public! !
!

