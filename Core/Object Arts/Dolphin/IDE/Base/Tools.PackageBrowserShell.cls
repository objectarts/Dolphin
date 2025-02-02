"Filed out from Dolphin Smalltalk"!

Tools.SmalltalkToolShell
	subclass: #'Tools.PackageBrowserShell'
	instanceVariableNames: 'packagesPresenter classesPresenter methodsPresenter methodRefactoringTool variablesPresenter resourcesPresenter currentCard commentPresenter cardsPresenter updateFlags scriptTextPresenter scriptNamesPresenter prerequisitesPresenter dependentsPresenter statusModel'
	classVariableNames: 'WordWrapComment'
	imports: #(#{OS.Win32Constants})
	classInstanceVariableNames: ''
	classConstants: {}!

Tools.PackageBrowserShell guid: (Core.GUID fromString: '{87b4c6c0-026e-11d3-9fd7-00a0cc3e4a32}')!

Tools.PackageBrowserShell comment: 'PackageBrowserShell is a <SmalltalkToolShell> that implements the Package Browser tool. This provides a user interface onto all the <Package>s held by the current <PackageManager>. 

Instance Variables:
	packagesPresenter		<ListPresenter> holding the list of currently loaded packages.
	classesPresenter		<ListPresenter> displaying the list of classes in the selected package.
	methodsPresenter		<ListPresenter> displaying the list of explicit methods in the selected package.
	globalsPresenter		<ListPresenter> displaying the list of globals in the selected package.
	resourcesPresenter		<ResourceListPresenter> displaying the list of resources in the selected package.
	scriptsPresenter		<ListPresenter> displaying a list of scripts for the selector package.
	sourceMode		<Symbol> indicating the current source mode, #class, #method, #global, #resource, #script.
	sourcePresenter		<SmalltalkWorkspace> displaying the source for the currently selected package object.
	commentPresenter		<SmalltalkWorkspace> displaying the package comment.
	inspectorPresenter		<PublishedAspectInspector> inspecting the selected package.
	cardPresenter		<CardContainer>. Package content cards.
	updatedFlags		<integer>. Flags indicating which of the source panes have been updated.
	namePresenter		<TextPresenter> displaying package name.
	pathPresenter		<TextPresenter> displaying package path.

Class Variables:
	OperationAborted 		<Signal> raised when a long running operation (e.g install/uninstall) is aborted by the user.
	UpdateMap 
	WordWrapComment		<boolean> indicating that the comment pane should word wrap.
'!

!Tools.PackageBrowserShell categoriesForClass!MVP-Presenters! !

!Tools.PackageBrowserShell methodsFor!

acceptItCommand
	"Private - Answer the <Symbol> of the contextual command to save changes, depending on the subview with focus."

	currentCard == #comment ifTrue: [^#saveComment].
	currentCard == #scripts ifTrue: [^#saveScript].
	^nil!

addToCommandRoute: route 
	"Update the <OrderedCollection>, path, with the receiver's contribution to the command path
	held by the <CommandPolicy>, route. Answer self to have the command policy decide where to
	go next."

	"Implementation Note: We want to make sure that the packages presenter is always in the
	route, and that it appears before SmalltalkSystem but after the receiver (if not already in
	the route)."

	methodRefactoringTool notNil ifTrue: [route appendTarget: methodRefactoringTool].
	route
		appendTarget: self;
		appendTarget: packagesPresenter;
		appendPresenter: self!

applyOptions
	"Private - Apply the class options to the receiver"

	super applyOptions.
	commentPresenter view wordWrap: self class wordWrapComment.!

browseClass
	"Open a new class browser on the selected class(es). If a single class is selected, then the
	default class browser is opened with initial selection set to that class. If more than one
	class is selected then an <EnvironmentBrowserShell> is opened and configured to display
	those classes."

	<commandQuery: #hasClassesSelected>
	| classes |
	classes := self selectedClasses.
	^classes size = 1
		ifTrue: [classes anyOne browse]
		ifFalse: [(self model browserEnvironment forClassesAndTheirMetaclasses: classes) browse]!

browseClassReferences
	"Browse all the methods in the entire system which refer to the class selected in the
	receiver."

	<commandQuery: #hasClassesSelected>
	self browseClassReferencesIn: self browserEnvironment!

browseClassReferencesIn: aBrowserEnvironment
	| class environments |
	class := self selectedClasses.
	environments := Array writeStream.
	class do: 
			[:each |
			environments
				nextPut: (aBrowserEnvironment referencesToVariable: each binding);
				nextPut: (aBrowserEnvironment referencesToClass: each)].
	self browseMethodsInEnvironments: environments contents!

browseDefinitionsCommand
	currentCard == #methods ifTrue: [^#browseMessageDefinitions].
	^nil!

browseHierarchyCommand
	^##(IdentityDictionary withAll: {
				#methods -> #browseHierarchyOfMethod.
				#classes -> #browseHierarchyOfClass.
				#variables -> #browseHierarchyOfVariable
			})
		lookup: currentCard!

browseHierarchyOfClass
	<commandQuery: #queryBrowseHierarchyOfClass:>
	self developmentSystem browseHierarchy: self selectedClass!

browseHierarchyOfMethod
	<commandQuery: #hasMethodSelected>
	self developmentSystem browseClassHierarchyOfMethod: self selectedMethod!

browseHierarchyOfVariable
	<commandQuery: #hasLiveVariableSelected>
	| var |
	var := self sharedVariable binding.
	self developmentSystem
		browseHierarchy: (var isClassBinding ifTrue: [var value] ifFalse: [var environment])!

