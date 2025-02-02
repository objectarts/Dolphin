"Filed out from Dolphin Smalltalk"!

UI.ListPresenter
	subclass: #'Tools.MethodBrowser'
	instanceVariableNames: 'methodsPresenter sourcePresenter filter searchEnvironment refactoringTool namespaceModel'
	classVariableNames: 'AdditionalAccelerators AutoFormat InfoTips WordWrap'
	imports: #(#{Kernel.CompilerFlags} #{Refactory.Browser private})
	classInstanceVariableNames: ''
	classConstants: {}!

Tools.MethodBrowser guid: (Core.GUID fromString: '{87b4c68d-026e-11d3-9fd7-00a0cc3e4a32}')!

Tools.MethodBrowser comment: 'MethodBrowser is a <compositePresenter> used to display a <collection> of <CompiledMethod>s. The browser can be instantiated and then filled with methods using #methods: aspect, the value of which must be a <BrowserEnvironment>. The methods defined in the environment are enumerated and displayed in the browser list.

Example:
	MethodBrowser show methods: BrowserEnvironment new.

Note that it is also possible to specify a <monadicValuable> filter that can be used to affect the subsequent maintenance of the browsers content. All methods in the original list are displayed. This is useful for when the browser is required to present a list of methods meeting a specific criteria. If any of these methods are recompiled (possibly in another browser) the filter is applied once more to see whether the browser should continue to display the method in its list.

Instance Variables:
	methodsPresenter		<ListPresenter> holding the methods being displayed.
	sourcePresenter		<MethodWorkspace> for displaying the source of the selected method.
	filter					<monadicValuable> to determine which methods are included in the list.
	searchEnvironment		<BrowserEnvironment> constraining any definition/reference searches performed in the browser
	refactoringTool			<MethodRefactoringTool>

Class Variables:
	AdditionalAccelerators	<Array> of <Array> of <Symbol>, <String> pairs.
	WordWrap			<boolean> indicating whether the source pane should wrap its text.
	AutoFormat			<boolean> indicating whether source is pretty printed when displayed.
	InfoTips				<boolean> indicating whether method info tips (showing category information) should be displayed. If nil then configured by view.

'!

!Tools.MethodBrowser categoriesForClass!MVP-Presenters!MVP-Resources-IDE Tools! !

!Tools.MethodBrowser methodsFor!

addCategoryMenu
	<commandQuery: #hasEditableMethodsSelected>
	<menuPopulator: #buildAddCategoryMenu:>
	!

addMethods: aCollectionOfMethods toCategory: aMethodCategory 
	aMethodCategory addMethods: aCollectionOfMethods.
	aCollectionOfMethods do: [:each | each storeCategories]!

addToCommandRoute: route 
	"Update the <OrderedCollection>, path, with the receiver's contribution to the command path
	held by the <CommandPolicy>, route. Answer the next <Presenter> to visit. The receiver is
	guaranteed not to be on the command path already."

	"Implementation Note: We add our method refactoring tool to the command route, and also the
	workspace to pick up any menu bar commands intended for it."

	| next |
	refactoringTool notNil ifTrue: [route appendTarget: refactoringTool].
	next := super addToCommandRoute: route.
	sourcePresenter addToCommandRoute: route.
	^next!

