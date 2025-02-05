﻿"Filed out from Dolphin Smalltalk"!

External.ArrayFieldLength
	subclass: #'External.SizeIsArrayFieldLength'
	instanceVariableNames: 'sizeIs getLength setLength'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

External.SizeIsArrayFieldLength guid: (Core.GUID fromString: '{3f017262-aded-499e-9c07-da6937249262}')!

External.SizeIsArrayFieldLength comment: ''!

!External.SizeIsArrayFieldLength categoriesForClass!Kernel-Objects! !

!External.SizeIsArrayFieldLength methodsFor!

buildLengthReader: anExternalField
	| expr blockArg structClass |
	blockArg := '__struct'.
	expr := String writeStream.
	expr
		nextPutAll: '[:';
		nextPutAll: blockArg;
		nextPutAll: ' | '.
	structClass := anExternalField structClass.
	(SizeIsExpressionFormatter structClass: structClass variable: blockArg)
		format: self sizeIsExpression
		on: expr.
	expr nextPut: $].
	^Compiler evaluate: expr contents for: structClass environment: structClass environment!

buildLengthWriter: anExternalField
	| expr varName |
	expr := anExternalField structClass newCodeGenerationContext.
	varName := '__struct'.
	self
		printSetSizeIsExpression: self sizeIsExpression
		for: anExternalField
		variable: varName
		on: expr.
	expr := expr contents.
	^expr isEmpty
		ifTrue: [[:struct :value | value]]
		ifFalse: 
			[| structClass |
			expr := String smalltalkWriteStream
						nextPutAll: '[:';
						nextPutAll: varName;
						nextPutAll: ' :';
						nextPutAll: anExternalField valueParameterName;
						nextPutAll: ' | ';
						nextPutAll: expr;
						nextPut: $];
						contents.
			structClass := anExternalField structClass.
			Compiler
				evaluate: expr
				for: structClass
				environment: structClass environment]!

getElementCountOf: anExternalField in: anExternalStructure
	"Private - Answer the number of elements in the conformant array pointer field of the
	<ExternalStructure> argument. This is calculated by evaluating the size_is expression, and
	is generally proportional to the value of an <integer> length field also stored in the
	structure."

	getLength isNil ifTrue: [getLength := self buildLengthReader: anExternalField].
	^getLength value: anExternalStructure!

invertSizeIsExpression: aParseTree paramName: aString
	| variables assignment |
	assignment := StAssignmentNode variable: (StBasicVariableNode named: aString , ' size') value: aParseTree.
	variables := OrderedCollection new.
	assignment nodesDo: [:each | each isVariable ifTrue: [variables add: each]].
	variables size > 2
		ifTrue: 
			["We can only solve for one variable, and only if it appears once in the
			 expression. Although the latter case could be handled by simplifying the
			 expression, this is unlikely to occur in practice."
			^nil].
	^assignment solveFor: variables first name!

printElementCountExpressionFor: anExternalField on: aCodeGenerationContext
	(SizeIsExpressionFormatter structClass: anExternalField structClass variable: 'self')
		format: self sizeIsExpression
		on: aCodeGenerationContext writeStream!

printSetSizeFor: anExternalField on: aCodeGenerationContext
	self
		printSetSizeIsExpression: self sizeIsExpression
		for: anExternalField
		variable: 'self'
		on: aCodeGenerationContext!

printSetSizeIsExpression: aStProgramNode for: anExternalField variable: aString on: aCodeGenerationContext
	| expr setter structClass sizeFieldName |
	expr := self invertSizeIsExpression: aStProgramNode paramName: anExternalField valueParameterName.
	sizeFieldName := expr variable name.
	setter := (sizeFieldName , ':') asSymbol.
	structClass := anExternalField structClass.
	((structClass template includesKey: sizeFieldName) or: [structClass canUnderstand: setter])
		ifTrue: 
			[| stream |
			stream := aCodeGenerationContext writeStream.
			stream
				nextPutAll: aString;
				space;
				display: setter;
				space.
			(SizeIsExpressionFormatter structClass: structClass variable: aString) format: expr value on: stream.
			stream
				nextPut: $.;
				crtab]!

setElementCount: anArrayedCollection of: anExternalField in: anExternalStructure
	"Private - Set the length field corresponding to this array field, if any."

	setLength isNil ifTrue: [setLength := self buildLengthWriter: anExternalField].
	^setLength value: anExternalStructure value: anArrayedCollection!

sizeIs: aString
	sizeIs := aString!

sizeIsExpression
	^Parser parseExpression: sizeIs! !

!External.SizeIsArrayFieldLength categoriesForMethods!
buildLengthReader:!accessing!private! !
buildLengthWriter:!accessing!private! !
getElementCountOf:in:!indirect accessing!private! !
invertSizeIsExpression:paramName:!private! !
printElementCountExpressionFor:on:!automatic generation!private! !
printSetSizeFor:on:!automatic generation!development!private! !
printSetSizeIsExpression:for:variable:on:!automatic generation!development!private! !
setElementCount:of:in:!indirect accessing!private! !
sizeIs:!accessing!private! !
sizeIsExpression!automatic generation!private! !
!

!External.SizeIsArrayFieldLength class methodsFor!

sizeIs: aString
	"Answer a new instance of the receiver to describe a conformant (sized) array length
	expressed by a size_is expression, which is a simple arithmetic expression in terms of one
	or more other named fields of the <ExternalStructure> of which the owning <ExternalField> is
	a field."

	^self new sizeIs: aString! !

!External.SizeIsArrayFieldLength class categoriesForMethods!
sizeIs:!instance creation!public! !
!

