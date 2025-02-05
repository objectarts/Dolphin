﻿"Filed out from Dolphin Smalltalk"!

Kernel.StRealVariableNode
	subclass: #'Kernel.StParameterNode'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Kernel.StParameterNode guid: (Core.GUID fromString: '{f8fdcb03-7380-4984-a7c1-c79eaeafcbf3}')!

Kernel.StParameterNode comment: 'StParameterNode is a parse tree node that represents a parameter definition for a method or block.
'!

!Kernel.StParameterNode categoriesForClass!System-Compiler! !

!Kernel.StParameterNode methodsFor!

acceptVisitor: aProgramNodeVisitor
	^aProgramNodeVisitor visitParameterNode: self!

isConstantNode
	"Answer whether the receiver describes a constant that cannot be assigned to."

	^true!

isParameter
	^true! !

!Kernel.StParameterNode categoriesForMethods!
acceptVisitor:!public!visitor! !
isConstantNode!public!testing! !
isParameter!public!testing! !
!

