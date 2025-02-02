"Filed out from Dolphin Smalltalk"!

Tools.SmalltalkToolShell
	subclass: #'Tools.ClassBrowserAbstract'
	instanceVariableNames: 'classesPresenter categoriesPresenter methodBrowserPresenter definitionPresenter modePresenter flags history variablesPresenter protocolsPresenter filterPresenter packageModel statusModel cardsPresenter loadedPlugins methodCategories'
	classVariableNames: 'GrayedMethodFadeFactor HistoryListSize LooseMethodColor WordWrapDefinition'
	imports: #()
	classInstanceVariableNames: 'plugins'
	classConstants: { 'FilterObjectMethodsMask' -> 16r200. 'ShowInheritedMethodsMask' -> 16r100 }!

Tools.ClassBrowserAbstract guid: (Core.GUID fromString: '{87b4c6bc-026e-11d3-9fd7-00a0cc3e4a32}')!

Tools.ClassBrowserAbstract isNonInstantiable: true!

Tools.ClassBrowserAbstract comment: 'ClassBrowserAbstract is an abstract <SmalltalkToolShell> that implements most of the functionality required for a class browser development tool. Concrete subclasses implement the Class Hierarchy Browser and System Browser development tools.

Instance Variables:
	classesPresenter			<ClassHierarchySelector> displaying the class hierarchy.
	categoriesPresenter		<treePresenter> displaying the category hierarchy filtered for methods of the selected class.
	methodBrowserPresenter	<MethodBrowser> browsing methods in the selected class.
	definitionPresenter		<SmalltalkWorkspace> holding the current class definition.
	commentPresenter		<SmalltalkWorkspace> holding the current class comment.
	modePresenter			<listPresenter> displaying the Instance and Class mode tabs.
	flags					<integer> mode flags for the browser.
	history					<HistoryList> keeping a history of visited methods.
	variablesPresenter		<listPresenter> holding a list of instance variables for the current class.
	protocolsPresenter		<listPresenter> holding a list of protocols that the current class conforms to.
	filterPresenter			<CardContainer> holding the Categories, Protocols and Variables cards.
	packageModel			<valueModel>
	statusModel				<valueModel>

Class Variables:
	DefaultPackageName 			<readableString> package name into which new classes are added by default.
	LooseMethodColor 			<Color> used to paint foreground text of loose methods'' selectors in method pane
	WordWrapComment			<boolean> indicating whether the comment pane should would wrap.
	WordWrapDefinition			<boolean> indicating whether the definition pane should word wrap.
	ShowInheritedMethodsMask	<integer>
	FilterObjectMethodsMask		<integer>
	HistoryListSize				<integer>. Maximum number of entries in the visit history list.
	HistoryDwellTime			<integer>. Period of time for which it is necessary to dwell on a visit for an entry to be recorded in the history list.

Class Instance Variables:
	DefaultShowInheritedMethods	<boolean>
	DefaultFilterObjectMethods		<boolean>
'!

!Tools.ClassBrowserAbstract categoriesForClass!MVP-Presenters! !

!Tools.ClassBrowserAbstract methodsFor!