applyOptions
	"Apply the class options to the receiver"

	| methodList |
	sourcePresenter view wordWrap: self class wordWrap.
	self class hasInfoTips 
		ifNotNil: 
			[:hasTips | 
			methodList := methodsPresenter view.
			(methodList respondsTo: #hasInfoTips:) ifTrue: [methodList hasInfoTips: hasTips]]!

browseCompilationFailures
	(self systemModel methodsThatFailedToCompileIn: self searchEnvironment)
		ifNotNil: [:failed | self browseMethodsIn: failed]!

browseCompilationIssues
	(self systemModel methodsWithCompilationIssuesIn: self searchEnvironment) 
		ifNotNil: [:failed | self browseMethodsIn: failed]!

browseContainingText
	"Prompt for a string and browse the methods containing that string."

	(self developmentSystem 
		methodsContainingText: ''
		in: self searchEnvironment
		prompt: true) ifNotNil: [:env | self browseMethodsIn: env]!

browseDefinitions
	"Browse method definitions with the same selector as the currently selected method."

	<commandQuery: #queryBrowseMethodSelector:>
	self browseDefinitionsMatching: (MethodSearch newSelector: self selectedMethod selector)
		in: self searchEnvironment!

browseDefinitionsMatching: aMethodSearch in: aBrowserEnvironment
	| definitions |
	definitions := OrderedCollection with: (aMethodSearch definitionsIn: aBrowserEnvironment).
	parentPresenter parseContext
		ifNotNil: 
			[:context |
			| class |
			class := context methodClass.
			(aBrowserEnvironment label beginsWith: 'Local hierarchy of <1p>' << class)
				ifFalse: 
					[definitions addLast: (aMethodSearch definitionsIn: (aBrowserEnvironment forClassHierarchyOf: class))]].
	aBrowserEnvironment isSystem
		ifFalse: 
			[definitions addLast: (aMethodSearch definitionsIn: self developmentSystem browserEnvironment)].
	self routeCommand: (CommandDescription
				command: (Message selector: #browseMethodsInEnvironments: argument: definitions))!

browseDefinitionsOfSelector: aSymbol in: aBrowserEnvironment
	"Private - Opens a MethodBrowser on all the methods whose selectors match the specified
	<readableString> pattern in the scope of the specified <BrowserEnvironment>."

	self browseDefinitionsMatching: (MethodSearch newSelector: aSymbol) in: aBrowserEnvironment!

browseHierarchy
	"Open a class hierarchy browser on the current method"

	<commandQuery: #queryBrowseClass:>
	self developmentSystem browseClassHierarchyOfMethod: self selection!

browseItCommand
	"Private - Open a class browser on the selected method(s) class(es)."

	^#browseMethodClasses!

browseMessage
	"Prompt for a selector and open a method browser displaying the implementors and senders of
	that selector."

	self browseMessagesIn: self searchEnvironment!

browseMessageDefinitions
	"Prompt for a selector and open a method browser displaying the implementors of that selector."

	self browseMessageDefinitionsIn: self searchEnvironment!

browseMessageDefinitionsIn: aBrowserEnvironment
	"Private - Prompt for a selector and open a method explorer displaying the implementors of that selector, both globally and in the local hierarchy."

	(self developmentSystem promptForDefinitionsOf: '' in: aBrowserEnvironment)
		ifNotNil: [:search | self browseDefinitionsMatching: search in: self searchEnvironment]!

browseMessageReferences
	"Prompt for a selector and open a method browserdisplaying the references to that selector
	within the context of the current search environment using the first word of the clipboard text as the initial
	suggestion."

	self browseMessageReferences: '' in: self searchEnvironment!

browseMessageReferences: aString in: aBrowserEnvironment
	"Private - Prompt for a selector and open a method explorer displaying the references to that
	selector, using the <readableString> argument as the initial suggestion (or if that is empty
	the first word of the clipboard text)."

	(self developmentSystem promptForReferencesTo: aString in: aBrowserEnvironment)
		ifNotNil: [:search | self browseReferencesMatching: search in: aBrowserEnvironment]!

browseMessagesIn: aBrowserEnvironment
	"Private - Prompt for a selector and open a method browser displaying the references to that
	selector, using the <readableString> argument as the initial suggestion (or if that is empty
	the first word of the clipboard text)."

	(self developmentSystem promptForSelector: ''
		caption: 'Browse Matching Messages in <1p>…' << aBrowserEnvironment)
			ifNotNil: [:search | self browseMessagesMatching: search in: aBrowserEnvironment]!

browseMessagesMatching: aMethodSearch in: aBrowserEnvironment
	| searches |
	searches := aMethodSearch matchesIn: aBrowserEnvironment.
	parentPresenter parseContext
		ifNotNil: 
			[:context |
			| class hierarchy |
			class := context methodClass.
			(aBrowserEnvironment label beginsWith: 'Local hierarchy of <1p>' << class)
				ifFalse: 
					[hierarchy := aBrowserEnvironment forClassHierarchyOf: class.
					searches := searches , (aMethodSearch matchesIn: hierarchy)]].
	self routeCommand: (CommandDescription
				command: (Message selector: #browseMethodsInEnvironments: argument: searches))!

browseMethodClasses
	"Open a class browser on the selected method(s) class(es)."

	"Implementation Note: If a single method is selected, then a default class browser is opened with that method selected, otherwise if methods of a single class are selected then a default class browser is opened on that class, otherwise an Environment Browser is opened on the methods' classes."

	<commandQuery: #queryBrowseMethodClasses:>
	| selections |
	selections := self selections.
	^(selections size = 1
		ifTrue: [selections anyOne]
		ifFalse: 
			[| classes |
			classes := (selections collect: [:each | each methodClass]) asSet.
			classes size = 1 ifTrue: [classes anyOne] ifFalse: [BrowserEnvironment new forClasses: classes]])
			browse!

browseMethodInheritanceChain
	"Open a method browser displaying the definitions of the 
	current selector in the superclass chain."

	<commandQuery: #hasOverrideSelected>
	self developmentSystem browseMethodHierarchyFrom: self selection in: self searchEnvironment!

browseMethodPackages
	"Open a package browser on the current methods' owning packages."

	<commandQuery: #queryBrowseMethodPackages:>
	self developmentSystem browsePackages: (self selections collect: [:each | each owningPackage]) asSet!

browseMethodsIn: aBrowserEnvironment 
	parentPresenter browseMethodsIn: aBrowserEnvironment!

browseMethodsMatching: aMethodSearch in: aBrowserEnvironment
	self browseMethodsIn: (aMethodSearch referencesIn: aBrowserEnvironment)!

browseOther
	"Browse Other menu - always enabled"!

browsePackages
	"Implement the context-sensitive browse packages command by browsing the package
	of the selected method."

	<commandQuery: #hasMethodsSelected>
	self browseMethodPackages.!

browseReferences
	"Context-sensitive 'Browse References' command. In this case browse refs. to the 
	current selector."

	<commandQuery: #queryBrowseMethodSelector:>
	<acceleratorKey: 'Shift+F12'>
	self browseReferencesMatching: (MethodSearch newSelector: self selection selector)
		in: self searchEnvironment!

browseReferencesMatching: aMethodSearch in: aBrowserEnvironment
	| references |
	references := OrderedCollection with: (aMethodSearch referencesIn: aBrowserEnvironment).
	parentPresenter parseContext
		ifNotNil: 
			[:context |
			| class |
			class := context methodClass.
			(aBrowserEnvironment label beginsWith: 'Local hierarchy of <1p>' << class)
				ifFalse: 
					[references addLast: (aMethodSearch referencesIn: (aBrowserEnvironment forClassHierarchyOf: class))]].
	aBrowserEnvironment isSystem
		ifFalse: [references addLast: (aMethodSearch referencesIn: self developmentSystem browserEnvironment)].
	self routeCommand: (CommandDescription
				command: (Message selector: #browseMethodsInEnvironments: argument: references))!

browseReferencesToGlobal
	"Prompt for a global name and open a method browser displaying the
	references to that global."

	| devsys variableName |
	devsys := self developmentSystem.
	variableName := devsys promptForSharedVariableName: self selectedWord.
	variableName ifNil: [^self].
	self browseMethodsIn: (self searchEnvironment
				referencesToVariable: variableName asQualifiedReference binding)!

browseReferencesToLiteral: anObject in: aBrowserEnvironment
	"Private - Opens a MethodBrowser on all the methods that refer to aString from their literal frames
	(aString is normally a symbolic selector), within the scope of the specified
	<BrowserEnvironment>."

	self browseReferencesMatching: (MethodSearch newLiteral: anObject) in: aBrowserEnvironment!

browserEnvironment
	^searchEnvironment!

browseSystem
	"Open a system browser on the current method"

	<commandQuery: #queryBrowseClass:>
	self developmentSystem browseSystemOnMethod: self selection!

browseVariableReferences: aVariableBinding in: aBrowserEnvironment
	"Private - Opens a new Method Browser on all the methods which refer to the shared variable represented by the <VariableBinding> first argument. Also includes methods that refer directly to the current value of the variable."

	self browseMethodsIn: (aBrowserEnvironment referencesToVariable: aVariableBinding)!

buildAddCategoryMenu: aMenu
	"Private - Build a dynamic pull-out menu to hold suggested categories and an 'Other…' 
	command to bring up the traditional prompter."

	"First clear away any previously set-up category addition commands"

	| methods suggestions |
	aMenu clear.
	methods := self selections.
	methods isEmpty ifTrue: [^self].
	suggestions := #().
	methods
		do: [:each | suggestions := suggestions union: (self methodCategorizationPolicy suggestionsFor: each)].
	suggestions notEmpty
		ifTrue: 
			[| suggested |
			suggested := IdentitySet new.
			suggestions do: 
					[:cat |
					(suggested includes: cat)
						ifFalse: 
							[| msg desc |
							suggested add: cat.
							msg := MessageSend
										receiver: self
										selector: #addMethods:toCategory:
										arguments: {methods. cat}.
							desc := cat name.
							(desc identityIncludes: $&) ifTrue: [desc := desc copyReplaceAll: '&' with: '&&'].
							aMenu addCommand: msg description: desc]]].
	aMenu addSeparator.
	aMenu addCommand: #categorizeMethods description: 'Other…'.
	aMenu setDefault: aMenu items size!

buildDefinitionsMenu: aMenu
	self developmentSystem
		buildMessageMenu: aMenu
		forMethods: self selections
		browseSelector: #browseDefinitionsOfSelector:in:
		extraArgs: { self searchEnvironment }
		browseOtherSelector: #browseMessageDefinitionsIn:!

buildParseTree
	^self selectionOrNil ifNotNil: [:method | Parser parseExistingMethodNoError: method]!

buildReferencesMenu: aMenu
	self developmentSystem
		buildMessageMenu: aMenu
		forMethods: self selections
		browseSelector: #browseReferencesToLiteral:in:
		extraArgs: { self searchEnvironment }
		browseOtherSelector: #browseMessageReferencesIn:!

buildRemoveCategoryMenu: aMenu
	| methods categories filterCats |
	aMenu clear.
	methods := self selections.
	filterCats := [:each | each categories reject: [:cat | cat isVirtual]].
	categories := (methods copyFrom: 2) inject: (filterCats value: methods first)
				into: [:cats :each | cats intersection: (filterCats value: each)].
	categories asSortedCollection do: 
			[:each |
			| msg desc |
			msg := MessageSend
						receiver: each
						selector: #removeMethods:
						argument: methods.
			desc := each name.
			(desc identityIncludes: $&) ifTrue: [desc := desc copyReplaceAll: '&' with: '&&'].
			aMenu addCommand: msg description: desc]!

canSaveMethod
	^parentPresenter canSaveMethod!

categorizeMethods
	"Invokes a dialog to categorize the currently selected methods."

	<commandQuery: #hasEditableMethodsSelected>
	| methods originalCategory chosenCategory categories captionPostscript |
	methods := self selections.
	methods size == 1
		ifTrue: 
			[| method |
			method := methods first.
			originalCategory := method categories asSortedCollection first.
			captionPostscript := method selector printString]
		ifFalse: 
			[originalCategory := nil.
			captionPostscript := 'methods'].
	categories := MethodCategory allMethodCategories.
	chosenCategory := (CategoryPrompter
				on: originalCategory
				choices: categories
				caption: 'Categorize ' , captionPostscript) showModal.
	(chosenCategory notNil and: [chosenCategory ~= originalCategory]) ifFalse: [^self].
	self addMethods: methods toCategory: chosenCategory!

clearErrors
	^sourcePresenter clearErrors!

commandPolicy
	^methodsPresenter commandPolicy!

createComponents
	"Create the presenters contained by the receiver"

	super createComponents.
	methodsPresenter := self
				add: (ListPresenter on: (ListModel newWithSearchPolicy: SearchPolicy method))
				name: 'methods'
				helpId: 10742.
	sourcePresenter := self
				add: self developmentSystem methodWorkspaceClass new yourself
				name: 'source'
				helpId: 10490.
	refactoringTool := self developmentSystem newMethodRefactoringToolFor: self!

createSchematicWiring
	"Create the trigger wiring for the receiver"

	super createSchematicWiring.
	self selectableItems
		when: #actionPerformed
			send: #browseIt
			to: self;
		when: #selectionChanged
			send: #onMethodSelected
			to: self;
		when: #selectionChanging:
			send: #onMethodSelectionChanging:
			to: self;
		when: #drag:
			send: #onDrag:
			to: self;
		when: #dragCut:
			send: #onDragCut:
			to: self;
		when: #dragOver:
			send: #onDragOver:
			to: self;
		when: #drop:
			send: #onDropOver:
			to: self.
	self developmentSystem
		when: #methodAdded:
			send: #onMethodAdded:
			to: self;
		when: #methodUpdated:
			send: #onMethodUpdated:
			to: self;
		when: #methodRemoved:
			send: #onMethodRemoved:
			to: self;
		when: #methodCategorized:
			send: #onMethodCategorized:
			to: self!

customDrawMethodClass: anNMLVCUSTOMDRAW
	"Private - Custom drawing to implement the emphasis in a method browser's class column."

	self developmentSystem setClassCustomDrawAttributes: anNMLVCUSTOMDRAW.
	self trigger: #classCustomDrawAttributesRequired: with: anNMLVCUSTOMDRAW!

customDrawSelector: anNMLVCUSTOMDRAW
	"Private - Custom drawing to implement the emphasis in a method browser's selector column."

	| method |
	method := anNMLVCUSTOMDRAW item.
	method isDeprecated ifTrue: [anNMLVCUSTOMDRAW font isStruckThrough: true].
	method isAbstract ifTrue: [anNMLVCUSTOMDRAW font isItalic: true]!

definitionsMenu
	"No commandQuery needed - always enabled, even if no methods selected, as the Messages... command is still available to prompt for a selector"

	<menuPopulator: #buildDefinitionsMenu:>
	!

deleteItCommand
	methodsPresenter hasFocus ifTrue: [^#removeMethod].
	^super deleteItCommand!

developmentSystem
	^SmalltalkSystem current!

enableSource: aBoolean 
	"Private - Enable the source pane of the receiver according to aBoolean."

	sourcePresenter isReadOnly: aBoolean not!

ensureSourceVisible
	"Ensure that the source pane is visible in the receiver"

	sourcePresenter ensureVisible!

errorModel
	"Answer the errorModel used to collect notifications from the Compiler."

	^sourcePresenter errorModel!

errorModel: aValueModel
	"Set the errorModel used to collect notifications from the Compiler."

	sourcePresenter errorModel: aValueModel!

evaluationContext
	^sourcePresenter evaluationContext!

filter
	"Answers the oneArgBlock that sppecifies a filter that determines how methods 
	are selected for display within the receiver. The filter must include any 
	criteria that are implicitly present in the methodsList."

	^filter!

filter: aOneArgBlock
	"Sets the filter that determines how methods are selected for display
	within the receiver. The filter must include any criteria that are
	implicitly present in the original methodsList."

	filter := aOneArgBlock.
!

findDetails
	^sourcePresenter findDetails!

findDetails: aFindDetails 
	sourcePresenter findDetails: aFindDetails!

findNext
	"Hilight the next occurrence of the current search string in the selected method."

	<commandQuery: #queryFindNext:>
	sourcePresenter view findNext!

findNextMatch
	"Hilight the next occurrence of the sourcePresenter's findString in its
	current source."

	sourcePresenter view basicFindNext!

findSelector: aSelector
	"Set the String to search for in the receiver's source to be one that describes aSelector"

	aSelector isNil ifTrue: [^self].
	sourcePresenter findDetails: (MethodSearch newSelector: aSelector) findDetails!

hasEditableMethodSelected
	"Answer true if a single method is selected and it is editable."

	^self selectedMethod ifNil: [false] ifNotNil: [:method | self isEditableMethod: method]!

hasEditableMethodsSelected
	^parentPresenter hasEditableMethodsSelected!

hasFindDetails
	^sourcePresenter hasFindDetails!

hasMethods
	^self model notEmpty!

hasMethodSelected
	"Answer true if the receiver currently has a method selected
	in the methodsPresenter"

	^self hasSingleSelection!

hasMethodsSelected
	"Answer true if the receiver currently has a method selected
	in the methodsPresenter"

	^self hasSelection!

hasOverrideSelected
	"Answer true if the receiver currently has a method selected in the methodsPresenter that is overriding a superclass method."

	^self selectedMethod ifNil: [false] ifNotNil: [:method | method isOverride]!

initialize
	"Private - Initialize the receiver"

	super initialize.
	"Initially the filter excludes all methods, this fixes the bug where a class browser
	without selection was picking up all methods added/modified."
	filter := [:aCompiledMethod | aCompiledMethod isNil].
	namespaceModel := ValueHolder new!

inspectIt
	"Open an inspector on the currently selected method."

	<commandQuery: #hasMethodsSelected>
	| methods |
	methods := self selections.
	(methods size = 1 ifTrue: [methods first] ifFalse: [methods]) inspect!

isEditableMethod: aCompiledMethod 
	^parentPresenter isEditableMethod: aCompiledMethod!

isModified
	^sourcePresenter isModified!

isSourceReadOnly
	^sourcePresenter isReadOnly!

list: aSequenceableCollection
	"MethodBrowser attempts to maintain selection when the list is changed. Perhaps all <listPresenter>s should do this, or at least as an option."

	| selections |
	(aSequenceableCollection isEmpty ifTrue: [self noMethodsView] ifFalse: [methodsPresenter view])
		ensureVisible.
	selections := self selections.
	self noEventsDo: 
			[super list: aSequenceableCollection.
			self selections: selections ifAbsent: []].
	self updateMethodNamespace.
	self selections = selections ifFalse: [self trigger: #selectionChanged].
!

method
	Notification deprecated.
	^self selectedMethod!

method: aCompiledMethodOrNil
	Notification deprecated.
	self selectMethod: aCompiledMethodOrNil!

methodCategorizationPolicy
	"Private - Answer the <MethodCategorizationPolicy> used by the receiver."

	^self developmentSystem methodCategorizationPolicy!

methodPackage
	"Prompt for the user to repackage the selected method(s)."

	<commandQuery: #hasEditableMethodsSelected>
	| methods oldPkg newPkg captionPostscript default |
	methods := self selections.
	methods size = 1
		ifTrue: 
			[captionPostscript := methods first.
			oldPkg := methods first owningPackage.
			default := methods first methodClass owningPackage]
		ifFalse: 
			[| classes packages |
			packages := methods collect: [:each | each owningPackage].
			oldPkg := packages asSet size = 1 ifTrue: [oldPkg := packages first].
			classes := methods collect: [:each | each methodClass].
			default := classes size = 1 ifTrue: [classes first].
			captionPostscript := 'methods'].
	newPkg := PackagePrompter
				showModalOn: oldPkg asValue
				caption: 'Package of <1d>…' << captionPostscript
				default: default.
	"We allow OK even if no change from existing package, so must check for that here"
	(newPkg notNil and: [newPkg ~= oldPkg]) ifFalse: [^self].
	methods do: [:each | Package manager addMethod: each to: newPkg].
	self selectionsByIndex do: [:each | self model refreshAtIndex: each]!

methods: aBrowserEnvironment
	Cursor wait showWhile: 
			[self
				list: aBrowserEnvironment allMethods;
				searchEnvironment: aBrowserEnvironment environment;
				filter: aBrowserEnvironment filter;
				findDetails: aBrowserEnvironment search findDetails]!

methodsPresenter
	^methodsPresenter!

model: aListModel
	"Set the receiver's model to aListModel of CompiledMethods"

	super model: aListModel.
	self selectableItems model: aListModel.
!

modifiedModel
	^sourcePresenter modifiedModel!

modifiedModel: aValueHolder
	sourcePresenter modifiedModel: aValueHolder!

namespaceModel
	^namespaceModel!

noMethodsView
	^view viewNamed: 'noMethodsText' ifNone: [methodsPresenter view]!

onCloseRequested: boolValueHolder
	"A request to close the view onto the receiver as occurred.
	Prompt to save any outstanding changed"

	boolValueHolder value: self promptToSaveChanges!

onDrag: aDragDropSession 
	"A drag has been started. Drag the currently selected methods."

	self developmentSystem beginDrag: aDragDropSession methods: self selections!

onDragCut: aDragDropSession
	"Private - A <DragDropSession> has just completed a successful move operation. The receiver is now
	responsible for deleting the dragged object from itself. Note that many targets will perform
	the cut operation themselves and suppress this (by resetting the drag/drop operation) in
	order to construct a single composite change."

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

onDragOver: session
	"Private - A drag operation described by the <DragDropSession>, session, has 
	moved over the receiver's method list pane. Forward on notification to any observers
	that might be interested."

	self trigger: #dragOver: with: session!

onDropOver: session
	"Private - A drag operation described by the <DragDropSession>, session, has 
	dropped over the receiver's method list pane. Forward on notification to any observers
	that might be interested."

	self trigger: #drop: with: session!

onMethod: oldCompiledMethod updatedTo: newCompiledMethod 
	| wasSelected index |
	index := self model indexOf: oldCompiledMethod.
	index == 0 
		ifTrue: [wasSelected := false]
		ifFalse: 
			[wasSelected := self selectionsByIndex includes: index.
			self model remove: oldCompiledMethod].
	(self filter value: newCompiledMethod) 
		ifTrue: 
			[self model add: newCompiledMethod.
			"Reselect it if an old instance was previously selected BUT NOT if the source presenter
			 is preserving prevously changed text for this method."
			(wasSelected and: [sourcePresenter isModified not]) 
				ifTrue: [self selections: (self selections copyWith: newCompiledMethod) ifAbsent: []]].

	"There may be visible effects (override markers) that need to be updated even when
	the added method is from a different class. Force the method presenter to redraw
	in order to guarantee that these are kept consistent"
	self selectableItems view updateAll!

onMethodAdded: aCompilationResult 
	| method |
	method := aCompilationResult method.
	(self filter value: method) 
		ifTrue: 
			[self model add: method.
			self model size = 1 ifTrue: [methodsPresenter view ensureVisible]].
	"There may be visible effects (override markers) that need to be updated even when
	the added method is from a different class. Force the method presenter to redraw
	in order to guarantee that these are kept consistent"
	self selectableItems view updateAll!

onMethodCategorized: aCompiledMethod
	"Private - The development system has re-categorized aCompiledMethod, update 
	appropriately, depending on whether the method passes the receiver's filter."

	(filter value: aCompiledMethod)
		ifTrue: [self model refresh: aCompiledMethod ifAbsent: [self model add: aCompiledMethod]]
		ifFalse: [self model remove: aCompiledMethod ifAbsent: nil]!

onMethodRemoved: aCompiledMethod
	"Private - The development system has removed aCompiledMethod. Remove this from
	our methods display if it includes it"

	self model remove: aCompiledMethod ifAbsent: nil.
	self model isEmpty ifTrue: [self noMethodsView ensureVisible].
	"There may be visible effects (override markers) that need to be updated even when
	the removed method is from a different class. Force the method presenter to redraw 
	in order to guarantee that these are kept consistent"
	self selectableItems view updateAll!

onMethodSelected
	"Private - The method selected within the receiver has changed. 
	Refresh the source pane"

	| text |
	self promptToCopyChanges.
	text := self selectedMethod
				ifNil: ['']
				ifNotNil: 
					[:method |
					AutoFormat
						ifTrue: [method parseTreeNoError ifNil: [method getSource] ifNotNil: [:tree | tree formattedCode]]
						ifFalse: [method getSource]].
	sourcePresenter
		clearStatus;
		text: text;
		selectionRange: (1 to: 0).
	self updateMethodNamespace.
	self trigger: #methodSelected!

onMethodSelectionChanging: aSelectionChangingEvent 
	"Private - A selection is about to change  within the receiver.
	Prompt to save any outstanding changes"

	sourcePresenter clearParseTree.
	self onPromptToSaveChanges: aSelectionChangingEvent!

onMethodUpdated: aCompilationResult
	"Private - The development system has added aCompiledMethod. Check to see if this should
	be included in the receiver's display of methods by running it through the filter. If it
	shouldn't then remove any existing occurrence of it from the display"

	self onMethod: aCompilationResult oldMethod updatedTo: aCompilationResult method!

onPromptToSaveChanges: aSelectionChangingEvent
	"Private - Check to see if the method source has been changed. 
	If so prompt to see if the changes should be retained and if they should then
	set the value of the parameter to false"

	^sourcePresenter prompt: 'source' toSaveChanges: aSelectionChangingEvent!

onViewAvailable
	super onViewAvailable.
	self applyOptions!

onViewClosed
	"Sent by the receiver's view when it has been closed.
	Disconnect from any events triggered by the devlopment system"

	super onViewClosed.
	self developmentSystem removeEventsTriggeredFor: self!

onViewStateRestored
	super onViewStateRestored.
	self applyOptions!

parseContext
	parentPresenter ifNotNil: [^parentPresenter parseContext].
	^self selectedMethod
		ifNil: [self developmentSystem defaultParseContext]
		ifNotNil: [:method | method parseContext]!

parseTree
	^sourcePresenter parseTree!

promptToCopyChanges
	"Private - If there are any changes, prompt the user as to whether they wish to copy them
	to the clipboard because a class selection change has occurred that is not preventable."

	^self onPromptToSaveChanges: (SelectionChangedEvent forSource: self)!

promptToSaveChanges
	| method |
	method := self selectedMethod.
	^self onPromptToSaveChanges: ((SelectionChangingEvent forSource: self)
				oldSelection: method;
				yourself)!

queryBrowseClass: aCommandQuery
	self selectedMethod
		ifNotNil: 
			[:method |
			aCommandQuery
				beEnabled;
				expandMenuTextWith: method]!

queryBrowseMethodClasses: aCommandQuery
	| methodClasses count class |
	methodClasses := (self selections collect: [:each | each methodClass]) asSet.
	count := methodClasses size.
	count == 0 ifTrue: [^self].
	aCommandQuery beEnabled.
	count == 1 ifFalse: [^self].
	class := methodClasses anyOne.
	aCommandQuery
		text: 'Class <p>' << class;
		image: class icon!

queryBrowseMethodPackages: aCommandQuery
	| packages count |
	packages := (self selections collect: [:each | each owningPackage]) asSet.
	count := packages size.
	count == 0 ifTrue: [^self].
	aCommandQuery
		beEnabled;
		expandMenuTextWith: (count == 1 ifTrue: [packages single name printString] ifFalse: ['Packages'])!

queryBrowseMethodSelector: aCommandQuery
	self selectedMethod
		ifNotNil: 
			[:method |
			aCommandQuery
				beEnabled;
				expandMenuTextWith: method selector]!

queryFindNext: aCommandQuery
	(self hasMethodSelected and: [self hasFindDetails]) ifFalse: [^self].
	aCommandQuery
		beEnabled;
		expandMenuTextWith: self findDetails pattern!

queryRemoveMethods: aCommandQuery
	| methods count |
	self hasEditableMethodsSelected ifFalse: [^self].
	methods := self selectedMethods.
	count := methods size.
	aCommandQuery
		beEnabled;
		expandMenuTextWith: (count = 1 ifTrue: [methods single] ifFalse: ['<d> Methods' << count])!

queryTogglePrivate: aCommandQuery
	| methods private allSame |
	self hasEditableMethodsSelected ifFalse: [^self].
	methods := self selections.
	private := methods first isPrivate.
	allSame := methods allSatisfy: [:each | each isPrivate = private].
	allSame ifFalse: [^self].
	aCommandQuery
		beEnabled;
		isChecked: private!

refactoringTool
	^refactoringTool!

referencesMenu
	"No commandQuery needed - always enabled, even if no methods selected, as the Messages... command is still available to prompt for a selector"

	<menuPopulator: #buildReferencesMenu:>
	!

removeCategoryMenu
	<commandQuery: #hasEditableMethodsSelected>
	<menuPopulator: #buildRemoveCategoryMenu:>
	!

removeMethod
	"Removes the selected method(s) from the system"

	<commandQuery: #queryRemoveMethods:>
	self promptToSaveChanges ifFalse: [^self].
	self developmentSystem removeMethods: self selections!

resetForNewMethod
	"Sets the receiver up for creating a new method"

	"Are there outstanding changes?"

	self promptToSaveChanges ifFalse: [^self].
	self selectMethod: nil.
	"#833: If there was previously no method selection (i.e. no selection change event occurred when the selection
	was reset), then we will need to clear down the source presenter, so do that regardless"
	sourcePresenter
		text: String new;
		setFocus!

saveMethod: aString in: aClass environment: aNamespace categories: aCollection package: aPackageOrNil
	| modified originalSelection change newMethod |
	originalSelection := sourcePresenter selectionRange.
	modified := sourcePresenter isModified.
	sourcePresenter
		clearErrors;
		isModified: false.
	
	[change := self developmentSystem
				compile: aString
				in: aClass
				environment: aNamespace
				categories: aCollection
				package: aPackageOrNil
				extraFlags: Interactive]
			on: Compiler notificationClass
			do: [:cn | sourcePresenter compilerNotification: cn offset: 0].
	newMethod := change ifNotNil: [change method].
	newMethod
		ifNil: 
			["If the compilation fails we must restore the modified flag"
			sourcePresenter isModified: modified]
		ifNotNil: [self selectionOrNil == newMethod ifFalse: [self selection: newMethod ifAbsent: []]].
	(sourcePresenter showFirstError: 0)
		ifFalse: [sourcePresenter view selectionRange: originalSelection].
	^newMethod!

saveNewMethod: aString
	| editedMethod selector |
	editedMethod := self selectedMethod.
	selector := self parseTree selector.
	(editedMethod notNil and: [selector == editedMethod selector])
		ifFalse: 
			["Saving a method other than that which was being edited."
			self parseContext
				ifNotNil: 
					[:context |
					| methodClass |
					methodClass := context methodClass.
					(methodClass includesSelector: selector)
						ifTrue: 
							[(MessageBox new
								headline: 'Overwrite existing method?';
								confirm: '<1p> already defines <2p><n><n>Are you sure you would like to overwrite it?'
											<< {methodClass. selector})
									ifFalse: [^nil]]]].
	parentPresenter saveNewMethod: aString!

searchEnvironment
	^searchEnvironment ifNil: [parentPresenter browserEnvironment]!

searchEnvironment: aBrowserEnvironment 
	"Set the <BrowserEnvironment> used as the context for searches such as those for references to a selector..
	By default this will be 'Smalltalk', which includes the whole system, so all searches will be global."

	searchEnvironment := aBrowserEnvironment.
	sourcePresenter searchEnvironment: aBrowserEnvironment
	!

selectableItems
	"Private - Answer the name of the <selectableItems> component that actually handles the selectable items in the receiver"

	^methodsPresenter!

selectedMethod
	"Answer the currently selected method, or nil if there is not exactly one selected."

	^self selectionOrNil!

selectedMethods
	"Answer the currently selected methods, or any empty collection if none are selected."

	^self selections!

selectedNode
	"Private - Answer an <StProgramNode> to represent the syntactic element which is currently
	selected, or which the caret is over in the source pane."

	^sourcePresenter selectedNode!

selectedWord
	^sourcePresenter selectedWord!

selection: aCompiledMethod ifAbsent: exceptionHandler
	"Set the currently selected method to aCompiledMethod"

	aCompiledMethod isNil 
		ifTrue: [self resetSelection]
		ifFalse: [super selection: aCompiledMethod ifAbsent: exceptionHandler]!

selectionEnvironment
	^parentPresenter selectionEnvironment!

selectMethod: aCompiledMethodOrNil 
	"Set the currently selected method to aCompiledMethodOrNil"

	self selectionOrNil: aCompiledMethodOrNil!

setInitialFocus
	self sourcePresenter setFocus!

sortBlock
	^self selectableItems sortBlock!

sortBlock: anObject
	self selectableItems sortBlock: anObject
!

source
	"Answer the source for the currently selected method as a String"

	^sourcePresenter source!

sourcePresenter
	^sourcePresenter!

sourcePresenter: anObject
	sourcePresenter := anObject!

sourceSelection
	"Answer the current selection of the selected methods source."

	^sourcePresenter view selection!

togglePrivate
	"Toggle the selected method between public and private status."

	<commandQuery: #queryTogglePrivate:>
	| methods |
	methods := self selections.
	methods do: 
			[:method | 
			method isPrivate 
				ifTrue: [self developmentSystem publicizeMethod: method]
				ifFalse: [self developmentSystem privatizeMethod: method]]!

updateMethodNamespace
	namespaceModel value: (self parseContext ifNotNil: [:context | context environment])! !

!Tools.MethodBrowser categoriesForMethods!
addCategoryMenu!commands-menus!public! !
addMethods:toCategory:!operations!private! !
addToCommandRoute:!commands-routing!public! !
applyOptions!operations!options!public! !
browseCompilationFailures!browsing!commands-actions!public! !
browseCompilationIssues!browsing!commands-actions!public! !
browseContainingText!browsing!commands-actions!public! !
browseDefinitions!browsing!commands-actions!public! !
browseDefinitionsMatching:in:!browsing!private! !
browseDefinitionsOfSelector:in:!browsing!private! !
browseHierarchy!browsing!commands-actions!public! !
browseItCommand!browsing!commands-mappings!helpers!private! !
browseMessage!commands-actions!public! !
browseMessageDefinitions!commands-actions!public! !
browseMessageDefinitionsIn:!browsing!commands-actions!private! !
browseMessageReferences!commands-actions!public! !
browseMessageReferences:in:!browsing!private! !
browseMessagesIn:!browsing!private! !
browseMessagesMatching:in:!browsing!private! !
browseMethodClasses!browsing!commands-actions!public! !
browseMethodInheritanceChain!browsing!commands-actions!public! !
browseMethodPackages!browsing!commands-actions!public! !
browseMethodsIn:!browsing!private! !
browseMethodsMatching:in:!browsing!private! !
browseOther!commands-menus!public! !
browsePackages!browsing!commands-actions!public! !
browseReferences!browsing!commands-actions!public! !
browseReferencesMatching:in:!browsing!private! !
browseReferencesToGlobal!browsing!commands-actions!public! !
browseReferencesToLiteral:in:!browsing!private! !
browserEnvironment!accessing!public! !
browseSystem!browsing!commands-actions!public! !
browseVariableReferences:in:!browsing!private! !
buildAddCategoryMenu:!commands-menus!private! !
buildDefinitionsMenu:!private! !
buildParseTree!helpers!private! !
buildReferencesMenu:!private! !
buildRemoveCategoryMenu:!commands-menus!private! !
canSaveMethod!helpers!private!testing! !
categorizeMethods!commands-actions!public! !
clearErrors!operations!public! !
commandPolicy!accessing!public! !
createComponents!initializing!public! !
createSchematicWiring!initializing!public! !
customDrawMethodClass:!helpers!private! !
customDrawSelector:!helpers!private! !
definitionsMenu!commands-menus!public! !
deleteItCommand!commands-mappings!private! !
developmentSystem!accessing!private! !
enableSource:!modes!private! !
ensureSourceVisible!operations!public! !
errorModel!accessing!public! !
errorModel:!accessing!public! !
evaluationContext!accessing!private! !
filter!accessing!public! !
filter:!accessing!public! !
findDetails!accessing!public! !
findDetails:!accessing!public! !
findNext!commands-actions!public!searching & replacing! !
findNextMatch!commands-actions!public!searching! !
findSelector:!public!searching! !
hasEditableMethodSelected!commands-queries!public!testing! !
hasEditableMethodsSelected!commands-queries!public!testing! !
hasFindDetails!public!testing! !
hasMethods!public!testing! !
hasMethodSelected!commands-queries!public!testing! !
hasMethodsSelected!commands-queries!public!testing! !
hasOverrideSelected!commands-queries!public!testing! !
initialize!initializing!private! !
inspectIt!commands-actions!public! !
isEditableMethod:!public!testing! !
isModified!public!testing! !
isSourceReadOnly!private!testing! !
list:!accessing!public! !
method!accessing!public! !
method:!accessing!public! !
methodCategorizationPolicy!constants!private! !
methodPackage!commands-actions!public! !
methods:!accessing!public! !
methodsPresenter!accessing!private! !
model:!accessing!public! !
modifiedModel!accessing!public! !
modifiedModel:!accessing!public! !
namespaceModel!accessing!public! !
noMethodsView!accessing!private! !
onCloseRequested:!event handling!public! !
onDrag:!event handling!public! !
onDragCut:!event handling!private! !
onDragOver:!event handling!private! !
onDropOver:!event handling!private! !
onMethod:updatedTo:!event handling!private! !
onMethodAdded:!event handling!private! !
onMethodCategorized:!event handling!private! !
onMethodRemoved:!event handling!private! !
onMethodSelected!event handling!private! !
onMethodSelectionChanging:!event handling!private! !
onMethodUpdated:!event handling!private! !
onPromptToSaveChanges:!private!testing! !
onViewAvailable!event handling!public! !
onViewClosed!event handling!public! !
onViewStateRestored!event handling!public! !
parseContext!accessing!public! !
parseTree!helpers!private! !
promptToCopyChanges!event handling!public! !
promptToSaveChanges!helpers!private! !
queryBrowseClass:!browsing!commands-queries!private! !
queryBrowseMethodClasses:!commands-queries!private! !
queryBrowseMethodPackages:!commands-queries!private! !
queryBrowseMethodSelector:!browsing!commands-queries!private! !
queryFindNext:!commands-queries!private! !
queryRemoveMethods:!browsing!commands-queries!private! !
queryTogglePrivate:!commands-queries!private! !
refactoringTool!accessing!public! !
referencesMenu!commands-menus!public! !
removeCategoryMenu!commands-menus!public! !
removeMethod!commands-actions!public! !
resetForNewMethod!commands-actions!public! !
saveMethod:in:environment:categories:package:!operations!private! !
saveNewMethod:!helpers!public! !
searchEnvironment!accessing!public! !
searchEnvironment:!accessing!public! !
selectableItems!accessing!private! !
selectedMethod!accessing!public! !
selectedMethods!accessing!public! !
selectedNode!accessing!private! !
selectedWord!accessing!public! !
selection:ifAbsent:!accessing!public! !
selectionEnvironment!accessing!public! !
selectMethod:!operations!public! !
setInitialFocus!operations!public! !
sortBlock!accessing!private! !
sortBlock:!accessing!private! !
source!accessing!public! !
sourcePresenter!accessing!private! !
sourcePresenter:!accessing!private! !
sourceSelection!accessing!public! !
togglePrivate!commands-actions!public! !
updateMethodNamespace!event handling!private! !
!

!Tools.MethodBrowser class methodsFor!

autoFormat
	^AutoFormat!

autoFormat: aBoolean
	AutoFormat := aBoolean!

defaultModel
	"Answer a default model to be assigned to the receiver when it
	is initialized."

	^ListModel newWithSearchPolicy: SearchPolicy method!

getAdditionalKeyBindings
	^AdditionalAccelerators!

hasInfoTips
	^InfoTips!

hasInfoTips: aBoolean
	InfoTips := aBoolean!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

initialize
	"Private - Initialize the receiver's class variables.
		self initialize
	"

	self wordWrap: true.
	self autoFormat: false!

publishedAspects
	"Answer a <LookupTable> of the <Aspect>s published by the receiver."

	^super publishedAspects
		add: (Aspect dictionary: #acceleratorKeyBindings) beImmutable;
		add: (Aspect nullableBoolean: #hasInfoTips);
		yourself!

publishedEventsOfInstances
	"Answer a Set of Symbols that describe the published events triggered
	by instances of the receiver."

	^(super publishedEventsOfInstances)
		add: #methodSelected;
		add: #dragOver:;
		add: #drop:;
		yourself!

resource_Class_browser_method_list
	"Answer the literal data from which the 'Class browser method list' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Class_browser_method_list)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ListView} 38 #{Core.Array} 45 nil nil 50 2 8 1409355849 1 32 838 2 #{UI.ListModel} 550 #{Core.OrderedCollection} 0 nil 6 #{Kernel.IdentitySearchPolicy} 6 #{Graphics.Color} #default nil 29 2886 4 #{UI.Menu} nil true 50 15 242 nil true 8 #() 8 '&Definitions of' #definitionsMenu 1 nil nil nil nil nil 242 nil true 8 #() 8 'Re&ferences to' #referencesMenu 1 nil nil nil nil nil 242 nil true 50 13 1094 2 #{UI.CommandMenuItem} 1 1350 4 #{UI.CommandDescription} #browseReferencesToGlobal 8 'References to Global…' 1 1 nil nil nil 418 1 450 #browseContainingText 8 'C&ontaining Text…' 1 1 838 4 #{Graphics.Icon} nil true 1030 #{Graphics.ImageFromStringResourceInitializer} 8 'SearchText.ico' 838 1 #{External.ResourceLibrary} 8 'dolphindr8.dll' 65541 nil nil nil 418 1 450 #browseMethodCategory 8 'Cate&gory…' 1 1 546 nil true 578 8 'Category.ico' 640 65541 nil nil nil 418 1 450 #browseCompilationFailures 8 'Compilation &Failures' 1 1 nil nil nil 326 1 #{UI.DividerMenuItem} 4097 418 1 450 #browseMethodPackages 8 'Package <s>' 1 1 546 nil true 578 8 'Package.ico' 640 65541 nil nil nil 418 1 450 #browseMethodClasses 8 'Method Classes' 1 1 nil nil nil 818 4097 418 1 450 #browseMethodHistory 8 '&Change History' 1 1 546 nil true 578 8 'MethodHistory.ico' 640 65541 nil nil nil 418 1 450 #browseAllChangedMethods 8 '&All Changed Methods' 1 1 nil nil nil 818 4097 418 1 450 #browseMethodInheritanceChain 8 '&Inheritance Chain' 1 1 nil nil nil 418 1 450 #browseOverriddenMethod 8 'Goto &Superclass Definition' 1 1 nil nil nil 8 '&Browse other' nil 134217729 nil nil nil nil nil 818 4097 418 1 450 #newMethod 8 '&New <s:Method>' 1 17 546 nil true 578 8 'NewMethod.ico' 640 65541 nil nil nil 418 1 450 #removeMethod 8 'Re&move' 1 1 546 nil true 578 8 'MethodDelete.ico' 640 65541 nil nil nil 242 nil true 50 16 418 1 450 #renameMethod 8 'Re&name' 1 1 546 nil true 578 8 'Rename.ico' 640 65541 nil nil nil 418 1 450 #renameMethodReferences 8 'Rename Re&ferences…' 1 1 nil nil nil 818 4097 418 1 450 #addParameter 8 'Add &Parameter…' 1 1 nil nil nil 242 nil true 8 #() 8 'Remo&ve Parameter' #removeParameterMenu 134217729 nil nil nil nil nil 242 nil true 8 #() 8 'Rena&me Parameter' #renameParameterMenu 134217729 nil nil nil nil nil 242 nil true 8 #() 8 '&Inline Parameter' #inlineParameterMenu 134217729 nil nil nil nil nil 818 4097 242 nil true 8 #() 8 'Rename &Temporary' #renameTempMenu 134217729 nil nil nil nil nil 242 nil true 8 #() 8 'Convert Temp to Inst. Var.' #convertTempToInstVarMenu 134217729 nil nil nil nil nil 818 4097 418 1 450 #inlineAllSelfSends 8 'Inline &Self Sends' 1 1 nil nil nil 418 1 450 #pushUpMethods 8 'Push &Up' 9325 1 nil nil nil 418 1 450 #pushDownMethods 8 'Push &Down' 9327 1 nil nil nil 418 1 450 #overrideMethods 8 'Ove&rride <d:Methods>' 1 17 nil nil nil 418 1 450 #moveMethod 8 'Move to &Component…' 1 1 nil nil nil 8 '&Refactorings' #methodRefactoringsMenu 134217729 546 nil true 578 8 'Refactoring.ico' 640 65541 nil nil nil nil nil 818 4097 418 1 450 #methodPackage 8 '&Package…' 1 1 546 nil true 578 8 'Package.ico' 640 65541 nil nil nil 242 nil true 8 #() 8 'Add to &Category' #addCategoryMenu 134217729 nil nil nil nil nil 242 nil true 8 #() 8 'Remo&ve from Category' #removeCategoryMenu 134217729 nil nil nil nil nil 418 1 450 #togglePrivate 8 'Priva&te' 1 1 nil nil nil 818 4097 418 1 450 #toggleFilterObjectMethods 8 'Filter &Object Methods' 1 1 nil nil nil 418 1 450 #toggleShowInheritedMethods 8 'Show &Inherited Methods' 1 1 nil nil nil 8 '&Method' #methodMenu 134217729 nil nil nil nil nil nil nil 32 nil nil 518 #{Core.Message} #selector 8 #() 2690 #iconImageIndex 8 #() 1350 1 #{Graphics.IconImageManager} nil 2690 #infoTip 8 #() 1382 3 #{Kernel.BlockClosure} 0 nil 1318 #{Kernel.CompiledExpression} 4 1 2832 8 'doIt' 8 '[:ctx | ctx view parentPresenter parentPresenter customDrawSelector: ctx]' 8 #[32 105 226 0 159 159 17 178 106] #view #parentPresenter #customDrawSelector: 2848 7 257 nil nil nil nil 146 3 3142 5 #{UI.ListViewColumn} 8 'Methods' 431 #left 2690 #displayString 2752 2690 #<= 8 #() 2690 #selector 8 #() nil 32 nil 3 nil 2848 2962 8 '' 33 #center 774 #{Core.MessageSend} #empty 8 #() #{Core.Utf16String} 2834 0 nil 2866 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:m1 :m2 | 
m1 isOverride = m2 isOverride 
	ifTrue: [m1 selector <= m2 selector]
	ifFalse: [m1 isOverride]]' 8 #[31 105 17 158 18 158 132 123 17 159 18 159 130 106 17 158 106] #isOverride #selector 3168 7 513 nil nil nil 32 2834 0 nil 2866 8 1 2832 8 'doIt' 8 '[:each | 
(each isOverride ifTrue: [CompiledMethod overriddenIcon] ifFalse: [UI.Icon blank]) 
	imageIndex]' 8 #[35 105 226 0 120 46 160 111 48 162 163 106] #isOverride 1094 2 #{Kernel.VariableBinding} #CompiledMethod #{Kernel.CompiledMethod} #{Kernel} 1 #overriddenIcon 3330 #Icon 544 #{Graphics} 1 #blank #imageIndex 3248 #ifTrue:ifFalse: 7 257 nil 1 nil nil 2962 8 '' 33 #center nil 2834 0 nil 2866 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:m1 :m2 | m1 isPublic = m2 isPublic ifTrue: [m1 selector <= m2 selector] ifFalse: [m1 isPublic]]' 8 #[31 105 17 158 18 158 132 123 17 159 18 159 130 106 17 158 106] #isPublic #selector 3408 7 513 nil nil nil 32 2736 1 nil nil #report 8 #() nil 133221 nil 1 nil nil nil nil 1 262 #{UI.ListViewVirtualUpdateMode} 32 nil nil nil nil nil nil nil nil nil 262 #{Core.MessageSequence} 50 3 3122 #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[255 14 0 0 10 0 0 0 250 15 0 0 126 0 0 0] 193 80 8 'Methods' 32 3122 #contextMenu: 50 1 256 32 3122 #columnOrder: 50 1 8 #(2 3 1) 32 1 8 #() 518 #{Graphics.Point} 193 193 nil 35)!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ContainerView} 38 #{Core.Array} 15 nil nil 50 2 8 1409286144 131073 32 nil nil nil 5 nil nil nil 32 518 #{UI.ProportionalLayout} 518 #{Kernel.STBCollectionProxy} #{Core.Dictionary} 50 1 518 #{Core.Association} 18 #{UI.Splitter} 50 12 nil 32 50 2 8 1140850688 1 224 nil nil nil 517 nil nil nil 3142 1 #{UI.DraggableViewInteractor} 224 nil 1 #left nil nil nil 518 #{Graphics.Point} 1 1 322 9 9 nil 336 nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[0 0 0 0 175 0 0 0 123 2 0 0 180 0 0 0] 193 256 8 '' 224 3 8 #() 322 193 193 nil 27 1 true 518 #{Kernel.STBIdentityDictionaryProxy} #{Core.IdentityDictionary} 50 4 18 #{UI.ReferenceView} 50 14 nil 32 50 2 8 1140850688 131073 640 nil nil nil 5 nil nil nil 640 582 1 #{UI.ResourceIdentifier} #{Tools.MethodBrowser} #resource_Method_browser_method_list nil 370 50 1 418 #createWindow: 50 1 466 498 8 #[0 0 0 0 0 0 0 0 123 2 0 0 175 0 0 0] 193 672 8 '' 640 3 8 #() 322 193 193 nil 27 8 'methodsList' 18 #{UI.ReferenceView} 50 14 nil 32 50 2 8 1140916224 131073 912 nil nil nil 5 nil nil nil 912 706 #{Tools.MethodWorkspace} #resource_Default_view nil 370 50 1 418 #createWindow: 50 1 466 498 8 #[0 0 0 0 180 0 0 0 123 2 0 0 99 1 0 0] 193 944 8 '' 912 3 864 322 193 193 nil 27 8 'source' nil 370 50 1 418 #createWindow: 50 1 466 498 8 #[255 14 0 0 10 0 0 0 122 17 0 0 109 1 0 0] 193 80 8 '' 32 1 50 3 640 224 912 322 193 193 nil 27)!

resource_Method_browser_method_list
	"Answer the literal data from which the 'Method browser method list' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Method_browser_method_list)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.WizardCardContainer} 38 #{Core.Array} 15 nil nil 50 2 8 1409286144 131073 32 nil nil nil 5 2886 4 #{UI.Menu} nil true 50 11 114 nil true 8 #() 8 '&Definitions of' #definitionsMenu 1 nil nil nil nil nil 114 nil true 8 #() 8 'Re&ferences to' #referencesMenu 1 nil nil nil nil nil 114 nil true 50 10 1094 2 #{UI.CommandMenuItem} 1 1350 4 #{UI.CommandDescription} #browseReferencesToGlobal 8 'R&eferences to Global…' 1 1 nil nil nil 290 1 322 #browseContainingText 8 'C&ontaining Text…' 1 1 838 4 #{Graphics.Icon} nil true 1030 #{Graphics.ImageFromStringResourceInitializer} 8 'SearchText.ico' 838 1 #{External.ResourceLibrary} 8 'dolphindr8.dll' 65541 nil nil nil 290 1 322 #browseMethodCategory 8 'Cate&gory…' 1 1 nil nil nil 290 1 322 #browseCompilationFailures 8 'Compilation &Failures' 1 1 nil nil nil 326 1 #{UI.DividerMenuItem} 4097 290 1 322 #browseMethodPackages 8 '&Package <s>' 1 17 418 nil true 450 8 'PackageBrowserShell.ico' 512 65541 nil nil nil 290 1 322 #browseMethodClasses 8 'Method Classes' 1 1 418 nil true 450 8 'ClassBrowserShell.ico' 512 65541 nil nil nil 642 4097 290 1 322 #browseMethodHistory 8 'Change &History' 1 1 418 nil true 450 8 'MethodHistory.ico' 512 65541 nil nil nil 290 1 322 #browseAllChangedMethods 8 '&All Changed Methods' 1 1 nil nil nil 8 '&Browse other' #browseOther 134217729 nil nil nil nil nil 642 4097 290 1 322 #removeMethod 8 'Re&move' 1 1 418 nil true 450 8 'MethodDelete.ico' 512 65541 nil nil nil 114 nil true 50 16 290 1 322 #renameMethod 8 'Re&name' 1 1 nil nil nil 290 1 322 #renameMethodReferences 8 'Rename Re&ferences…' 1 1 nil nil nil 642 4097 290 1 322 #addParameter 8 'Add &Parameter…' 1 1 nil nil nil 114 nil true 8 #() 8 'Remo&ve Parameter' #removeParameterMenu 134217729 nil nil nil nil nil 114 nil true 8 #() 8 'Rena&me Parameter' #renameParameterMenu 134217729 nil nil nil nil nil 114 nil true 8 #() 8 '&Inline Parameter' #inlineParameterMenu 134217729 nil nil nil nil nil 642 4097 114 nil true 8 #() 8 'Rename &Temporary' #renameTempMenu 134217729 nil nil nil nil nil 114 nil true 8 #() 8 'Conv&ert Temp to Inst. Var.' #convertTempToInstVarMenu 134217729 nil nil nil nil nil 642 4097 290 1 322 #inlineAllSelfSends 8 'Inline &Self Sends' 1 1 nil nil nil 290 1 322 #pushUpMethods 8 'Push &Up' 9325 1 nil nil nil 290 1 322 #pushDownMethods 8 'Push &Down' 9327 1 nil nil nil 290 1 322 #overrideMethods 8 'Ove&rride <d:Methods>' 1 17 nil nil nil 290 1 322 #moveMethod 8 'Move to &Component…' 1 1 nil nil nil 8 '&Refactorings' #methodRefactoringsMenu 134217729 418 nil true 450 8 'Refactoring.ico' 512 65541 nil nil nil nil nil 642 4097 290 1 322 #methodPackage 8 '&Package…' 1 1 418 nil true 450 8 'Package.ico' 512 65541 nil nil nil 114 nil true 8 #() 8 'Add to &Category' #addCategoryMenu 134217729 nil nil nil nil nil 114 nil true 8 #() 8 'Remo&ve from Category' #removeCategoryMenu 134217729 nil nil nil nil nil 290 1 322 #togglePrivate 8 'Priva&te' 1 1 nil nil nil 8 '&Method' nil 134217729 nil nil nil nil nil nil nil 32 1350 1 #{UI.CardLayout} 550 #{Core.OrderedCollection} 2 518 #{Core.Association} 3 18 #{UI.ListView} 50 45 nil 32 50 2 8 1140920393 1 2288 838 2 #{UI.ListModel} 2226 0 nil 6 #{Kernel.IdentitySearchPolicy} 6 #{Graphics.Color} #default nil 13 nil nil nil 2288 nil nil 518 #{Core.Message} #displayString 8 #() 2466 #iconImageIndex 8 #() 1350 1 #{Graphics.IconImageManager} nil nil nil nil nil nil 2226 5 3142 5 #{UI.ListViewColumn} 8 'Selector' 335 #left 2466 #selector 8 #() 1382 3 #{Kernel.BlockClosure} 0 nil 1318 #{Kernel.CompiledExpression} 2 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a :b | a selector <= b selector]' 8 #[30 105 226 0 226 32 130 106] #selector 2688 7 513 nil nil nil 2288 nil 1 2466 #infoTip 8 #() 2674 0 nil 2706 4 1 2672 8 'doIt' 8 '[:ctx | ctx view parentPresenter customDrawSelector: ctx]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #customDrawSelector: 2816 7 257 nil 2594 8 'Class' 333 #left 2466 #name 8 #() 2466 #<= 8 #() 2466 #methodClass 8 #() nil 2288 2512 1 nil 2674 0 nil 2706 4 1 2672 8 'doIt' 8 '[:ctx | ctx view parentPresenter customDrawMethodClass: ctx]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #customDrawMethodClass: 3024 7 257 nil 2594 8 'Namespace' 301 #left 2466 #fullName 8 #() 2674 0 nil 2706 2 1 2672 8 'doIt' 8 '[:a :b | a fullName <= b fullName ]' 8 #[30 105 226 0 226 32 130 106] #fullName 3168 7 513 nil 2466 #environment 8 #() nil 2288 nil 1 nil nil 2594 8 'Package' 65 #left 2466 #name 8 #() 2674 0 nil 2706 2 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a :b | a name <= b name]' 8 #[30 105 226 0 226 32 130 106] #name 3344 7 513 nil 2466 #owningPackage 8 #() nil 2288 2512 3 nil nil 2594 8 '' 33 #center nil 2674 0 nil 2706 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:m1 :m2 | m1 isPublic = m2 isPublic ifTrue: [m1 selector <= m2 selector] ifFalse: [m1 isPublic]]' 8 #[31 105 17 158 18 158 132 123 17 159 18 159 130 106 17 158 106] #isPublic #selector 3488 7 513 nil nil nil 2288 2512 1 nil nil #report 8 #() nil 133221 nil 1 nil nil nil nil 1 262 #{UI.ListViewVirtualUpdateMode} 2288 nil nil nil nil nil nil nil nil nil 262 #{Core.MessageSequence} 50 2 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[0 0 0 0 0 0 0 0 229 1 0 0 210 0 0 0] 193 2320 8 'Selector' 2288 3666 #columnOrder: 50 1 8 #(5 1 2 3 4) 2288 3 8 #() 518 #{Graphics.Point} 193 193 nil 35 2258 5 18 #{UI.StaticText} 50 16 nil 32 50 2 8 1140850945 1 3920 nil 2434 #window nil 5 nil nil nil 3920 nil nil 518 #{UI.NullConverter} nil nil nil 3618 50 3 3666 #createWindow: 50 1 3714 3746 8 #[0 0 0 0 0 0 0 0 229 1 0 0 210 0 0 0] 193 3952 nil 3920 3666 #isEnabled: 8 #(false) 3920 3666 #text: 50 1 8 '
There are no methods to browse' 3920 1 8 #() 3874 193 193 nil 27 2288 nil nil nil 518 #{Kernel.STBIdentityDictionaryProxy} #{Core.IdentityDictionary} 50 4 2288 8 'methods' 3920 8 'noMethodsText' nil 3618 50 2 3666 #createWindow: 50 1 3714 3746 8 #[255 14 0 0 10 0 0 0 228 16 0 0 220 0 0 0] 193 80 8 '' 32 3666 #contextMenu: 50 1 128 32 1 50 2 2288 3920 3874 193 193 nil 27)!

setAdditionalKeyBindings: anArray
	AdditionalAccelerators := anArray!

wordWrap
	"Answer true if instances of the receiver use word wrapping by default."

	^WordWrap!

wordWrap: aBoolean
	"Sets the word wrapping state for instances of the receiver to aBoolean."

	WordWrap := aBoolean! !

!Tools.MethodBrowser class categoriesForMethods!
autoFormat!accessing!public! !
autoFormat:!accessing!public! !
defaultModel!models!public! !
getAdditionalKeyBindings!accessing!private! !
hasInfoTips!accessing!options!public! !
hasInfoTips:!accessing!options!public! !
icon!constants!public! !
initialize!initializing!private! !
publishedAspects!public! !
publishedEventsOfInstances!events!public! !
resource_Class_browser_method_list!public!resources-views! !
resource_Default_view!public!resources-views! !
resource_Method_browser_method_list!public!resources-views! !
setAdditionalKeyBindings:!accessing!private! !
wordWrap!accessing!options!public! !
wordWrap:!accessing!options!public! !
!

