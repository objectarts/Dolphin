﻿"Filed out from Dolphin Smalltalk"!

Core.Tests.DolphinTestClassResource
	subclass: #'Core.Tests.MustBeBooleanTestClasses'
	instanceVariableNames: 'trueClass falseClass'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Core.Tests.MustBeBooleanTestClasses guid: (Core.GUID fromString: '{7a283553-a0fa-4c3f-8502-7d21d0babca4}')!

Core.Tests.MustBeBooleanTestClasses comment: ''!

!Core.Tests.MustBeBooleanTestClasses methodsFor!

createClasses
	trueClass := self
				createClass: #MustBeBooleanTestTrueClass
				superclass: Object
				instVars: ''
				imports: #()
				classVars: ''
				classConsts: #().
	trueClass compile: 'mustBeBoolean ^true'.
	falseClass := self
				createClass: #MustBeBooleanTestFalseClass
				superclass: Object
				instVars: ''
				imports: #()
				classVars: ''
				classConsts: #().
	falseClass compile: 'mustBeBoolean ^false'!

falseClass
	^falseClass!

isAvailable
	^trueClass notNil!

tearDown
	super tearDown.
	trueClass := falseClass := nil!

trueClass
	^trueClass! !

!Core.Tests.MustBeBooleanTestClasses categoriesForMethods!
createClasses!public!unit tests! !
falseClass!accessing!public! !
isAvailable!public!Testing! !
tearDown!public!Running! !
trueClass!accessing!public! !
!

