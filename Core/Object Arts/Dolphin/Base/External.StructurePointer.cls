﻿"Filed out from Dolphin Smalltalk"!

External.Structure
	subclass: #'External.StructurePointer'
	instanceVariableNames: 'elementClass'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

External.StructurePointer guid: (Core.GUID fromString: '{e3b2fb6a-4ea0-48f6-bd97-5f65c176fb00}')!

External.StructurePointer comment: ''!

!External.StructurePointer categoriesForClass!External-Data-Structured! !

!External.StructurePointer methodsFor!

elementClass
	"Private - Answer the value of the receiver's ''elementClass'' instance variable."

	^elementClass!

elementClass: anObject
	"Private - Set the value of the receiver's ''elementClass'' instance variable to the argument, anObject."

	elementClass := anObject!

value
	"Answer the receiver's value field as a Smalltalk object."

	^self elementClass fromAddress: bytes! !

!External.StructurePointer categoriesForMethods!
elementClass!accessing!private! !
elementClass:!accessing!private! !
value!accessing!public! !
!

!External.StructurePointer class methodsFor!

byteSize
	^VMConstants.IntPtrSize!

elementClass: elementClass
	"Answer a new instance of the receiver that will contain a pointer to
	an <ExternalStructure> or the specified type."

	^self new
		elementClass: elementClass;
		yourself!

fromAddress: anAddress elementClass: elementClass
	"Answer a new instance of the receiver that contains a pointer to
	an <ExternalStructure> of the specified type."

	^anAddress isNull ifFalse: [
		self basicNew
			initializeAtAddress: anAddress;
			elementClass: elementClass;
			yourself]!

getFieldNames
	^#(#value)!

newNull: pointerClass elementClass: elementClass
	"Answer a new instance of the receiver that contains an
	initially null memory pointer of the specified class pointer to 
	an <ExternalStructure> of the specified type."

	^self basicNew
		initializeAtAddress: pointerClass new;
		elementClass: elementClass;
		yourself! !

!External.StructurePointer class categoriesForMethods!
byteSize!accessing!public! !
elementClass:!instance creation!public! !
fromAddress:elementClass:!instance creation!public! !
getFieldNames!constants!private! !
newNull:elementClass:!instance creation!public! !
!