browseItCommand
	"Private - Answer the command that the context-sensitive 'Browse-It' command would be linked
	to if sent to the receiver at this moment."

	| focus |
	focus := View focus.
	focus == packagesPresenter packagesPresenter view ifTrue: [^#browsePackageSources].
	focus == classesPresenter view ifTrue: [^#browseClass].
	focus == methodsPresenter view ifTrue: [^#browseMethods].
	focus == variablesPresenter view ifTrue: [^#browseVariableClass].
	^nil!

browseLocalClassReferences
	"Browse all the methods in the currently selected set of packages system which refer to the
	class selected in the receiver."

	self browseClassReferencesIn: self searchEnvironment!

browseLocalMessageDefinitions
	"Open a method browser displaying all implementors of the current selector in the currently
	selected packages."

	<commandQuery: #hasPackages>
	self browseMessageDefinitionsIn: self searchEnvironment!

browseLocalMessageReferences
	"Open a method browser displaying all references to the current selector in the currently
	selected packages."

	<commandQuery: #hasPackages>
	self browseMessageReferencesIn: self searchEnvironment!

browseLooseMethods: aCollection
	| env packageEnv |
	packageEnv := packagesPresenter selectionEnvironment.
	env := packageEnv forMethods: aCollection.
	env label: 'Loose methods from package(s): <1p>' << packageEnv.
	self model browseMethodsIn: env!

browseMessageDefinitions
	"Open a method browser displaying all implementors of the current selector in the system."

	<commandQuery: #hasMethodsSelected>
	self browseMessageDefinitionsIn: self browserEnvironment!

browseMessageDefinitionsIn: aBrowserEnvironment
	| methods |
	methods := self selectedMethods.
	methods isEmpty
		ifTrue: [self model browseMessageDefinitionsIn: aBrowserEnvironment]
		ifFalse: 
			[self browseMethodsInEnvironments: (methods
						collect: [:each | (MethodSearch newSelector: each selector) definitionsIn: aBrowserEnvironment])]!

browseMessageReferences
	"Open a method browser displaying all references to the current selector in the entire system."

	<commandQuery: #hasMethodsSelected>
	self browseMessageReferencesIn: self browserEnvironment!

browseMessageReferencesIn: aBrowserEnvironment
	| methods |
	methods := self selectedMethods.
	methods isEmpty
		ifTrue: [self model browseMessageReferencesIn: aBrowserEnvironment]
		ifFalse: 
			[self browseMethodsInEnvironments: (methods
						collect: [:each | aBrowserEnvironment referencesToLiteral: each selector])]!

browseMethodClass
	"Open a default browser on the currently selected method."

	<commandQuery: #hasMethodSelected>
	^self selectedMethod browse!

browseMethods
	"Open a default browser on the currently selected method or methods."

	<commandQuery: #queryBrowseMethods:>
	| methods |
	methods := self selectedMethods.
	methods size == 1 ifTrue: [self browseMethodClass] ifFalse: [self browseLooseMethods: methods]!

browsePackageSources
	<commandQuery: #hasPackages>
	^packagesPresenter browsePackageSources!

browseReferencesCommand
	^##(IdentityDictionary withAll: {
				#methods -> #browseMessageReferences.
				#classes -> #browseClassReferences.
				#variables -> #browseVariableReferences
			})
		lookup: currentCard!

browseSystem
	"Open a system browser on the currently selected class or method,
	and with the same package selection."

	<commandQuery: #queryBrowseSystem:>
	| pkgs method class browser |
	pkgs := self packages.
	pkgs isEmpty ifTrue: [^super browseSystem].
	browser := self developmentSystem browseSystemPackages: pkgs.
	browser isNil ifTrue: [^nil].
	(currentCard == #methods and: [(method := self selectedMethod) notNil])
		ifTrue: [browser selectMethod: method].
	(currentCard == #classes and: [(class := self selectedClass) notNil])
		ifTrue: [browser actualClass: class].
	^browser!

browseVariableClass
	"Open a default browser on the currently selected method."

	<commandQuery: #hasLiveVariableSelected>
	^self sharedVariable browse!

browseVariableReferences
	"Browse all the methods which refer to the shared variable selected in the receiver."

	<commandQuery: #hasVariableSelected>
	self model browseSharedVariableReferences: self sharedVariable in: self browserEnvironment!

cacheCurrentCard: aView
	currentCard := aView name asSymbol!

canSaveState
	"Private - Answer true if the receiver can successfully have it's state saved by #saveStateOn:. Some
	tools may not be able to save their state and therefore will not be able to be exported as
	part of a IdeaSpace save operation"

	^true!

clearCard: aSymbol
	self perform: (self updateMap at: aSymbol) third!

clearClasses
	"Private - Clear the classes list."

	classesPresenter clear!

clearComment
	"Private - Clear down the comment presenter"

	commentPresenter clear!

clearDependents
	"Private - Clear the dependents tree."

	dependentsPresenter clear!

clearMethods
	"Private - Clear the methods list."

	methodsPresenter clear!

clearPrerequisites
	"Private - Clear the prerequisites list."

	prerequisitesPresenter clear!

clearResources
	"Private - Clear the resources list."

	resourcesPresenter clear!

clearScriptNames
	"Private - Clear the scripts list."

	scriptNamesPresenter clear.
	self onScriptSelected!

clearVariables
	"Private - Clear the Variables list."

	variablesPresenter clear!

createComponents
	"Private - Create the presenters contained by the receiver"

	| workspaceClass |
	super createComponents.
	packagesPresenter := self
				add: PackageSelector new
				name: 'packages'
				helpId: 10755.
	classesPresenter := (self
				add: ListPresenter new
				name: 'classes'
				helpId: 10811) beSorted.
	methodsPresenter := self
				add: (ListPresenter on: ListModel new)
				name: 'methods'
				helpId: 10812.
	methodsPresenter beSorted: [:x :y | x selector <= y selector].
	methodRefactoringTool := self developmentSystem newMethodRefactoringToolFor: self.
	variablesPresenter := (self
				add: ListPresenter new
				name: 'variables'
				helpId: 10814)
				beSorted: [:a :b | a displayString <= b displayString];
				yourself.
	variablesPresenter model searchPolicy: SearchPolicy equality.
	resourcesPresenter := self
				add: ResourceListPresenter new
				name: 'resources'
				helpId: 10813.
	scriptNamesPresenter := self
				add: ListPresenter new
				name: 'scriptNames'
				helpId: 10815.
	workspaceClass := self workspaceClass.
	commentPresenter := self
				add: (workspaceClass new
						textStyles: ClassCommentPlugin textStyles;
						yourself)
				name: 'comment'
				helpId: 10808.
	scriptTextPresenter := self
				add: workspaceClass new
				name: 'scriptText'
				helpId: 10815.
	prerequisitesPresenter := self
				add: PackagePrerequisites new
				name: 'prerequisites'
				helpId: 10816.
	dependentsPresenter := self
				add: PackageDependents new
				name: 'dependents'
				helpId: 10817!

createSchematicWiring
	"Private - Create the trigger wiring for the receiver"

	super createSchematicWiring.
	self
		when: #closeRequested:
		send: #onCloseRequested:
		to: self.
	"We don't listen for #classAdded: events, as we pick up the addition of new classes to
	 a package through the PackageManager's #classRepackaged:from:to: event"
	self model
		when: #classRemoved:
			send: #onClassRemoved:
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
		when: #variableRemoved:
			send: #onVariableRemoved:
			to: self;
		when: #variableRenamed:from:
			send: #onVariableRenamed:from:
			to: self.
	"Note that as we are using the ResourceListPresenter, which keeps in sync. by itself,
	 we don't need (or want) to hook any resource related events"
	self packageManager
		when: #classRepackaged:from:to:
			send: #onClassRepackaged:from:to:
			to: self;
		when: #methodRepackaged:from:to:
			send: #onMethodRepackaged:from:to:
			to: self;
		when: #variableRepackaged:from:to:
			send: #onVariableRepackaged:from:to:
			to: self;
		when: #packageChanged:
			send: #onPackageChanged:
			to: self.
	packagesPresenter
		when: #selectionChanging:
			send: #onPackageSelectionChanging:
			to: self;
		when: #selectionChanged
			send: #onPackageSelected
			to: self.
	classesPresenter
		when: #actionPerformed
			send: #browseClass
			to: self;
		when: #drag:
			send: #onDragClasses:
			to: self;
		when: #drop:
			send: #onDropOverPackage:
			to: self;
		when: #dragEnter:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #Class);
		when: #dragOver:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #Class);
		when: #labelOf:editedTo:accept:
			send: #onClass:renameTo:accept:
			to: self.
	methodsPresenter
		when: #actionPerformed
			send: #browseIt
			to: self;
		when: #drag:
			send: #onDragMethods:
			to: self;
		when: #drop:
			send: #onDropOverPackage:
			to: self;
		when: #dragEnter:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #CompiledMethod);
		when: #dragOver:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #CompiledMethod).
	variablesPresenter
		when: #actionPerformed
			send: #inspectSharedVariables
			to: self;
		when: #drag:
			send: #onDragVariable:
			to: self;
		when: #drop:
			send: #onDropOverPackage:
			to: self;
		when: #dragEnter:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #VariableName);
		when: #dragOver:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #VariableName).
	resourcesPresenter
		when: #drag:
			send: #onDragResource:
			to: self;
		when: #drop:
			send: #onDropOverPackage:
			to: self;
		when: #dragEnter:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #ResourceIdentifier);
		when: #dragOver:
			send: #onDragOver:type:
			to: self
			withArguments: #(nil #ResourceIdentifier).
	scriptNamesPresenter
		when: #selectionChanged
		send: #onScriptSelected
		to: self!

customDrawClassList: anNMLVCUSTOMDRAW
	"Private - Custom drawing to implement the emphasis in the classes list tree."

	self developmentSystem setClassCustomDrawAttributes: anNMLVCUSTOMDRAW!

defaultHelpId
	^10807!

hasClassesSelected
	^classesPresenter hasSelection!

hasClassSelected
	"Answer true if the receiver has a single (i.e. not multiple) class selected"

	^classesPresenter hasSingleSelection!

hasLiveVariableSelected
	| ref |
	ref := self sharedVariable.
	^ref notNil and: [ref isDefined]!

hasMethodSelected
	"Answer true if the receiver has a single (i.e. not multiple) method selected"

	^self selectedMethod notNil!

hasMethodsSelected
	^self selectedMethods notEmpty!

hasPackages
	"Private - Answer whether one or more packages are currently selected."

	^self packages notEmpty!

hasPackageSelected
	"Answer true if the receiver has a single (i.e. not multiple) package selected"

	^self singlePackage notNil!

hasResourcesSelected
	^self resourceIdentifiers notEmpty!

hasVariableSelected
	^self sharedVariable notNil!

hasVariablesSelected
	^self variableNames notEmpty!

initialize
	"Private - Initialize the state of the receiver"

	super initialize.
	updateFlags := 0.
	self caption: 'Package Browser'.
	statusModel := ValueHolder new!

inspectClasses
	"Open an inspector on the currently selected classes."

	<commandQuery: #hasClassesSelected>
	self inspectCollection: self selectedClasses!

inspectCollection: aCollection
	(aCollection size = 1 ifTrue: [aCollection first] ifFalse: [aCollection]) inspect!

inspectItCommand
	"Private - Answer the command that the context-sensitive 'Inspect-It' command would be linked
	to if sent to the receiver at this moment."

	| focus |
	focus := View focus.
	focus == packagesPresenter packagesPresenter view ifTrue: [^#inspectPackages].
	focus == classesPresenter view ifTrue: [^#inspectClasses].
	focus == methodsPresenter view ifTrue: [^#inspectMethods].
	focus == variablesPresenter view ifTrue: [^#inspectSharedVariables].
	focus == resourcesPresenter view ifTrue: [^#inspectResources].
	^nil!

inspectMethods
	"Open an inspector on the currently selected methods."

	<commandQuery: #hasMethodsSelected>
	self inspectCollection: self selectedMethods!

inspectResources
	"Open an inspector on the currently selected resources."

	self inspectCollection: self resourceIdentifiers!

inspectSharedVariables
	"Open an inspector on the currently selected variables."

	<commandQuery: #hasVariablesSelected>
	self inspectCollection: (self variableNames collect: [:each | each bindingOrNil])!

isCardUpToDate: aSymbol
	^updateFlags allMask: (self updateMap at: aSymbol) first!

markCardDirty: aSymbol
	| updateInfo |
	updateInfo := self updateMap at: aSymbol.
	updateFlags := updateFlags maskClear: updateInfo first.
	self perform: updateInfo third!

objectRepackaged: anObject from: oldPackage to: newPackage card: cardSymbol list: aListModel
	| packages displayingNewPackage |
	currentCard == cardSymbol ifFalse: [^self markCardDirty: cardSymbol].
	packages := self packages.
	displayingNewPackage := packages includes: newPackage.
	(packages includes: oldPackage) 
		ifTrue: 
			[displayingNewPackage 
				ifTrue: [aListModel refresh: anObject]
				ifFalse: [aListModel remove: anObject]]
		ifFalse: [displayingNewPackage ifTrue: [aListModel add: anObject]]!

onCardChangedFrom: previousView to: currentView
	"Private - The source object card has been changed. Update the source pane
	accordingly."

	self cacheCurrentCard: currentView.
	(self isCardUpToDate: currentCard) ifFalse: [self updateCardNow: currentCard]!

onClassRemoved: aClass
	"Private - The <Behavior>, aClass, has been deleted. Update the receiver's
	cards as necessary to reflect the classes removal."

	currentCard == #classes
		ifTrue: [classesPresenter model remove: aClass ifAbsent: nil]
		ifFalse: [self markCardDirty: #classes].
	currentCard == #methods
		ifTrue: 
			[(methodsPresenter list select: [:each | each methodClass == aClass])
				do: [:each | methodsPresenter model remove: each]]
		ifFalse: [self markCardDirty: #methods]!

onClassRepackaged: aClass from: oldPackage to: newPackage
	"The class, aClass, has been repackaged, moving it from the <Package> or nil, oldPackage
	to the <Package>, or nil, newPackage. Note that we only bother attempting any
	kind of update if the classes card is actually displayed. If not we just mark the classes
	card as dirty to reduce overhead."

	self
		objectRepackaged: aClass
		from: oldPackage
		to: newPackage
		card: #classes
		list: classesPresenter model.
	#(#methods #resources) do: [:each | self refreshCard: each]!

onCloseRequested: boolValueHolder
	"Private - A request to close the view onto the receiver as occurred.
	Prompt to save any outstanding changed"

	boolValueHolder value: self promptToSaveChanges!

onDragClasses: session
	"Private - A drag of one or more classes has been started. Populate the 
	<DragDropSession>, session, with the objects to be dragged."

	| ddObjects |
	ddObjects := self selectedClasses collect: 
					[:e |
					(session newDragObject: e)
						format: #Class data: e;
						format: #String data: e definition;
						format: #Chunk data: e definitionChunk;
						yourself].
	session dragObjects: ddObjects!

onDragMethods: aDragDropSession 
	"Private - A drag has been started. Drag the currently selected methods."

	self developmentSystem beginDrag: aDragDropSession methods: self selectedMethods!

onDragOver: session type: format 
	"Private - A drag session is passing over one of the receiver's panes.
	Update the <DragDropSession>, session, with the drop operation supported
	(if any)."

	session operation: nil.
	(session isFormatAvailable: format) 
		ifTrue: 
			[self singlePackage 
				ifNotNil: 
					[:package | 
					session
						suggestedTarget: package;
						operation: #move.
					^true]].
	^false!

onDragResource: aDragDropSession
	"Private - A drag has been initiated of a resource, populate the <DragDropSession>, session,
	accordingly."

	| resId ddObject |
	resId := aDragDropSession suggestedSource.
	ddObject := aDragDropSession newDragObject: resId resource copy.
	ddObject format: #ResourceIdentifier data: resId.
	aDragDropSession
		dragObjects: (OrderedCollection with: ddObject);
		defaultOperation: #copy!

onDragVariable: aDragDropSession
	"Private - A Global drag has been started. Populate the <DragDropSession>, 
	session with the objects to be dragged."

	aDragDropSession dragObjects: nil.
	variablesPresenter selections do: 
			[:each |
			aDragDropSession addDragObject: ((aDragDropSession newDragObject: each)
						format: #VariableName data: each;
						yourself)].
	aDragDropSession defaultOperation: #copy!

onDropOverPackage: aDragDropSession
	"Private - The drag operation described by session would like to do a drop.
	Override this method to accept the dragObject(s)."

	| targetPackage packageManager |
	targetPackage := aDragDropSession suggestedTarget.
	targetPackage isNil
		ifTrue: 
			[Sound errorBeep.
			^false].
	packageManager := Package manager.
	Cursor wait showWhile: 
			[aDragDropSession dragObjects do: 
					[:each |
					"See if the drop is a CompiledMethod"
					(each isFormatAvailable: #CompiledMethod)
						ifTrue: 
							[| method |
							method := each format: #CompiledMethod.
							packageManager addMethod: method to: targetPackage].
					(each isFormatAvailable: #ResourceIdentifier)
						ifTrue: 
							[| resource |
							resource := each format: #ResourceIdentifier.
							packageManager addResourceIdentifier: resource to: targetPackage].
					(each isFormatAvailable: #VariableName)
						ifTrue: 
							[| bindingRef |
							bindingRef := each format: #VariableName.
							packageManager addVariableNamed: bindingRef asQualifiedReference to: targetPackage].
					(each isFormatAvailable: #Class)
						ifTrue: 
							[| class |
							class := each format: #Class.
							packageManager addClass: class to: targetPackage]]].

	"Operation must never be #move to avoid methods being removed"
	aDragDropSession operation: #copy.
	^true!

onMethodAdded: aCompilationResult
	currentCard == #methods 
		ifTrue: 
			[| method |
			method := aCompilationResult method.
			(method isLoose and: [self packages includes: method owningPackage]) 
				ifTrue: [methodsPresenter model add: method]]
		ifFalse: [self markCardDirty: #methods]!

onMethodRemoved: aCompiledMethod
	currentCard == #methods
		ifTrue: 
			["By this time, the package's may have been updated, so we may not be able to tell
			 if the method was originally loose, therefore we must just attempt to remove it regardless."
			methodsPresenter model remove: aCompiledMethod ifAbsent: nil]
		ifFalse: [self markCardDirty: #methods]!

onMethodRepackaged: aCompiledMethod from: oldPackage to: newPackage 
	| packages displayingNewPackage |
	currentCard == #methods ifFalse: [^self markCardDirty: #methods].
	packages := self packages.
	displayingNewPackage := packages includes: newPackage.
	(packages includes: oldPackage) 
		ifTrue: 
			[| wasLoose |
			wasLoose := methodsPresenter model indexOf: aCompiledMethod.
			(displayingNewPackage and: [aCompiledMethod isLoose]) 
				ifTrue: 
					[wasLoose ~= 0 
						ifTrue: [methodsPresenter model refreshAtIndex: wasLoose]
						ifFalse: [methodsPresenter model add: aCompiledMethod]]
				ifFalse: [wasLoose ~= 0 ifTrue: [methodsPresenter model removeAtIndex: wasLoose]]]
		ifFalse: 
			[(displayingNewPackage and: [aCompiledMethod isLoose]) 
				ifTrue: [methodsPresenter model add: aCompiledMethod]]!

onMethodUpdated: aCompilationResult 
	"Private - A method has been updated in the system. Ensure that the methods presenter
	is updated if necessary."

	currentCard == #methods 
		ifTrue: 
			[| method oldMethod |
			method := aCompilationResult method.
			oldMethod := aCompilationResult oldMethod.
			(methodsPresenter list identityIncludes: oldMethod) 
				ifTrue: 
					[| sel |
					sel := self selectedMethods copyReplacing: oldMethod withObject: method.
					(methodsPresenter model)
						remove: oldMethod;
						add: method.
					sel notEmpty ifTrue: [methodsPresenter selections: sel]]]
		ifFalse: [self markCardDirty: #methods]!

onPackageChanged: aPackage
	"Private - The specified <Package> has moved from changed to not-changed state, or vice versa.
	Repaint the current card to ensure that any change markers are added/removed."

	cardsPresenter currentCard invalidate.
	self updateCaption!

onPackageSelected
	"Private - A package has been selected. Update the receiver's display
	to show the package contents."

	self updateContents!

onPackageSelectionChanging: aSelectionChangingEvent 
	self promptToSaveChanges: aSelectionChangingEvent!

onScriptSelected
	"Private - A script has been selected. Fill and show the source view with a
	definition of the script."

	| script |
	currentCard == #scripts ifFalse: [^self].
	script := self scriptName.
	script notNil
		ifTrue: 
			[| pkg |
			pkg := self singlePackage.
			self scriptText: (pkg scriptAt: script).
			scriptTextPresenter
				evaluationContext: pkg;
				ensureVisible]
		ifFalse: [self scriptText: '']!

onVariableRemoved: aVariableBinding
	"Private - The shared variable with the specified binding has been removed from the system.
	The variables pane must be kept up to date."

	currentCard == #variables
		ifTrue: [variablesPresenter model remove: aVariableBinding fullyQualifiedReference ifAbsent: nil]
		ifFalse: [self markCardDirty: #variables]!

onVariableRenamed: aVariableBinding from: aBindingReference
	"Private - The shared variable with the specified binding has been renamed, the <Symbol>
	argument being its original name. The variables pane must be kept up to date."

	currentCard == #variables
		ifTrue: 
			[(variablesPresenter model remove: aBindingReference ifAbsent: nil) notNil
				ifTrue: [variablesPresenter model add: aVariableBinding fullyQualifiedReference]]
		ifFalse: [self markCardDirty: #variables]!

onVariableRepackaged: aBindingReference from: oldPackage to: newPackage
	self
		objectRepackaged: aBindingReference
		from: oldPackage
		to: newPackage
		card: #variables
		list: variablesPresenter model!

onViewOpened
	"Private - Received when the receiver's view is been connected. "

	super onViewOpened.
	(self view viewNamed: 'errors' ifNone: nil)
		ifNotNil: 
			[:item |
			item model: statusModel.
			scriptTextPresenter errorModel: statusModel].

	"Really a CardContainer view, but we treat as if a presenter"
	cardsPresenter := self view viewNamed: 'ownedCards'.
	cardsPresenter
		when: #currentCardChangedFrom:to:
		send: #onCardChangedFrom:to:
		to: self.	";
		when: #currentCardChanging: send: #onSelectionChanging: to: self"

	"Make sure the classes tab is visble"
	commentPresenter ensureVisible.
	self packageManager youShouldBeProcessingEvents!

openWorkspace
	"Create a new workspace window on a file"

	| workspaceClass |
	workspaceClass := self developmentSystem workspaceShellClass.
	^(FileOpenDialog new
		fileTypes: workspaceClass fileTypes;
		defaultExtension: workspaceClass defaultFileExtension;
		initialDirectory: (packagesPresenter selectedFolder ifNil: [SessionManager current imageBase]);
		showModal)
			ifNotNil: 
				[:path |
				(workspaceClass filename: path)
					show;
					yourself]!

packages
	"Answer the collection of currently selected packages"

	^packagesPresenter selections!

packages: aPackageCollection
	"Set the selected packages."

	packagesPresenter
		selections: aPackageCollection asArray;
		ensureSelectionVisible;
		synchronizeFilter!

promptToSaveChanges
	^self promptToSaveChanges: (SelectionChangingEvent forSource: self)!

promptToSaveChanges: aSelectionChangingEvent 
	^(commentPresenter prompt: 'comment' toSaveChanges: aSelectionChangingEvent) 
		and: [scriptTextPresenter prompt: 'script' toSaveChanges: aSelectionChangingEvent]!

queryBrowseHierarchyOfClass: aCommandQuery
	| class |
	class := self selectedClass.
	class ifNil: [^self].
	aCommandQuery
		beEnabled;
		expandMenuTextWith: class!

queryBrowseMethods: aCommandQuery
	| methods |
	methods := self selectedMethods.
	methods isEmpty ifTrue: [^self].
	aCommandQuery beEnabled.
	methods size = 1 ifTrue: [aCommandQuery expandMenuTextWith: methods single]!

queryBrowseSystem: aCommandQuery
	| pkgs |
	pkgs := self packages.
	pkgs isEmpty ifTrue: [^self].
	aCommandQuery
		beEnabled;
		expandMenuTextWith: (pkgs size = 1 ifTrue: [pkgs single] ifFalse: ['Selected Packages'])!

querySaveComment: aCommandQuery
	(packagesPresenter hasSinglePackage and: [commentPresenter isModified])
		ifTrue: 
			[aCommandQuery
				beEnabled;
				isDefault: true]!

querySaveScript: aCommandQuery
	(packagesPresenter hasSinglePackage and: [scriptTextPresenter isModified])
		ifTrue: 
			[aCommandQuery
				beEnabled;
				isDefault: true]!

refreshCard: aSymbol
	currentCard == aSymbol 
		ifTrue: [self updateCardNow: aSymbol]
		ifFalse: [self markCardDirty: aSymbol]!

release
	"Remove references to objects that may refer back to the receiver. 
	Remove the event registrations we have lodged with the package manager and
	system dictionary."

	super release.
	self packageManager removeEventsTriggeredFor: self!

removeClasses
	"Private - Remove the currently selected classes from the package."

	<commandQuery: #hasClassesSelected>
	self selectedClasses do: [:e | e owningPackage removeClass: e]!

removeLooseMethods
	"Private - Remove the currently selected method(s) from their packages.
	Note that the methods are not actually removed from the system (i.e.
	ownership is transferred to the package of their method class)."

	<commandQuery: #hasMethodsSelected>
	self selectedMethods do: [:each | each owningPackage removeMethod: each]!

removeVariables
	"Private - Remove the currently selected variables from their packages."

	<commandQuery: #hasVariablesSelected>
	self variableNames do: [:each | Package manager addVariableNamed: each to: nil]!

resourceIdentifier
	"Private - Answer the currently selected <ResourceIdentifier>, or nil if there not exactly one selection."

	| rids |
	rids := self resourceIdentifiers.
	^rids size = 1 ifTrue: [rids first]!

resourceIdentifiers
	"Private - Answer a <Collection> of the <ResourceIdentifier>s in the package which are currently
	selected."

	^resourcesPresenter selections!

saveComment
	"Private - Save the comment from the source text."

	<commandQuery: #querySaveComment:>
	self singlePackage comment: commentPresenter plainText.
	commentPresenter isModified: false!

saveScript
	"Private - Save the script from the source text."

	<commandQuery: #querySaveScript:>
	self singlePackage scriptAt: self scriptName put: self scriptText.
	self updateScriptNames!

scriptName
	"Answer the currently selected script name."

	^(scriptNamesPresenter selectionIfNone: nil) ifNotNil: [:script | script key]!

scriptText
	"Private - Answer the text for the currently selected script as a String"

	^scriptTextPresenter plainText!

scriptText: text 
	"Private - Set the text of the receiver's scriptPresenter to the argument,
	text (either plain or rich text)."

	scriptTextPresenter text: text
!

searchEnvironment
	"Private - Answer the environment used to scope local searches. This will include only those
	packages which are currently selected."

	^self selectionEnvironment!

selectedClass
	"Answer the currently selected class if there is exactly one selection, otherwise answer nil."

	| classes |
	classes := self selectedClasses.
	^classes size == 1 ifTrue: [classes first]!

selectedClasses
	"Answer the currently selected class, or an empty collection if none."

	^classesPresenter selections!

selectedMethod
	| methods |
	methods := self selectedMethods.
	^methods size == 1 ifTrue: [methods first]!

selectedMethods
	"Answer a <collection> of the currently selected loose methods."

	^(self isCardUpToDate: #methods) ifTrue: [methodsPresenter selections] ifFalse: [#()]!

selectionEnvironment
	^packagesPresenter selectionEnvironment!

setInitialFocus
	packagesPresenter view tabFirst!

sharedVariable
	| bindingRefs |
	bindingRefs := self variableNames.
	^bindingRefs size = 1 ifTrue: [bindingRefs first]!

shortCaption
	^'Packages'!

showPrerequisitesFor: aPackage
	"Private - Set the receiver to display aPackage and show the Prerequisites card for this"

	self singlePackage: aPackage.
	prerequisitesPresenter ensureVisible!

singlePackage
	"Answer the single selected package."

	^packagesPresenter singlePackage
!

singlePackage: aPackage
	"Set the receiver to be displaying a single package, aPackage"

	self packages: {aPackage}!

source
	"Private - Answer the source for the currently selected method as a String"

	^scriptTextPresenter plainText!

statusModel
	^statusModel!

statusText: aString
	statusModel value: (aString isNil ifFalse: [Notification messageText: aString])!

updateCaption
	"Refresh the caption to reflect the currently selected packages in the receiver, if any."

	| pkgs count text |
	pkgs := self packages.
	count := pkgs size.
	text := String smalltalkWriteStream: 64.
	count == 0
		ifTrue: [text display: self class]
		ifFalse: 
			[| package version |
			package := pkgs first.
			text display: package.
			version := package packageVersion.
			(version notNil and: [version notEmpty])
				ifTrue: 
					[text
						space;
						display: package packageVersion].
			count == 1 ifFalse: [text nextPutAll: ', and other packages']].
	self caption: text contents!

updateCardNow: aSymbol
	| updateInfo |
	updateInfo := self updateMap at: aSymbol.
	self perform: updateInfo second.
	updateFlags := updateFlags maskSet: updateInfo first!

updateCards
	"Private - Update the source object cards for the currently selected package(s).
	Implementation Note: It takes quite a bit of effort to update some of the cards, so we only 
	truly update the one which is actually displayed. We do this by clearing all models,
	except for the current card (to avoid flicker), and reset the update flags so that
	panes get refreshed on demand as they are displayed. Then we refresh the current card."

	self updateMap
		keysDo: [:each | (each ~~ currentCard and: [self isCardUpToDate: each]) ifTrue: [self clearCard: each]].
	updateFlags := 0.
	self updateCardNow: currentCard!

updateClasses
	"Private - Update the classes list for this package."

	| classes |
	classes := OrderedCollection new: 64.
	self packages 
		do: [:each | each classesDo: [:eachClass | classes addLast: eachClass]].
	classesPresenter list: classes!

updateComment
	"Private - Update the comment for a single package."

	self singlePackage 
		ifNil: 
			[commentPresenter text: ''.
			commentPresenter view disable]
		ifNotNil: 
			[:package | 
			commentPresenter text: package comment.
			"#642: Note must enable after setting text, or view may not display scrollbar correctly"
			commentPresenter view enable]!

updateContents
	"Private - Fill the contents presenters based on the currently selected package."

	currentCard isNil ifTrue: [self cacheCurrentCard: cardsPresenter currentCard].
	self
		updateCards;
		updateCaption;
		updateStatus!

updateDependents
	dependentsPresenter packages: self packages!

updateMap
	^##(IdentityDictionary new
		at: #classes put: #(1 #updateClasses #clearClasses);
		at: #methods put: #(2 #updateMethods #clearMethods);
		at: #variables put: #(4 #updateVariables #clearVariables);
		at: #scripts put: #(8 #updateScriptNames #clearScriptNames);
		at: #resources put: #(16 #updateResources #clearResources);
		at: #prerequisites put: #(32 #updatePrerequisites #clearPrerequisites);
		at: #comment put: #(64 #updateComment #clearComment);
		at: #dependents put: #(128 #updateDependents #clearDependents);
		shrink;
		beImmutableObject;
		yourself)!

updateMethods
	"Private - Update the methods list for the selected package."

	| methods |
	methods := OrderedCollection new.
	self packages do: [:each | methods addAll: each methods].
	methodsPresenter list: methods!

updatePrerequisites
	"Private - Update the prerequisites list for this package."
	
	prerequisitesPresenter packages: self packages

!

updateResources
	"Private - Update the resources list for this package."

	Package manager looseMethods.
	resourcesPresenter showResourcesOwnedByPackages: self packages!

updateScriptNames
	"Private - Update the scripts list for a single package."

	| scriptSelected |
	scriptSelected := scriptNamesPresenter selectionByIndex.
	scriptNamesPresenter clear.
	self singlePackage 
		ifNil: [scriptTextPresenter view isEnabled: false]
		ifNotNil: 
			[:package | 
			#(#preinstall #postinstall #preuninstall #postuninstall) 
				do: [:each | scriptNamesPresenter model add: each -> (package scriptAt: each) notEmpty].
			scriptNamesPresenter 
				selectionByIndex: (scriptSelected = 0 ifTrue: [1] ifFalse: [scriptSelected]).
			scriptTextPresenter view isEnabled: true]!

updateStatus
	"Private - The receiver has changed in such a way that the caption may need to be refreshed.
	Do this here"

	self statusText: (self singlePackage ifNotNil: [:package | package packageFileName])!

updateVariables
	"Private - Update the Shared Variables list for this package."

	| bindingRefs |
	bindingRefs := OrderedCollection new.
	self packages do: [:each | bindingRefs addAll: each variableNames].
	variablesPresenter list: bindingRefs!

upgradeResources
	"Private - Uprade & resave the selected resources, by loading them into a ViewComposer."

	<commandQuery: #hasResourcesSelected>
	self resourceIdentifiers do: [:each | each reassign]!

variableNames
	^variablesPresenter selections! !

!Tools.PackageBrowserShell categoriesForMethods!
acceptItCommand!commands-mappings!private! !
addToCommandRoute:!commands-routing!public! !
applyOptions!operations!options!private! !
browseClass!commands-actions!public! !
browseClassReferences!commands-actions!public! !
browseClassReferencesIn:!helpers!private! !
browseDefinitionsCommand!commands-mappings!private! !
browseHierarchyCommand!commands-mappings!private! !
browseHierarchyOfClass!commands-actions!private! !
browseHierarchyOfMethod!commands-actions!private! !
browseHierarchyOfVariable!commands-actions!private! !
browseItCommand!helpers!private! !
browseLocalClassReferences!commands-actions!public! !
browseLocalMessageDefinitions!commands-actions!public! !
browseLocalMessageReferences!commands-actions!public! !
browseLooseMethods:!helpers!private! !
browseMessageDefinitions!commands-actions!public! !
browseMessageDefinitionsIn:!helpers!private! !
browseMessageReferences!commands-actions!public! !
browseMessageReferencesIn:!helpers!private! !
browseMethodClass!commands-actions!public! !
browseMethods!commands-actions!public! !
browsePackageSources!commands-actions!public! !
browseReferencesCommand!commands-mappings!private! !
browseSystem!commands-actions!public! !
browseVariableClass!commands-actions!public! !
browseVariableReferences!commands-actions!public! !
cacheCurrentCard:!event handling!private! !
canSaveState!private!saved state! !
clearCard:!private!updating! !
clearClasses!private!updating! !
clearComment!private!updating! !
clearDependents!private!updating! !
clearMethods!private!updating! !
clearPrerequisites!private!updating! !
clearResources!private!updating! !
clearScriptNames!private!updating! !
clearVariables!private!updating! !
createComponents!commands-actions!private! !
createSchematicWiring!commands-actions!private! !
customDrawClassList:!private! !
defaultHelpId!public! !
hasClassesSelected!private!testing! !
hasClassSelected!public!testing! !
hasLiveVariableSelected!private!testing! !
hasMethodSelected!public!testing! !
hasMethodsSelected!public!testing! !
hasPackages!private!testing! !
hasPackageSelected!public!testing! !
hasResourcesSelected!private!testing! !
hasVariableSelected!private!testing! !
hasVariablesSelected!private!testing! !
initialize!initializing!private! !
inspectClasses!commands-actions!public! !
inspectCollection:!helpers!private! !
inspectItCommand!helpers!private! !
inspectMethods!commands-actions!public! !
inspectResources!commands-actions!public! !
inspectSharedVariables!commands-actions!public! !
isCardUpToDate:!private!testing! !
markCardDirty:!helpers!private! !
objectRepackaged:from:to:card:list:!event handling!private! !
onCardChangedFrom:to:!event handling!private! !
onClassRemoved:!event handling!private! !
onClassRepackaged:from:to:!event handling!private! !
onCloseRequested:!event handling!private! !
onDragClasses:!event handling!private! !
onDragMethods:!event handling!private! !
onDragOver:type:!event handling!private! !
onDragResource:!event handling!private! !
onDragVariable:!event handling!private! !
onDropOverPackage:!event handling!private! !
onMethodAdded:!event handling!private! !
onMethodRemoved:!event handling!private! !
onMethodRepackaged:from:to:!event handling!private! !
onMethodUpdated:!event handling!private! !
onPackageChanged:!event handling!private! !
onPackageSelected!event handling!private! !
onPackageSelectionChanging:!private! !
onScriptSelected!event handling!private! !
onVariableRemoved:!event handling!private! !
onVariableRenamed:from:!event handling!private! !
onVariableRepackaged:from:to:!event handling!private! !
onViewOpened!event handling!private! !
openWorkspace!commands-actions!public! !
packages!accessing!public! !
packages:!accessing!public! !
promptToSaveChanges!helpers!private! !
promptToSaveChanges:!helpers!private! !
queryBrowseHierarchyOfClass:!commands-queries!private! !
queryBrowseMethods:!commands-queries!private! !
queryBrowseSystem:!commands-queries!private! !
querySaveComment:!commands-queries!private! !
querySaveScript:!commands-queries!private! !
refreshCard:!helpers!private! !
release!dependency!public! !
removeClasses!commands-actions!private! !
removeLooseMethods!commands-actions!private! !
removeVariables!commands-actions!private! !
resourceIdentifier!accessing!private! !
resourceIdentifiers!accessing!private! !
saveComment!commands-actions!private! !
saveScript!operations!private! !
scriptName!accessing!private! !
scriptText!accessing!private! !
scriptText:!accessing!private! !
searchEnvironment!accessing!private! !
selectedClass!accessing!public! !
selectedClasses!accessing!public! !
selectedMethod!accessing!public! !
selectedMethods!accessing!public! !
selectionEnvironment!accessing!private! !
setInitialFocus!operations!public! !
sharedVariable!accessing!public! !
shortCaption!accessing!public! !
showPrerequisitesFor:!helpers!private! !
singlePackage!accessing!public! !
singlePackage:!accessing!public! !
source!accessing!private! !
statusModel!accessing!public! !
statusText:!accessing!private! !
updateCaption!public!updating! !
updateCardNow:!private!updating! !
updateCards!private!updating! !
updateClasses!private!updating! !
updateComment!private!updating! !
updateContents!private!updating! !
updateDependents!private!updating! !
updateMap!private!updating! !
updateMethods!private!updating! !
updatePrerequisites!private!updating! !
updateResources!private!updating! !
updateScriptNames!private!updating! !
updateStatus!private!updating! !
updateVariables!private!updating! !
upgradeResources!commands-actions!public! !
variableNames!accessing!public! !
!

!Tools.PackageBrowserShell class methodsFor!

defaultOptionFlags
	^##(CanUseIdeaSpaceMask | ReuseIfOpenMask)!

displayOn: aPuttableStream
	"Append to the <puttableStream> argument a String whose characters are a representation of the receiver that an end-user might want to see."

	aPuttableStream nextPutAll: 'Package Browser'!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

initialize
	"Private - Register the receiver with SmalltalkSystem.

		self initialize.
	"

	SmalltalkSystem current
		addSystemFolderIcon: self toolsFolderIcon;
		registerTool: self.
	WordWrapComment := true!

publishedAspects
	"Answer a <LookupTable> of the <Aspect>s published by the receiver."

	| aspects |
	aspects := super publishedAspects.
	(aspects at: #reuseIfOpen) defaultValue: true.
	aspects add: self canUseIdeaSpaceAspect.
	aspects add: ((Aspect boolean: #wordWrapComment)
				defaultValue: true;
				yourself).
	^aspects!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ShellView} 38 #{Core.Array} 27 nil nil 8 #(13565952 65536) 32 nil 518 #{Graphics.ThemeColor} #toolBackground nil 517 nil nil nil 32 1798 #{UI.BorderLayout} 1 1 18 #{UI.Toolbar} 50 28 nil 32 50 2 8 1140853580 131073 160 nil nil nil 517 nil nil nil 160 6 #{Graphics.Color} #default nil 518 #{Kernel.STBIdentityDictionaryProxy} #{Core.IdentityDictionary} 50 10 18 #{UI.Toolbar} 50 28 nil 160 50 2 8 1140853580 131073 304 nil nil nil 517 nil nil nil 304 240 nil 258 #{Core.IdentityDictionary} 8 #() nil nil nil nil 50 5 1606 2 #{UI.ToolbarIconButton} 304 1 1350 4 #{UI.CommandDescription} #newPackage 8 'New Package' 1 1 838 4 #{Graphics.Icon} nil true 1030 #{Graphics.ImageFromStringResourceInitializer} 8 'NewPackage.ico' 838 1 #{External.ResourceLibrary} 8 'dolphindr8.dll' 65541 nil nil nil nil 418 304 1 450 #openPackage 8 'Install Package…' 1 1 498 nil true 530 8 'FileOpen.ico' 592 65541 nil nil nil nil 418 304 1 450 #savePackageChanges 8 'Save Package Changes' 1 1 498 nil true 530 8 'FileSave.ico' 592 65541 nil nil nil nil 418 304 1 450 #browsePackageSources 8 'Open Source Browser' 1 1 498 nil true 530 8 'SourceBrowser.ico' 592 65541 nil nil nil nil 582 1 #{UI.ToolbarSeparator} 304 1 nil nil 9 1 nil nil nil nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[11 2 0 0 0 0 0 0 111 2 0 0 25 0 0 0] 193 336 8 '' 304 3 8 #() 518 #{Graphics.Point} 193 193 nil 31 8 'fileTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 1200 nil nil nil 5 nil nil nil 1200 582 1 #{UI.ResourceIdentifier} #{UI.Toolbar} #resource_Image_tools nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 0 0 0 0 31 0 0 0 25 0 0 0] 193 1232 8 '' 1200 3 384 1154 193 193 nil 27 8 'imageTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 1456 nil nil nil 5 nil nil nil 1456 1266 #{UI.Toolbar} #resource_Search_tools nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[51 1 0 0 0 0 0 0 11 2 0 0 25 0 0 0] 193 1488 8 '' 1456 3 384 1154 193 193 nil 27 8 'searchTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 1696 nil nil nil 5 nil nil nil 1696 1266 #{UI.Toolbar} #resource_Smalltalk_tools nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[31 0 0 0 0 0 0 0 51 1 0 0 25 0 0 0] 193 1728 8 '' 1696 3 384 1154 193 193 nil 27 8 'smalltalkTools' 18 #{UI.Toolbar} 50 28 nil 160 50 2 8 1140853612 131137 1936 nil nil nil 517 nil nil nil 1936 240 nil 258 #{Core.IdentityDictionary} 384 nil nil nil nil 50 1 418 1936 273 450 #viewModeSelect 8 'Views' 1 1 498 nil true 530 8 'ViewMode.ico' 592 65541 nil nil nil nil nil nil 9 1 nil nil nil nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[111 2 0 0 0 0 0 0 143 2 0 0 25 0 0 0] 193 1968 8 '' 1936 3 8 #() 1154 193 193 nil 31 8 'viewTools' nil nil nil nil 8 #() nil nil 9 1311 #smallIcons nil nil 838 1 #{UI.FlowLayout} 1 1 1 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 0 0 0 0 227 2 0 0 25 0 0 0] 193 192 8 '' 160 3 50 5 1200 1696 1456 304 1936 1154 193 193 nil 31 18 #{UI.StatusBar} 50 21 nil 32 50 2 8 1140850956 1 2512 nil 240 nil 5 nil 1350 1 #{Graphics.Font} nil true 262 #{OS.LOGFONTW} 8 #[245 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 77 0 105 0 99 0 114 0 111 0 115 0 111 0 102 0 116 0 32 0 83 0 97 0 110 0 115 0 32 0 83 0 101 0 114 0 105 0 102 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 193 nil nil 2512 nil nil 258 #{Core.IdentityDictionary} 50 2 1862 1 #{UI.StatusBarItem} 8193 -1 2512 nil 518 #{Core.Message} #displayString 8 #() 2722 #iconImageIndex 2752 nil 8 'errors' nil nil nil 50 1 2704 1094 1 #{UI.StatusBarNullItem} 8705 1 2512 nil nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 185 1 0 0 227 2 0 0 205 1 0 0] 193 2544 8 '' 2512 3 8 #() 1154 193 193 nil 29 nil nil 18 #{UI.ContainerView} 50 15 nil 32 50 2 8 1140850688 131073 3008 nil nil nil 5 nil nil nil 3008 518 #{UI.ProportionalLayout} 550 #{Core.LookupTable} 0 true 550 #{Core.IdentityDictionary} 0 nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 25 0 0 0 227 2 0 0 185 1 0 0] 193 3040 8 '' 3008 3 50 1 18 #{UI.ContainerView} 50 15 nil 3008 50 2 8 1140850688 131073 3312 nil nil nil 5 nil nil nil 3312 3074 518 #{Kernel.STBCollectionProxy} 3104 50 1 518 #{Core.Association} 18 #{UI.ContainerView} 50 15 nil 3312 50 2 8 1140850688 131073 3472 nil nil nil 5 nil nil nil 3472 3074 3394 #{Core.Dictionary} 50 1 3442 18 #{UI.CardContainer} 50 16 nil 3472 50 2 8 1140850688 131073 3600 nil nil nil 5 2886 4 #{UI.Menu} nil true 50 2 3666 nil true 50 4 1094 2 #{UI.CommandMenuItem} 1025 450 2722 #tabOrientation: 8 #(#top) 8 '&Top' 1 1 nil nil nil 3746 1025 450 2722 #tabOrientation: 8 #(#bottom) 8 '&Bottom' 1 1 nil nil nil 3746 1025 450 2722 #tabOrientation: 8 #(#left) 8 '&Left' 1 1 nil nil nil 3746 1025 450 2722 #tabOrientation: 8 #(#right) 8 '&Right' 1 1 nil nil nil 8 '&Orientation' nil 134217729 nil nil nil nil nil 3666 nil true 50 6 3746 1025 450 2722 #viewMode: 8 #(#noIcons) 8 '&No Icons' 1 1 nil nil nil 3746 1025 450 2722 #viewMode: 8 #(#smallIcons) 8 '&Small Icons' 1 1 nil nil nil 3746 1025 450 2722 #viewMode: 8 #(#mediumIcons) 8 '&Medium Icons' 1 1 nil nil nil 3746 1025 450 2722 #viewMode: 8 #(#largeIcons) 8 '&Large Icons' 1 1 nil nil nil 3746 1025 450 2722 #viewMode: 8 #(#tileIcons) 8 '&Tile Icons' 1 1 nil nil nil 3746 1 450 2722 #viewMode: 8 #(#thumbnails) 8 'Thum&bnails' 1 1 nil nil nil 8 '&View' nil 134217729 nil nil nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3600 1350 1 #{UI.CardLayout} 550 #{Core.OrderedCollection} 8 3442 838 1 #{UI.CardLabel} 8 'Classes' 994 #icon 8 #() #{Core.Behavior} nil 18 #{UI.ListView} 50 45 nil 3600 50 2 8 1140920395 1 4800 838 2 #{UI.ListModel} 4674 0 nil 6 #{Kernel.IdentitySearchPolicy} 240 nil 29 3666 nil true 50 8 3746 2097153 450 #browseClass 8 '&Browse Hierarchy' 1 1 498 nil true 530 8 'ClassBrowserShell.ico' 592 65541 nil nil nil 3746 1 450 #browseClassReferences 8 'All Re&ferences' 1 1 nil nil nil 3746 1 450 #browseLocalClassReferences 8 'L&ocal References' 1 1 nil nil nil 326 1 #{UI.DividerMenuItem} 4097 3746 1 450 #addClass 8 '&Add Uncommitted..' 1 1 nil nil nil 3746 1 450 #removeClasses 8 'Re&move from Package' 1 1 nil nil nil 5170 4097 3666 nil true 50 4 3746 2097153 450 #renameClass 8 'Re&name…' 1 1 498 nil true 530 8 'Rename.ico' 592 65541 nil nil nil 3746 1 450 #changeClassNamespace 8 'C&hange Namespace…' 1 1 nil nil nil 5170 4097 3746 1 450 #removeDuplicateMethods 8 'Remove Dup&licate Methods' 1 1 nil nil nil 8 '&Refactorings' #classRefactoringsMenu 134217729 498 nil true 530 8 'Refactoring.ico' 592 65541 nil nil nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 4800 nil nil 2722 #fullName 8 #() 2768 1350 1 #{Graphics.IconImageManager} nil nil 1382 3 #{Kernel.BlockClosure} 0 nil 1318 #{Kernel.CompiledExpression} 4 1 5696 8 'doIt' 8 '[:ctx | ctx view parentPresenter customDrawClassList: ctx]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #customDrawClassList: 5712 7 257 nil 1154 65 65 nil nil 4674 5 3142 5 #{UI.ListViewColumn} 8 '' 41 #left 5698 0 nil 5730 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:x | x ifTrue: [''Changed''] ifFalse: ['''']]' 8 #[31 105 17 119 29 106 30 106] 8 'Changed' 8 '' 5888 7 257 nil 5698 0 nil 5730 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:x :y | x & y not]' 8 #[31 105 233 1 158 177 106] #not #& 6000 7 513 nil 2722 #isChanged 8 #() nil 4800 5698 0 nil 5730 5 1 5696 8 'doIt' 8 '[:x | x ifTrue: [Package changedIcon imageIndex]] ' 8 #[32 105 17 121 45 159 160 106 60 106] 1094 2 #{Kernel.VariableBinding} #Package #{Kernel.Package} #{Kernel} 1 #changedIcon #imageIndex 6112 #ifTrue: 7 257 nil 1 nil nil 5842 8 'Namespace' 301 #left 2722 #displayString 8 #() 5698 0 nil 5730 2 1 5696 8 'doIt' 8 '[:a :b | a displayString <= b displayString]' 8 #[30 105 226 0 226 32 130 106] #displayString 6288 7 513 nil 2722 #environment 8 #() nil 4800 2768 1 nil nil 5842 8 'Name' 375 #left 2722 #unqualifiedName 5648 2722 #<= 8 #() nil nil 4800 2768 1 nil 5698 0 nil 5730 4 1 5696 8 'doIt' 8 '[:ctx | ctx view parentPresenter customDrawClassList: ctx]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #customDrawClassList: 6480 7 257 nil 5842 #Package 201 #left 2736 5698 0 nil 5730 2 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a :b | a name < b name]' 8 #[30 105 17 158 18 158 128 106] #name 6576 7 513 nil 2722 #owningPackage 8 #() nil 4800 nil 1 nil nil 5842 8 'File Out Name' 2001 #left 2736 2722 #<= 8 #() 2722 #fileOutName 8 #() nil 4800 nil 1 nil nil #list 8 #() nil 133221 nil 1 nil nil nil nil 1 262 #{UI.ListViewVirtualUpdateMode} 4800 nil nil nil nil nil nil nil nil nil 946 50 2 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 4832 8 '' 4800 994 #contextMenu: 50 1 4944 4800 1 8 #() 1154 193 193 nil 35 3442 4722 8 'Methods' 994 #icon 4784 #{Kernel.CompiledMethod} nil 18 #{UI.ListView} 50 45 nil 3600 50 2 8 1140920393 1 7088 4866 4674 0 nil 4928 240 nil 29 3666 nil true 50 8 3746 2097153 450 #browseMethods 8 '&Browse <d:Methods>' 1 17 498 nil true 530 8 'MethodBrowser.ico' 592 65541 nil nil nil 3746 1 450 #browseMessageDefinitions 8 'All Defi&nitions' 1 1 nil nil nil 3746 1 450 #browseMessageReferences 8 'All Re&ferences' 1 1 nil nil nil 3746 1 450 #browseLocalMessageDefinitions 8 'Local &Definitions' 1 1 nil nil nil 3746 1 450 #browseLocalMessageReferences 8 '&Local References' 1 1 nil nil nil 5170 4097 3746 1 450 #removeLooseMethods 8 '&Remove from Package' 1 1 nil nil nil 3666 nil true 50 7 3746 1 450 #renameMethod 8 'Re&name' 1 1 498 nil true 530 8 'Rename.ico' 592 65541 nil nil nil 3746 1 450 #renameMethodReferences 8 'Rename Re&ferences' 1 1 nil nil nil 5170 4097 3746 1 450 #removeMethods 8 '&Remove' 1 1 nil nil nil 5170 4097 3746 1 450 #addParameterToMethod 8 'Add &Parameter…' 1 1 nil nil nil 3666 nil true 8 #() 8 'Remo&ve Parameter' #removeParameterMenu 134217729 nil nil nil nil nil 8 'Refactorin&gs' #methodRefactoringsMenu 134217729 498 nil true 530 8 'Refactoring.ico' 592 65541 nil nil nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 7088 nil nil 2736 2768 5680 nil nil nil 1154 65 65 nil nil 4674 4 5842 8 'Selector' 401 #left 2722 #selector 8 #() 5698 0 nil 5730 2 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a :b | a selector < b selector]' 8 #[30 105 17 158 18 158 128 106] #selector 8096 7 513 nil nil nil 7088 2768 1 nil 5698 0 nil 5730 3 1 5696 8 'doIt' 8 '[:ctx | 
ctx forecolor: Tools.ClassBrowserAbstract.LooseMethodColor]' 8 #[31 105 17 45 177 106] 6194 8 'LooseMethodColor' 226 #purple #{Tools.ClassBrowserAbstract} 5 #forecolor: 8176 7 257 nil 5842 8 'Class' 389 #left 2722 #name 8 #() 2722 #<= 8 #() 2722 #methodClass 8 #() nil 7088 2768 1 nil 5698 0 nil 5730 4 1 5696 8 'doIt' 8 '[:ctx | ctx view parentPresenter customDrawClassList: ctx]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #customDrawClassList: 8432 7 257 nil 5842 8 'Namespace' 301 #left 2722 #printString 8 #() 5698 0 nil 5730 4 1 2720 8 'doIt' 8 '[:a :b | a isNil or: [
	b notNil and: [a printString <= b printString]]]' 8 #[32 105 17 223 2 58 106 18 222 6 226 2 226 34 130 106 59 106] #or: #and: #printString 8576 7 513 nil 2722 #environment 8 #() nil 7088 2768 1 nil nil 5842 #Package 149 #left 2736 5698 0 nil 5730 2 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a :b | a name < b name]' 8 #[30 105 17 158 18 158 128 106] #name 8704 7 513 nil 2722 #owningPackage 8 #() nil 7088 nil 3 nil nil #report 6784 nil 131173 nil 1 nil nil nil nil 1 6802 7088 nil nil nil nil nil nil nil nil nil 946 50 2 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 7120 8 'Selector' 7088 994 #contextMenu: 50 1 7184 7088 1 8 #() 1154 193 193 nil 35 3442 4722 8 'Resources' 994 #icon 4784 1264 nil 18 #{UI.ReferenceView} 50 14 nil 3600 50 2 8 1140850688 131073 9088 nil nil nil 5 3666 nil true 50 4 3746 2097153 450 #editResource 8 '&Edit' 1 1 498 nil true 530 8 'ViewComposer.ico' 592 65541 nil nil nil 3746 1 450 #showResource 8 '&Show' 1 1 498 nil true 530 8 'TestView.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #deleteResource 8 '&Delete' 1 1 498 nil true 530 8 'EditClear.ico' 592 65541 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 9088 1266 #{Tools.ResourceListPresenter} #resource_Package_view nil 946 50 2 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 9120 8 '' 9088 994 #contextMenu: 50 1 9152 9088 1 384 1154 193 193 nil 27 3442 4722 8 'Scripts' nil nil 18 #{UI.ContainerView} 50 15 nil 3600 50 2 8 1140850688 131073 9744 nil nil nil 5 nil nil nil 9744 262 #{UI.FramingLayout} 258 3104 50 4 18 #{UI.TabViewXP} 50 28 nil 9744 50 2 8 1140916866 1 9872 4866 4674 0 nil 4928 240 nil 5 nil nil nil 9872 nil nil 2722 #key 8 #() 5698 0 nil 5730 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:x | x value icon imageIndex]' 8 #[31 105 17 142 158 159 106] #icon #imageIndex 10000 7 257 nil 5680 nil nil nil nil nil #smallIcons nil nil nil nil nil 946 50 2 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 0 0 0 0 226 1 0 0 108 1 0 0] 193 9904 8 '' 9872 994 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 9872 3 8 #() 1154 193 193 nil 27 2118 2 #{UI.FramingConstraints} 1030 #{UI.FramingCalculation} #fixedParentLeft 1 10306 #fixedParentRight 1 10306 #fixedParentTop 1 10306 #fixedParentBottom 1 18 #{UI.Scintilla.ScintillaView} 50 56 nil 9744 50 2 8 1176572228 1025 10384 1094 2 #{UI.ValueHolder} nil false 6 #{Kernel.EqualitySearchPolicy} nil 240 nil 21 3666 nil true 50 13 3746 1 450 #accept 8 '&Accept' 1 1 nil nil nil 5170 4097 3666 nil true 50 11 3746 1 450 #undo 8 '&Undo' 1 1 498 nil true 530 8 'EditUndo.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #cutSelection 8 'Cu&t' 1 1 498 nil true 530 8 'EditCut.ico' 592 65541 nil nil nil 3746 1 450 #copySelection 8 '&Copy' 1 1 498 nil true 530 8 'EditCopy.ico' 592 65541 nil nil nil 3746 1 450 #pasteClipboard 8 '&Paste' 1 1 498 nil true 530 8 'EditPaste.ico' 592 65541 nil nil nil 3746 1 450 #clearSelection 8 'De&lete' 1 1 498 nil true 530 8 'EditClear.ico' 592 65541 nil nil nil 3746 1 450 #clear 8 'Clea&r' 1 1 498 nil true 530 8 'ClearDocument.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #reformatSource 8 'Re&format' 1 1 nil nil nil 5170 4097 3746 1 450 #selectAll 8 '&Select All' 1 1 nil nil nil 8 '&Edit' nil 134217729 nil nil nil nil nil 3666 nil true 50 10 3746 1 450 #inspectWorkspacePool 8 '&Variables' 1 1 498 nil true 530 8 'BasicInspector.ico' 592 65541 nil nil nil 3746 1 450 #cloneNew 8 '&Clone' 1 1 498 nil true 530 8 'SmalltalkWorkspace.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #toggleAutoCompletion 8 '&Auto-complete' 1 1 nil nil nil 3746 1 450 #toggleIndentationGuides 8 'Indentation &Guides' 1 1 nil nil nil 3746 1 450 #toggleLineNumbers 8 'Line N&umbers' 1 1 nil nil nil 3746 1 450 #toggleLineEndings 8 'Line &Endings' 1 1 2374 2 #{Graphics.TextTileIcon} $¶ 8 'Arial' nil nil nil nil 1 nil nil nil nil 3746 1 450 #toggleStyling 8 '&Syntax Coloring' 1 1 nil nil nil 3746 1 450 #toggleWhitespace 8 'W&hitespace' 1 1 nil nil nil 3746 1 450 #toggleWordWrap 8 '&Word Wrap' 1 1 nil nil nil 8 'Wor&kspace' nil 134217729 nil nil nil nil nil 5170 4097 3746 1 450 #browseIt 8 'Bro&wse It' 1 1 498 nil true 530 8 'ClassBrowserShell.ico' 592 65541 nil nil nil 3746 1 450 #displayIt 8 '&Display It' 1 1 498 nil true 530 8 'DisplayIt.ico' 592 65541 nil nil nil 3746 1 450 #printIt 8 '&Print It' 1 1 498 nil true 530 8 'PrintIt.ico' 592 65541 nil nil nil 3746 1 450 #evaluateIt 8 'E&valuate It' 1 1 498 nil true 530 8 'EvaluateIt.ico' 592 65541 nil nil nil 3746 1 450 #inspectIt 8 '&Inspect It' 1 1 498 nil true 530 8 'BasicInspector.ico' 592 65541 nil nil nil 3746 1 450 #debugIt 8 'Deb&ug It' 1 1 498 nil true 530 8 'Debugger.ico' 592 65541 nil nil nil 5170 4097 3666 nil true 50 3 3746 2097153 450 #browseDefinitions 8 'Defi&nitions…' 1 1 nil nil nil 3746 1 450 #browseReferences 8 '&References…' 1 1 nil nil nil 3746 1 450 #browseMessages 8 '&Messages…' 1 1 nil nil nil 8 '&Browse' nil 134217729 nil nil nil nil nil 8 '&Workspace' nil 134217729 nil nil nil nil nil nil nil 10384 nil nil 518 #{UI.NullConverter} nil nil 9 #focusLost nil nil nil nil 3138 2 #callTip 3142 1 #{UI.Scintilla.TextStyle} 77 226 #gray 226 #white 1 nil nil nil nil #callTip nil nil nil #normal 12882 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1286 #{Tools.SmalltalkExpressionStyler} 1 nil nil false 4674 0 3138 1 #default 3142 2 #{UI.Scintilla.MarkerDefinition} 1 nil nil nil 10384 #circle nil nil nil nil nil nil 294 #{Core.IdentitySet} 0 nil 3106 0 9215 nil nil 3106 1 81 226 #windowText nil nil 262 #{UI.Scintilla.NullScintillaLibrary} nil 65 nil nil 3138 3 #literalArray 8 '()' #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' nil 3 3138 1 #container 12864 nil nil nil nil #{Core.Utf8String} nil 3138 2 #Error 3142 5 #{UI.Scintilla.IndicatorDefinition} 19 10384 226 #red 3 3 #Error nil nil nil nil nil nil #Warning 13266 17 10384 226 #blue 3 3 #Warning nil nil nil nil nil nil nil nil 3138 3 #Error 12882 1031 226 #firebrick 226 #floralWhite 1 nil nil nil nil #Error nil nil nil #Notification 12882 1029 nil 226 #gainsboro 1 nil nil nil nil #Notification nil nil nil #Warning 12882 1027 226 #darkGoldenrod 226 #ivory 1 nil nil nil nil #Warning nil nil nil nil nil nil 946 50 9 994 #createWindow: 50 1 1042 1074 8 #[10 0 0 0 10 0 0 0 180 1 0 0 98 1 0 0] 193 10416 nil 10384 994 #contextMenu: 50 1 10512 10384 994 #wordWrap: 8 #(true) 10384 994 #margins: 50 1 50 3 2118 3 #{UI.Scintilla.Margin} 1 10384 nil 3 nil nil 5 nil 13714 3 10384 nil nil nil 67108863 5 nil 13714 5 10384 nil nil nil nil 5 nil 10384 994 #sciSetHScrollBar: 8 #(false) 10384 994 #maxCompletionListHeight: 8 #(9) 10384 994 #sciSetTechnology: 8 #(1) 10384 994 #sciSetFontQuality: 8 #(3) 10384 994 #sciSetSelectionLayer: 8 #(1) 10384 3 8 #() 1154 193 193 nil 45 10274 10320 21 10336 -91 10352 21 10368 -19 258 3136 50 4 9872 8 'scriptNames' 10384 8 'scriptText' nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 9776 8 '' 9744 1 50 2 10384 9872 1154 193 193 nil 27 3442 4722 8 'Prerequisites' nil nil 18 #{UI.ReferenceView} 50 14 nil 3600 50 2 8 1140850688 131073 14256 nil nil nil 5 nil nil nil 14256 1266 #{Tools.PackageDependencyPresenter} #resource_Default_view nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 14288 8 '' 14256 1 384 1154 193 193 nil 27 3442 4722 8 'Dependents' nil nil 18 #{UI.ReferenceView} 50 14 nil 3600 50 2 8 1140850688 131073 14528 nil nil nil 5 nil nil nil 14528 1266 #{Tools.PackageDependencyPresenter} #resource_Default_view nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 14560 8 '' 14528 1 384 1154 193 193 nil 27 3442 4722 8 'Comment' nil nil 18 #{UI.Scintilla.ScintillaView} 50 56 nil 3600 50 2 8 1176572228 1 14800 10450 nil false 10496 nil 98 #commentWorkspace nil 5 3666 nil true 50 12 3746 1 450 #accept 8 '&Accept' 1 1 nil nil nil 5170 4097 3666 nil true 50 10 3746 1 450 #undo 8 '&Undo' 1 1 498 nil true 530 8 'EditUndo.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #cutSelection 8 'Cu&t' 1 1 498 nil true 530 8 'EditCut.ico' 592 65541 nil nil nil 3746 1 450 #copySelection 8 '&Copy' 1 1 498 nil true 530 8 'EditCopy.ico' 592 65541 nil nil nil 3746 1 450 #pasteClipboard 8 '&Paste' 1 1 498 nil true 530 8 'EditPaste.ico' 592 65541 nil nil nil 3746 1 450 #clearSelection 8 'De&lete' 1 1 498 nil true 530 8 'EditClear.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #clear 8 'Clea&r' 1 1 498 nil true 530 8 'ClearDocument.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #selectAll 8 '&Select All' 1 1 nil nil nil 8 '&Edit' nil 134217729 nil nil nil nil nil 5170 4097 3746 1 450 #browseIt 8 'Bro&wse It' 1 1 12080 nil nil 3746 1 450 #displayIt 8 '&Display It' 1 1 498 nil true 530 8 'DisplayIt.ico' 592 65541 nil nil nil 3746 1 450 #printIt 12256 1 1 12272 nil nil 3746 1 450 #evaluateIt 8 'E&valuate It' 1 1 498 nil true 530 8 'EvaluateIt.ico' 592 65541 nil nil nil 3746 1 450 #inspectIt 8 '&Inspect It' 1 1 12464 nil nil 3746 1 450 #debugIt 12544 1 1 12560 nil nil 5170 4097 3666 nil true 50 2 3746 2097153 450 #browseDefinitions 8 'Defi&nitions…' 1 1 nil nil nil 3746 1 450 #browseReferences 8 '&References…' 1 1 nil nil nil 8 '&Browse' nil 134217729 nil nil nil nil nil 8 '&Workspace' nil 134217729 nil nil nil nil nil nil nil 14800 226 #seaGreen nil 12834 nil nil 9 #focusLost nil nil nil nil 3138 25 #blockQuote 12882 31 326 1 #{Graphics.RGB} 17825793 nil 1 nil nil nil nil #blockQuote nil nil nil #callTip 12882 77 12912 12928 1 nil nil nil nil #callTip nil nil nil #code 12882 39 16322 17825793 16322 31317469 1 nil nil nil nil #code nil nil nil #code2 12882 41 16322 17825793 16322 31317469 1 nil nil nil nil #code2 nil nil nil #codeBlock 12882 43 16322 17825793 16322 31317469 1 nil nil nil nil #codeBlock nil nil nil #em1 12882 9 16322 26317 nil 9 nil nil nil nil #em1 nil nil nil #em2 12882 11 16322 26317 nil 9 nil nil nil nil #em2 nil nil nil #header1 12882 13 16322 6887587 nil 1 nil nil nil nil #header1 nil 1401 nil #header2 12882 15 16322 6887587 nil 1 nil nil nil nil #header2 nil 1401 nil #header3 12882 17 16322 6887587 nil 1 nil nil nil nil #header3 nil 1401 nil #header4 12882 19 16322 6887587 nil 1 nil nil nil nil #header4 nil 1401 nil #header5 12882 21 16322 6887587 nil 1 nil nil nil nil #header5 nil 1401 nil #header6 12882 23 16322 6887587 nil 1 nil nil nil nil #header6 nil 1401 nil #horizontalRule 12882 35 16322 11184811 nil 1 nil nil nil nil #horizontalRule nil 1401 nil #indentGuide 12882 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #lineBegin 12882 3 nil nil 1 nil nil nil nil #lineBegin nil nil nil #lineNumber 12882 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #link 12882 37 16322 22282241 nil 33 nil nil nil nil #link nil nil nil #normal 12882 1 nil 226 #window 1 nil nil nil nil #normal nil nil nil #olistItem 12882 29 16322 11184811 nil 1 nil nil nil nil #olistItem nil nil nil #preChar 12882 25 226 #black 16322 22404573 1 nil nil nil nil #preChar nil 1401 nil #strikeOut 12882 33 16322 7768625 16322 20673875 1 nil nil nil nil #strikeOut nil nil nil #strong1 12882 5 16322 13404229 nil 1 nil nil nil nil #strong1 nil 1401 nil #strong2 12882 7 16322 13404229 nil 1 nil nil nil nil #strong2 nil 1401 nil #ulistItem 12882 27 16322 11184811 nil 1 nil nil nil nil #ulistItem nil nil nil nil 326 1 #{UI.Scintilla.NullStyler} #normal 3138 1 #default 13026 1 nil nil nil 14800 #circle nil nil nil nil nil nil 13058 0 nil 3106 0 nil nil nil 3106 1 81 13120 nil nil 13152 nil 65 nil nil nil nil 3 3138 2 #container 3138 2 #callTip 12882 77 12912 12928 1 nil nil nil nil #callTip nil nil nil #normal 12882 1 nil nil 1 nil nil nil nil #normal nil nil nil #markdown 16288 nil nil nil nil #{Core.Utf8String} nil 3138 2 #Error 13266 17 14800 13296 3 3 #Error nil nil nil nil nil nil #Warning 13266 19 14800 13328 3 3 #Warning nil nil nil nil nil nil nil nil 3138 3 #Error 12882 1031 13376 13392 1 nil nil nil nil #Error nil nil nil #Notification 12882 1029 nil 13424 1 nil nil nil nil #Notification nil nil nil #Warning 12882 1027 13456 13472 1 nil nil nil nil #Warning nil nil nil nil nil nil 946 50 9 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 14832 nil 14800 994 #contextMenu: 50 1 14896 14800 994 #wordWrap: 8 #(true) 14800 994 #margins: 50 1 50 3 13714 1 14800 nil 3 nil nil 5 nil 13714 3 14800 nil nil nil 67108863 5 nil 13714 5 14800 nil nil nil nil 5 nil 14800 994 #maxCompletionListHeight: 8 #(9) 14800 994 #setLexerLanguage: 8 #(#markdown) 14800 994 #sciSetTechnology: 8 #(1) 14800 994 #sciSetFontQuality: 8 #(3) 14800 994 #sciSetSelectionLayer: 8 #(1) 14800 3 8 #() 1154 193 193 nil 45 3442 4722 8 'Variables' nil nil 18 #{UI.ListView} 50 45 nil 3600 50 2 8 1140920393 1 17936 4866 4674 0 nil 4928 240 nil 29 3666 nil true 50 6 3746 1 450 #addSharedVariable 8 '&Add Uncommitted…' 1 1 nil nil nil 3746 1 450 #removeVariables 8 '&Remove from Package' 1 1 nil nil nil 5170 4097 3746 2097153 450 #inspectSharedVariables 8 '&Inspect' 1 1 498 nil true 530 8 'BasicInspector.ico' 592 65541 nil nil nil 3746 1 450 #browseVariableReferences 8 'All Re&ferences' 1 1 nil nil nil 3746 1 450 #browseLocalGlobalReferences 8 '&Local References' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 17936 nil nil 2736 5698 0 nil 5730 4 1 5696 8 'doIt' 8 '[:x | x valueOrNil icon imageIndex]' 8 #[32 105 226 0 159 160 106] #valueOrNil #icon #imageIndex 18384 7 257 nil 5680 nil nil nil 1154 65 65 nil nil 4674 5 5842 8 '' 41 #left 5698 0 nil 5730 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:x | x ifTrue: [''Changed''] ifFalse: ['''']]' 8 #[31 105 17 119 29 106 30 106] 8 'Changed' 5984 18528 7 257 nil 5698 0 nil 5730 3 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:x :y | x & y not]' 8 #[31 105 233 1 158 177 106] #not #& 18624 7 513 nil 5698 0 nil 5730 6 1 5696 8 'doIt' 8 '[:x | [x asQualifiedReference value isChanged] on: Error do: [:y | false]]' 8 #[33 105 17 252 0 0 0 2 5 0 226 0 142 159 106 47 34 111 59 106 193 106] #asQualifiedReference #isChanged 6194 #Error #{Core.Error} #{Core} 1 #on:do: 18704 5698 0 nil 18720 39 257 nil 7 257 nil nil 17936 5698 0 nil 5730 5 1 5696 8 'doIt' 8 '[:x | x ifTrue: [Package changedIcon imageIndex]] ' 8 #[32 105 17 121 45 159 160 106 60 106] 6208 #changedIcon #imageIndex 18816 #ifTrue: 7 257 nil 1 nil nil 5842 8 'Name' 301 #left 2722 #unqualifiedName 8 #() 2722 #<= 8 #() nil nil 17936 5698 0 nil 5730 4 1 5696 8 'doIt' 8 '[:x | x valueOrNil icon imageIndex]' 8 #[32 105 226 0 159 160 106] #valueOrNil #icon #imageIndex 18992 7 257 nil 1 nil nil 5842 8 'Namespace' 301 #left 2722 #printString 8 #() 5698 0 nil 5730 4 1 2720 8 'doIt' 8 '[:a :b | a isNil or: [
	b notNil and: [a printString <= b printString]]]' 8 #[32 105 17 223 2 58 106 18 222 6 226 2 226 34 130 106 59 106] #or: #and: #printString 19136 7 513 nil 5698 0 nil 5730 4 1 5696 8 'doIt' 8 '[:each | each bindingOrNil ifNotNil: [:binding | binding environment]]' 8 #[32 105 226 0 100 222 2 70 159 106] #bindingOrNil #environment #ifNotNil: 19216 7 65793 nil nil 17936 nil 1 nil nil 5842 #Package 201 #left 2736 5698 0 nil 5730 2 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a :b | a name < b name]' 8 #[30 105 17 158 18 158 128 106] #name 19312 7 513 nil 5698 0 nil 5730 4 1 5696 8 'doIt' 8 '[:x | Package manager packageOfVariableNamed: x] ' 8 #[32 105 45 159 17 178 106] 6208 #manager #packageOfVariableNamed: 19392 7 257 nil nil 17936 nil 1 nil nil 5842 8 'File Out Name' 2001 #left 2736 2722 #<= 8 #() 5698 0 nil 5730 7 1 5696 8 'doIt' 8 '[:x | | glob |
glob := x valueOrNil.
(glob class conformsToProtocol: #sourceObject) ifTrue: [glob fileOutName] ifFalse: ['''']]' 8 #[35 105 226 0 70 144 30 178 120 226 35 106 34 106] #valueOrNil #sourceObject #conformsToProtocol: #fileOutName #ifTrue:ifFalse: 8 '' 19536 7 65793 nil nil 17936 nil 1 nil nil #report 6784 nil 133221 nil 1 nil nil nil nil 1 6802 17936 nil nil nil nil nil nil nil nil nil 946 50 2 994 #createWindow: 50 1 1042 1074 8 #[4 0 0 0 44 0 0 0 230 1 0 0 156 1 0 0] 193 17968 8 '' 17936 994 #contextMenu: 50 1 18032 17936 1 8 #() 1154 193 193 nil 35 14800 nil nil nil 258 3136 50 16 4800 8 'classes' 14800 8 'comment' 14528 8 'dependents' 7088 8 'methods' 14256 8 'prerequisites' 9088 8 'resources' 9744 8 'scripts' 17936 8 'variables' nil 18 #{UI.TabViewXP} 50 28 nil 3600 50 2 8 1140916736 1 20000 4866 4674 8 14768 4736 7040 9040 17904 9712 14224 14496 nil 4928 nil nil 1 nil nil nil 20000 nil nil 2736 2768 5680 nil nil nil nil nil #smallIcons nil nil nil nil nil 946 50 3 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 0 0 0 0 234 1 0 0 160 1 0 0] 193 20032 8 '' 20000 994 #setSingleSelection: 8 #(1) 20000 994 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 20000 3 8 #() 1154 193 193 nil 27 946 50 2 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 0 0 0 0 234 1 0 0 160 1 0 0] 193 3632 8 '' 3600 994 #contextMenu: 50 1 3680 3600 3 50 9 14800 4800 7088 9088 17936 9744 14256 14528 20000 1154 193 193 nil 27 5 false 258 3136 50 2 3600 8 'ownedCards' nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[249 0 0 0 0 0 0 0 227 2 0 0 160 1 0 0] 193 3504 8 '' 3472 3 50 1 3600 1154 193 193 nil 27 5 false 258 3136 50 2 18 #{UI.ReferenceView} 50 14 nil 3312 50 2 8 1140850688 131073 20752 nil nil nil 5 nil nil nil 20752 1266 #{Tools.PackageSelector} #resource_Default_view nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 0 0 0 0 244 0 0 0 160 1 0 0] 193 20784 8 '' 20752 3 384 1154 193 193 nil 27 8 'packages' nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[0 0 0 0 0 0 0 0 227 2 0 0 160 1 0 0] 193 3344 8 '' 3312 3 50 3 20752 18 #{UI.Splitter} 50 12 nil 3312 50 2 8 1140850688 1 21136 nil nil nil 517 nil nil nil 3142 1 #{UI.DraggableViewInteractor} 21136 nil 1 #left nil nil nil 1154 1 1 1154 9 9 nil 21232 nil 946 50 1 994 #createWindow: 50 1 1042 1074 8 #[244 0 0 0 0 0 0 0 249 0 0 0 160 1 0 0] 193 21168 8 '' 21136 3 8 #() 1154 193 193 nil 27 3472 1154 193 193 nil 27 1154 193 193 nil 27 258 3136 50 4 2512 8 'statusbar' 160 8 'toolbar' nil 2886 4 #{UI.MenuBar} nil true 50 10 3666 nil true 50 24 3746 1 450 #newPackage 8 '&New Package…' 9373 5 498 nil true 530 8 'NewPackage.ico' 592 65541 nil nil nil 3746 1 450 #openPackage 8 '&Install Package…' 9375 5 498 nil true 530 8 'FileOpen.ico' 592 65541 nil nil nil 3746 1 450 #removePackage 8 '&Uninstall Package' 1 5 nil nil nil 5170 4097 3666 nil true 50 2 3746 2097153 450 #addClass 8 '&Class…' 1 1 498 nil true 530 8 'Behavior.ico' 592 65541 nil nil nil 3746 1 450 #addSharedVariable 8 '&Global…' 1 1 nil nil nil 8 'Add Unco&mmitted' nil 134217729 nil nil nil nil nil 3746 1 450 #chooseDefaultPackage 8 'Set as De&fault Package…' 1 1 nil nil nil 3746 1 450 #synchronizeFilter 8 '&Goto Folder' 1 1 498 nil true 530 8 'GotoFolder.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #savePackages 8 '&Save Package' 1 1 498 nil true 530 8 'FileSave.ico' 592 65541 nil nil nil 3746 1 450 #savePackageChanges 8 'Save Package C&hanges' 1 1 nil nil nil 3746 1 450 #savePackageAs 8 'Save Package &As…' 1 1 nil nil nil 5170 4097 3746 1 450 #toggleUsingPAX 8 'Use PAX S&ource Format' 1 1 nil nil nil 3746 1 450 #browsePackageSources 8 'Bro&wse PAX Sources' 1 1 498 nil true 530 8 'SourceBrowser.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #saveImage 8 'Sa&ve Image' 1 1 498 nil true 530 8 'Snapshot.ico' 592 65541 nil nil nil 3746 1 450 #smalltalkExit 8 'E&xit Dolphin' 1 1 498 nil true 530 8 'PowerSwitch.ico' 592 65541 nil nil nil 5170 4097 3666 nil true 50 1 3746 2097153 450 #browseTests 8 '&Browse' 1 1 nil nil nil 8 '&Tests' nil 1 498 nil true 1030 #{Graphics.ImageFromFileInitializer} 8 'TestRunner.ico' 6 #{Kernel.ImageRelativeFileLocator} 5 nil nil nil nil nil 3666 nil true 50 4 3746 2097153 450 #deploy 8 '&Deploy Executable…' 13445 1 nil nil nil 3746 1 450 #browseDeployed 8 'Bro&wse Executable Manifest' 1 1 498 nil true 530 8 'EnvironmentBrowserShell.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #saveBinaryPackage 8 'Deploy &Binary Package…' 1 1 nil nil nil 8 '&Deployment' nil 134217729 498 nil true 530 8 'ApplicationDeploymentWizard.ico' 592 65541 nil nil nil nil nil 5170 4097 3746 1 450 #inspectPackage 8 'P&roperties' 1 1 498 nil true 530 8 'BasicInspector.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #exit 8 '&Close' 17639 1 11810 8 $✖ nil nil nil nil nil 1 nil nil nil nil 8 '&File' nil 134217729 nil nil nil nil nil 3666 nil true 50 12 3746 1 450 #undo 8 '&Undo' 9397 1 498 nil true 530 8 'EditUndo.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #cutSelection 8 'Cu&t' 9393 1 498 nil true 530 8 'EditCut.ico' 592 65541 nil nil nil 3746 1 450 #copySelection 8 '&Copy' 9351 1 498 nil true 530 8 'EditCopy.ico' 592 65541 nil nil nil 3746 1 450 #pasteClipboard 8 '&Paste' 9389 1 498 nil true 530 8 'EditPaste.ico' 592 65541 nil nil nil 3746 1 450 #editDelete 8 '&Delete' 1 1 498 nil true 530 8 'EditClear.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #selectAll 8 'Select &All' 9347 1 nil nil nil 5170 4097 3746 1 450 #editFind 8 '&Find…' 9357 1 498 nil true 1030 #{Graphics.ImageFromResourceInitializer} 47 262 #{OS.ShellLibrary} 65541 nil nil nil 3746 1 450 #findNext 8 'Find &Next' 1253 1 498 nil true 530 8 'FindNext.ico' 592 65541 nil nil nil 3746 1 450 #findReplace 8 '&Replace…' 9361 1 nil nil nil 8 '&Edit' nil 134217729 nil nil nil nil nil 3666 nil true 50 14 3746 1 450 #browseIt 8 '&Browse It' 9349 1 498 nil true 530 8 'ClassBrowserShell.ico' 592 65541 nil nil nil 3746 1 450 #displayIt 8 '&Display It' 9353 1 498 nil true 530 8 'DisplayIt.ico' 592 65541 nil nil nil 3746 1 450 #printIt 8 '&Print It' 9377 1 498 nil true 530 8 'PrintIt.ico' 592 65541 nil nil nil 3746 1 450 #evaluateIt 8 '&Evaluate It' 9355 1 498 nil true 530 8 'EvaluateIt.ico' 592 65541 nil nil nil 3746 1 450 #inspectIt 8 '&Inspect It' 9363 1 498 nil true 530 8 'BasicInspector.ico' 592 65541 nil nil nil 3746 1 450 #debugIt 8 'Deb&ug It' 1269 1 498 nil true 530 8 'Debugger.ico' 592 65541 nil nil nil 3746 1 450 #fileItIn 8 '&File It In' 1 1 nil nil nil 5170 4097 3746 1 450 #browseDefinitions 8 'Defi&nitions…' 1271 1 nil nil nil 3746 1 450 #browseReferences 8 '&References…' 5367 1 nil nil nil 5170 4097 3746 1 450 #accept 8 '&Accept' 9383 1 nil nil nil 5170 4097 3666 nil true 50 7 3746 1 450 #toggleAutoCompletion 8 '&Auto-complete' 1 1 nil nil nil 3746 1 450 #toggleIndentationGuides 8 'Indentation &Guides' 1 1 nil nil nil 3746 1 450 #toggleLineEndings 8 'Line &Endings' 1 1 11810 $¶ 8 'Arial' nil nil nil nil 1 nil nil nil nil 3746 1 450 #toggleLineNumbers 8 'Line N&umbers' 1 1 nil nil nil 3746 1 450 #toggleStyling 8 '&Syntax Coloring' 1 1 nil nil nil 3746 1 450 #toggleWhitespace 8 'W&hitespace' 1 1 nil nil nil 3746 1 450 #toggleWordWrap 8 '&Word Wrap' 1 1 nil nil nil 8 '&Options' nil 134217729 498 nil true 530 8 'Preferences.ico' 592 65541 nil nil nil nil nil 8 '&Workspace' nil 134217729 nil nil nil nil nil 3666 nil true 50 4 3746 1 450 #browseLocalMessageDefinitions 8 '&Definitions Of…' 1 1 nil nil nil 3746 1 450 #browseLocalMessageReferences 8 '&References To…' 1 1 nil nil nil 5170 4097 3746 1 450 #browseUnimplemented 8 '&Unimplemented Messages' 1 1 nil nil nil 8 '&Browse' nil 134217729 nil nil nil nil nil 3666 nil true 50 10 3746 1 450 #toggleUsingPAX 8 'Use PAX S&ource Format' 1 1 nil nil nil 3746 2097153 450 #browsePackageSources 8 'Bro&wse PAX Sources' 1 1 498 nil true 530 8 'SourceBrowser.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #checkOut 8 'Check Out &All' 1 1 nil nil nil 3746 1 450 #checkOutChanges 8 '&Check Out Changes' 9367 1 nil nil nil 3746 1 450 #checkIn 8 'Check &In' 9387 1 nil nil nil 5170 4097 3746 1 450 #savePackageChanges 8 'Save C&hanges' 1 1 498 nil true 530 8 'FileSave.ico' 592 65541 nil nil nil 5170 4097 3746 1 450 #resetChangeFlags 8 'Clear Change &Markers' 1 1 nil nil nil 8 'Sou&rce Control' nil 134217729 nil nil nil nil nil 3666 nil true 50 10 3746 1 450 #renameMethod 8 'Re&name Method…' 1 1 498 nil true 530 5424 592 65541 nil nil nil 3746 1 450 #renameMethodReferences 8 'Rename Re&ferences…' 1 1 nil nil nil 5170 4097 3746 1 450 #removeMethod 8 'Re&move Method…' 1 1 498 nil true 530 8 'MethodDelete.ico' 592 65541 nil nil nil 3746 1 450 #removeDuplicateMethods 8 'Remove Dup&licate Methods' 1 1 nil nil nil 5170 4097 3746 1 450 #addParameter 8 'Add Method &Parameter…' 1 1 nil nil nil 3746 1 450 #removeParameter 8 'Remo&ve Method Parameter…' 1 1 nil nil nil 5170 4097 3746 1 450 #moveAllTempsToInnerScope 8 'Move All &Temps To Inner Scope…' 1 5 nil nil nil 8 'Refactorin&gs' #refactoringsMenu 134217729 nil nil nil nil nil 3666 nil true 50 3 3746 1 450 #undoChange 8 '&Undo <d>' 1 17 498 nil true 530 8 'EditUndo.ico' 592 65541 nil nil nil 3746 1 450 #redoChange 8 '&Redo <d>' 1 17 498 nil true 530 8 'EditRedo.ico' 592 65541 nil nil nil 3746 1 450 #clearChangeHistory 8 'Clear Change &History' 1 1 498 nil true 530 8 'MethodHistoryErase.ico' 592 65541 nil nil nil 8 'H&istory' nil 134217729 nil nil nil nil nil 3666 nil true 8 #() 8 '&Tools' #toolsMenu 134217729 nil nil nil nil nil 3666 nil true 8 #() 8 'Wi&ndow' #windowMenu 134217729 nil nil nil nil nil 3666 nil true 50 15 3746 1 450 #helpContents 8 '&Contents' 1025 1 498 nil true 530 8 'Help.ico' 592 65541 nil nil nil 3746 1 450 #help 8 'On this &Tool' 1249 1 nil nil nil 3746 1 450 #helpWhatsThis 8 'What''s This?' 5345 1 nil nil nil 5170 4097 3746 1 450 #learnSmalltalk 8 'Learn Smalltalk' 1 1 11810 8 $🎓 nil 226 #orchid 12928 nil nil 1 nil nil nil nil 5170 4097 3746 1 450 #helpWhatsNew 8 'What''s &New' 1 1 nil nil nil 3746 1 450 #helpGuidedTour 8 '&Guided Tour' 1 1 nil nil nil 3746 1 450 #helpTutorials 8 'Tutorials' 1 1 nil nil nil 5170 4097 3746 1 450 #dolphinHomePage 8 'Dolphin Homepage' 1 1 498 nil true 530 8 '!!APPLICATION' 592 65541 nil nil nil 3746 1 450 #dolphinNewsgroup 8 'Dolphin Newsgroup/Forum' 1 1 nil nil nil 3746 1 450 #dolphinWikiWeb 8 'Dolphin WikiWeb' 1 1 nil nil nil 5170 4097 3746 1 450 #aboutDolphin 8 '&About Dolphin Smalltalk' 1 1 11810 8 $🐬 nil nil 226 #darkSlateBlue nil nil 1 nil nil nil nil 8 '&Help' #help 134217729 nil nil nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil 1154 771 621 nil nil 193 946 50 1 994 #createWindow: 50 1 1042 518 #{Graphics.Rectangle} 1154 7679 21 1154 9189 1061 193 80 8 'Package Browser' 32 1 50 3 160 3008 2512 1154 193 193 nil 27)!

toolsFolderHelpId
	^10598!

wordWrapComment
	"Answer true if instances of the receiver use comment word wrapping."

	^WordWrapComment!

wordWrapComment: aBoolean
	"Sets the comment word wrapping state for instances of the receiver to aBoolean."

	WordWrapComment == aBoolean ifTrue: [^self].
	WordWrapComment := aBoolean.
	self persistOptions! !

!Tools.PackageBrowserShell class categoriesForMethods!
defaultOptionFlags!constants!options!private! !
displayOn:!displaying!public! !
icon!constants!public! !
initialize!initializing!private! !
publishedAspects!public! !
resource_Default_view!public!resources-views! !
toolsFolderHelpId!public! !
wordWrapComment!accessing!options!public! !
wordWrapComment:!accessing!options!public! !
!