acceptItCommand
	"Private - Answer which of the various accept commands should apply at this time."

	self isDefinitionCardVisible ifTrue: [^#saveDefinition].
	^nil!

actualClass
	"Answer the actual class selected in the receiver after taking account of instance or class mode. Answer nil if there is no class selected"

	^classesPresenter actualClass!

actualClass: class
	"Sets the actual class selected and determines the current mode"

	classesPresenter actualClass: class!

actualClass: aClass ifAbsent: exceptionHandler
	"Sets the actual class selected and determines the current mode."

	classesPresenter actualClass: aClass ifAbsent: exceptionHandler!

actualClassChain
	"Private - Answer the method search chain for the actual class selected in the receiver after taking account
	of instance or class mode and whether superclass searching is enabled."

	| actualClass chain |
	(actualClass := self actualClass) ifNil: [^#()].
	self isShowInheritedMethods ifFalse: [^{ actualClass }].
	chain := actualClass withAllSuperclasses.
	self isFilterObjectMethods
		ifTrue: 
			[| objectClass |
			objectClass := self isInstanceMode ifTrue: [Object] ifFalse: [Object class].
			actualClass ~~ objectClass
				ifTrue: 
					[| i |
					i := chain identityIndexOf: objectClass.
					i == 0 ifFalse: [chain := chain copyFrom: 1 to: i - 1]]].
	^chain!

actualClassChainCategories
	"Private - Answer an <set> of all the method categories in the search chain for the actual class selected in the receiver.
	This is after taking account of instance or class mode and whether superclass searching is enabled."

	"Implementation Note: Optimized for the common case of displaying only the immediate classes methods."

	| chain categories |
	chain := self actualClassChain.
	chain isEmpty ifTrue: [^#()].
	categories := chain first methodCategories.
	2 to: chain size do: [:i | (chain at: i) methodsCatalogue keysDo: [:each | categories add: each]].
	^categories!

actualClassChainMethods
	"Private - Answer an <OrderedCollection> of all the methods in the search chain for the actual class selected in the receiver. This is after taking account of instance or class mode and whether superclass searching is enabled."

	"Implementation Note: Optimized for the common case of displaying only the immediate classes methods."

	| chain |
	chain := self actualClassChain.
	^chain size == 1
		ifTrue: [chain first methodDictionary values]
		ifFalse: 
			[| dict |
			dict := IdentityDictionary new.
			chain reverseDo: 
					[:eachClass |
					eachClass methodDictionary
						keysAndValuesDo: [:eachSelector :eachMethod | dict at: eachSelector put: eachMethod]].
			dict values]!

actualClasses
	"Answer the actual classes selected in the receiver after taking account of instance or class mode. Answer an empty collection if there is no class selected."

	^classesPresenter actualClasses!

addCategoriesOfMethod: aCompiledMethod
	| categoryModel |
	categoryModel := categoriesPresenter model.
	(aCompiledMethod realCategories difference: categoryModel asSet)
		do: [:each | categoryModel addCategory: each]!

addMethod: method toCategory: target
	"Private - Add the <CompiledMethod>, method, to the <methodCategory>,
	target, e.g. following a drag-copy operation in the category pane."

	methodBrowserPresenter addMethods: {method} toCategory: target!

addMethodCategory
	"Private - Add a new method category to the receiver's category pane."

	<commandQuery: #hasClassSelected>
	| actualClass newCategory |
	actualClass := self actualClass.
	newCategory := (CategoryPrompter choices: MethodCategory allMethodCategories
				caption: 'Add Method Category…') showModal.
	newCategory notNil ifFalse: [^self].
	categoriesPresenter model addCategory: newCategory.
	newCategory addClass: actualClass!

addMethodProtocol
	"Private - Add a new <MethodProtocol> to the selected class in the receiver."

	<commandQuery: #hasClassSelected>
	| actualClass newProtocol protocols |
	actualClass := self actualClass.
	protocols := MethodProtocol allMethodProtocols asSortedCollection: [:a :b | a name < b name].
	newProtocol := (ChoicePrompter
				create: 'Extensible choice prompter'
				on: nil asValue
				choices: protocols
				caption: 'Add Protocol to ' , actualClass name , '…')
				getTextBlock: [:protocol | protocol name];
				newBlock: [:aString | MethodProtocol name: aString];
				showModal.
	newProtocol notNil ifTrue: [self model addClass: actualClass toProtocol: newProtocol]!

addToCommandRoute: aCommandPolicy
	"Update the command routing path of the <CommandPolicy> argument with the receiver's contribution to the command path. "

	"Implementation Note: We want to make sure that the methods and classes presenter are always in the route, and that they appear before SmalltalkSystem (added by the supersend) but after the receiver (if not already in the route)."

	aCommandPolicy
		appendTarget: self;
		appendTarget: methodBrowserPresenter;
		appendTarget: classesPresenter.
	self loadedPlugins do: [:each | each addToCommandRouteInactive: aCommandPolicy].
	^super addToCommandRoute: aCommandPolicy!

allCategoriesOfMethod: aCompiledMethod
	"Answer a collection of all the categories that contain the <CompiledMethod> argument, 
	including any intermediate categories in the tree."

	| categoryTree categories |
	categories := IdentitySet new.
	categoryTree := categoriesPresenter model.
	aCompiledMethod categories do: [:each | categories addAll: (categoryTree withAllParents: each)].
	categories removeAll: categoryTree roots.
	^categories!

allCategory
	^categoriesPresenter model title!

applyOptions
	"Private - Apply the class options to the receiver"

	super applyOptions.
	definitionPresenter view wordWrap: self class wordWrapDefinition.
	self isShowingInheritedMethods: self class defaultShowInheritedMethods.
	self isFilteringObjectMethods: self class defaultFilterObjectMethods!

browseClassHierarchy
	<commandQuery: #queryBrowseClass:>
	self developmentSystem browseHierarchy: self actualClass!

browseContainingText
	"Prompt for a string and open a method browser displaying the
	methods containing that string."

	self developmentSystem browseContainingTextIn: self searchEnvironment!

browseDefinitionsMatching: aMethodSearch in: aBrowserEnvironment
	self developmentSystem browseMethodsInEnvironments: {
				aMethodSearch definitionsIn: aBrowserEnvironment.
				aMethodSearch
					definitionsIn: (aBrowserEnvironment forClassHierarchyOf: self actualClass)
			}!

browseInstanceVariableReferences
	"Browse methods that reference any of the selected instance variables of the selected class."

	<commandQuery: #hasInstanceVariablesSelected>
	self developmentSystem
		browseReferencesToInstVars: (self variables collect: [:each | each value])
		inHierarchyOf: self actualClass
		within: self searchEnvironment!

browseItCommand
	| focus |
	filterPresenter isNil ifTrue: [^nil].
	focus := View focus.
	focus == categoriesPresenter view
		ifTrue: [^#browseMethodCategory]
		ifFalse: 
			[focus == protocolsPresenter view
				ifTrue: [^#browseMethodProtocol]
				ifFalse: [focus == variablesPresenter view ifTrue: [^#browseInstanceVariableReferences]]].
	^nil!

browseMessageDefinitionsIn: aBrowserEnvironment
	"Private - Prompt for a selector and open a method browser displaying all definitions of
	that selector in the specified <BrowserEnvironment>."

	<commandQuery: #hasClassSelected>
	(self developmentSystem promptForDefinitionsOf: '' in: aBrowserEnvironment)
		ifNotNil: [:search | self browseDefinitionsMatching: search in: aBrowserEnvironment]!

browseMessageReferencesIn: aBrowserEnvironment
	"Private - Prompt for a selector and open a method browser displaying the references to that
	selector from methods defined in the specified <BrowserEnvironment>."

	<commandQuery: #hasClassSelected>
	(self developmentSystem promptForReferencesTo: '' in: aBrowserEnvironment)
		ifNotNil: [:search | self browseReferencesMatching: search in: aBrowserEnvironment]!

browseMethodCategory
	"Private - Browse all the methods which are in the currently selected category."

	<commandQuery: #hasMethodCategoriesSelected>
	self developmentSystem browseMethodCategories: self categories in: self searchEnvironment!

browseOverriddenMethod
	"Reposition the browser to the method which the currently selected method is overridding."

	<commandQuery: #hasOverrideSelected>
	| method |
	method := self method.
	self method: (method methodClass superclass lookupMethod: method selector)!

browseReferencesCommand
	View focus == variablesPresenter view ifTrue: [^#browseInstanceVariableReferences].
	^nil!

browseReferencesMatching: aMethodSearch in: aBrowserEnvironment
	self browseMethodsInEnvironments: {
				aMethodSearch referencesIn: aBrowserEnvironment.
				aMethodSearch
					referencesIn: (aBrowserEnvironment forClassHierarchyOf: self actualClass)
			}!

browserEnvironment
	^classesPresenter browserEnvironment!

browseSelectorsInProtocol
	"Private - Pop-up a multi-select <ChoicePrompter> displaying the selectors 
	implemented in the receiver and its superclasses, with all those which are
	part of the protocol selected."

	<commandQuery: #hasMutableProtocolSelected>
	| protocol newSelectors oldSelectors added removed |
	protocol := self protocols first.
	oldSelectors := protocol selectors.
	(newSelectors := self model chooseSelectorsInProtocol: protocol forClass: self actualClass) notNil
		ifFalse: [^self].
	added := newSelectors difference: oldSelectors.
	self model addSelectors: added toProtocol: protocol.
	removed := oldSelectors difference: newSelectors.
	self model removeSelectors: removed fromProtocol: protocol!

browseSystem
	"Open a new system browser on at the same point as the receiver."

	<commandQuery: #queryBrowseClass:>
	self developmentSystem browseSystem: self actualClass!

buildHistoryFutureMenu: aMenu
	"Private - Answer a dynamically created future visit menu."

	super buildHistoryFutureMenu: aMenu.
	self
		buildHistoryMenu: aMenu
		visits: history upToEnd
		command: #historyForward:!

buildHistoryMenu: aMenu visits: aSequenceableCollection command: cmdSelector
	"Private - Answer a dynamically created past visit history menu."

	| class subMenu selectors |
	class := nil.
	aSequenceableCollection keysAndValuesDo: 
			[:i :m |
			| mclass sel |
			mclass := m methodClass.
			mclass = class
				ifFalse: 
					[selectors := IdentitySet new.
					subMenu := aMenu addSubmenu: mclass name.
					class := mclass].
			sel := m selector.
			"We only want to add each method to the menu once"
			(selectors includes: sel)
				ifFalse: 
					[subMenu addCommand: (Message selector: cmdSelector argument: i) description: sel.
					selectors add: sel].
			subMenu setDefault: 1].
	aMenu setDefault: 1!

buildHistoryPastMenu: aMenu
	"Private - Answer a dynamically created past visit history menu."

	super buildHistoryPastMenu: aMenu.
	self
		buildHistoryMenu: aMenu
		visits: history past
		command: #historyBack:!

canRemoveMethodsInCategory
	| cat |
	^(cat := self category) notNil and: [(cat methodsInBehavior: self actualClass) notEmpty]!

canSaveMethod
	"In order to be able to save a method in the browser there must be either a single editable method selected, or a class selected with no method selection."

	^self hasEditableMethodSelected
		or: [self hasClassSelected and: [methodBrowserPresenter hasMethodsSelected not]]!

canSaveState
	"Private - Answer true if the receiver can successfully have it's state saved by #saveStateOn:. Some
	tools may not be able to save their state and therefore will not be able to be exported as
	part of a IdeaSpace save operation"

	^true!

canShowLocalHierarchy
	^false!

cardsPresenter
	^cardsPresenter!

categories
	"Private - Answer a Collection of all the method categories which are currently selected."

	| cat |
	cat := self category ifNil: [self allCategory].
	^cat == self allCategory ifTrue: [{cat}] ifFalse: [self hierarchyOfCategory: cat]!

categoriesEnvironment
	^self searchEnvironment forMethodCategories: self categories!

categoriesFilter
	^(self category isNil or: [self category == AllMethodsCategory current])
		ifTrue: [self classMethodFilter]
		ifFalse: [self categoriesMethodFilter]!

categoriesMethodFilter
	"Private - Answer a <monadicValuable> that, when passed a <CompiledMethod>, answers true if
	the method should be displayed in the receiver by warrant of the category that is selected"

	^
	[:eachMethod | 
	(self isMethodVisible: eachMethod) 
		and: [self categories anySatisfy: [:eachCategory | eachCategory includesMethod: eachMethod]]]!

category
	"Answer the currently selected category or nil if there isn't one."

	^categoriesPresenter selectionOrNil!

classDefinition
	"Private - Answer the definition for the currently selected class as a String"

	^definitionPresenter plainText!

classForNewMethod
	^self actualClass ifNil: 
			[self developmentSystem 
				chooseClass: nil asValue
				caption: 'Choose Class of New Method…'
				allowNil: false]!

classMenu
	"Private - The Class menu should always be enabled"!

classMethodFilter
	"Private - Answer a <monadicValuable> that, when passed a <CompiledMethod>, answers true if the
	method should be displayed in the receiver by warrant of the class that is selected."

	^[:m | (self isMethodVisible: m)]!

classMode
	^classesPresenter isInstanceMode ifTrue: [#instanceMode] ifFalse: [#classMode]!

classMode: aSymbol
	modePresenter value: aSymbol!

createAccessors
	"Private - Generate get and set accessors for the currently selected instance variables.
	When the Refactoring Browser is installed this uses the 'Create Instance Variable
	Accessors' refactoring (which is undoable), otherwise it uses the base Dolphin
	implementation (which is not undoable)."

	<commandQuery: #hasInstanceVariablesSelected>
	self model
		createVariableAccessors: self variables
		classVariables: false
		within: self searchEnvironment!

createComponents
	"Private - Create the presenters contained by the receiver"

	| workspaceClass |
	super createComponents.
	methodBrowserPresenter := self add: self methodBrowserClass new name: 'methodBrowser'.
	methodBrowserPresenter methodsPresenter helpId: 10741.
	workspaceClass := self workspaceClass.
	definitionPresenter := self
				add: workspaceClass new
				name: 'definition'
				helpId: 10746.
	categoriesPresenter := self
				add: (TreePresenter on: (CategoryTreeModel new title: MethodCategory all))
				name: 'categories'
				helpId: 10740.
	modePresenter := self
				add: RadioButtonSetPresenter new
				name: 'mode'
				helpId: 10752.
	variablesPresenter := self add: (ListPresenter on: ListModel newEquality) name: 'variables'.
	protocolsPresenter := self
				add: ListPresenter new
				name: 'protocols'
				helpId: 10743.
	cardsPresenter := self add: Presenter new name: 'cards'.
	packageModel := ValueHolder new.
	statusModel := ValueHolder new!

createPlugins
	"Create the plugins used by the receiver"

	self class plugins do: 
			[:each | 
			| plugin |
			plugin := each createIn: cardsPresenter on: self.
			plugin view arrangement: plugin.
			self loadedPlugins add: plugin]!

createSchematicWiring
	"Create the trigger wiring for the receiver"

	super createSchematicWiring.
	self 
		when: #timerTick:
		send: #onTimerTick:
		to: self.
	classesPresenter
		when: #modeChanged
			send: #onClassModeChanged
			to: self;
		when: #selectionChanged
			send: #onClassSelected
			to: self;
		when: #selectionChanging:
			send: #onClassSelectionChanging:
			to: self.
	categoriesPresenter
		when: #selectionChanged
			send: #onCategorySelected
			to: self;
		when: #selectionChanging:
			send: #onFilterSelectionChanging:
			to: self;
		when: #drag:
			send: #onDragCategory:
			to: self;
		when: #dragCut:
			send: #onDragMethodsCut:
			to: self;
		when: #dragOver:
			send: #onDragOverCategory:
			to: self;
		when: #drop:
			send: #onDropOverCategory:
			to: self;
		when: #labelOf:editedTo:accept:
			send: #onCategory:renameTo:accept:
			to: self.
	modePresenter
		when: #valueChanged
			send: #onModeSelectionChanged
			to: self;
		when: #dragOver:
			send: #onDragOverMode:
			to: self;
		when: #drop:
			send: #onDropOverMode:
			to: self.
	methodBrowserPresenter
		when: #methodSelected
			send: #onMethodSelected
			to: self;
		when: #dragOver:
			send: #onDragOverMethod:
			to: self;
		when: #drop:
			send: #onDropOverMethods:
			to: self.
	methodBrowserPresenter selectableItems 
		when: #leftButtonDoubleClicked:
		send: #onMethodListDoubleClicked:
		to: self.
	self 
		when: #closeRequested:
		send: #onCloseRequested:
		to: self.
	(self model)
		when: #methodCategorized:
			send: #onMethodCategorized:
			to: self;
		when: #methodAdded:
			send: #onMethodAdded:
			to: self;
		when: #methodUpdated:
			send: #onMethodUpdated:
			to: self;
		when: #methodRemoved:
			send: #onMethodRemoved:
			to: self;
		when: #classUpdated:
			send: #onClassUpdated:
			to: self;
		when: #classCategorized:
			send: #onClassCategorized:
			to: self;
		when: #protocolUpdated:
			send: #onProtocolUpdated:
			to: self;
		when: #protocolRemoved:
			send: #onProtocolRemoved:
			to: self.
	(self packageManager)
		when: #methodRepackaged:from:to:
			send: #onMethodRepackaged:from:to:
			to: self;
		when: #classRepackaged:from:to:
			send: #onClassRepackaged:from:to:
			to: self.
	protocolsPresenter
		when: #selectionChanged
			send: #onProtocolSelected
			to: self;
		when: #selectionChanging:
			send: #onFilterSelectionChanging:
			to: self;
		when: #actionPerformed
			send: #browseMethodProtocol
			to: self;
		when: #drag:
			send: #onDragProtocol:
			to: self;
		when: #dragOver:
			send: #onDragOverProtocol:
			to: self model;
		when: #drop:
			send: #onDropOverProtocol:
			to: self model;
		when: #labelOf:editedTo:accept:
			send: #onRenameMethodProtocol:to:accept:
			to: self.
	variablesPresenter
		when: #drag:
			send: #onDragVariableRefs:
			to: self;
		when: #dragCut:
			send: #onDragMethodsCut:
			to: self;
		when: #selectionChanged
			send: #onVariableSelected
			to: self;
		when: #selectionChanging:
			send: #onFilterSelectionChanging:
			to: self;
		when: #labelOf:editedTo:accept:
			send: #onRenameInstVar:to:accept:
			to: self;
		when: #labelOf:changedTo:
			send: #onRenameInstVar:to:
			to: self.
	cardsPresenter view 
		when: #currentCardChangedFrom:to:
		send: #onBrowserCardChangedFrom:to:
		to: self!

currentCard
	"Answer the current card presenter on view in the receiver"

	^self cardsPresenter view currentCard presenter!

customDrawCategoryTree: aNMTVCUSTOMDRAW
	"Private - Custom drawing to implement the emphasis in the method category tree."

	| category |
	category := aNMTVCUSTOMDRAW item.
	category isNil ifTrue: [^self].
	self emphasiseCategoryItem: aNMTVCUSTOMDRAW isRelevant: (methodCategories includes: category)!

customDrawProtocols: aNMLVCUSTOMDRAW 
	"Private - Custom drawing to implement the emphasis in the Method Protocol list."

	| protocol |
	protocol := aNMLVCUSTOMDRAW item.
	protocol isNil ifTrue: [^self].
	self emphasiseProtocolItem: aNMLVCUSTOMDRAW isRelevant: (self methodProtocols includes: protocol)!

customDrawSelector: anNMLVCUSTOMDRAW
	"Private - Custom drawing to implement the emphasis in a class browser's method list's selector column."

	| method |
	method := anNMLVCUSTOMDRAW item.
	method isLoose ifTrue: [anNMLVCUSTOMDRAW forecolor: LooseMethodColor].
	(self isEditableMethod: method)
		ifFalse: [anNMLVCUSTOMDRAW forecolor: (anNMLVCUSTOMDRAW forecolor fadedBy: GrayedMethodFadeFactor)].
	method isDeprecated ifTrue: [anNMLVCUSTOMDRAW font isStruckThrough: true].
	method isAbstract ifTrue: [anNMLVCUSTOMDRAW font isItalic: true]!

definitionCardName
	^'definition'!

definitionOfClass: aClass
	| strm filer |
	strm := (WriteStream on: (Utf8String new: 256))
				locale: SmalltalkLocale.Hex;
				yourself.
	filer := aClass sourceFilerClass on: strm.
	filer environment: aClass environment.
	filer printBasicDefinitionOfClass: aClass on: strm.
	^(Parser parseExpression: strm contents) formattedCode!

deleteItCommand
	| focus |
	focus := View focus.
	focus == categoriesPresenter view ifTrue: [^#removeMethodCategory].
	focus == protocolsPresenter view ifTrue: [^#removeMethodProtocol].
	(self canRefactor and: [focus == variablesPresenter view]) ifTrue: [^#removeInstanceVariables].
	^nil!

displayLocalHierarchyOf: class
	"Private - Update the receiver to display only the local hierarchy of the <ClassDescription>,
	class."

	| instClass |
	instClass := class instanceClass.
	classesPresenter model: (ClassHierarchyModel withAllClasses
				filter: [:x | (instClass allSuperclasses includes: x) or: [instClass withAllSubclasses includes: x]])!

dropMethods: aDragDropSession onto: aClass
	| changes isMove count |
	changes := CompositeRefactoryChange new.
	isMove := aDragDropSession isMove.
	count := 0.
	aDragDropSession dragObjects do: 
			[:each |
			(each isFormatAvailable: #CompiledMethod)
				ifTrue: 
					[| method |
					method := each format: #CompiledMethod.
					((classesPresenter
						dropMethod: method
						onto: aClass
						isMove: isMove
						changes: changes) and: 
								[count := count + 1.
								isMove])
						ifTrue: [changes removeSelector: method selector from: method methodClass]]].
	changes name: ('<1s> <2p> methods' expandMacrosWith: aDragDropSession operation with: count).
	"Prevent cut operation in the source"
	aDragDropSession resetOperation.
	classesPresenter performDropChanges: changes target: Object!

emphasiseCategoryItem: anNMTVCUSTOMDRAW isRelevant: aBoolean 
	"Apply emphasis to a category tree entry, depending on whether or not it is relevant to the current method selection.
	By default we implement this by emboldening the relevant categories, but one could also fade the irrelevant categories,
	or use italics or colour to distinguish."

	anNMTVCUSTOMDRAW font isBold: aBoolean!

emphasiseProtocolItem: anNMTVCUSTOMDRAW isRelevant: aBoolean 
	"Apply emphasis to a Method Protocol list entry, depending on whether or not it is relevant to the current method selection.
	By default we implement this by emboldening the relevant protocols, but one could also fade the irrelevant protocols,
	or use italics or colour to distinguish."

	anNMTVCUSTOMDRAW font isBold: aBoolean!

ensureDefinitionVisible
	definitionPresenter ensureVisible!

ensureSourceVisible
	self view topView isActive ifTrue: [methodBrowserPresenter ensureSourceVisible]!

futureSize
	"Answer the number of visits in the history which were made after the
	current one."

	^history futureSize!

hasClassSelected
	"Answer true if the receiver currently has a class selected
	in the classesPresenter"

	"#954: Note we used to use classesPresenter hasSelection here but this could cause
	a discrepancy between #hasClassSelected and #selectedClass if the class name has
	just been changed."

	^self selectedClass notNil!

hasEditableMethodSelected
	"Answer whether there is a single editable method selected."

	^self method ifNil: [false] ifNotNil: [:method | self isEditableMethod: method]!

hasEditableMethodsSelected
	| methods |
	methods := self selectedMethods.
	^methods notEmpty and: [methods allSatisfy: [:each | self isEditableMethod: each]]!

hasHistory
	^self hasPast or: [self hasFuture]!

hasInstanceVariableSelected
	^self variables size = 1!

hasInstanceVariablesSelected
	^self variables notEmpty!

hasMethodCategoriesSelected
	^self categories notEmpty!

hasMethodSelected
	"Answer true if the receiver currently has a method selected in the methodsPresenter"

	^methodBrowserPresenter hasMethodSelected!

hasMutableProtocolSelected
	^self protocols size == 1 and: [self protocols first isReadOnly not]!

hasNonVirtualCategorySelected
	| cat |
	cat := self category.
	"Virtual categories are permanent/calculated and cannot be removed"
	^cat notNil and: [cat isVirtual not]!

hasOverrideSelected
	^self hasMethodSelected and: [self method isOverride]!

hasProtocolSelected
	^self protocols size = 1!

hasProtocolsSelected
	^self protocols notEmpty!

hierarchyOfCategory: aMethodCategory 
	^(categoriesPresenter model withAllChildren: aMethodCategory) reject: [:each | each isIntermediate]!

historyClear
	<commandQuery: #hasHistory>
	history clear!

historySkip: anInteger
	"Private - Move around in the history list by the specified <integer> delta (negative for
	backwards)."

	| method class currentMethod |
	self promptToSaveChanges ifFalse: [^self].
	history skip: anInteger.
	method := history current.
	class := method methodClass.
	self resetFor: class.
	currentMethod := class compiledMethodAt: method selector ifAbsent: nil.
	currentMethod isNil
		ifTrue: 
			[self statusText: ('<1p> has been deleted' expandMacrosWith: method).
			Sound warningBeep.
			self actualClass: class]
		ifFalse: [self method: currentMethod]!

initialize
	"Private - Initialize the receiver"

	super initialize.
	flags := 0.
	history := HistoryList new: self class historyListSize.
	loadedPlugins := OrderedCollection new.
	methodCategories := #()!

inspectCollection: aCollection
	(aCollection size = 1 ifTrue: [aCollection first] ifFalse: [aCollection]) inspect!

inspectInstanceVariables
	<commandQuery: #hasInstanceVariablesSelected>
	| vars |
	vars := self variables.
	self inspectCollection: (vars isEmpty ifTrue: [variablesPresenter list asArray] ifFalse: [vars])!

inspectItCommand
	filterPresenter notNil
		ifTrue: 
			[| focus |
			focus := View focus.
			focus == categoriesPresenter view
				ifTrue: [^#inspectMethodCategories]
				ifFalse: 
					[focus == protocolsPresenter view
						ifTrue: [^#inspectMethodProtocols]
						ifFalse: [focus == variablesPresenter view ifTrue: [^#browseInstanceVariableReferences]]]].
	^nil!

inspectMethodCategories
	<commandQuery: #hasMethodCategoriesSelected>
	self inspectCollection: self categories!

inspectMethodProtocols
	| prots |
	prots := self protocols.
	self inspectCollection: (prots isEmpty 
				ifTrue: [protocolsPresenter list asArray]
				ifFalse: [prots])!

isDefinitionCardVisible
	^self currentCard view name = self definitionCardName!

isDisplayingCategories
	"Private - Answer whether the categories pane is currently active."

	^filterPresenter isNil or: [filterPresenter currentCard == categoriesPresenter view]!

isDisplayingProtocols
	"Private - Answer whether the protocols pane is currently active."

	^filterPresenter notNil and: [filterPresenter currentCard == protocolsPresenter view]!

isDisplayingVariables
	"Private - Answer whether the instance variables pane is currently active."

	^filterPresenter notNil and: [filterPresenter currentCard == variablesPresenter view]!

isEditableMethod: aCompiledMethod
	"Answer true if aCompiledMethod should be judged as being editable"

	^(aCompiledMethod isUnbound or: [self isInheritedMethod: aCompiledMethod]) not!

isFilteringObjectMethods: aBoolean
	flags := flags mask: FilterObjectMethodsMask set: aBoolean!

isFilterObjectMethods
	"Answer whether the receiver is in 'filter <Object> methods' mode"

	^flags allMask: FilterObjectMethodsMask!

isInheritedMethod: aCompiledMethod 
	"Answer true if aCompiledMethod should be judged as being inherited (i.e. does not belong to the actual class)"

	^aCompiledMethod methodClass name ~= self actualClass name!

isInstanceMode
	"Private - Answer true if the receiver is in instance mode"

	^classesPresenter isInstanceMode
!

isInstanceMode: aBoolean
	"Private - Set the receiver into class mode, i.e. displaying the class methods on the selected class."

	self classMode: (aBoolean ifTrue: [#instanceMode] ifFalse: [#classMode])!

isLocalHierarchyMode
	"Private - Answer whether the receiver is in 'local hierarchy' mode displaying a subset of the entire
	class hierarchy."

	^false!

isLocalHierarchyMode: aBoolean
	aBoolean ifTrue: [self error: 'Not supported']!

isMethodFiltrate: aCompiledMethod
	"Private - Answer whether the <CompiledMethod> argument passes through the current method filter.
	It is assumed that the method is from the currently displayed hierarchy."

	self isFilterObjectMethods ifFalse: [^true].
	^((self isInstanceMode ifTrue: [Object] ifFalse: [Object class])
		includesBehavior: aCompiledMethod methodClass) not!

isMethodVisible: aCompiledMethod 
	| actualClass |
	actualClass := self actualClass.
	^aCompiledMethod methodClass == actualClass or: 
			[self isShowInheritedMethods and: 
					[(actualClass lookupMethod: aCompiledMethod selector) == aCompiledMethod 
						and: [self isMethodFiltrate: aCompiledMethod]]]!

isModified
	^methodBrowserPresenter isModified 
		or: [definitionPresenter isModified or: [self loadedPlugins anySatisfy: [:each | each isModified]]]!

isShowingInheritedMethods: aBoolean
	flags := flags mask: ShowInheritedMethodsMask set: aBoolean!

isShowInheritedMethods
	"Answer whether the receiver is in 'show inherited methods' mode"

	^flags allMask: ShowInheritedMethodsMask!

isSourceCardVisible
	^self currentCard view name = self sourceCardName!

killVisitTimer
	self view killTimer: 1!

loadedPlugins
	^loadedPlugins!

method
	"Answer the method displayed by the receiver or nil if there is none"

	^methodBrowserPresenter selectedMethod!

method: method
	"Set the receiver to browse the <CompiledMethod>, method."

	^self method: method
		ifAbsent: 
			[MessageBox new
				headline: '<1p> is not defined in <2p>' << {method. self browserEnvironment};
				errorMsg]!

method: method ifAbsent: exceptionHandler 
	"Set's the receiver to browse the <CompiledMethod>, method,
	or, if the method is not found, evalutes the <niladicValuable>,
	exceptionHandler."

	| mclass |
	mclass := method methodClass.
	classesPresenter actualClass: mclass ifAbsent: [^exceptionHandler value].
	^methodBrowserPresenter selection: method
		ifAbsent: 
			["Not in list, so is it a valid method?"
			(mclass includesSelector: method selector) ifFalse: [^exceptionHandler value].
			"Try realigning filter pane to include method"
			self isDisplayingCategories 
				ifTrue: 
					["The method exists, but not in the selected category, so we try in the all category"
					categoriesPresenter selection: self allCategory]
				ifFalse: 
					[self isDisplayingProtocols 
						ifTrue: [protocolsPresenter resetSelection]
						ifFalse: [self isDisplayingVariables ifTrue: [variablesPresenter resetSelection]]].
			"Now try again"
			methodBrowserPresenter selection: method ifAbsent: exceptionHandler]!

methodCategories: aCollection 
	(methodCategories noDifference: aCollection) ifTrue: [^self].
	methodCategories := aCollection.
	categoriesPresenter view invalidate!

methodMenu
	"Private - The Method menu should always be enabled"!

methodProtocols
	"Answer the <MethodProtocol>s that the currently selected method contributes towards
	implementing in the currently selected class."

	^self method ifNil: [#()] ifNotNil: [:method | method protocols]!

methodProtocols: aCollection 
	protocolsPresenter view invalidate!

methods
	"Answer a <sequencedReadableCollection> of the methods currently visible in the receiver's method list."

	^methodBrowserPresenter list!

methodsMatching: aMonadicValuable
	^self actualClassChainMethods select: aMonadicValuable!

modifiedModel: aValueHolder
	(self view viewNamed: 'modified' ifNone: nil) ifNotNil: [:item | item model: aValueHolder]!

namespaceForNewMethodOf: aClass
	self packageForNewMethod
		ifNotNil: [:package | package environment ifNotNil: [:packageNs | ^model modelClassFor: packageNs]].
	^aClass environment!

newMethod
	"Sets the receiver up for creating a new method"

	<commandQuery: #queryNewMethod:>
	methodBrowserPresenter resetForNewMethod!

onBrowserCardChangedFrom: previousView to: currentView
	| currentCardName |
	currentCardName := currentView name.
	(currentCardName = self sourceCardName
		ifTrue: [methodBrowserPresenter sourcePresenter]
		ifFalse: [currentCardName = self definitionCardName ifTrue: [definitionPresenter]])
			ifNotNil: 
				[:workspace |
				workspace updateErrorStatus.
				self modifiedModel: workspace modifiedModel]!

onCategory: aMethodCategory renameTo: aString accept: aValueHolder
	| newCategory newName |
	newName := Category.Separator join: (aMethodCategory subNames allButLast copyWith: aString).
	newCategory := aMethodCategory class name: newName.
	self renameMethodCategory: aMethodCategory to: newCategory.
	aValueHolder value: true!

onCategorySelected
	"Private - A new category has been selected."

	"Update the method browser to display the new methods"

	| method |
	(self isDisplayingCategories and: [self category notNil]) ifFalse: [^self].
	method := self method.
	self updateMethodsInCategory.
	self method == method
		ifFalse: 
			[methodBrowserPresenter selection: method
				ifAbsent: 
					["Method selection cleared, so we need to ensure that none of the categories remain emboldened."
					self methodCategories: #()]].
	self updateCaption!

onClassCategorized: aClass
	"Private - A class within the receiver has been recategorized. 
	Update the caption to match."

	self selectedClass == aClass ifTrue: [
		self updateCaption]!

onClassModeChanged
	"Private - The user has switched between class and Instance modes, or vice versa, so the method filters list need to be refreshed appropriately."

	"This may have no effect, but sometimes the classes presenter will change mode, e.g. due to a history skip, so that our own instance/class mode tab is out of step."

	self
		isInstanceMode: classesPresenter isInstanceMode;
		updateFilters;
		updatePackage;
		updateCaption!

onClassRepackaged: aClass from: source to: destination
	"Private - A class has been repackaged. If it is currently under scrutiny, refresh the displayed package."

	aClass == self selectedClass ifTrue: [
		self updatePackage]!

onClassSelected
	"Private - The class selected within the receiver has changed. 
	Refresh the method browser, etc."

	"If the selection change is due to a class deletion, for example, then there may be outstanding changes that
	 the user would like to preserve, though our only sensible option is to copy them to the clipboard"

	self promptToCopyChanges.
	self hasClassSelected
		ifTrue: [self isInstanceMode: classesPresenter isInstanceMode]
		ifFalse: 
			[methodBrowserPresenter
				filter: [:method | false];
				clear].
	self
		updateFilters;
		updatePackage;
		updateClassDefinition;
		updateSourceEnablement;
		updateCaption.

	"If we have a plugin as the current card then let it decide whether to show the class definition pane"
	(self loadedPlugins includes: self currentCard)
		ifFalse: 
			[(self hasMethodSelected not and: [self isSourceCardVisible]) ifTrue: [self ensureDefinitionVisible]].
	self trigger: #classSelected!

onClassSelectionChanging: aSelectionChangingEvent
	"Private - A selection is about to change  within the receiver.
	Prompt to save any outstanding changes"

	self onPromptToSaveChanges: aSelectionChangingEvent!

onClassUpdated: aClass
	"Private - A class within the receiver has changed. Refresh the definition pane if it is the selected class, and refresh other panes if it is the actual class/metaclass being displayed."

	| class |
	class := self actualClass.
	(class isNil or: [(class instanceClass includesBehavior: aClass instanceClass) not])
		ifTrue: [^self].
	class instanceClass == aClass instanceClass
		ifTrue: 
			[self
				updateClass: 'definition'
				presenter: definitionPresenter
				source: (self definitionOfClass: aClass instanceClass)].

	"If displaying the actual class or a superclass, then may need to refresh variables"
	(class includesBehavior: aClass) ifFalse: [^self].
	self
		updateVariables;
		updateCaption!

onCloseRequested: boolValueHolder
	"Private - A request to close the view onto the receiver as occurred.
	Prompt to save any outstanding changed"

	boolValueHolder value: self promptToSaveChanges!

onDragCategory: aDragDropSession
	"Private - A drag of a category has been started. Enter details into the <DragDropSession>,
	session."

	| methods category |
	category := aDragDropSession suggestedSource.
	methods := self methodsMatching: (category == AllMethodsCategory current
						ifTrue: [self classMethodFilter]
						ifFalse: 
							[| categories |
							categories := self hierarchyOfCategory: category.
							
							[:eachMethod |
							(self isMethodVisible: eachMethod)
								and: [categories anySatisfy: [:eachCategory | eachCategory includesMethod: eachMethod]]]]).
	self developmentSystem beginDrag: aDragDropSession methods: methods!

onDragMethodsCut: aDragDropSession
	"Private - The <DragDropSession>, session, has just completed a successful move operation. 
	The receiver is now responsible for deleting the drag object from its origin."

	| methods |
	methods := OrderedCollection new.
	aDragDropSession dragObjects do: 
			[:each |
			(each isFormatAvailable: #CompiledMethod)
				ifTrue: 
					[| method |
					method := each format: #CompiledMethod.
					methods add: method]].
	self developmentSystem basicRemoveMethods: methods!

onDragOverCategory: session
	"Private - The user is dragging over the category hierarchy pane.
	Set the operation of the <DragDropSession>, session,
	that would occur if a drop took place now of the objects in that session."

	(session isTargetSameAsSource not and: [session isFormatAvailable: #CompiledMethod])
		ifTrue: 
			[| target op |
			target := session suggestedTarget.
			op := session intendedOperation.
			(target notNil and: [target acceptsAdditions])
				ifTrue: 
					[session
						supportedOperations: #(#copy #move #link);
						operation: op.
					^self]].

	"Set the operation to nil to signify that we don't want the drop"
	session operation: nil!

onDragOverMethod: aDragDropSession
	"Private - The user is dragging over the method list pane.
	Set the operation of the <DragDropSession>, session,
	that would occur if a drop took place now of the objects in that session."

	aDragDropSession
		operation: ((aDragDropSession dragSource ~= aDragDropSession dropTarget
				and: [aDragDropSession isFormatAvailable: #CompiledMethod])
					ifTrue: [aDragDropSession intendedOperation])!

onDragOverMode: aDragDropSession
	"Private - The user is dragging over the instance/class mode selection tab.
	Set the operation of the <DragDropSession> argument that would occur 
	if a drop took place now of the objects in that session."

	| allowDrop |
	allowDrop := false.
	(aDragDropSession isFormatAvailable: #CompiledMethod)
		ifTrue: 
			[aDragDropSession dragSource topView == self view topView
				ifTrue: 
					["Drag was sourced from this class browser"
					allowDrop := aDragDropSession suggestedTarget ~= modePresenter value]]
		ifFalse: 
			["Drag sourced from another browser"
			allowDrop := true].
	aDragDropSession operation: (allowDrop ifTrue: [aDragDropSession intendedOperation])!

onDragProtocol: session
	"Private - A protocol drag has been started. Just extend the available formats
	to mention the availability of MethodProtocols."

	session dragObjects
		do: [:dragee | dragee format: #MethodProtocol data: (dragee format: #Object)]!

onDragVariableRefs: aDragDropSession 
	"Private - A drag of the methods referencing a particular variable has been started (useful
	when refactoring and pulling an instance variable up or pushing down). Enter details into
	the <DragDropSession>, session."

	self developmentSystem beginDrag: aDragDropSession methods: (self methodsMatching: self variablesFilter)!

onDropOverCategory: aDragDropSession
	"Private - The drag operation described by <DragDropSession>, session, would like to do a drop.
	Override this method to accept the dragObject(s)."

	| targetCategory |
	targetCategory := aDragDropSession suggestedTarget.
	targetCategory isNil
		ifTrue: 
			[Sound errorBeep.
			^false].
	aDragDropSession dragObjects do: 
			[:each |
			"See if the drop is a CompiledMethod"
			(each isFormatAvailable: #CompiledMethod)
				ifTrue: 
					[| method |
					method := each format: #CompiledMethod.

					"Check for a move to single category"
					aDragDropSession isMove
						ifTrue: 
							["Don't change the privacy unless the target is public/private"
							method
								categories: (targetCategory isPrivacy
											ifTrue: [{targetCategory}]
											ifFalse: [{targetCategory. method privacyCategory}]);
								storeCategories].

					"Check for a copy to additional category"
					aDragDropSession isCopy ifTrue: [self addMethod: method toCategory: targetCategory].

					"Check for a removal from target category"
					(aDragDropSession isLink and: [targetCategory includesMethod: method])
						ifTrue: [self removeMethod: method fromCategory: targetCategory]]].
	aDragDropSession isMove
		ifTrue: 
			["Operation must never be #move to avoid methods being removed"
			aDragDropSession operation: #copy].
	^true!

onDropOverMethods: aDragDropSession 
	"Private - The drag operation described by the <DragDropSession> would like 
	to do a drop of methods over the receiver's method list"

	self dropMethods: aDragDropSession onto: self actualClass!

onDropOverMode: aDragDropSession 
	"Private - The drag operation described by the <DragDropSession> would like 
	to do a drop of methods over the receiver's mode tab.
	If the drop fails then we must set the operation to nil in order that the drag-drop
	session can detect the failure (as this is an event handler the return value is ignored)."

	"See if the drop is a CompiledMethod"

	"The drop operation failed (probably due to a duplicate method)"

	| dropClass |
	dropClass := self selectedClass.
	aDragDropSession suggestedTarget == #classMode ifTrue: [dropClass := dropClass class].
	self dropMethods: aDragDropSession onto: dropClass!

onFilterCardChangedFrom: previousView to: currentView
	"Private - The method filter card has been changed. Update the method list
	and dynamic filter accordingly."

	self actualClass ifNil: [^self].
	self isDisplayingCategories 
		ifTrue: [self updateMethodsInCategory]
		ifFalse: [
			self isDisplayingProtocols 
				ifTrue: [self updateMethodsInProtocol]
				ifFalse: [
					self isDisplayingVariables 
						ifTrue: [self updateMethodsReferencingVariables]]].
	self updateCaption!

onFilterSelectionChanging: aSelectionChangingEvent
	"Private - The selection of class/instance mode, or in one of the method filters is changing. Note that
	this can only affect the method source pane, so there is no need to prompt to save changes
	to definition or comment panes."

	self onPromptToSaveMethodChanges: aSelectionChangingEvent!

onMethodAdded: aCompilationResult
	"Private - The development system has added CompiledMethod identified by aCompilationResult.
	Implementation Note: Some complexity arises if in 'show inherited methods'
	mode as the new method may supplant an inherited method that is currently
	being displayed. We must also ensure that the method's categories are correctly 
	displayed within the receiver's category presenter, if the method is visible."

	| method visible actualClass |
	actualClass := self actualClass.
	actualClass ifNil: [^self].
	method := aCompilationResult method.
	(self isShowInheritedMethods and: [actualClass includesBehavior: method methodClass])
		ifTrue: 
			[| superclass selector |
			superclass := method methodClass superclass.
			selector := method selector.
			((visible := (actualClass lookupMethod: selector) == method) and: [superclass notNil])
				ifTrue: 
					["The newly added method is the implementation, perhaps inherited, for the 
					currently selected class  so we must check to see if it supplants a previous 
					implementation, which we will need to remove from the list - note that we start 
					the search in the superclass of the method, just like a Smalltalk supersend."
					(superclass lookupMethod: selector)
						ifNotNil: [:overridden | methodBrowserPresenter model remove: overridden ifAbsent: nil]]]
		ifFalse: [visible := method methodClass == actualClass].
	visible ifTrue: [self addCategoriesOfMethod: method]!

onMethodCategorized: aCompiledMethod 
	"Private - The development system has recategorized aCompiledMethod.
	Check to ensure that the method's categories are correctly displayed within
	the receiver's category presenter"

	| isDisplayingMethod |
	aCompiledMethod methodClass == self actualClass ifFalse: [^self].
	self addCategoriesOfMethod: aCompiledMethod.
	isDisplayingMethod := self method == aCompiledMethod.
	isDisplayingMethod ifTrue: [self methodCategories: (self allCategoriesOfMethod: aCompiledMethod)].
	self isDisplayingCategories 
		ifTrue: 
			[#todo.	"Remove this"
			isDisplayingMethod 
				ifTrue: 
					[(aCompiledMethod categories intersection: self categories) isEmpty 
						ifTrue: [methodBrowserPresenter onMethod: aCompiledMethod updatedTo: aCompiledMethod]]]
		ifFalse: [isDisplayingMethod ifTrue: [self updateCaption]]!

onMethodListDoubleClicked: aMouseEvent 
	| hittest method superMethod methodList |
	methodList := methodBrowserPresenter selectableItems view.
	hittest := methodList basicItemFromPoint: aMouseEvent position.
	"A hack to allow for old list boxes as the method list"
	hittest isInteger ifTrue: [^self].
	"Here we are assuming a certain set of columns in the method browser - also a hack. I think
	what we should probably do is associate a command with each column, and then fire that
	when the column is double clicked with full row select off."
	(hittest iItem < 0 or: [hittest iSubItem ~= 1]) ifTrue: [^self].
	method := methodBrowserPresenter selectableItems model at: hittest handle.
	method isOverride ifFalse: [^self].
	aMouseEvent lResult: 0.
	superMethod := method methodClass superclass lookupMethod: method selector.
	[self method: superMethod] postToMessageQueue!

onMethodRemoved: aCompiledMethod 
	"Private - The development system has removed aCompiledMethod."

	"Implementation Note: Some complexity arises if in 'show inherited methods'
	mode as the method may have been hiding a superclass implementation which
	we now need to add into the browser."

	| actualClass methodClass |
	self isShowInheritedMethods ifFalse: [^self].
	methodClass := aCompiledMethod methodClass.
	actualClass := self actualClass.
	(actualClass includesBehavior: methodClass) ifFalse: [^self].

	"A method has been removed in the selected class' inheritance chain - this may possibly
	 have exposed a method higher up the chain."
	(actualClass lookupMethod: aCompiledMethod selector) ifNotNil: 
			[:visibleMethod | 
			((methodClass inheritsFrom: visibleMethod methodClass) 
				and: [self isMethodFiltrate: visibleMethod]) 
					ifTrue: 
						[methodBrowserPresenter model add: visibleMethod.
						self addCategoriesOfMethod: visibleMethod]]!

onMethodRepackaged: method from: source to: destination
	"Private - The <Package>, updatee, has had its contents amended. 
	Update the package display in case either the selected class or method
	has been repackaged."

	self method == method ifTrue: [
		self updatePackage]!

onMethodSelected
	"Private - The method selected within the receiver has changed"

	| method categories protocols |
	self killVisitTimer.
	method := self method.
	method isNil 
		ifTrue: [protocols := categories := #()]
		ifFalse: 
			[categories := self allCategoriesOfMethod: method.
			protocols := method protocols.
			self setVisitTimer].
	self methodCategories: categories.
	self methodProtocols: protocols.
	self updateSourceEnablement.
	self updatePackage.
	self updateCaption.

	"If we have a plugin as the current card then let it decide whether to show the method source pane"
	(self loadedPlugins includes: self currentCard) ifFalse: [self ensureSourceVisible].
	self trigger: #methodSelected!

onMethodUpdated: aCompilationResult
	"Private - The development system has updated the CompiledMethod identified by aCompilationResult. We may need to update the category tree, being careful not to depend on our method browser component having responded to the event already."

	| newMethod actualClass methodClass selectedMethod |
	(actualClass := self actualClass) ifNil: [^self].
	newMethod := aCompilationResult method.
	methodClass := newMethod methodClass.
	(methodClass == actualClass
		or: [self isShowInheritedMethods and: [actualClass includesBehavior: methodClass]])
			ifFalse: [^self].
	self addCategoriesOfMethod: newMethod.
	(selectedMethod := self method) ifNil: [^self].
	(selectedMethod == newMethod or: [selectedMethod == aCompilationResult oldMethod])
		ifTrue: 
			[self methodCategories: (self allCategoriesOfMethod: newMethod).
			self updateCaption]!

onModeSelectionChanged
	"Private - The browser has toggled from instance to class mode, or vice versa."

	| changingEvent |
	changingEvent := SelectionChangingEvent forSource: modePresenter view.
	changingEvent
		newSelection: modePresenter value;
		oldSelection: self classMode.
	self onPromptToSaveMethodChanges: changingEvent.
	changingEvent value
		ifTrue: [classesPresenter isInstanceMode: changingEvent newSelection == #instanceMode]
		ifFalse: [modePresenter noEventsDo: [modePresenter value: changingEvent oldSelection]]!

onPackageDoubleClicked: aPoint
	"Private - The receiver's package status item was double clicked at the specified point.
	Open the package browser on the package."

	| package |
	package := packageModel value.
	package isNil
		ifTrue: 
			[classesPresenter hasSelection ifTrue: [classesPresenter classPackage] ifFalse: [Sound errorBeep]]
		ifFalse: [Cursor wait showWhile: [packageModel value browse]]!

onPromptToSaveChanges: aSelectionChangingEvent
	"Private - Check to see if the source, definition or comment panes have been changed. 
	If so prompt to see if the changes should be retained and if they should then
	set the value of the out parameter, aBooleanValue, to false"

	^(self onPromptToSaveMethodChanges: aSelectionChangingEvent) 
		and: [self onPromptToSaveClassChanges: aSelectionChangingEvent]!

onPromptToSaveClassChanges: aSelectionChangingEvent 
	"Private - Check to see if the class definition or comment panes have been changed. 
	If so prompt to see if the changes should be retained and if they should then
	set the value of the out parameter, aBooleanValue, to false"

	^(definitionPresenter prompt: 'definition' toSaveChanges: aSelectionChangingEvent) and: 
			[self loadedPlugins allSatisfy: [:each | each promptToSaveClassChanges: aSelectionChangingEvent]]!

onPromptToSaveMethodChanges: aSelectionChangingEvent
	^methodBrowserPresenter onPromptToSaveChanges: aSelectionChangingEvent!

onProtocolRemoved: aMethodProtocol
	"Private - The <MethodProtocol>, aMethodProtocol, has been removed from the system.
	Update the protocols list."

	(protocolsPresenter model includes: aMethodProtocol) ifTrue: [
		protocolsPresenter model remove: aMethodProtocol]!

onProtocolSelected
	"Private - A new protocol has been selected."

	"Update the method browser to display the new methods"

	| method |
	self isDisplayingProtocols ifFalse: [^self].
	method := self method.
	self updateMethodsInProtocol.
	self method == method 
		ifFalse: 
			[methodBrowserPresenter selection: method
				ifAbsent: 
					["Ignore"
					]]!

onProtocolUpdated: aMethodProtocol 
	"Private - The <MethodProtocol>, aMethodProtocol, has been updated in some manner (normally
	by having classes/selectors added/removed), update the browser to reflect the change."

	| class |
	(class := self actualClass) isNil ifTrue: [^self].
	(class conformsToProtocol: aMethodProtocol) 
		ifTrue: 
			["Selected class conforms to the updated protocol, may need to refresh
			 protocol pane or methods list."
			| i |
			(i := protocolsPresenter model identityIndexOf: aMethodProtocol) isZero 
				ifTrue: 
					["Protocol has been added to our selected class, so we need
					 to add it in too."
					protocolsPresenter model add: aMethodProtocol]
				ifFalse: 
					["Protocol has been updated, and we already have it in our
					 list, we need to ensure our protocol list method browser
					 are up-to-date."
					protocolsPresenter model refreshAtIndex: i.
					self onProtocolSelected]]
		ifFalse: 
			["Selected class does not conform to the updated protocol. May need to
			 refresh the protocol pane if it did previously. If not present then we
			 obviously don't care about this protocol in this browser."
			(protocolsPresenter model includes: aMethodProtocol) 
				ifTrue: 
					["Protocol has apparently been removed from the selected
					 class (we have it in list, but class no longer conforms)."
					protocolsPresenter model remove: aMethodProtocol]].
	self method ifNotNil: [:method | self methodProtocols: method protocols]!

onRenameInstVar: anAssociation to: aString
	"Private - Action an in-place inst var rename that passed validation."

	"Implementation Note: Selection will be lost by #classUpdated: event, unless we explicitly maintain it"

	| selections |
	selections := variablesPresenter selectionsByIndex.
	"Release any mouse capture that might have been made by the control where the label was edited, otherwise the cursor may disappear when the dialog is shown."
	View releaseCapture.
	(self developmentSystem
		renameInstanceVariable: anAssociation value
		to: aString
		in: anAssociation key
		within: BrowserEnvironment new) ifNotNil: [variablesPresenter selectionsByIndex: selections]!

onRenameInstVar: anAssociation to: aString accept: aValueHolder
	"Private - In-place inst var rename has been made by the user, validate it."

	| result |
	result := self developmentSystem
				validateRenameInstVar: anAssociation value
				to: aString
				in: anAssociation key.
	result value
		ifFalse: 
			[| mb |
			mb := MessageBox new.
			mb text: 'Unable to rename <1d>.<2d> to ''<3s>'''
						<< {anAssociation key. anAssociation value. aString}.
			result hint
				ifNil: [mb iconStyle: #error]
				ifNotNil: 
					[:ex |
					mb
						headline: ex displayString;
						iconStyle: ex iconStyle].
			mb open].
	aValueHolder value: result value!

onRenameMethodProtocol: aMethodProtocol to: aString accept: aValueHolder
	(self validateProtocol: aMethodProtocol renameTo: aString) 
		ifTrue: [aMethodProtocol rename: aString]!

onRepackaged: anObject
	"Private - The development system has re-packaged anObject.
	Check to ensure that the package is correctly displayed within
	the receiver if it is displaying this object"

	(self selectedClass==anObject or: [self method==anObject]) ifTrue: [
		self updatePackage]!

onStatusDoubleClicked: aPoint 
	"Private - The receiver's status item was double clicked at the specified point."

	self trigger: #statusActionPerformed!

onTimerTick: anInteger 
	anInteger == 1 ifFalse: [^self].
	self killVisitTimer.
	self recordMethodVisit!

onVariableSelected
	"Private - A new instance variable has been selected."

	"Update the method browser to display the new methods"

	| method |
	self isDisplayingVariables ifFalse: [^self].
	method := self method.
	self updateMethodsReferencingVariables.
	self updateCaption.
	self method == method 
		ifFalse: 
			[methodBrowserPresenter selection: method
				ifAbsent: 
					["Ignore"
					]]!

onViewOpened
	"Private - Received when the receiver's view is been connected. "

	| modifiedModel |
	super onViewOpened.
	self createPlugins.
	methodBrowserPresenter beSorted: [:a :b | a selector <= b selector].
	(self view viewNamed: 'message' ifNone: nil)
		ifNotNil: 
			[:item |
			item
				when: #doubleClicked:
				send: #onStatusDoubleClicked:
				to: self.
			item model: self statusModel.
			methodBrowserPresenter errorModel: self statusModel.
			definitionPresenter errorModel: self statusModel].
	(self view viewNamed: 'packageOfSelection' ifNone: nil)
		ifNotNil: 
			[:item |
			item
				when: #doubleClicked:
				send: #onPackageDoubleClicked:
				to: self.
			item model: packageModel].
	(self view viewNamed: 'namespace' ifNone: nil)
		ifNotNil: [:item | item model: methodBrowserPresenter namespaceModel].
	modifiedModel := methodBrowserPresenter modifiedModel.
	self modifiedModel: modifiedModel.
	"Historically we have only flagged method changes in the caption."
	modifiedModel
		when: #valueChanged
		send: #updateCaption
		to: self.

	"Really a CardContainer view, but we treat as if a presenter"
	filterPresenter := self view viewNamed: 'filters' ifNone: nil.
	filterPresenter notNil
		ifTrue: 
			[filterPresenter
				when: #currentCardChangedFrom:to:
					send: #onFilterCardChangedFrom:to:
					to: self;
				when: #currentCardChanging:
					send: #onFilterSelectionChanging:
					to: self].
	definitionPresenter ensureVisible!

packageForNewMethod
	"Private - Answer the <Package> into which newly defined methods should be saved, or 
	nil to use the default (the owning class' package)."

	^nil!

packageNames: aCollection
	"Set the receiver's package selection to include only those packages named in the argument.
	This may have no effect if the receiver does not support filtering by package."

	self packages: (aCollection collect: [:each | Package manager packageNamed: each])!

packages: aCollection 
	"Set the receiver's package selection to include only those packages in the argument.
	This may have no effect if the receiver does not support filtering by package."

	classesPresenter packages: aCollection asArray!

parseContext
	"Answer the {Class. Namespace} scope in who's context methods should be compiled."

	self method
		ifNotNil: [:m | (model modelMethodFor: m) ifNotNil: [:modelMethod | ^modelMethod parseContext]].
	self actualClass
		ifNotNil: 
			[:class |
			(model modelClassFor: class)
				ifNotNil: 
					[:modelClass |
					^ParseContext methodClass: modelClass environment: (self namespaceForNewMethodOf: modelClass)]].
	^model defaultParseContext!

parseTree
	^methodBrowserPresenter parseTree!

pastSize
	"Answer the number of visits in the history which were made before the current one."

	^history pastSize!

printBasicCaptionOn: aPuttableStream
	aPuttableStream display: self class!

printCaptionForClass: aClass on: aWriteStream 
	"Private - Answer a suitable caption for the selected method."

	self isDisplayingVariables 
		ifTrue: 
			[| variables |
			variables := self variables.
			variables notEmpty 
				ifTrue: 
					[aWriteStream nextPutAll: 'Methods in '.
					self printClassTitle: aClass on: aWriteStream.
					aWriteStream nextPutAll: ' which access '.
					variables do: 
							[:v | 
							aWriteStream
								print: v key;
								nextPut: $.;
								display: v value]
						separatedBy: [aWriteStream nextPutAll: ' or '].
					^self]].
	self printClassTitle: aClass on: aWriteStream.
	aWriteStream nextPutAll: ' ('.
	aClass instanceClass categories asSortedArray 
		do: [:category | aWriteStream nextPutAll: category name]
		separatedBy: [aWriteStream nextPutAll: ', '].
	aWriteStream nextPut: $)!

printCaptionForMethod: aCompiledMethod on: aWriteStream
	aCompiledMethod displayOn: aWriteStream!

printClassTitle: anObject on: target 
	"Private - Print the 'title' of the currently selected class onto the <puttableStream>, target."

	target nextPutAll: anObject fullName
!

printShortCaptionForClass: aClass on: aWriteStream
	aClass isNil
		ifTrue: [self class displayOn: aWriteStream]
		ifFalse: [self printClassTitle: aClass on: aWriteStream]!

promptToCopyChanges
	"Private - If there are any changes, prompt the user as to whether they wish to copy them
	to the clipboard because a class selection change has occurred that is not preventable."

	^self onPromptToSaveChanges: (SelectionChangedEvent forSource: self)!

promptToSaveChanges
	"Private - If there are any changes, prompt the user as to whether they wish to save them,
	and answer a <Boolean> indicating the response."

	^self onPromptToSaveChanges: ((SelectionChangingEvent forSource: self)
				oldSelection: self selectedClass;
				yourself)!

protocols
	"Answer a Collection of all the method protocols which
	are currently selected."

	^protocolsPresenter hasView
		ifTrue: [protocolsPresenter selections]
		ifFalse: [#()]!

protocols: protocols 
	"Set the currently selected method protocols the <collection> of protocols"

	self hasClassSelected 
		ifTrue: 
			[protocolsPresenter
				selections: protocols;
				ensureVisible]!

protocolsMethodFilter
	"Private - Answer a <monadicValuable> that, when passed a <CompiledMethod>, answers true if the
	method should be displayed in the receiver by warrant of the protocol that is selected"

	^
	[:m | 
	(self isMethodVisible: m) 
		and: [self protocols anySatisfy: [:each | each includesSelector: m selector]]]!

queryBrowseClass: aCommandQuery
	self hasClassSelected ifFalse: [^self].
	aCommandQuery
		beEnabled;
		expandMenuTextWith: self actualClass!

queryFilterObjectMethods: aCommandQuery
	aCommandQuery
		isChecked: self isFilterObjectMethods;
		isEnabled: self isShowInheritedMethods!

queryHistoryBack: aCommandQuery
	self hasPast
		ifTrue: 
			[aCommandQuery
				beEnabled;
				expandMenuTextWith: history previous]!

queryHistoryForward: aCommandQuery
	self hasFuture
		ifTrue: 
			[aCommandQuery
				beEnabled;
				expandMenuTextWith: history next]!

queryNewMethod: aCommandQuery
	| cat |
	self selectedClass ifNil: [^self].
	cat := self category.
	aCommandQuery
		beEnabled;
		expandMenuTextWith: ((cat isNil
					or: [cat == self allCategory or: [cat isIntermediate or: [cat isPseud]]])
						ifTrue: ['unclassified method']
						ifFalse: ['method in <d>' << cat])!

queryRemoveMethodCategory: aCommandQuery
	<commandQuery: #hasNonVirtualCategorySelected>
	self hasNonVirtualCategorySelected ifFalse: [^self].
	aCommandQuery
		beEnabled;
		expandMenuTextWith: ('category <2p> from <1p>' expandMacrosWith: self actualClass
					with: self category name)!

queryRemoveMethodProtocols: aCommandQuery
	| prots |
	prots := self protocols.
	"Can only remove selected protocols if this is the first implementor in the superclass chain"
	(prots isEmpty or: [(prots difference: self actualClass protocols) notEmpty]) ifTrue: [^self].
	aCommandQuery
		beEnabled;
		expandMenuTextWith: (prots size = 1 ifTrue: [prots single] ifFalse: ['Method Protocols'])!

queryRenameItCommand: aCommandQuery
	self renameItCommand ifNotNil: [:selector | self queryContextCommand: aCommandQuery as: selector]!

queryToggleLocalHierarchy: aCommandQuery
	self isLocalHierarchyMode
		ifTrue: 
			[aCommandQuery
				beEnabled;
				isChecked: true]
		ifFalse: 
			[aCommandQuery
				isEnabled: (self canShowLocalHierarchy
							and: [self hasClassSelected and: [self actualClass superclass notNil]]);
				isChecked: false]!

queryToggleProtocolReadOnly: aCommandQuery
	| prots |
	prots := self protocols.
	prots size == 1
		ifTrue: 
			[| prot |
			prot := prots first.
			aCommandQuery
				isChecked: prot isReadOnly;
				isEnabled: prot isANSI not]!

queryToggleShowInheritedMethods: aCommandQuery
	| showing |
	(self hasClassSelected and: [self actualClass superclass notNil]) ifFalse: [^self].
	showing := self isShowInheritedMethods.
	aCommandQuery
		beEnabled;
		isChecked: showing;
		expandMenuTextWith: showing!

recordMethodVisit
	"Add to the visit history - note that the current item is at the top of the history list"

	| method |
	method := self method.
	method isNil ifTrue: [^self].
	(history isEmpty or: 
			[| cur |
			cur := history current.
			cur methodClass ~= method methodClass or: [cur selector ~= method selector]]) 
		ifTrue: 
			[history addLast: method.
			self invalidateUserInterface]
		ifFalse: [history current: method]!

reformatAll
	<commandQuery: #hasClassSelected>
	| env |
	env := classesPresenter selectionEnvironment.
	(MessageBox new
		owner: self view;
		headline: 'Reformat methods in selected class?';
		confirm: 'Are you sure you want to reformat all methods in <1p>?<n><n>(The operation is undoable)'
					<< env)
			ifFalse: [^self].
	self model reformatAllMethodsIn: env!

removeMethod: aCompiledMethod fromCategory: aMethodCategory 
	"Private - Remove the <CompiledMethod>, method, from the <MethodCategory>,
	targetCategory, e.g. following a drag-link operation in the category pane."

	aMethodCategory removeMethod: aCompiledMethod.
	aCompiledMethod storeCategories!

removeMethodCategory
	"Private - Remove the currently selected category without deleting any	of the methods."

	<commandQuery: #queryRemoveMethodCategory:>
	| actualClass catModel args |
	actualClass := self actualClass.
	args := { actualClass. self category }.
	(MessageBox new
		owner: self view;
		headline: 'Remove ''<2d>'' from <1p>?' << args;
		confirm: 'Are you sure you would like to remove the method category ''<2d>'' and its sub-categories from <1p>?<n><n>(No methods will be deleted)'
					<< args)
			ifFalse: [^self].
	self categories do: [:category | category removeClass: actualClass].
	catModel := categoriesPresenter model.
	catModel remove: self category.
	categoriesPresenter selection: self allCategory!

removeMethodProtocol
	"Private - Remove the currently selected protocols from the class."

	<commandQuery: #queryRemoveMethodProtocols:>
	self protocols do: [:p | self model removeClass: self actualClass fromProtocol: p]!

removeMethodsInCategory
	"Private - Remove all of the methods in the currently selected category. As this is rather
	drastic the user will be prompted."

	<commandQuery: #canRemoveMethodsInCategory>
	| classEnvironment categoryEnvironment searchEnvironment mb |
	searchEnvironment := self searchEnvironment.
	classEnvironment := searchEnvironment forClasses: { self actualClass }.
	categoryEnvironment := classEnvironment forMethodCategories: self categories.
	categoryEnvironment label: ('methods of <1p> in the ''<2d>'' category and its subcategories'
				expandMacrosWith: classEnvironment
				with: self category).
	mb := MessageBox new
				headline: 'Remove Methods?';
				defaultButton: 2;
				customButtons: #(#(#yes '&Remove') #(#no '&Don''t Remove'));
				isCancellable: true;
				yourself.
	self developmentSystem canRefactor
		ifTrue: [mb checkboxText: self developmentSystem showChangesText].
	(mb confirm: 'Are you sure you would like to remove <1p>?' << categoryEnvironment)
		ifTrue: 
			[self developmentSystem
				basicRemoveMethodsIn: categoryEnvironment
				within: searchEnvironment
				showChanges: mb isChecked]!

removeMethodsInProtocol
	"Private - Remove all of the methods in the currently selected protocol.
	As this is pretty drastic we give the user a second chance."

	<commandQuery: #hasProtocolsSelected>
	| actualClass |
	actualClass := self actualClass.
	self protocols do: 
			[:p |
			| args methods |
			methods := p methodsInBehavior: actualClass.
			args := { actualClass. p. methods size }.
			(MessageBox new
				defaultButton: 2;
				owner: self view;
				headline: 'Remove <2d> from <1p>?' << args;
				confirm: '<1p> will no longer conform to <2d>, and <3d> of its methods will be deleted.<n><n>Are you sure you would like to remove the protocol <2d> and all of its methods from <1p>?'
							<< args)
					ifTrue: [actualClass removeSelectors: (methods collect: [:m | m selector])]]!

removePlugin: aClassBrowserPlugin 
	self loadedPlugins remove: aClassBrowserPlugin.
	cardsPresenter remove: aClassBrowserPlugin!

renameInstanceVariable
	"Private - Initiate a rename of the  first selected instance variable."

	<commandQuery: #queryRemoveInstanceVariables:>
	variablesPresenter view editSelectionLabel!

renameIt
	<commandQuery: #queryRenameItCommand:>
	<acceleratorKey: 'F2'>
	self perform: self renameItCommand!

renameItCommand
	"Private - Answer the appropriate rename command for the context sensitive 'Rename It' command, given
	the current focus in the receiver."

	| focus |
	focus := View focus.
	focus == categoriesPresenter view ifTrue: [^#renameMethodCategoryInPlace].
	focus == protocolsPresenter view ifTrue: [^#renameMethodProtocol].
	focus == variablesPresenter view ifTrue: [^#renameInstanceVariable].
	^nil!

renameMethodCategory
	"Private - Prompter for a new name for the current category, and rename it."

	<commandQuery: #hasNonVirtualCategorySelected>
	| originalCategory newName actualClass |
	originalCategory := self category.
	actualClass := self actualClass.
	newName := (CategoryPrompter createOn: originalCategory asValue)
				list: MethodCategory allMethodCategories;
				caption: ('Rename  ''<1d>'' within <2p>' expandMacrosWith: originalCategory with: actualClass);
				allowIntermediates: originalCategory isIntermediate;
				showModal.
	self renameMethodCategory: originalCategory to: newName!

renameMethodCategory: aMethodCategory to: aString
	"Private - Rename the specified <MethodCategory>. This is complicated by the pseudo category hierarchy which
	is built up - if a branch category is renamed, then we need to rename all its sub-categories."

	| rootSubNames originalSubNames actualClass |
	(aString notNil and: [aString ~= aMethodCategory]) ifFalse: [^self].
	originalSubNames := aMethodCategory subNames.
	actualClass := self actualClass.
	rootSubNames := aString subNames.
	self categories do: 
			[:category |
			| methods subNames newSubNames name newCategory |
			subNames := category subNames.
			newSubNames := rootSubNames copy , (subNames copyFrom: originalSubNames size + 1).
			name := String new.
			newSubNames do: [:subName | name := name , subName]
				separatedBy: [name := name copyWith: Category.Separator].
			newCategory := MethodCategory name: name.

			"Ensure it is in the category tree"
			categoriesPresenter model addCategory: newCategory.
			methods := category methodsInBehavior: actualClass.
			category removeClass: actualClass.
			methodBrowserPresenter addMethods: methods toCategory: newCategory].
	self actualClass: actualClass.
	categoriesPresenter selection: aString
		ifAbsent: [categoriesPresenter selection: (IntermediateCategory name: aString name)].
	categoriesPresenter model remove: aMethodCategory!

renameMethodCategoryInPlace
	"Private - Initiate an in-place rename of the currently selected category node."

	<commandQuery: #hasNonVirtualCategorySelected>
	categoriesPresenter selectableItems view editSelectionLabel!

renameMethodProtocol
	"Private - Rename the current method protocol."
	
	protocolsPresenter view editSelectionLabel!

resetFor: aClass 
	"Private - Reset the receiver to place it into a state required to display aClass"

	!

resetForFoundClass: class 
	"Private - Reset the receiver to place it into a state required to display aClass
	that has just been searched for"

	self resetFor: class!

saveDefinition
	"Private - Save the class definition currently in the definition window"

	<commandQuery: #hasClassSelected>
	| wasModified |
	wasModified := definitionPresenter isModified.
	definitionPresenter isModified: false.
	#todo.	"Use change objects so this is undoable/redoable."
	
	[definitionPresenter evaluateRange: (1 to: definitionPresenter textLength)
		ifFail: 
			[definitionPresenter isModified: wasModified.
			^self]]
			on: Error
			do: 
				[:e |
				definitionPresenter isModified: wasModified.
				e okCancel]!

saveNewMethod: aString
	"Private - Save the specified text as the method source of a new method in the current
	category or leave unclassified if no suitable category is selected."

	| method newMethod status |
	method := self method.
	newMethod := method isNil
				ifTrue: 
					[| cat class categories package |
					cat := self category.
					categories := (cat notNil and: [cat acceptsAdditions])
								ifTrue: [{ cat }]
								ifFalse: [self model defaultMethodCategories].
					class := self classForNewMethod.
					class isNil ifTrue: [^self].
					package := self packageForNewMethod.
					methodBrowserPresenter
						saveMethod: aString
						in: class
						environment: (package ifNotNil: [package environment])
						categories: categories
						package: package]
				ifFalse: 
					[| package methodClass namespace |
					methodClass := method methodClass.
					(self packageManager packageOfMethod: method)
						ifNotNil: 
							[:p |
							"Existing loose method "
							package := p.
							namespace := (package ?? method) environment]
						ifNil: 
							[package := methodClass owningPackage.
							namespace := methodClass environment].
					package := method owningPackage.
					newMethod := methodBrowserPresenter
								saveMethod: aString
								in: methodClass
								environment: namespace
								categories: method realCategories
								package: package].
	"When a method is saved it may no longer match the filter. If this is the case we reselect method
	 causing the filter to be reset, preserving the status model value in case there were any compilation
	 warnings."
	(newMethod notNil and: [self method ~~ newMethod]) ifFalse: [^self].
	status := self statusModel value.
	self method: newMethod.
	self statusModel value: status!

saveStateOn: aWriteStream
	"Private - Write the source of a monadic block that will configure an instance of the receiver's class
	to match the state current receiver, to aWriteStream. The block expects a fresh instance of
	the receiver's class as it's parameter"

	aWriteStream nextPutAll: '[:aClassBrowser | '.
	self method
		ifNil: 
			[self hasClassSelected
				ifTrue: 
					['aClassBrowser actualClass: <1s>.' expandMacrosWithArguments: {self actualClass fullName} on: aWriteStream.
					aWriteStream cr]]
		ifNotNil: 
			[:method |
			'aClassBrowser method: <1s> >> <2p>.'
				expandMacrosWithArguments: {method methodClass fullName. method selector}
				on: aWriteStream.
			aWriteStream cr].
	super saveStateOn: aWriteStream.
	aWriteStream nextPutAll: ' value: aClassBrowser.'.
	aWriteStream nextPut: $]!

searchEnvironment
	^classesPresenter searchEnvironment!

searchForClass: aClass 
	self promptToSaveChanges ifFalse: [^self].
	self resetForFoundClass: aClass.
	self actualClass: aClass ifAbsent: [^super searchForClass: aClass]!

searchForMethod: aCompiledMethod 
	self promptToSaveChanges ifFalse: [^self].
	self method: aCompiledMethod ifAbsent: [super searchForMethod: aCompiledMethod]!

selectedClass
	"Private - Answer the class selected in the classes tree (or nil if there is no selection)."

	^classesPresenter selectionOrNil!

selectedClasses
	^classesPresenter selections!

selectedMethod
	^methodBrowserPresenter selectedMethod!

selectedMethods
	^methodBrowserPresenter selections!

selectedMethods: aCollection
	methodBrowserPresenter selections: aCollection!

selectionEnvironment
	| env |
	env := self searchEnvironment.
	classesPresenter hasSelection
		ifTrue: 
			[| methods |
			methods := self selectedMethods.
			env := methods isEmpty
						ifFalse: [(env forMethods: methods) label: 'Some methods of <1p>' << classesPresenter selection]
						ifTrue: [classesPresenter selectionEnvironment]].
	^env!

selectMethod: aCompiledMethod 
	"Refine the browser's selection to be browsing the <CompiledMethod> argument."

	"Note that we check to see if aCompiledMethod is a valid method, this
	is because the hidden UndefinedObject>>doIt method may be supplied
	or some other problem with the method may have ensued. There is a chance
	this may hide some problems so beware."

	| selector class |
	class := aCompiledMethod methodClass.
	selector := aCompiledMethod selector.
	(class includesSelector: selector) 
		ifTrue: [self method: (class compiledMethodAt: selector)]
		ifFalse: [self actualClass: class]!

setInitialFocus
	self hasMethodSelected 
		ifTrue: [methodBrowserPresenter setInitialFocus]
		ifFalse: 
			[self hasClassSelected ifTrue: [classesPresenter setInitialFocus] ifFalse: [super setInitialFocus]]!

setMethodsFilter: aMonadicValuable
	methodBrowserPresenter
		list: (self methodsMatching: aMonadicValuable) asOrderedCollection;
		filter: aMonadicValuable!

setVisitTimer
	self view setTimer: 1 interval: self class historyDwellTime!

shortCaption
	| stream |
	stream := String smalltalkWriteStream: 32.
	self isOpen
		ifTrue: 
			[self printShortCaptionForClass: self actualClass on: stream.
			self isModified ifTrue: [stream nextPut: $*]]
		ifFalse: 
			[stream
				nextPutAll: 'A closed ';
				print: self class].
	^stream contents!

slideyPinNames
	^#('filtersSlidey')!

sourceCardName
	^'source'!

statusModel
	^statusModel!

statusText: aString
	self statusModel value: (aString isNil ifFalse: [Notification messageText: aString])!

systemModel
	^self model!

toggleFilterObjectMethods
	"Toggle between showing <Object> methods or not"

	<commandQuery: #queryFilterObjectMethods:>
	self isFilteringObjectMethods: self isFilterObjectMethods not.
	self onClassSelected!

toggleProtocolReadOnly
	"Toggle the currenty method protocol between read-only and updatable status."

	<commandQuery: #queryToggleProtocolReadOnly:>
	| prot |
	prot := self protocols first.
	prot isReadOnly: prot isReadOnly not!

toggleShowInheritedMethods
	"Toggle between showing inherited methods or not"

	<commandQuery: #queryToggleShowInheritedMethods:>
	self isShowingInheritedMethods: self isShowInheritedMethods not.
	self onClassSelected!

updateCaption
	"The receiver has changed in such a way that the caption may need to be refreshed.
	Do this here"

	| stream |
	stream := String smalltalkWriteStream: 64.
	self method
		ifNotNil: [:method | self printCaptionForMethod: method on: stream]
		ifNil: 
			[self actualClass
				ifNil: [self printBasicCaptionOn: stream]
				ifNotNil: [:class | self printCaptionForClass: class on: stream]].
	self isModified ifTrue: [stream nextPut: $*].
	self caption: stream contents!

updateCategories
	"Private - Update the tree of method categories, attempting to maintain
	the current selection."

	classesPresenter hasSelection
		ifTrue: 
			[| last |
			last := self category.
			"Set up the category tree for the class"
			categoriesPresenter model list: self actualClassChainCategories.
			categoriesPresenter expand: self allCategory.
			(last isNil or: [(categoriesPresenter selection: last ifAbsent: []) ~= last])
				ifTrue: [categoriesPresenter selection: self allCategory]]
		ifFalse: [categoriesPresenter model clear]!

updateClass: aspectString presenter: aSmalltalkWorkspace source: sourceString
	| class event |
	class := self actualClass.
	event := (SelectionChangingEvent forSource: self)
				oldSelection: class;
				newSelection: class;
				yourself.
	(aSmalltalkWorkspace prompt: aspectString toSaveChanges: event)
		ifTrue: [aSmalltalkWorkspace text: sourceString]!

updateClassDefinition
	| selection |
	selection := self selectedClass.
	definitionPresenter
		text: (selection isNil ifTrue: [''] ifFalse: [self definitionOfClass: selection]);
		evaluationContext: selection!

updateFilters
	"Private - Update the various filter lists displayed in the middle pane of the browser."

	self
		updateCategories;
		updateProtocols;
		updateVariables!

updateMethodsInCategory
	"Private - Set the methods of the receiver's methodBrowserPresenter so it
	only shows methods of the selected class and any selected categories."

	self setMethodsFilter: self categoriesFilter!

updateMethodsInProtocol
	"Private - Set the methods of the receiver's methodBrowserPresenter so it
	only shows methods of the selected class and any selected protocols."

	| filter |
	filter := self protocols isEmpty 
				ifTrue: [self classMethodFilter]
				ifFalse: [self protocolsMethodFilter].
	self setMethodsFilter: filter!

updateMethodsReferencingVariables
	"Private - Set the methods of the receiver's methodBrowserPresenter so it
	only shows methods of the selected class which reference any of the 
	selected instance variables."

	self setMethodsFilter: self variablesFilter!

updatePackage
	"Private - Update the currently displayed package to reflect the package which owns
	either the current method or class."

	| package |
	self hasMethodSelected ifTrue: [package := self method owningPackage].
	(package isNil and: [self hasClassSelected]) ifTrue: [
		package := self selectedClass owningPackage].
	packageModel value: package.
!

updateProtocols
	"Private - Update the list of protocols implemented by the class, attempting to maintain
	the current selection."

	| class |
	protocolsPresenter hasView ifFalse: [^self].
	(class := self actualClass) isNil
		ifTrue: [protocolsPresenter clear]
		ifFalse: [ | last |
			last := self protocols.
			protocolsPresenter model list: (class allProtocols asSortedCollection: [:a :b | a name < b name]).
			"If there was previously no selection, then the list view won't issue a selection change
			 event, so we must forcibly refresh the methods list"
			last isEmpty
				ifTrue: [self onProtocolSelected]
				ifFalse: [protocolsPresenter selections: last ifAbsent: []]]!

updateSourceEnablement
	methodBrowserPresenter enableSource: self canSaveMethod!

updateVariables
	"Private - Update the list of instance variables in this class and its superclasses."

	| class count vars |
	variablesPresenter hasView ifFalse: [^self].
	((class := self actualClass) isNil or: [(count := class instSize) = 0])
		ifTrue: 
			[variablesPresenter clear.
			^self].
	"Construct a list associating each class with each of its instance variables"
	vars := OrderedCollection new: count.
	class withAllSuperclasses reverseDo: 
			[:eachClass |
			eachClass instanceVariableNames do: [:eachInstVar | vars addLast: eachClass -> eachInstVar]].
	variablesPresenter model list = vars
		ifFalse: 
			[| selectedVars |
			selectedVars := variablesPresenter selections.
			variablesPresenter model list: vars.
			selectedVars := selectedVars intersection: vars.
			selectedVars notEmpty
				ifTrue: 
					[variablesPresenter selections: selectedVars.
					^self]].
	"If there will be no selection, or the variables list has not changed, then the list view won't issue a selection change event, so we must forcibly refresh the methods list"
	self onVariableSelected!

validateProtocol: targetProtocol renameTo: newName
	"Private - Warn that renaming a protocol is not wise, especially if it already has conforming
	classes."

	| otherClasses msg |
	(MethodProtocol exists: newName)
		ifTrue: 
			[MessageBox new
				headline: 'Unable to rename <1d> to <2p>' << {targetProtocol. newName};
				errorMsg: 'A protocol named <1p> already exists' << newName.
			^false].
	otherClasses := targetProtocol baseBehaviors
				remove: self actualClass ifAbsent: nil;
				yourself.
	otherClasses isEmpty
		ifTrue: 
			[msg := String writeStream
						nextPutAll: 'The protocol ';
						display: targetProtocol;
						nextPutAll: ' is not currently implemented by any other class hierarchies.';
						cr;
						nextPutAll: 'Even so are you sure that you would like to rename it to ';
						print: newName;
						nextPut: $?;
						contents]
		ifFalse: 
			[msg := String writeStream.
			msg
				nextPutAll: 'The protocol ';
				display: targetProtocol;
				nextPutAll: ' is also implemented by unrelated or superclass hierarchies with the following roots:';
				cr.
			otherClasses asSortedCollection do: 
					[:c |
					msg
						cr;
						nextPutAll: '    ';
						display: c].
			msg
				cr;
				cr;
				nextPutAll: 'If this protocol is renamed these classes or their clients may be adversely affected.';
				cr;
				cr;
				nextPutAll: 'Are you sure that you would like to proceed (not recommended)?'.
			msg := msg contents].
	^MessageBox new
		defaultButton: 2;
		headline: 'Rename protocol <1d> to <2p>?' << {targetProtocol. newName};
		confirm: msg!

variables
	"Private - Answer a <collection> of all the instance variables names
	which are currently selected."

	^variablesPresenter hasView 
		ifTrue: [variablesPresenter selections]
		ifFalse: [#()]!

variablesFilter
	^self variables isEmpty 
		ifTrue: [self classMethodFilter]
		ifFalse: [self variablesMethodFilter]!

variablesIndices
	"Private - Answer an <Array> of indices of the selected instance variable"

	| varNames |
	varNames := self actualClass allInstanceVariableNames.
	^self variables collect: [:iv | varNames indexOf: iv value].
!

variablesMethodFilter
	"Private - Answer a <monadicValuable> that, when passed a <CompiledMethod>, answers true if the
	method should be displayed in the receiver by warrant of the variable that is selected"

	| indices |
	indices := self variablesIndices.
	^[:m | (self isMethodVisible: m) and: [m byteCodeDispatcher accessesInstVarAtAnyOf: indices]]! !

!Tools.ClassBrowserAbstract categoriesForMethods!
acceptItCommand!helpers!private! !
actualClass!accessing!public! !
actualClass:!accessing!public! !
actualClass:ifAbsent:!accessing!public! !
actualClassChain!accessing!private! !
actualClassChainCategories!accessing!private! !
actualClassChainMethods!helpers!private! !
actualClasses!accessing!public! !
addCategoriesOfMethod:!helpers!private! !
addMethod:toCategory:!operations!private! !
addMethodCategory!commands-actions!private! !
addMethodProtocol!commands-actions!private! !
addToCommandRoute:!commands-routing!public! !
allCategoriesOfMethod:!helpers!private! !
allCategory!private!updating! !
applyOptions!operations!options!private! !
browseClassHierarchy!commands-actions!public! !
browseContainingText!commands-actions!public! !
browseDefinitionsMatching:in:!helpers!private! !
browseInstanceVariableReferences!commands-actions!public! !
browseItCommand!commands-mappings!private! !
browseMessageDefinitionsIn:!commands-actions!private! !
browseMessageReferencesIn:!commands-actions!private! !
browseMethodCategory!commands-actions!private! !
browseOverriddenMethod!commands-actions!public! !
browseReferencesCommand!helpers!private! !
browseReferencesMatching:in:!helpers!private! !
browserEnvironment!accessing!public! !
browseSelectorsInProtocol!commands-actions!private! !
browseSystem!commands-actions!public! !
buildHistoryFutureMenu:!helpers!menus!private! !
buildHistoryMenu:visits:command:!helpers!menus!private! !
buildHistoryPastMenu:!helpers!menus!private! !
canRemoveMethodsInCategory!commands-queries!private! !
canSaveMethod!commands-queries!private!testing! !
canSaveState!private!saved state! !
canShowLocalHierarchy!private!testing! !
cardsPresenter!accessing!private! !
categories!accessing!private! !
categoriesEnvironment!commands-actions!private! !
categoriesFilter!accessing!private! !
categoriesMethodFilter!accessing!private! !
category!accessing!public! !
classDefinition!accessing!private! !
classForNewMethod!operations!private! !
classMenu!commands-menus!private! !
classMethodFilter!accessing!private! !
classMode!accessing!private! !
classMode:!modes!private! !
createAccessors!commands-actions!private!refactoring! !
createComponents!initializing!private! !
createPlugins!initializing!public! !
createSchematicWiring!initializing!public! !
currentCard!accessing!public! !
customDrawCategoryTree:!helpers!private! !
customDrawProtocols:!helpers!private! !
customDrawSelector:!helpers!private! !
definitionCardName!constants!private! !
definitionOfClass:!event handling!private! !
deleteItCommand!commands-mappings!private! !
displayLocalHierarchyOf:!private!updating! !
dropMethods:onto:!helpers!private! !
emphasiseCategoryItem:isRelevant:!helpers!private! !
emphasiseProtocolItem:isRelevant:!helpers!private! !
ensureDefinitionVisible!operations!private! !
ensureSourceVisible!operations!private! !
futureSize!accessing!public! !
hasClassSelected!commands-queries!public!testing! !
hasEditableMethodSelected!public!testing! !
hasEditableMethodsSelected!public!testing! !
hasHistory!private!testing! !
hasInstanceVariableSelected!private!testing! !
hasInstanceVariablesSelected!private!testing! !
hasMethodCategoriesSelected!private!testing! !
hasMethodSelected!public!testing! !
hasMutableProtocolSelected!private!testing! !
hasNonVirtualCategorySelected!private!testing! !
hasOverrideSelected!private!testing! !
hasProtocolSelected!private!testing! !
hasProtocolsSelected!private!testing! !
hierarchyOfCategory:!helpers!private! !
historyClear!commands-actions!public! !
historySkip:!commands-actions!private! !
initialize!initializing!private! !
inspectCollection:!helpers!private! !
inspectInstanceVariables!commands-actions!private! !
inspectItCommand!commands-actions!private! !
inspectMethodCategories!commands-actions!private! !
inspectMethodProtocols!commands-actions!private! !
isDefinitionCardVisible!private!testing! !
isDisplayingCategories!commands-actions!private! !
isDisplayingProtocols!commands-actions!private! !
isDisplayingVariables!commands-actions!private! !
isEditableMethod:!modes!public! !
isFilteringObjectMethods:!commands-actions!public! !
isFilterObjectMethods!public!testing! !
isInheritedMethod:!modes!public! !
isInstanceMode!modes!private! !
isInstanceMode:!modes!private! !
isLocalHierarchyMode!private!testing! !
isLocalHierarchyMode:!accessing!private! !
isMethodFiltrate:!private!testing! !
isMethodVisible:!private!testing! !
isModified!public!testing! !
isShowingInheritedMethods:!commands-actions!public! !
isShowInheritedMethods!public!testing! !
isSourceCardVisible!private!testing! !
killVisitTimer!helpers!private! !
loadedPlugins!accessing!public! !
method!accessing!public! !
method:!accessing!public! !
method:ifAbsent:!accessing!public! !
methodCategories:!accessing!private! !
methodMenu!commands-menus!private! !
methodProtocols!accessing!private! !
methodProtocols:!accessing!public! !
methods!accessing!public! !
methodsMatching:!helpers!private! !
modifiedModel:!accessing!public! !
namespaceForNewMethodOf:!accessing!private! !
newMethod!commands-actions!public! !
onBrowserCardChangedFrom:to:!event handling!private! !
onCategory:renameTo:accept:!event handling!private! !
onCategorySelected!event handling!private! !
onClassCategorized:!event handling!private! !
onClassModeChanged!event handling!private! !
onClassRepackaged:from:to:!event handling!private! !
onClassSelected!event handling!private! !
onClassSelectionChanging:!event handling!private! !
onClassUpdated:!event handling!private! !
onCloseRequested:!event handling!private! !
onDragCategory:!event handling!private! !
onDragMethodsCut:!event handling!private! !
onDragOverCategory:!event handling!private! !
onDragOverMethod:!event handling!private! !
onDragOverMode:!event handling!private! !
onDragProtocol:!event handling!private! !
onDragVariableRefs:!event handling!private! !
onDropOverCategory:!event handling!private! !
onDropOverMethods:!event handling!private! !
onDropOverMode:!event handling!private! !
onFilterCardChangedFrom:to:!event handling!private! !
onFilterSelectionChanging:!event handling!private! !
onMethodAdded:!event handling!private! !
onMethodCategorized:!event handling!private! !
onMethodListDoubleClicked:!event handling!private! !
onMethodRemoved:!event handling!private! !
onMethodRepackaged:from:to:!event handling!private! !
onMethodSelected!event handling!private! !
onMethodUpdated:!event handling!private! !
onModeSelectionChanged!event handling!private! !
onPackageDoubleClicked:!event handling!private! !
onPromptToSaveChanges:!helpers!private! !
onPromptToSaveClassChanges:!helpers!private! !
onPromptToSaveMethodChanges:!helpers!private! !
onProtocolRemoved:!event handling!private! !
onProtocolSelected!event handling!private! !
onProtocolUpdated:!event handling!private! !
onRenameInstVar:to:!event handling!private! !
onRenameInstVar:to:accept:!event handling!private! !
onRenameMethodProtocol:to:accept:!event handling!private! !
onRepackaged:!event handling!private! !
onStatusDoubleClicked:!event handling!private! !
onTimerTick:!event handling!private! !
onVariableSelected!event handling!private! !
onViewOpened!event handling!private! !
packageForNewMethod!operations!private! !
packageNames:!accessing!public! !
packages:!accessing!public! !
parseContext!accessing!public! !
parseTree!accessing!private! !
pastSize!accessing!public! !
printBasicCaptionOn:!private!updating! !
printCaptionForClass:on:!helpers!private! !
printCaptionForMethod:on:!private!updating! !
printClassTitle:on:!private!updating! !
printShortCaptionForClass:on:!helpers!private! !
promptToCopyChanges!commands-actions!private! !
promptToSaveChanges!commands-actions!private! !
protocols!accessing!public! !
protocols:!accessing!public! !
protocolsMethodFilter!accessing!private! !
queryBrowseClass:!commands-queries!private! !
queryFilterObjectMethods:!commands-queries!private! !
queryHistoryBack:!commands-queries!private! !
queryHistoryForward:!commands-queries!private! !
queryNewMethod:!commands-queries!private! !
queryRemoveMethodCategory:!commands-queries!private! !
queryRemoveMethodProtocols:!commands-queries!private! !
queryRenameItCommand:!commands-queries!private! !
queryToggleLocalHierarchy:!commands-queries!private! !
queryToggleProtocolReadOnly:!commands-queries!private! !
queryToggleShowInheritedMethods:!commands-queries!private! !
recordMethodVisit!helpers!private! !
reformatAll!commands-actions!public! !
removeMethod:fromCategory:!helpers!private! !
removeMethodCategory!commands-actions!private! !
removeMethodProtocol!commands-actions!private! !
removeMethodsInCategory!commands-actions!private! !
removeMethodsInProtocol!commands-actions!private! !
removePlugin:!accessing!public! !
renameInstanceVariable!commands-actions!private!refactoring! !
renameIt!commands-actions!public! !
renameItCommand!commands-mappings!private! !
renameMethodCategory!commands-actions!private! !
renameMethodCategory:to:!commands-actions!private! !
renameMethodCategoryInPlace!commands-actions!private! !
renameMethodProtocol!commands-actions!private! !
resetFor:!commands-actions!private! !
resetForFoundClass:!commands-actions!private! !
saveDefinition!commands-actions!private! !
saveNewMethod:!operations!private! !
saveStateOn:!private!saved state! !
searchEnvironment!commands-actions!public! !
searchForClass:!helpers!private! !
searchForMethod:!helpers!private! !
selectedClass!accessing!private! !
selectedClasses!accessing!private! !
selectedMethod!public! !
selectedMethods!accessing!public! !
selectedMethods:!accessing!public! !
selectionEnvironment!accessing!private! !
selectMethod:!operations!private! !
setInitialFocus!operations!public! !
setMethodsFilter:!private!updating! !
setVisitTimer!helpers!private! !
shortCaption!accessing!public! !
slideyPinNames!accessing!private! !
sourceCardName!constants!private! !
statusModel!accessing!public! !
statusText:!accessing!private! !
systemModel!accessing!private! !
toggleFilterObjectMethods!commands-actions!public! !
toggleProtocolReadOnly!commands-actions!public! !
toggleShowInheritedMethods!commands-actions!public! !
updateCaption!public!updating! !
updateCategories!private!updating! !
updateClass:presenter:source:!helpers!private! !
updateClassDefinition!event handling!private! !
updateFilters!private!updating! !
updateMethodsInCategory!private!updating! !
updateMethodsInProtocol!private!updating! !
updateMethodsReferencingVariables!private!updating! !
updatePackage!private!updating! !
updateProtocols!private!updating! !
updateSourceEnablement!helpers!private! !
updateVariables!private!updating! !
validateProtocol:renameTo:!operations!private! !
variables!accessing!private! !
variablesFilter!accessing!private! !
variablesIndices!accessing!private! !
variablesMethodFilter!accessing!private! !
!

Tools.ClassBrowserAbstract methodProtocol: #methodBrowserHost attributes: #(#readOnly) selectors: #(#hasEditableMethodSelected #isEditableMethod: #parseContext #saveNewMethod:)!

!Tools.ClassBrowserAbstract class methodsFor!

addPlugin: aClassBrowserPlugin 
	^plugins add: aClassBrowserPlugin!

availablePluginClasses
	"Private - Answers a  collection of plugin classes to choose from"

	^(ClassCategory name: 'Browser-Plugins') classes!

basicPlugins
	^plugins!

basicPlugins: aSequencedReadableCollection
	plugins := aSequencedReadableCollection!

classCommentIcon
	"Private - Answer the <Icon> to use for the class comment tab"

	^Icon fromId: 'ClassComment.ico'!

defaultFilterObjectMethods
	"Answer true if instances of the receiver filter out <Object> methods by default."

	^self optionFlags allMask: FilterObjectMethodsMask!

defaultFilterObjectMethods: aBoolean
	"Sets the default showing of filtering out of <Object> methods for instances of the receiver to aBoolean."

	self setOptionFlag: FilterObjectMethodsMask value: aBoolean!

defaultOptionFlags
	^##(CanUseIdeaSpaceMask | FilterObjectMethodsMask)!

defaultPluginsCollection
	"Private - Answers a  collection of plugin classes to choose from"

	| answer |
	answer := OrderedCollection new.
	#(#{ClassCommentPlugin} #{ClassDiagramPlugin} #{ResourceListPlugin} #{CodeMentorPlugin} #{CodeRewriterPlugin} #{UnitTestPlugin})
		do: [:each | each ifDefined: [:class | answer add: class]].
	^answer!

defaultShowInheritedMethods
	"Answer true if instances of the receiver show inherited methods by default."

	^self optionFlags allMask: ShowInheritedMethodsMask!

defaultShowInheritedMethods: aBoolean
	"Sets the default showing of inherited methods for instances of the receiver to aBoolean."

	self setOptionFlag: ShowInheritedMethodsMask value: aBoolean!

grayedMethodFadeFactor
	self ensureOptionsLoaded.
	^GrayedMethodFadeFactor!

grayedMethodFadeFactor: aNumber
	self grayedMethodFadeFactor = aNumber ifTrue: [^self].
	GrayedMethodFadeFactor := aNumber.
	self persistOptions!

historyListSize
	self ensureOptionsLoaded.
	^HistoryListSize!

historyListSize: anInteger
	HistoryListSize = anInteger ifTrue: [^self].
	HistoryListSize := anInteger.
	self persistOptions!

looseMethodColor
	"Answer the <Color> used to highlight loose methods."

	self ensureOptionsLoaded.
	^LooseMethodColor!

looseMethodColor: aColor
	"Set the <Color> used to highlight loose methods."

	self looseMethodColor = aColor ifTrue: [^self].
	LooseMethodColor := aColor.
	self persistOptions!

plugins
	"Answer the plugins installed by instances of the receiver"

	self ensureOptionsLoaded.
	^OS.SystemMetrics current hasWebView
		ifTrue: [plugins]
		ifFalse: 
			["The CodeMentor plugin relies on the Internet Explorer control>"
			plugins reject: [:each | each name == #CodeMentorPlugin]]!

plugins: anOrderedCollection 
	"Sets the plugins installed by instances of the receiver"

	plugins = anOrderedCollection ifTrue: [^self].
	plugins := anOrderedCollection.
	self persistOptions!

publishedAspects
	"Answer a <LookupTable> of the <Aspect>s published by the receiver."

	| aspects |
	aspects := super publishedAspects.
	aspects add: self canUseIdeaSpaceAspect.
	#(#wordWrapSource #wordWrapDefinition #defaultFilterObjectMethods)
		do: [:each | aspects add: ((Aspect boolean: each)
						defaultValue: true;
						yourself)].
	aspects
		add: (Aspect boolean: #defaultShowInheritedMethods);
		add: ((Aspect color: #looseMethodColor)
					defaultValue: Color purple;
					yourself);
		add: ((Aspect number: #grayedMethodFadeFactor)
					defaultValue: 2;
					yourself);
		add: ((Aspect sequenceableCollection: #plugins addFrom: [self availablePluginClasses])
					beMutable;
					defaultValue: [self defaultPluginsCollection];
					yourself);
		add: ((Aspect integer: #historyListSize)
					defaultValue: self defaultHistoryListSize;
					yourself).
	^aspects!

removePlugin: aClassBrowserPlugin
	plugins ifNil: [^aClassBrowserPlugin].
	^plugins remove: aClassBrowserPlugin ifAbsent: nil!

wordWrapDefinition
	"Answer true if instances of the receiver use definition word wrapping."

	^WordWrapDefinition!

wordWrapDefinition: aBoolean
	"Sets the definition word wrapping state for instances of the receiver to aBoolean."

	self wordWrapDefinition == aBoolean ifTrue: [^self].
	WordWrapDefinition := aBoolean.
	self persistOptions!

wordWrapSource
	"Answer true if instances of the receiver use source word wrapping."

	^MethodBrowser wordWrap!

wordWrapSource: aBoolean
	"Sets the source word wrapping state for instances of the receiver to aBoolean."

	self wordWrapSource == aBoolean ifTrue: [^self].
	MethodBrowser wordWrap: aBoolean.
	self persistOptions! !

!Tools.ClassBrowserAbstract class categoriesForMethods!
addPlugin:!initializing!private! !
availablePluginClasses!helpers!private! !
basicPlugins!accessing!private! !
basicPlugins:!accessing!private! !
classCommentIcon!helpers!private! !
defaultFilterObjectMethods!accessing!options!public! !
defaultFilterObjectMethods:!accessing!options!public! !
defaultOptionFlags!constants!options!private! !
defaultPluginsCollection!helpers!private! !
defaultShowInheritedMethods!accessing!options!public! !
defaultShowInheritedMethods:!accessing!options!public! !
grayedMethodFadeFactor!options!public! !
grayedMethodFadeFactor:!options!public! !
historyListSize!accessing!public! !
historyListSize:!accessing!public! !
looseMethodColor!accessing!options!public! !
looseMethodColor:!accessing!options!public! !
plugins!accessing!public!wine fix! !
plugins:!accessing!public! !
publishedAspects!public! !
removePlugin:!initializing!private! !
wordWrapDefinition!accessing!options!public! !
wordWrapDefinition:!accessing!options!public! !
wordWrapSource!accessing!options!public! !
wordWrapSource:!accessing!options!public! !
!

