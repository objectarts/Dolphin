﻿"Filed out from Dolphin Smalltalk"!

UI.LayoutManager
	subclass: #'UI.CardLayout'
	instanceVariableNames: 'names currentCard events _unused4 _unused5'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

UI.CardLayout guid: (Core.GUID fromString: '{87b4c647-026e-11d3-9fd7-00a0cc3e4a32}')!

UI.CardLayout comment: '`CardLayout` implements a specialised `<layoutManager>` to layout `<view>` objects within a `<cardView>`. It arranges the contained views so that they stack on top of one another in z-order sequence. Only one of the views, the so-called current card, is allowed to be visible at any one time.

The arrangement aspects of the managed views are used as a descriptive names for the cards (generally instances of `CardLabel`). The containing `<cardView>` may make use of these names as it sees fit. For example, a `CardContainer` uses these as the names for the tabs that it displays.

## Instance Variables:
  `names`			`OrderedCollection` of `Association`, pairing card names with each of the managed views.
  `currentCard` 	`<view>` that is currently visible in the container.
  `events`			`<eventsCollection>`



'!

!UI.CardLayout categoriesForClass!MVP-Layout Managers-Specialized! !

!UI.CardLayout methodsFor!

arrangementOf: aView
	"Answer the arrangement parameter of aView in the receiver"

	^(names detect: [:each | each value == aView] ifNone: [##(Association new)]) key!

arrangementOf: aView put: anObject
	"Set the arrangement parameter of aView in the receiver to be anObject."

	(names detect: [:each | each value == aView] ifNone: nil)
		ifNotNil: [:previous | previous key: anObject]
		ifNil: [names add: anObject -> aView]!

cards
	"Private - Answer an OrderedCollection of views that are managed by the 
	receiver. These views are in the z-order sequence of the ContainerView
	that manages them"

	| views container |
	views := self cardViews.
	views isEmpty ifTrue: [^OrderedCollection new].
	container := views anyOne parentView.
	^container managedSubViews select: [:each | views includes: each]!

cardViews
	"Answers the Set of views that are managed by the receiver"

	| views |
	views := names collect: [:each | each value].
	^views asSet!

changeDefaultButton: aView
	| shellView |
	currentCard
		ifNotNil: 
			[shellView := currentCard topView.
			currentCard allSubViewsDo: 
					[:each |
					each isDefaultButton
						ifTrue: 
							[shellView defaultButtonId: each id.
							^self]]].
	aView ifNil: [^self].
	"The new current card has no default button, but we may still want to reset the shell's default if it was on the previous card"
	shellView := aView topView.
	(shellView defaultButtonId ~~ 0
		and: [(aView findItemHandle: shellView defaultButtonId ifAbsent: nil) notNil])
			ifTrue: 
				["Default button was indeed on the hidden card"
				shellView resetDefaultButton]!

currentCard
	"Answer the current card or nil if there is none"

	^currentCard!

cycleNextCard
	"Select the next card in z order sequence after the current card.
	Cycle round to the first card in the sequence where necessary.
	Answers the card selected"

	self nextCard isNil ifTrue: [ self firstCard ].
	^self currentCard
	!

cyclePreviousCard
	"Select the previous card in z order sequence before the current card.
	Cycle round to the last card in the sequence where necessary.
	Answers the card selected"

	self previousCard isNil ifTrue: [ self lastCard ].
	^self currentCard
	!

firstCard
	"Show the card which is first in the z-order sequence of the 
	associated container. It is an error to ask for the first card
	when there is none. Answers the view that is the first card."
	
	| card |
	card := self cards first.
	self showCard: card.
	^card!

getEvents
	"Private - Answer the EventsCollection belonging to the receiver, or nil if the receiver
	has no events registered for it"

	^events!

initialize
	"Private - Initialize the state of the receiver."

	super initialize.
	names := OrderedCollection new!

lastCard
	"Show the card which is last in the z-order sequence of the 
	associated container. It is an error to ask for the first card
	when there is none. Answers the view that is the last card."
	
	| card |
	card := self cards last.
	self showCard: card.
	^card!

layoutContainer: aCompositeView context: aLayoutContext 
	"Private - Update the <LayoutContext> argument with rectangles for the sub-views of the
	specified container view, laying out those sub-views according to the rules and
	configuration of the particular layout manager."

	| rect |
	rect := (0 @ 0 extent: (aLayoutContext clientExtentOf: aCompositeView)) 
				insetBy: (aCompositeView actualInsets: aLayoutContext).
	aCompositeView managedSubViewsDo: [:view | aLayoutContext setView: view rectangle: rect]!

names
	^names!

nextCard
	"Show the card which is next in the z-order sequence of the associated container after the
	current card that is visible. Answers the view that is the next card, or nil if there is
	none"

	| index cards |
	cards := self cards.
	index := (cards indexOf: currentCard) + 1.
	^index <= cards size 
		ifTrue: 
			[| card |
			card := cards at: index.
			self showCard: card.
			card]!

preferredLayoutExtentOf: aCompositeView context: aLayoutContext 
	"Answer a <Point> specifying the preferred extent for the <CompositeView> argument when
	laying out in the context of the specified <LayoutContext>."

	"Implementation Note: The preferred extent is the maximum extent required by any card in
	both dimensions"

	| max insets |
	max := 0 @ 0.
	aCompositeView managedSubViewsDo: 
			[:each | 
			| extent |
			extent := aLayoutContext extentOf: each.
			max
				x: (max x max: extent x);
				y: (max y max: extent y)].
	insets := aCompositeView actualInsets: aLayoutContext.
	^max + insets origin + insets corner!

previousCard
	"Show the card which is previous in the z-order sequence of the associated container before
	the current card that is visible. Answers the view that is the previous card, or nil if
	there is none"

	| index cards |
	cards := self cards.
	index := (cards indexOf: currentCard ifAbsent: [2]) - 1.
	^index > 0 
		ifTrue: 
			[| card |
			card := cards at: index.
			self showCard: card.
			card]!

removeSubView: aView
	"Remove aView from the collection of views which have been explicitly
	arranged by the receiver.
	Answer aView."

	aView==currentCard ifTrue: [ currentCard := nil ].
	names copy do: [:assoc |
		assoc value == aView ifTrue: [ names remove: assoc ]].
	^aView
!

setEvents: anEventsCollectionOrNil
	events := anEventsCollectionOrNil!

showCard: aView
	"Show the card, aView and make this the current card. Any existing current card is hidden."

	| previousCard |
	currentCard == aView ifTrue: [^self].
	aView show.
	currentCard notNil ifTrue: [currentCard hide].
	previousCard := currentCard.
	currentCard := aView.
	"We may need to change the default button id if it referred to a button on the hidden card"
	self changeDefaultButton: previousCard.
	self
		trigger: #currentCardChangedFrom:to:
		with: previousCard
		with: currentCard.
	"Also trigger the pre-8 event for backwards compatibility"
	self trigger: #currentCardChanged!

showCardWithArrangement: anObject
	"Show the card identified by an arrangement of anObject and make this the current card.
	Signals a NotFound exception if a matching view does not exist in the
	receiver. Answer the view that corresponds to anObject"
	
	| view |
	view := (names detect: [ :each | each key = anObject ]) value.
	self showCard: view.
	^view!

stbSaveOn: anSTBOutFiler
	"Output the receiver to anSTBOutFiler. We must ensure that the local events collection
	is NOT saved to the filer"

	anSTBOutFiler override: events with: nil.
	super stbSaveOn: anSTBOutFiler.! !

!UI.CardLayout categoriesForMethods!
arrangementOf:!accessing!public! !
arrangementOf:put:!accessing!public! !
cards!accessing!private! !
cardViews!accessing!private! !
changeDefaultButton:!helpers!private! !
currentCard!accessing!public! !
cycleNextCard!operations!public! !
cyclePreviousCard!operations!public! !
firstCard!operations!public! !
getEvents!events!private! !
initialize!initializing!private! !
lastCard!operations!public! !
layoutContainer:context:!geometry!private! !
names!accessing!private! !
nextCard!operations!public! !
preferredLayoutExtentOf:context:!public! !
previousCard!operations!public! !
removeSubView:!public!removing! !
setEvents:!events!private! !
showCard:!operations!public! !
showCardWithArrangement:!operations!public! !
stbSaveOn:!binary filing!public! !
!

!UI.CardLayout class methodsFor!

stbConvertFrom: anSTBClassFormat
	"Version 1 adds event instance variable and two spares."

	anSTBClassFormat version == 0
		ifTrue: [^[:data | (self stbConvertFromVersion0: data) becomeA: self]].
	^super stbConvertFrom: anSTBClassFormat!

stbConvertFromVersion0: anArray
	"Version 1 adds event instance variable and two spares."

	^anArray resize: anArray size + 3!

stbVersion
	^1! !

!UI.CardLayout class categoriesForMethods!
stbConvertFrom:!binary filing!private! !
stbConvertFromVersion0:!binary filing!private! !
stbVersion!binary filing!public! !
!

