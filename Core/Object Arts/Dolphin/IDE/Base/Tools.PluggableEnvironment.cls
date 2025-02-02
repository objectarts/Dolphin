"Filed out from Dolphin Smalltalk"!

Refactory.Browser.BrowserEnvironmentWrapper
	subclass: #'Tools.PluggableEnvironment'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Tools.PluggableEnvironment guid: (Core.GUID fromString: '{09ce2832-6e4a-40f8-83c8-b7685a4f6b62}')!

Tools.PluggableEnvironment comment: '`PluggableEnvironment` is a Dolphin specific `BrowserEnvironment` that includes only those methods (and the classes of those methods) that pass a configurable `<monadicValuable>` filter. This is very useful for maintaining the contents of dynamically updating method browsers.

Instance Variables:
	filter		`<monadicValuable>` evaluated against each candidate method
'!

!Tools.PluggableEnvironment categoriesForClass!Refactory-Environments! !

!Tools.PluggableEnvironment methodsFor!

addMethods: methodCollection 
	^(self snapshot)
		addMethods: methodCollection;
		yourself!

classesAndSelectorsDo: aBlock
	environment
		classesDo: [:class | self selectorsForClass: class do: [:sel | aBlock value: class value: sel]]!

classesDo: aBlock
	environment classesDo: [:each | (self includesAnyMethodsOf: each) ifTrue: [aBlock value: each]]!

includesAnyMethodsOf: aClass 
	aClass selectorsAndMethodsDo: 
			[:eachSelector :eachMethod | 
			(environment includesSelector: eachSelector in: aClass) 
				ifTrue: [(filter value: eachMethod) ifTrue: [^true]]].
	^false!

includesClass: aClass 
	^(super includesClass: aClass) and: [self includesAnyMethodsOf: aClass]!

includesSelector: aSelector in: aClass
	^(super includesSelector: aSelector in: aClass) and: 
			[| method |
			method := aClass compiledMethodAt: aSelector ifAbsent: nil.
			method notNil and: [filter value: method]]!

selectorsForClass: aClass do: aBlock 
	"Override for improved performance."

	aClass methodsDo: 
			[:each | 
			((environment includesSelector: each selector in: aClass) and: [filter value: each]) 
				ifTrue: [aBlock value: each selector]]!

snapshot
	"Answer a static snapshot of this dynamic method environment."

	^(Refactory.Browser.SelectorEnvironment onMethods: self allMethods in: environment)
		label: self label;
		yourself!

storeOn: aStream 
	self snapshot storeOn: aStream! !

!Tools.PluggableEnvironment categoriesForMethods!
addMethods:!adding!public! !
classesAndSelectorsDo:!accessing!public! !
classesDo:!accessing!public! !
includesAnyMethodsOf:!private!testing! !
includesClass:!public!testing! !
includesSelector:in:!public!testing! !
selectorsForClass:do:!enumerating!public! !
snapshot!accessing!private! !
storeOn:!printing!public! !
!

!Tools.PluggableEnvironment class methodsFor!

onEnvironment: anEnvironment select: aMonadicValuable 
	^(self onEnvironment: anEnvironment)
		filter: aMonadicValuable;
		yourself! !

!Tools.PluggableEnvironment class categoriesForMethods!
onEnvironment:select:!instance creation!public! !
!

