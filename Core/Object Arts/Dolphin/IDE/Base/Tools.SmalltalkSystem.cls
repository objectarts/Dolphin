"Filed out from Dolphin Smalltalk"!

Core.Model
	subclass: #'Tools.SmalltalkSystem'
	instanceVariableNames: 'systemFolderClass workspaceClass defaultInspectorClass defaultBrowserClass systemFolder packageBrowserClass debuggerClass viewComposerClass protocolBrowserClass workspaceShellClass resourceBrowserClass changedIcon hierarchyBrowserClass preferAlternateInspectors formatterClass classChooserClass resourceIdentifierDialogClass findDetails methodWorkspaceClass allSelectors argumentClasses methodExplorerClass aboutBoxClass testBrowserClass toolbarBitmapSize displayItLocale'
	classVariableNames: 'ChangedIcon Current RegisteredTools'
	imports: #(#{Kernel.CompilerFlags} #{Refactory.Browser} #{Kernel.ParseErrorCodes} #{XProgramming.SUnit private})
	classInstanceVariableNames: ''
	classConstants: {
			'FileDrops'
				-> (LookupTable withAll: {
								'chg' -> #dropScriptFile:.
								'cls' -> #dropClassFile:.
								'pac' -> #dropPackageFile:.
								'pax' -> #dropPackageFile:.
								'sml' -> #dropScriptFile:.
								'st' -> #dropScriptFile:.
								'txt' -> #dropTextFile:.
								'xml' -> #dropXmlFile:
							})
		}!

Tools.SmalltalkSystem guid: (Core.GUID fromString: '{87b4c66c-026e-11d3-9fd7-00a0cc3e4a32}')!

Tools.SmalltalkSystem comment: 'SmalltalkSystem is a Facade onto the Dolphin Smalltalk development environment. Most of the development tools hold the Singleton instance of SmalltalkSystem as their model and use it to act as a go-between between programmer, user interface, and the development image.

Instance Variables:
	classHierarchyModel		<ClassHierarchyModel> representing the hierarchy of classes in the system.
	unused			<UndefinedObject> reserved for future use.
	isOAD			<boolean> indicating whether the system is configured for Object Arts development use.
	systemFolder		<treeModel> holding the contents of the System Folder.

Class Variables:
	RegisteredTools		<Set>
	Current			<SmalltalkSystem>

'!

!Tools.SmalltalkSystem categoriesForClass!MVP-Models!System-Support! !

!Tools.SmalltalkSystem methodsFor!

aboutBoxClass
	"Private - Answer the class of about box to display on request."

	^aboutBoxClass
!

aboutBoxClass: aSplash 
	"Set the class of about box to display on request."

	aboutBoxClass := aSplash!

aboutDolphin
	"Show the About box, or if the display is not capable a simple MessageBox with pertinent details."

	| splashClass |
	splashClass := self aboutBoxClass.
	(splashClass notNil and: [splashClass canDisplay])
		ifTrue: [splashClass new show]
		ifFalse: 
			[| msg version |
			version := VM versionInfo.
			msg := 'Dolphin Smalltalk - <1s><n><n><2s>' expandMacrosWith: self sessionManager versionString
						with: version legalCopyright.
			MessageBox new
				caption: 'About Dolphin Smalltalk…';
				icon: self sessionManager icon;
				text: msg;
				open]!

actualFont
	"Answer the default font to use for the development system tools"

	^View desktop actualFont!

add: selectors toProtocolWarning: targetProtocol
	"Private - Warn about the generation of stub methods if a protocol is being extended
	and doing so would require new stubs."

	"First determine if any warning is necessary"

	| msg newSelectors stubs mb |
	newSelectors := selectors difference: targetProtocol selectors.
	newSelectors isEmpty
		ifTrue: 
			["No change in protocol"
			^true].
	stubs := (targetProtocol baseBehaviors
				collect: [:c | c -> (newSelectors reject: [:s | c canUnderstand: s])])
					select: [:a | a value notEmpty].
	stubs isEmpty
		ifTrue: 
			["All classes still conform"
			^true].
	msg := String writeStream.
	msg
		nextPutAll: 'Please be aware that extending the protocol ';
		display: targetProtocol;
		nextPutAll: ' to include:';
		crtab.
	newSelectors do: [:s | msg print: s] separatedBy: [msg space].
	msg
		cr;
		cr;
		nextPutAll: 'will cause the following stub methods to be automatically generated:';
		crtab.
	stubs do: 
			[:a |
			msg
				nextPutAll: a key name;
				space;
				nextPut: $(.
			a value do: [:s | msg print: s] separatedBy: [msg space].
			msg
				nextPut: $);
				crtab].
	msg
		cr;
		nextPutAll: 'These stub methods can be subsequently be located by browsing the ';
		cr;
		nextPutAll: '''not yet implemented'' category.';
		cr;
		cr;
		nextPutAll: 'Are you sure that you would like to proceed?'.
	mb := MessageBox new.
	mb
		buttonStyle: #yesNo;
		defaultButton: 2;
		caption: ('Extend protocol <1d>' expandMacrosWith: targetProtocol).
	^(mb warning: msg contents) == #yes!

addAdditionalToolsFolderIcon: aSmalltalkSystemIcon
	"Adds aSmalltalkSystemFolderIcon to the Additional Tools system folder.
	Note that an attempt is made to first remove any equivalent (same named) icons from 
	the entire sytem folder hierarchy. Answers aSmalltalkSystemIcon."

	^self addSystemFolderIcon: aSmalltalkSystemIcon to: self additionalToolsFolder

!

addAdditionalToolsFolderIconFor: anInstallableSystemTool description: titleString
	"Add a <SmalltalkSystemIcon> to the Additional Tools system folder for the
	specified <installableSystemTool> and with the <readableString> description, titleString."

	^self addAdditionalToolsFolderIcon: (SmalltalkSystemIcon show: anInstallableSystemTool
				description: titleString)!

addClass: class toProtocol: newProtocol
	"Private - Add the <MethodProtocol>, newProtocol, to the <ClassDescription>, class, if
	either the class already implements all of the methods, or alternatively if the user 
	agrees to the generation of stub methods. Answer whether the protocol was actually	
	added."

	"Determine if the class includes the protocol already - if it does, then early out"

	| missing |
	(class conformsToProtocol: newProtocol) ifTrue: [^false].
	missing := newProtocol selectors reject: [:s | class canUnderstand: s].
	missing notEmpty
		ifTrue: 
			[| stm args |
			stm := String smalltalkWriteStream: 256.
			stm
				print: class;
				nextPutAll: ' is missing implementations of the following sectors of ';
				display: newProtocol;
				nextPut: $:;
				cr.
			missing do: 
					[:m |
					stm
						cr;
						nextPutAll: '    ';
						display: m].
			args := {class. newProtocol. missing size. missing size > 1}.
			(MessageBox new
				headline: 'Extend <1p> to implement protocol <2d>?' << args;
				detailsText: stm contents;
				footerText: 'Stub methods must be generated for <3p> unimplemented selector<4?s:>.' << args;
				footerIcon: Icon warning;
				customButtons: #(#(#yes '&Extend') #(#no 'Cancel'));
				isCancellable: true;
				confirm) ifFalse: [^false]].
	newProtocol addClass: class.
	self classChanged: class.
	^true!

addGlobalName: aSymbol
	"Adds a global called aSymbol to the system dictionary"

	aSymbol asQualifiedReference declare!

additionalToolsFolder
	"Private - Answer the <SmalltalkSystemFolder> that holds the addtional tools hierarchy. This is can
	be used by 3rd party tools to install themselves into the system folder"

	^self systemFolderNamed: 'Additional Tools'!

addMethod: method toProtocol: target
	"Add the <CompiledMethod>, method, to the <MethodProtocol> target"

	(self add: {method selector} toProtocolWarning: target)
		ifTrue: [target addSelector: method selector]!

addProtocolSelectors: source toProtocol: target
	"Private - Add the all of the selectors from <MethodProtocol> source to the target <MethodProtocol>."

	self addSelectors: source selectors toProtocol: target
!

addSamplesFolderIcon: aSmalltalkSystemIcon
	"Adds aSmalltalkSystemFolderIcon to the Sample Applications system folder.
	Note that an attempt is made to first remove any equivalent (same named) icons from 
	the entire sytem folder hierarchy. Answers aSmalltalkSystemIcon."

	^self addSystemFolderIcon: aSmalltalkSystemIcon to: self samplesFolder!

addSamplesFolderIconFor: anInstallableSystemTool description: titleString
	"Add a <SmalltalkSystemIcon> to the Sample Applications system folder for the
	specified <installableSystemTool> and with the <readableString> description, titleString."

	^self
		addSamplesFolderIcon: (SmalltalkSystemIcon show: anInstallableSystemTool description: titleString)!

addSamplesFolderIconFor: anInstallableSystemTool description: titleString helpId: helpId
	"Add a <SmalltalkSystemIcon> to the Sample Applications system folder for the
	specified <installableSystemTool> and with the <readableString> description, titleString and
	context help identifier, helpId."

	^self addSamplesFolderIcon: (SmalltalkSystemIcon
				show: anInstallableSystemTool
				description: titleString
				helpId: helpId)!

addSamplesFolderIconFor: anInstallableSystemTool helpId: helpId
	"Add a <SmalltalkSystemIcon> to the Sample Applications system folder for the
	specified <installableSystemTool> and with the <readableString> description, titleString and
	context help identifier, helpId."

	^self
		addSamplesFolderIconFor: anInstallableSystemTool
		description: anInstallableSystemTool displayString
		helpId: helpId!

addSelectors: sels toProtocol: protocol 
	"Add the <collection> of selectors, sels, to the <MethodProtocol>, protocol.
	Bring up a warning indicating the ramifications of such a global action."

	sels notEmpty 
		ifTrue: 
			[(self add: sels toProtocolWarning: protocol) 
				ifTrue: [sels do: [:s | protocol addSelector: s]]]!

addSystemFolderIcon: aSmalltalkSystemIcon
	"Adds aSmalltalkSystemFolderIcon to the root system folder.
	Note that an attempt is made to first remove any equivalent (same named) icons from 
	the entire sytem folder hierarchy. Answers aSmalltalkSystemIcon."

	^self addSystemFolderIcon: aSmalltalkSystemIcon to: nil

!

addSystemFolderIcon: aSmalltalkSystemIcon to: aSmalltalkSystemFolderOrNil 
	"Adds aSmalltalkSystemFolderIcon to the system folder identified by aSmalltalkSystemFolderOrNil.
	If the latter is nil then the icon is added to the root folder. Note that an attempt is made to first remove
	any equivalent (same named) icons from the entire sytem folder hierarchy. Answers
	aSmalltalkSystemIcon."

	self removeSystemFolderIconNamed: aSmalltalkSystemIcon description.
	self systemFolder add: aSmalltalkSystemIcon asChildOf: aSmalltalkSystemFolderOrNil.
	^aSmalltalkSystemIcon!

allResourceIdentifiers
	^ResourceIdentifier allResourceIdentifiers!

allSelectors
	allSelectors isNil ifTrue: [allSelectors := self buildAllSelectors].
	^allSelectors!

allSelectorsImplementedIn: aBrowserEnvironment
	"Answer an <IdentitySet> of all the <Symbol>s which currently have at least one implementation in the scope of the <BrowserEnvironment> argument."

	^aBrowserEnvironment allSelectorsImplemented!

allSelectorsSentIn: aBrowserEnvironment
	"Answer a <Set> of all the <Symbol>s which are directly sent by methods in the specified <BrowserEnvironment>.
	N.B. This may take some time (depending on the BrowserEnvironment used), and will not contain any selectors 
	which are only sent dynamically with #perform(etc).
		SmalltalkSystem current allSelectorsSentIn: (PackageEnvironment onEnvironment: BrowserEnvironment new packageNames: #('ActiveX Automation'))
	"

	^aBrowserEnvironment allSelectorsSent!

allSymbolsReferencedIn: aBrowserEnvironment
	"Answer a <Set> of all the <Symbol>s which might be selectors which are referenced from
	methods in the image. N.B. This might take some time to execute, and may contain some
	symbols which are not actually selectors. "

	"
		SmalltalkSystem current allSymbolsReferencedIn:BrowserEnvironment new
	"

	| symbols |
	symbols := (IdentitySet new: 10000)
				addAll: VM specialSelectors;
				yourself.
	aBrowserEnvironment methodsDo: 
			[:eachMethod |
			"Deliberately exclude any #defineFields methods of classes"
			(eachMethod selector == #defineFields and: [eachMethod methodClass class isMeta])
				ifFalse: 
					[eachMethod literalsDo: 
							[:eachLiteral |
							eachLiteral class == Symbol
								ifTrue: [symbols add: eachLiteral]
								ifFalse: 
									["Probe 1-level deep into literal arrays"
									eachLiteral class == Array
										ifTrue: 
											[eachLiteral do: [:eachElement | eachElement class == Symbol ifTrue: [symbols add: eachElement]]]]]]].
	"Now remove any event names"
	aBrowserEnvironment classesDo: 
			[:eachClass |
			#(#publishedEvents #publishedEventsOfInstances) do: 
					[:selector |
					(eachClass includesSelector: selector)
						ifTrue: 
							[(eachClass compiledMethodAt: selector)
								literalsDo: [:eachLiteral | symbols remove: eachLiteral ifAbsent: nil]]]].

	"Remove all global names"
	self environment keysDo: [:k | symbols remove: k ifAbsent: nil].
	^symbols!

allUnimplementedSelectors
	"Answer a <Set> of all the <Symbol>s which are selectors which are referenced from methods
	in the image but which have no corresponding implementation. N.B. This may not include any
	messages sent dynamically with #perform: and friends, and so should not be considered a
	guarantee that no send will ever result in a DNU (which, of course, cannot be guaranteed
	anyway because there is no way of knowing that the object to which the message is sent
	actually implements that message)."

	"
		SmalltalkSystem current allUnimplementedSelectors asSortedCollection asArray
			do: [:m | SmalltalkSystem current browseReferencesTo: m]
	"

	^self unimplementedSelectorsIn: self browserEnvironment!

applyOptionsToTool: aSmalltalkToolShell
	aSmalltalkToolShell view managedSubViews
		do: [:each | (each isKindOf: Toolbar) ifTrue: [each imageSize: self toolbarImageSize]]!

applyPublishedAspectsLiteralMap: aLookupTable to: aTool
	"Private - Applies the literal publishes aspect values held in aLookupTable to aTool"

	aLookupTable keysAndValuesDo: 
			[:eachAspect :eachLiteralValueArray |
			(aTool aspectValue: eachAspect) value: (Object fromLiteralStoreArray: eachLiteralValueArray)]!

argumentClasses
	^argumentClasses!

argumentClasses: anObject
	argumentClasses := anObject!

autoFormatMethodSource
	^MethodBrowser autoFormat!

autoFormatMethodSource: aBoolean
	MethodBrowser autoFormat: aBoolean!

availableNamespaces
	"Answers a <sequencedReadableCollection> of all available pools in ascending name order.
		SmalltalkSystem current availablePools
	The system pools (identified by a name that starts with an underscore) are specifically excluded."

	^(Namespace allSubclasses reject: [:each | each isVisiblyAbstract or: [each name first == $_]])
		asSortedArray!

backupOnImageSave
	"Answer whether the image should be backed up (i.e. the old .img file is renamed to .bak when the new .img
	file is successfully written). Note that this will slow down the operation quite a bit, as the OS has to do a lot
	more juggling."

	^self sessionManager backupOnImageSave!

backupOnImageSave: aBoolean 
	self sessionManager backupOnImageSave: aBoolean!

basicCreateSubclass: aClassDetails subclasses: aCollection
	"Private - Create a subclass a subclass with the specified details and subclasses. Answer the new class.
	Note that the operation is undoable."

	| addClass |
	aCollection notEmpty
		ifTrue: 
			[^self
				error: 'Unable to reparent subclasses in this version of the system (requires Dolphin Professional)'].
	addClass := AddClassChange details: aClassDetails.
	self changeManager performChange: addClass.
	^addClass classReference valueOrNil!

basicRemoveMethods: aCollection
	| changes |
	changes := CompositeRefactoryChange
				named: ('Remove <1p> Methods' expandMacrosWith: aCollection size).
	aCollection do: [:each | self removeMethod: each changes: changes].
	self changeManager
		performChange: (aCollection size = 1 ifTrue: [changes changes first] ifFalse: [changes])!

basicRemoveMethods: aCollection within: aBrowserEnvironment showChanges: aBoolean
	self basicRemoveMethods: aCollection!

basicRemoveMethodsIn: aBrowserEnvironment within: searchEnvironment showChanges: aBoolean
	self
		basicRemoveMethods: aBrowserEnvironment allMethods
		within: searchEnvironment
		showChanges: aBoolean!

beginDrag: aDragDropSession methods: aCollection
	| ddObjects stream chunks |
	ddObjects := OrderedCollection new.
	aCollection do: 
			[:each |
			ddObjects add: ((aDragDropSession newDragObject: each)
						format: #CompiledMethod data: each;
						yourself)].
	stream := String writeStream.
	(ChunkSourceFiler on: stream) fileOutMethods: aCollection.
	chunks := stream contents.
	ddObjects add: ((aDragDropSession newDragObject: chunks)
				format: #Chunk data: chunks;
				yourself).
	aDragDropSession
		dragObjects: ddObjects;
		supportedOperations: #(#move #copy);
		defaultOperation: #copy!

beNotChanged
	"Private - Reset all of the changed flags for the entire system"

	Class allClasses do: [:c | c isChanged: false].
	self packageManager packages do: [:p | p isChanged: false]!

binaryClassFilesType
	"Private - Answer a two element array suitable for adding to the FileDialog
	with the fileTypes: message."

	^#('Binary Class Files (*.stc)' '*.stc')!

browseAllChangedMethods
	"Open a method browser on all methods in the system which have been changed (i.e. which
	have source in the change log and are in classes marked as changed)."

	self browseMethodsIn: (self changedMethodsIn: self browserEnvironment)!

browseAllUnimplementedSelectors
	"
		Smalltalk developmentSystem browseAllUnimplementedSelectors
	"

	| env |
	env := self browserEnvironment.
	self
		browseSelectors: env unimplementedSelectors asSortedCollection
		caption: 'Unimplemented Selectors'
		environment: env!

browseChangedMethodsOf: aClass
	"Open a method browser on methods in aClass which have been changed (i.e. which
	have source in the change log and are in classes marked as changed)."

	self browseChangedMethodsOfClasses: {aClass}!

browseChangedMethodsOfClasses: aCollection 
	"Open a method browser on methods that belong to the <collection> of <Class>, classes,
	and which have been changed (i.e. which have source in the change log and are in classes marked 
	as changed)."

	self browseMethodsIn: (self changedMethodsOfClasses: aCollection)!

browseClass
	"Opens a new default browser on Object"

	^self browseClass: Object!

browseClass: aClass 
	"Opens a new default browser on aClass"

	^self browseClass: aClass with: self defaultBrowserClass!

browseClass: aClass with: aBrowserClass 
	"Opens a new browser of aBrowserClass on aClass"

	^(aBrowserClass show)
		actualClass: aClass;
		setInitialFocus;
		yourself!

browseClassHierarchyOfMethod: aCompiledMethod 
	"Open a new hierarchy browser on the <CompiledMethod> argument."

	^self browseMethod: aCompiledMethod with: self hierarchyBrowserClass!

browseClassReferences: aClass 
	"Opens a new MethodBrowser on all the methods which refer to the <Class>, aClass."

	self browseClassReferences: aClass in: self browserEnvironment!

browseClassReferences: aClass in: aBrowserEnvironment
	"Opens a new MethodBrowser on all the methods defined in the specified <BrowserEnvironment>
	which refer to the <Class>, aClass."

	self browseMethodsInEnvironments: (self referencesToClass: aClass in: aBrowserEnvironment)!

browseClassVariables: aClass
	"Opens a selection dialog to choose one of the class variables of browseClass to browse.
	Then a MethodBrowser is opened on all methods that refer to the chosen variable."

	| aVariable classVars |
	classVars := OrderedCollection new.
	aClass withAllSuperclassesDo: 
			[:each |
			each classBindingNames asSortedArray reverseDo: [:eachName | classVars addFirst: eachName]].
	aVariable := ChoicePrompter choices: classVars caption: 'Class Variables'.
	aVariable notNil
		ifTrue: 
			[self
				browseReferencesToClassVar: aVariable
				of: aClass
				within: self browserEnvironment]!

browseCompilationFailures
	"Open a method browser on all methods in the system which have failed compilation (i.e. which
	are instances of CompileFailedMethod)."

	self browseCompilationFailuresIn: self browserEnvironment!

browseCompilationFailuresIn: aBrowserEnvironment 
	"Open a method browser on all methods defined in the specified <BrowserEnvironment> which
	have failed compilation (i.e. which are instances of CompileFailedMethod)."

	(self methodsThatFailedToCompileIn: aBrowserEnvironment) 
		ifNotNil: [:failed | self browseMethodsIn: failed]!

browseCompilationIssues
	"Open a method browser on all methods in the system which have compilation issues of any
	sort as detected by either the smalltalk parser of semantic analyser."

	self browseCompilationIssuesIn: self browserEnvironment!

browseCompilationIssuesIn: aBrowserEnvironment 
	"Open a method browser on all methods defined in the specified <BrowserEnvironment> which
	have compilation issues, as detected by either the smalltalk parser or semantic analyser.
	This will include syntactic errors and semantic warnings."

	(self methodsWithCompilationIssuesIn: aBrowserEnvironment) 
		ifNotNil: [:issues | self browseMethodsIn: issues]!

browseContainingText
	"Prompt for a search string, using contents of the clipboard as the initial suggestion, and open 
	a Method Browser on all the methods that contain that search string in their source."

	self browseContainingTextIn: self browserEnvironment!

browseContainingText: aString 
	"Open a Method Browser on all the methods that contain the search string, aString, in their
	source."

	self 
		browseContainingText: aString
		in: self browserEnvironment
		prompt: false!

browseContainingText: aString in: aBrowserEnvironment prompt: aBoolean 
	"Private-"

	(self 
		methodsContainingText: aString
		in: aBrowserEnvironment
		prompt: aBoolean) ifNotNil: [:env | self browseMethodsIn: env]!

browseContainingTextIn: aBrowserEnvironment 
	"Prompt for a search string, using contents of the clipboard as the initial suggestion, and
	open a Method Browser on all the methods defined in the specified <BrowserEnvironment> that
	contain that search string in their source."

	self 
		browseContainingText: ''
		in: aBrowserEnvironment
		prompt: true!

browseDefinitionsMatching: aMethodSearch in: aBrowserEnvironment
	"Private - Open a MethodBrowser on all the methods whose selectors are matched by the <MethodSearch>
	argument in the specified <readableString> pattern in the scope of the specified
	<BrowserEnvironment>."

	self browseMethodsIn: (aMethodSearch definitionsIn: aBrowserEnvironment)!

browseDefinitionsMatching: aMethodSearch inHierarchyOf: aBehavior within: aBrowserEnvironment 
	"Private - Open a MethodBrowser on all the methods whos' selectors match the <MethodSearch>
	argument in the class hierarchy of the <Behavior> argument that are visible in the scope of
	specified <BrowserEnvironment>."

	self browseMethodsIn: (self 
				definitionsMatching: aMethodSearch
				inHierarchyOf: aBehavior
				within: aBrowserEnvironment)!

browseDefinitionsOf: selectorPattern
	"Opens a MethodBrowser on all the methods whose selectors match the specified
	<readableString> pattern."

	self browseDefinitionsMatching: (MethodSearch newPattern: selectorPattern)
		in: self browserEnvironment!

browseDefinitionsOfSelector: aSymbol in: aBrowserEnvironment
	"Opens a MethodBrowser on all the methods whose selectors match the specified
	<readableString> pattern in the scope of the specified <BrowserEnvironment>."

	self browseDefinitionsMatching: (MethodSearch newSelector: aSymbol) in: aBrowserEnvironment!

browseEnvironment: aBrowserEnvironment 
	"Open a browser on the content of the specified <BrowserEnvironment>."

	^self browseMethodsIn: aBrowserEnvironment!

browseFolder: aString
	OS.Shell32 shellOpen: aString!

browseHierarchy
	"Open a new hierarchy browser at the root of the standard class hierarchy."

	^self browseHierarchy: Object!

browseHierarchy: aClass
	"Open a new hierarchy browser on aClass"

	^self browseClass: aClass with: self hierarchyBrowserClass!

browseInstanceVariables: browseClass 
	"Prompt the user to choose one of the instance variables of the <Class>, aClass. Then open a
	method browser all methods that refer to the chosen variable."

	self 
		browseInstanceVariables: browseClass
		action: #browseReferencesToInstVar:inHierarchyOf:within:
		in: self browserEnvironment!

browseInstanceVariables: browseClass action: selector in: aBrowserEnvironment
	| instVars varName |
	instVars := OrderedCollection new.
	browseClass
		withAllSuperclassesDo: [:each | instVars addAllFirst: each instanceVariableNames asSortedCollection].
	instVars isEmpty
		ifFalse: [varName := ChoicePrompter choices: instVars caption: 'Instance Variables']
		ifTrue: [MessageBox notify: browseClass name , ' has no instance variables.'].
	varName notNil
		ifTrue: 
			[self
				perform: selector
				with: varName
				with: browseClass
				with: aBrowserEnvironment]!

browseMessageDefinitions: aString in: aBrowserEnvironment
	"Private - Prompt for a selector and open a method browser displaying the
	implementors of that selector."

	(self promptForDefinitionsOf: aString in: aBrowserEnvironment)
		ifNotNil: [:search | Cursor wait showWhile: [self browseDefinitionsMatching: search in: aBrowserEnvironment]]!

browseMessageDefinitionsIn: aBrowserEnvironment 
	"Private - Prompt for a selector and open a method browser displaying all definitions of
	that selector in the specified <BrowserEnvironment>."

	self browseMessageDefinitions: '' in: aBrowserEnvironment!

browseMessageReferences: aString in: aBrowserEnvironment
	"Private - Prompt for a selector and open a method browser displaying the references to that
	selector, using the <readableString> argument as the initial suggestion (or if that is empty
	the first word of the clipboard text)."

	(self promptForReferencesTo: aString in: aBrowserEnvironment)
		ifNotNil: [:search | self browseReferencesMatching: search in: aBrowserEnvironment]!

browseMessageReferencesIn: aBrowserEnvironment 
	"Private - Prompt for a selector and open a method browser displaying the references to that
	selector from methods defined in the specified <BrowserEnvironment>."

	self browseMessageReferences: '' in: aBrowserEnvironment!

browseMessageReferencesInHierarchyOf: aClass within: aBrowserEnvironment
	"Private - Prompt for a selector and open a method browser displaying the
	references to that selector from the local hierarchy of aClass."

	| hierarchyEnv |
	hierarchyEnv := aBrowserEnvironment forClassHierarchyOf: aClass.
	(self promptForReferencesTo: '' in: hierarchyEnv)
		ifNotNil: [:search | self browseReferencesMatching: search in: hierarchyEnv]!

browseMessagesMatching: aMethodSearch in: aBrowserEnvironment
	"Private - Open a MethodBrowser on all the methods whose selectors are matched by the <MethodSearch>
	argument in the specified <readableString> pattern in the scope of the specified
	<BrowserEnvironment>."

	self browseMethodsIn: (aMethodSearch matchesIn: aBrowserEnvironment)!

browseMessagesSentBy: aCompiledMethod in: aBrowserEnvironment
	"Private - Prompt the user with a list of messages sent from the specified <CompiledMethod>,
	and then open a method browser on the definitions of that message that can be found in the
	specified <BrowserEnvironment>."

	| selectors |
	selectors := aCompiledMethod messages asSortedCollection.
	selectors isEmpty
		ifTrue: [^MessageBox notify: ('<1p> does not send any messages.' expandMacrosWith: aCompiledMethod)].
	(ChoicePrompter choices: selectors caption: 'Browse Definitions of…')
		ifNotNil: [:selector | self browseDefinitionsOfSelector: selector in: aBrowserEnvironment]!

browseMethod: aCompiledMethod 
	"Open a new default browser on the <CompiledMethod> argument."

	^self browseMethod: aCompiledMethod with: self defaultBrowserClass!

browseMethod: aCompiledMethod with: aClassBrowserClass
	^aClassBrowserClass show
		packages: (Set with: aCompiledMethod owningPackage);
		selectMethod: aCompiledMethod;
		setInitialFocus;
		yourself!

browseMethodCategories: aCollection 
	"Browse the set of methods which is the union of all those belonging to at least one of the
	<collection> of <MethodCategory> which is the argument."

	self browseMethodCategories: aCollection in: self browserEnvironment!

browseMethodCategories: aCollection in: aBrowserEnvironment
	"Browse the set of methods defined in the specified <BrowserEnvironment> which is the union
	of all those belonging to at least one of the specified <collection> of <MethodCategory>s."

	| categoryEnv categories |
	categories := aCollection collect: [:each | each asMethodCategory].
	categoryEnv := aBrowserEnvironment forMethodCategories: categories.
	self
		browseMethodsIn: ((categories anySatisfy: [:each | each isVirtual and: [each isSlowToEnumerate]])
				ifTrue: 
					[(self
						selectMethods: [:method | categories anySatisfy: [:each | each includesMethod: method]]
						in: aBrowserEnvironment
						withProgress: ('Finding methods in <1d>'
								expandMacrosWith: (categories size = 1 ifTrue: [categories anyOne] ifFalse: ['categories'])))
							ifNil: [^self]
							ifNotNil: 
								[:env |
								env
									label: categoryEnv label;
									yourself]]
				ifFalse: [categoryEnv])!

browseMethodCategory
	"Browse all the methods which belong to a chosen method category."

	| chosenCategory categories |
	categories := MethodCategory allMethodCategories.
	chosenCategory := (CategoryPrompter choices: categories caption: 'Browse category…')
				allowReadOnly: true;
				showModal.
	chosenCategory notNil ifTrue: [self browseMethodCategories: {chosenCategory}]!

browseMethodHierarchyFrom: aCompiledMethod
	"Opens a MethodBrowser on all the overidden methods in the superclass chain for aCompiledMethod."

	self browseMethodHierarchyFrom: aCompiledMethod in: self browserEnvironment!

browseMethodHierarchyFrom: aCompiledMethod in: aBrowserEnvironment
	"Opens a MethodBrowser on all the overidden methods in the superclass chain for aCompiledMethod that are visible in the specified <BrowserEnvironment>."

	| chain browser |
	chain := (aBrowserEnvironment forClassHierarchyTo: aCompiledMethod methodClass)
				definitionsOf: aCompiledMethod selector.
	browser := self browseMethodsIn: chain.
	"We want to display the methods in hierarchy order, nearest first, so we must apply a sort block."
	browser browser beSorted: [:a :b | a methodClass inheritsFrom: b methodClass].
	^browser!

browseMethodProtocols: protocolNames
	"Browse all the methods which participate in the implementation of the named method
	protocols."

	| protocols env |
	protocols := protocolNames collect: [:each | MethodProtocol name: each asSymbol].
	env := MethodProtocolEnvironment onEnvironment: self browserEnvironment protocols: protocols.
	self browseMethodsIn: env!

browseMethodsIn: aBrowserEnvironment 
	| browser |
	browser := self methodExplorerClass show.
	browser methods: aBrowserEnvironment.
	^browser!

browseMethodsIn: aBrowserEnvironment filter: aMonadicValuable
	"Open a method browser on all methods included in the specified <BrowserEnvironment> that
	pass the specified <monadicValuable> filter. Newly defined or modified methods are
	considered for inclusion based on the filter."

	^self browseMethodsIn: ((aBrowserEnvironment filterMethods: aMonadicValuable)
				label: aBrowserEnvironment label;
				yourself)!

browseMethodsInEnvironments: aCollectionOfBrowserEnvironment 
	^self methodExplorerClass browseMethodsInEnvironments: aCollectionOfBrowserEnvironment!

browseMethodsWithCompilationIssuesIn: aBrowserEnvironment 
	^self browseMethodsIn: (self methodsWithCompilationIssuesIn: aBrowserEnvironment)!

browseMethodsWithFullBlocks
	"Open a <MethodBrowser> on all methods in the system that require full blocks (see the
	BlockClosure class comment for an explanation).
		Smalltalk developmentSystem browseMethodsWithFullBlocks 
	"

	| methods |
	methods := self browserEnvironment filterMethods: [:method | method needsContext].
	methods label: 'Methods with Full Blocks'.
	self browseMethodsIn: methods!

browseMethodsWithNewBytecodes
	"Open a method browser on all the methods that would have different bytecodes if recompiled
	with the current compiler."

	"
	Smalltalk developmentSystem browseMethodsWithNewBytecodes
	"

	^self browseMethodsIn: self methodsWithNewBytecodes!

browsePackages
	"Open a new package browser."
	
	^self packageBrowserClass show!

browsePackages: aPackageCollection
	"Open a new Package Browser on aPackageCollection"
	
	^self packageBrowserClass show
		packages: aPackageCollection;
		yourself!

browseProtocols
	"Open a new protocol browser."
	
	^self protocolBrowserClass show!

browseReferencesMatching: aMethodSearch in: aBrowserEnvironment
	"Private - Opens a MethodBrowser on all the methods that refer to aString from their literal frames
	(aString is normally a symbolic selector), within the scope of the specified
	<BrowserEnvironment>."

	self browseMethodsIn: (aMethodSearch referencesIn: aBrowserEnvironment)!

browseReferencesTo: anObject 
	"Open a Method Browser on all the methods that refer to anObject from their literal frames."

	^self browseReferencesToLiteral: anObject in: self browserEnvironment!

browseReferencesToClassVar: aString of: aClass within: aBrowserEnvironment
	"Private - Open a MethodBrowser on all the methods that reference the class variable named by the <readableString> first argument , in the hierarchy of the <Behavior>, aClass."

	self
		browseReferencesToClassVars: { aString }
		of: aClass
		within: aBrowserEnvironment!

browseReferencesToClassVars: aCollection of: aClass within: aBrowserEnvironment
	"Private - Open a MethodBrowser on all the methods that reference the class variables in aCollection, in the hierarchy of the <Behavior>, aClass."

	| environments |
	environments := Array writeStream.
	aCollection do: 
			[:each |
			environments nextPutAll: (self
						referencesToClassVar: each
						of: aClass
						within: aBrowserEnvironment)].
	self browseMethodsInEnvironments: environments contents!

browseReferencesToGlobal: aString 
	self browseReferencesToGlobal: aString in: self browserEnvironment!

browseReferencesToGlobal: aString in: aBrowserEnvironment 
	(self promptForReferencesToGlobal: aString in: aBrowserEnvironment) 
		ifNotNil: [:env | self browseMethodsIn: env]!

browseReferencesToInstVar: aString inHierarchyOf: aBehavior within: aBrowserEnvironment
	"Private - Open a method browser on all the methods that refer to the instance variable named by <readableString> first argument, in the hierarchy of the <Behavior> 2nd argument, within the <BrowserEnvironment> 3rd argument."

	self
		browseReferencesToInstVars: { aString }
		inHierarchyOf: aBehavior
		within: aBrowserEnvironment!

browseReferencesToInstVars: aCollection inHierarchyOf: aBehavior within: aBrowserEnvironment
	"Private - Open a method browser on all the methods that refer to the instance variables named by the <collection> of <readableString> argument, in the hierarchy of the <Behavior> argument."

	| environments |
	environments := Array writeStream.
	aCollection do: 
			[:each |
			environments nextPutAll: (self
						referencesToInstVar: each
						inHierarchyOf: aBehavior
						within: aBrowserEnvironment)].
	self browseMethodsInEnvironments: environments contents!

browseReferencesToLiteral: anObject in: aBrowserEnvironment 
	"Opens a MethodBrowser on all the methods that refer to aString from their literal frames
	(aString is normally a symbolic selector), within the scope of the specified
	<BrowserEnvironment>."

	self browseMethodsIn: (self referencesToLiteral: anObject in: aBrowserEnvironment)!

browseReferencesToVariable: anAssociation 
	"Open a MethodBrowser on all the methods that refer to the variable, anAssociation
	(which is presumably a variable from some PoolDictionary)."

	self browseReferencesToLiteral: anAssociation in: self browserEnvironment!

browserEnvFromDom: anIXMLDOMDocument
	| manifest classes env exeName time model deletedSharedVars retainedSharedVars unbound |
	manifest := anIXMLDOMDocument selectSingleNode: './/Manifest'.
	classes := manifest selectNodes: 'Classes/Class'.
	env := SelectorEnvironment new.
	exeName := File splitFilenameFrom: (anIXMLDOMDocument selectSingleNode: './/Target') text.
	time := (anIXMLDOMDocument selectSingleNode: './/TimeStamp') text.
	env label: ('<1s> (<2s>)' expandMacrosWith: exeName with: time).
	unbound := Set new.
	classes do: 
			[:each |
			| methods className classMethods |
			className := each getAttribute: 'name'.
			className asQualifiedReference ifDefined: 
					[:class |
					(each getAttribute: 'unbound') = 'true' ifTrue: [unbound add: class].
					methods := each selectNodes: 'Methods/Method'.
					env addClass: class selectors: (methods collect: [:eachMethod | eachMethod text asSymbol]).
					classMethods := each selectNodes: 'ClassMethods/Method'.
					env addClass: class class
						selectors: (classMethods collect: [:eachMethod | eachMethod text asSymbol])]].
	model := RBModel onEnvironment: env.
	retainedSharedVars := (manifest selectNodes: 'RemainingSharedVariables/VariableBinding')
				collect: [:each | each text].
	deletedSharedVars := LookupTable new.
	model rootNamespace allClassesDo: 
			[:each |
			| toDelete |
			toDelete := each bindings reject: 
							[:eachVar |
							eachVar isClassBinding
								or: [eachVar isClassVariable or: [retainedSharedVars includes: eachVar fullName]]].
			toDelete isEmpty ifFalse: [deletedSharedVars at: each put: toDelete]].
	deletedSharedVars
		keysAndValuesDo: [:eachClass :deadVars | deadVars do: [:each | eachClass removeBindingFor: each key]].
	unbound do: [:each | (each environment classInModel: model) removeBindingFor: each name].
	^model!

browserEnvironment
	^BrowserEnvironment new!

browserEnvironmentForClasses: aCollection
	^self browserEnvironment forClassesAndTheirMetaclasses: aCollection!

browseResourceIdentifier: aResourceIdentifier 
	"Open a browser onto aResourceIdentifier."

	aResourceIdentifier edit!

browseResources
	"Ensure the ResourceBrowser is visible."

	self resourceBrowserClass show!

browseResourcesReferencingView: aResourceIdentifier
	"Open a resource browser displaying the resources that reference 
	the specified view (i.e. via a ReferenceView)."

	ResourceListPresenter showResourcesReferencingView: aResourceIdentifier!

browseSelectors: aCollection caption: aString environment: aBrowserEnvironment 
	"Private - Open a method browser on the <collection> of methods, methods, with
	the caption, aString. Answer the new browser instance."

	| browser refs |
	refs := aCollection collect: [:each | self referencesToLiteral: each in: aBrowserEnvironment].
	browser := self methodExplorerClass browseMethodsInEnvironments: refs.
	browser caption: aString.
	^browser
		searchEnvironment: aBrowserEnvironment;
		yourself!

browseSharedVariableReferences: aBindingReference in: aBrowserEnvironment
	"Opens a new Method Browser on all the methods in the specified <BrowserEnvironment> which refer to the shared variable identified by the specified <BindingReference>, 
	either directly as a variable, or indirectly via another binding reference, or to the value."

	"We resolve the variable, if it exists, and search for refs to that or its value, otherwise just look for references to the BindingReference."

	^self browseMethodsIn: (aBindingReference bindingOrNil
				ifNotNil: [:var | aBrowserEnvironment referencesToVariable: var]
				ifNil: [aBrowserEnvironment referencesToBinding: aBindingReference])!

browseSystem
	"Open a new system browser at the root of the standard class hierarchy."

	^self browseSystem: Object!

browseSystem: aClassOrNil
	"Opens a new System Browser on aClassOrNil"

	| packages |
	packages := Set new.
	aClassOrNil ifNotNil: [:class | packages add: class owningPackage].
	^(self browseSystemPackages: packages)
		ifNotNil: 
			[:browser |
			browser
				actualClass: aClassOrNil;
				setInitialFocus;
				yourself]!

browseSystemOnMethod: aCompiledMethod 
	"Open a new system browser on aCompiledMethod."

	self requiresDolphinPro: 'The System Browser'.
	^nil!

browseSystemPackages: aCollection 
	self requiresDolphinPro: 'The System Browser'.
	^nil!

browseTests
	"Open a new SUnit browser on all test."

	<commandQuery: #hasTestBrowser>
	^self testBrowserClass show!

browseVariableReferences: aVariableBinding in: aBrowserEnvironment
	"Opens a new Method Browser on all the methods which refer to the shared variable represented by the <VariableBinding> argument. Also includes methods that refer directly to the current value of the variable."

	self browseMethodsIn: (aBrowserEnvironment referencesToVariable: aVariableBinding)!

browseViewHierarchy: aView
	"Useful utility for browsing a view hierarchy."

	| model tree |
	model := VirtualTreeModel withRoots: {aView}.
	model getChildrenBlock: [:each | each subViews].
	model getParentBlock: [:each | each parentView].
	tree := TreePresenter showOn: model.
	tree view getTextBlock: [:each | each printString].
	tree view getImageBlock: [:each | each iconImageIndex].
	tree view viewMode: #smallIcons.
	tree topShell
		caption: ('View hierarchy of a <1p> (<2d>)' expandMacrosWith: aView class with: aView handle)!

buildAllSelectors
	"Private - Answer a set of all message selectors understood by any class in the system. This
	needs to run as fast as possible to avoid impacting browser perf when editing."

	| set classes count accumulate |
	classes := Smalltalk allClasses.
	"On average there seem to be between 10 and 11 unique selectors per class"
	count := classes size.
	set := IdentitySet new: count * 11.
	accumulate := [:s | set add: s].
	1 to: count
		do: 
			[:i |
			| each  |
			each := classes at: i.
			each understoodSelectorsDo: accumulate.
			each class understoodSelectorsDo: accumulate].
	^set!

buildMessageMenu: aMenu forMethods: aCollection browseSelector: browseSelector extraArgs: extraArgs browseOtherSelector: browseOtherSelector
	"Private - Build a messages dynamic pop-up for [local] references to/definitions of."

	| messages |
	aMenu clear.
	aCollection do: 
			[:method |
			aMenu addCommand: (Message selector: browseSelector arguments: {method selector} , extraArgs)
				description: (method selector copyReplaceAll: '&' with: '&&').
			"Rather than include only sent messages, we include all referenced symbols as useful for tracking down events, etc"
			messages := method allSymbolLiterals.
			messages remove: method selector ifAbsent: nil.
			aMenu addSeparator.
			messages notEmpty
				ifTrue: 
					[messages asSortedCollection do: 
							[:selector |
							aMenu addCommand: (Message selector: browseSelector arguments: {selector} , extraArgs)
								description: (selector copyReplaceAll: '&' with: '&&')].
					aMenu addSeparator]].
	aMenu addCommand: (Message selector: browseOtherSelector arguments: extraArgs)
		description: '&Message…'.
	(aMenu itemAt: 1) isDefault: true!

buildSimpleSignatureFor: aSymbol
	| stream |
	stream := String writeStream.
	self printSignatureForKeywordsAndArgs: (self keywordsAndArgsForSelector: aSymbol) on: stream.
	^stream contents!

buildSystemFolder
	systemFolder := TreeModel new.
	self initializeSystemFolder.
	self
		when: #classRemoved:
		send: #removeSystemFolderIconsForClass:
		to: self!

canChangeClassNamespaces: aCollectionOfClasses
	^false!

canRefactor
	"Answer whether the receiver is capable of performing refactorings."

	^false!

canRenameClass: aClass
	^(aClass isNil or: [ClassBuilder isFixedName: aClass]) not!

changedIcon
	"Private - Answer the icon to mark source objects that have been changed: ✨"

	^ChangedIcon!

changedMethodCategory
	^'*-changed'!

changedMethodsIn: aBrowserEnvironment
	^(aBrowserEnvironment forMethodCategories: {self changedMethodCategory})
		label: ('Changed methods in <1p>' expandMacrosWith: aBrowserEnvironment);
		yourself!

changedMethodsOfClasses: aCollection 
	"Answer a <BrowserEnvironment> that includes all changed methods in the specified
	<Collection> of <Behavior>s."

	^self changedMethodsIn: (self browserEnvironmentForClasses: aCollection)!

changedResources
	"Answer a <collection> of <ResourceIdentifier>s identifying all the resources that have been
	changed."

	^self allResourceIdentifiers select: [:each | each isChanged]!

changeHistorySize
	"Answer the maximum size of the system change history list."

	^self changeManager class undoSize!

changeHistorySize: anInteger 
	self changeManager class undoSize: anInteger!

changeManager
	"Answer the change manager responsible for maintaining the development system undo/redo
	history."

	^RefactoryChangeManager instance!

chooseClass
	"Prompt the user for a Class and answer it, or nil if cancelled."

	^self 
		chooseClass: nil asValue
		caption: 'Choose Class…'
		allowNil: false!

chooseClass: aValueModel caption: aString allowNil: aBoolean 
	^(self classChooserClass createOn: aValueModel)
		caption: aString;
		allowNil: aBoolean;
		showModal!

chooseDefaultPackage
	"Allow the user to set the default package which all new classes are added to."

	| package |
	package := PackagePrompter
				showModalOn: self defaultPackage asValue
				caption: 'Default package for new objects'
				default: nil.
	package notNil ifTrue: [self defaultPackage: (package = Package uncommitted ifFalse: [package])]!

chooseSelectorsInProtocol: protocol forClass: class
	"Private - Pop-up a multi-select <ChoicePrompter> displaying the selectors 
	implemented in the <Class> class  and its superclasses, with all those which are
	part of the <MethodProtocol> protocol selected. If class is nil then only those
	selectors in the protocol are displayed.

	Answers a <collection> of the selectors chosen or nil if the dialog was cancelled."

	| selectors newSelectors oldSelectors |
	selectors := class isNil ifTrue: [#()] ifFalse: [class allSelectors].
	oldSelectors := protocol selectors.
	selectors := oldSelectors asSortedArray , (selectors difference: oldSelectors) asSortedArray.
	newSelectors := protocol selectors asArray asValue.
	(ChoicePrompter
		on: newSelectors
		multipleChoices: selectors
		caption: ('Method Protocol <1d>' expandMacrosWith: protocol)) isNil
		ifTrue: [^nil].
	^newSelectors value!

chooseViewOf: aClass
	"Choose one of the existing views of aClass.
	Allow the user to choose from a list if necessary"

	| viewResourceNames name |
	viewResourceNames := aClass resourceNames.
	name := viewResourceNames size == 1
				ifTrue: [viewResourceNames first]
				ifFalse: [ChoicePrompter choices: viewResourceNames caption: 'Available views'].
	^name notNil ifTrue: [ResourceIdentifier class: aClass name: name]!

classBrowserClasses
	^Set with: self hierarchyBrowserClass!

classChanged: aClass
	"Private - The <ClassDescription>, aClass, has updated, but in such a way
	that only affects its 'changed' status rather than its representation in a browser
	(for example a loose method in  package has been given up back to its class
	which means that the class is now changed from the source code control
	point of view).	Add the instance class to our set of changed classes."

	aClass isChanged: true
!

classChooserClass
	classChooserClass isNil ifTrue: [classChooserClass := #{ChooseClassDialog} value].
	^classChooserClass!

classChooserClass: toolClass
	classChooserClass := toolClass!

classFileIn: aClass
	"The user has chosen to file in aClass. Prompt for a file and file it in"

	| filename |
	filename := FileOpenDialog new
				caption: 'File In ' , aClass name , ' Class';
				fileTypes: {self classFilesType. FileDialog allFilesType};
				value: aClass fileOutName;
				showModal.
	filename notNil ifTrue: [self sourceManager fileInPackagedClass: aClass from: filename]!

classFileOut: aClass
	"The user has chosen to file out aClass. Prompt for a file and file it out"

	| filename |
	filename := FileSaveDialog new
				caption: 'File Out ' , aClass name , ' Class';
				fileTypes: {self classFilesType. FileDialog allFilesType};
				value: aClass fileOutName;
				showModal.
	filename notNil ifTrue: [self sourceManager fileOutPackagedClass: aClass to: filename]!

classFilesType
	"Private - Answer a two element array suitable for adding to the FileDialog
	with the fileTypes: message."

	^#('Class Files (*.cls)' '*.cls')!

classHierarchy
	"Answer the <ClassHierarchyModel> for the tree of classes managed by the
	receiver."

	^ClassHierarchyModel withAllClasses!

clearSystemFolder
	"Private - Clear the system folder. Only intended to be called when image stripping"

	systemFolder := nil.!

cloneClass: aClass as: aString under: superClass in: aPackage
	| changes details |
	changes := CompositeRefactoryChange
				named: ('Clone class <1p> as <1s>' expandMacrosWith: aClass with: aString).
	details := ClassDetails fromClass: aClass.
	details
		superclass: superClass;
		className: aString;
		package: aPackage.
	details instanceVariableNames: (aClass allInstanceVariableNames
				difference: (superClass ifNil: [#()] ifNotNil: [superClass allInstanceVariableNames])).
	details classVariableNames: (aClass allClassVarNames
				difference: (superClass ifNil: [#()] ifNotNil: [superClass allClassVarNames])).
	details
		imports: (aClass allImports difference: (superClass ifNil: [#()] ifNotNil: [superClass allImports])).
	details classInstanceVariableNames: (aClass class allInstanceVariableNames
				difference: (superClass ifNil: [#()] ifNotNil: [superClass class allInstanceVariableNames])).
	changes defineClassWithDetails: details.
	self
		copyAllMethodsOf: aClass
		to: aString
		changes: changes.
	self
		copyAllMethodsOf: aClass class
		to: aString
		changes: changes.
	self changeManager performChange: changes.
	^aString asQualifiedReference valueOrNil!

closeAll
	"Close all views, prompting to save changes."

	| mb |
	mb := MessageBox new.
	mb beTaskModal.
	(mb
		headline: 'Close all open windows?';
		text: 'All open windows will be closed, but you will be prompted to save or retain any changes.';
		isSizedToContent: true;
		customButtons: #(#(#yes '&Close All') #(#no 'Cancel'));
		isCancellable: true;
		confirm) ifFalse: [^self].
	View topLevelViews
		do: [:each | each presenter class == self systemFolderClass ifFalse: [each close]]!

compilationFailuresCategory
	^'*-compilation failures'!

compilationWarningClass
	^CompilerWarningNotification!

compile: aString in: class environment: aNamespace categories: anArray package: aPackageOrNil extraFlags: anInteger
	| change flags |
	change := AddMethodChange
				compile: aString
				in: class
				environment: aNamespace
				categories: anArray
				package: aPackageOrNil.
	flags := class defaultCompilationFlags bitOr: anInteger.
	change compilationFlags: flags.
	self changeManager performChange: change.
	(change method notNil and: [flags allMask: Interactive])
		ifTrue: [self warnOfUndefinedSelectorsSentBy: change method].
	^change!

compilerNotification: aCompilerNotification
	"Private - A notification has been sent by the Compiler.
	Display a suitable MessageBox"

	MessageBox notify: aCompilerNotification displayString!

compressChanges
	"Compresses the current changes file to remove superseded entries and old expression evaluations."

	| srcmgr |
	srcmgr := self sourceManager.
	(MessageBox new
		caption: 'Compress Changes…';
		headline: 'Compact change log?';
		text: 'The change log <1p> will be compacted, removing all but the latest sources.'
					<< (File splitFilenameFrom: srcmgr changesFileName);
		detailsText: 'Compressing changes removes superseded method source, and all expression evaluations from the change log.<n><n>Compressing changes can be useful when you want to collapse a very large log that you may have been working with for an extended period. Be aware, however, that you will lose the ability to browse method histories other than the original and latest source for changed methods. You will also be unable to refer back to the log to see the history of evaluations.'
					expandMacros;
		expandLabel: 'Show &Help';
		collapseLabel: 'Hide &Help';
		customButtons: #(#(#yes '&Compact') #(#no '&Don''t Compact'));
		isCancellable: true;
		defaultButton: 2;
		confirm) ifTrue: [srcmgr compressChanges]!

compressSources
	"Compresses the current changes file and transfers all source to the sources (.sml)
	file."

	| progress srcmgr |
	srcmgr := self sourceManager.
	(MessageBox new
		caption: 'Compress Sources…';
		headline: 'Compact changes into sources file?';
		text: 'The change log <1p> will be compacted into the source files <2p>'
					<< {File splitFilenameFrom: srcmgr changesFileName. File splitFilenameFrom: srcmgr sourcesFileName};
		detailsText: 'Compressing sources combines the latest method source from the the change log and/or sources (.sml) file for all source objects (e.g,. methods) in the system, and writes the result into a replacement sources file.<n><n>After compaction all record of what has changed will be lost and the change log will be empty. <n><n>Compressing sources is useful when you want to consolidate your work into a a new baseline image, but should otherwise be avoided as you will lose the ability to browse method histories, or to refer back to the log to see the history of evaluations.'
					expandMacros;
		expandLabel: 'Show &Help';
		collapseLabel: 'Hide &Help';
		customButtons: #(#(#yes '&Compact') #(#no '&Don''t Compact'));
		isCancellable: true;
		defaultButton: 2;
		confirm) ifFalse: [^self].
	progress := ProgressDialog create: 'No cancel view' operation: [].
	progress caption: 'Compressing  sources, please wait…'.
	srcmgr compressSourcesWith: progress!

confirmRenameClass: aClass to: aString
	^MessageBox new
		headline: 'Rename <1s>?' << aClass unqualifiedName;
		text: '<1s> will be renamed to <2s>.<n><n>Any references in code will require amending after the rename.'
					<< {aClass fullName. aString};
		customButtons: #(#(#yes '&Rename') #(#no 'Cancel'));
		isCancellable: true;
		yourself!

copyAllMethodsOf: aClass to: newClass changes: aCompositeRefactoryChange
	aClass methodsDo: 
			[:each |
			| change |
			change := AddMethodChange
						compile: each getSource
						in: aClass
						environment: each environment
						categories: each categories
						package: each owningPackageIfLoose.
			change changeClassName: newClass.
			aCompositeRefactoryChange addChange: change]!

copyClass: aClass
	| dialog newClassName superclass package |
	newClassName := aClass asQualifiedReference.
	
	[newClassName := BindingReference
				path: (newClassName path allButLast copyWith: 'CopyOf' , newClassName path last).
	newClassName isDefined]
			whileTrue.
	dialog := CreateSubclassDialog on: aClass superclass asValue.
	dialog
		package: aClass owningPackage;
		createView: dialog class defaultView.
	dialog
		subclassFullName: newClassName pathString;
		isNonInstantiable: aClass isNonInstantiable;
		isBytes: aClass isBytes;
		isVariable: aClass isVariable;
		disableAttributeChanges.
	dialog caption: 'Clone <1p>…' << aClass.
	dialog showModal isNil ifTrue: [^nil].
	newClassName := dialog subclassFullName asSymbol.
	superclass := dialog superclass.
	package := dialog package.
	^self
		cloneClass: aClass
		as: newClassName
		under: superclass
		in: package!

createClassVariableAccessors: aString in: aClass within: aBrowserEnvironment
	"Implement the 'Create Variable Accessors' class refactoring on class variables."

	self
		createVariableAccessors: { aClass -> aString }
		classVariables: true
		within: aBrowserEnvironment!

createSubclass: aClassDetails subclasses: aCollection
	"Create a subclass a named subclass of the specified class and assign it to the 
	specified package. Answer the new class."

	| newClass |
	newClass := self basicCreateSubclass: aClassDetails subclasses: aCollection.
	newClass notNil ifTrue: [newClass sourceManager logChanged: newClass].
	^newClass!

createSubclassOf: aClass
	"Prompt for details of a new subclass of the <Class> argument (e.g. the name) and then create it.
	Answer the new class, or nil if none was created."

	| aPackage |
	aPackage := aClass owningPackage.
	^self createSubclassOf: aClass inPackage: aPackage!

createSubclassOf: aClass inPackage: aPackageOrNil
	| dialog |
	dialog := CreateSubclassDialog subclassOf: aClass inPackage: aPackageOrNil.
	dialog answer ifNil: [^nil].
	^self createSubclass: dialog classDetails subclasses: dialog subclasses!

createVariableAccessors: variableNamePairs classVariables: aBoolean within: aBrowserEnvironment
	"Generate get and set accessors for the specified class and variable name pairs. Note that
	if any methods with the same selectors as the generated accessors already exist, then these
	are left unchanged.

	Please heed Kent Beck's advice - don't introduce unecessary accessors. If you are using the
	Refactoring version of Dolphin it is a trivial matter to abstract an instance variable at a
	later date.

	This method is present to speed development when you really need them, but frankly it is
	better to directly access instance variables - it is a simple matter to add accessors and
	modify the existing usage sites using the browser's facilities. As accessor methods tend to
	expose implementation details of the class the generated methods are now private by
	default."

	| name changes categories |
	aBoolean
		ifTrue: 
			["Not implemented for class variables"
			^Error notYetImplemented].
	categories := {'accessing'. 'private'}.
	name := String writeStream.
	name nextPutAll: 'Create accessors for '.
	changes := CompositeRefactoryChange new.
	variableNamePairs do: 
			[:each |
			| instVarNames selector aClass variable |
			variable := each value.
			aClass := each key.
			name
				print: aClass;
				nextPut: $.;
				nextPutAll: variable.
			instVarNames := aClass instanceVariableNames.
			(instVarNames includes: variable) ifFalse: [^aClass errorNotFound: variable].
			selector := variable asSymbol.
			(aClass includesSelector: selector)
				ifFalse: 
					[changes
						compile: ('<1s>
	"Private - Answer the value of the receiver''s ''<2s>'' instance variable."

	^<2s>'
								expandMacrosWith: selector
								with: variable)
						in: aClass
						categories: categories].
			selector := (variable , ':') asSymbol.
			(aClass includesSelector: selector)
				ifFalse: 
					[changes
						compile: ('<1s> anObject
	"Private - Set the value of the receiver''s ''<2s>'' instance variable to the argument."

	<2s> := anObject'
								expandMacrosWith: selector
								with: variable)
						in: aClass
						categories: categories]]
		separatedBy: [name nextPut: $,].
	changes name: name contents.
	self changeManager performChange: changes!

debuggerClass
	"Answer the class of the tool used for debugging in the development system."

	debuggerClass isNil ifTrue: [debuggerClass := #{Debugger} value].
	^debuggerClass!

debuggerClass: toolClass
	"Set the class of the tool used for debugging in the development system."
	
	debuggerClass := toolClass!

defaultBrowserClass
	"Answer the class of browser (a <SmalltalkToolShell>)
	to be used by default in the development environment."

	defaultBrowserClass isNil ifTrue: [defaultBrowserClass := #{ClassBrowserShell} value].
	^defaultBrowserClass!

defaultBrowserClass: toolClass 
	"Set the class of browser (a <SmalltalkToolShell>)
	to be used by default in the development environment."

	defaultBrowserClass := toolClass!

defaultFont
	"Answer the default font to use for the development system tools"

	^View desktop font!

defaultFont: aFontOrNil
	"Set the default font to use for the development system tools to aFontOrNil"

	View desktop font: aFontOrNil!

defaultInspectorClass
	"Answer the class of inspector (a <SmalltalkToolShell>) to be used by default in 
	the development environment."

	defaultInspectorClass isNil 
		ifTrue: [defaultInspectorClass := #{FlipperInspector} value].
	^defaultInspectorClass!

defaultInspectorClass: toolClass 
	defaultInspectorClass := toolClass!

defaultMaxStack
	"Answer the default maximum stack size for a newly forked <Process>, expressed in 'K' (i.e. units of 1024 slots).
	This represents the maximum number of slots (each of 4-bytes in a 32-bit VM) that can be allocated in the stack. 
	The memory space is reserved and then allocated on demand if the stack grows to require it. Normally the stack 
	will remain physically small, and increasing this maximum size will not directly impact physical memory usage. 
	On the other hand each Process forked will block out the required maximum from the available virtual memory
	space, so making this value large rwill consume more of the available 4Gb address space.
	The minimum recommended size is 32K - less than that and recursive algorithms may hit the limit too easily. 
	The maximum recommended size is 128K - more than that, and virtual memory limits will be hit too quickly when
	forking a large number of processes.
	Note that this is only the default size allocated when forking a process without specifying a different size."

	^(Process classPool at: 'DefaultMaxStack') // 1024!

defaultMaxStack: anInteger
	"Set the default maximum stack size for a newly forked <Process>, expressed in 'K' (i.e. units of 1024 slots).
	See #defaultMaxStack for further details."

	Process.DefaultMaxStack := anInteger * 1024!

defaultMethodCategories
	"Answer an <collection> of the default method categories associated with new
	methods when there is no other sensible set."

	^#()!

defaultPackage
	"Answer the default <Package> for new objects, or nil if they should not be
	placed into a package."

	^self packageManager defaultPackage!

defaultPackage: aPackageOrNil
	"Set the default Package for new objects."

	self packageManager defaultPackage: aPackageOrNil!

defaultParseContext
	^ParseContext methodClass: UndefinedObject environment: Smalltalk!

defaultPublishedAspectsLiteralsMapOf: aTool 
	"Private - Answers a literal representation of the default state of the published aspects of the
	receiver. This can be used to compare with the current state to find the aspects with
	non-default values."

	^aTool propertyAt: #_defaultPublishedAspectsLiteralsMap
		ifAbsent: [self saveDefaultPublishedAspectsOf: aTool]!

definitionsMatching: aMethodSearch inHierarchyOf: aBehavior within: aBrowserEnvironment
	| class hierarchy |
	class := aBehavior instanceClass.
	hierarchy := aBrowserEnvironment forClassHierarchyOf: class.
	^(hierarchy filterMethods: aMethodSearch definitionFilter)
		label: ('Definitions of <1p> in the local hierarchy of <2p>' expandMacrosWith: aMethodSearch pattern
					with: class);
		yourself!

definitionsOf: aSymbol
	^(MethodSearch newSelector: aSymbol) definitionsIn: self browserEnvironment!

deleteResource: aResourceIdentifier
	(MessageBox confirm: 'Are you sure you wish to delete ' , aResourceIdentifier displayString)
		ifFalse: [^self].
	self sourceManager logEvaluate: 'SessionManager current resourceManager removeResource: '
				, aResourceIdentifier storeString.
	self resourceManager removeResource: aResourceIdentifier!

deprecatedIcon
	"Private - Answers an Icon that can be used to represent a deprecated method"

	^Icon warning!

disassembleMethod: aCompiledCode 
	^'Disassembly is only available in Dolphin Professional'!

disassemblyStylerClass
	^nil!

displayItLocale
	"Answer the Locale to be used when generating the displayString for the evaluated result in Display-It commands."

	^displayItLocale ifNil: [Locale smalltalk]!

displayItLocale: aLocale
	"Answer the Locale to be used when generating the displayString for the evaluated result in Display-It commands."

	displayItLocale := aLocale!

displayOn: aPuttableStream
	"Append to the <puttableStream> argument a String whose characters are a representation of the receiver that an end-user might want to see."

	aPuttableStream nextPutAll: 'Development System'!

dolphinHomePage
	self openUrl: self dolphinSmalltalkUrl!

dolphinNewsgroup
	self openUrl: self dolphinNewsgroupUrl!

dolphinNewsgroupUrl
	^'http://groups.google.com/group/comp.lang.smalltalk.dolphin'!

dolphinSmalltalkUrl
	"Private - Answer the URL of the Object Arts home page"

	^'http://www.github.com/DolphinSmalltalk/Dolphin'!

dolphinWikiUrl
	^'https://github.com/dolphinsmalltalk/Dolphin/wiki'!

dolphinWikiWeb
	self openUrl: self dolphinWikiUrl!

dpiAwareness
	"Answer the preferred <DpiAwareness> context for the development environment."

	^OS.UserLibrary desiredDpiAwareness!

dpiAwareness: aSymbol
	"Set the DPI awareness mode to be applied in the development environment. The mode can be one of:
		#unaware	- Dolphin will be unaware of the monitor DPI settings and will operate at a virtual 96-dpi. Windows will scale everything, resulting in some blurriness of text and images
		#gdiScaled	- As above, but GDI is able to scale some drawing, such as fonts, without using bitmaps scaling, so there is much less blurriness. There are, however, some compatibility issues with this mode as described in the commentary for issue #308.
		#system		- Dolphin will be aware of the primary monitor DPI and will internally scale to this. Windows will scale any windows opened on or moved to secondary monitors at different DPIs. If the primary monitor DPI is changed, Dolphin will be unaware of the change and Windows will scale everything (i.e. no rescaling until restart). This mode provides an acceptable user experience and it is not uncommon for applications to use this mode as it is considerably simpler to implement than per-monitor. Older code may require changes to operate correctly.
		#perMonitor	- Dolphin will be fully aware of the DPI settings of all monitors and will rescale internally when windows are opened on or moved to monitors at different DPIs. If the DPI settings are changed, Dolphin will respond immediately. Note that this corresponds to the Per Monitor V2 setting described in the Windows documentation. This mode has the potential for the best user experience, and is the default. As with the system mode, older code may require changes to operate correctly and those changes may be more complex because it is not possible to rely on a single unchanging scale factor."

	"N.B. Windows does not support changing the DPI awareness of an entire running process, so this cannot take effect until restart."

	OS.UserLibrary desiredDpiAwareness: aSymbol!

dropClassFile: aString
	| defaultPackage |
	defaultPackage := self packageManager defaultPackage.
	(MessageBox
		confirm: ((defaultPackage
				ifNil: ['File in <1p>?<n><n>If the class is new it will be unpackaged.']
				ifNotNil: [:pkg | 'File in <1p>?<n><n>If the class is new it will be added to the default package (<2d>)'])
					expandMacrosWith: aString
					with: defaultPackage))
			ifTrue: [self sourceManager fileIn: aString normalizeLineEndings: true]!

dropFile: aString
	[OS.Shell32 shellOpen: aString] on: OS.Win32Error
		do: [:ex | MessageBox warning: ex description caption: ('Drop <1p>' expandMacrosWith: aString)]!

dropPackageFile: aString 
	| packages |
	packages := self installPackage: aString.
	packages notEmpty ifTrue: [packages last browse]!

dropScriptFile: aString
	SmalltalkWorkspaceDocument filename: aString!

dropTextFile: aString
	"Private - Open a txt file. A Smalltalk Workspace is a perfectly good tool for this."

	self openWorkspace: aString!

dropXmlFile: aString
	"Private - Open an XML file that has been dropped onto a tool."

	self openXmlFile: aString!

educationCenter
	"Open the Education Centre contents page"

	self helpContents!

environment
	"Answer the global name space of the receiver."

	^Smalltalk!

expressionStylerClass
	^SmalltalkExpressionStyler!

fileFileIn
	"The user has selected the standard File/File In command. Prompt for a file
	(containing chunks) and file it in"

	| filename |
	filename := FileOpenDialog new
				caption: 'File in…';
				fileTypes: {self smalltalkFilesType. self classFilesType. FileDialog allFilesType};
				defaultExtension: '';
				showModal.
	filename notNil
		ifTrue: [Cursor wait showWhile: [self sourceManager fileIn: filename normalizeLineEndings: true]]!

fileNew
	"Basic implementation of context-sensitive file-new command. Tools typically implement
	this to open their own favourite."

	self newWorkspace!

fileOpen
	"Basic implementation of context-sensitive file-open command. Tools typically implement
	this to open their own favourite file types."

	self openWorkspace!

findDetails
	findDetails isNil ifTrue: [findDetails := AdvancedFindDetails new].
	^findDetails!

findMatchingClass: aString in: aBrowserEnvironment
	| classes className pattern global |
	self assert: [aString notEmpty].
	global := aBrowserEnvironment bindingFor: aString asSymbol.
	(global notNil and: [global isClassBinding]) ifTrue: [^global value].
	pattern := ('#*' includes: aString last) ifTrue: [aString] ifFalse: [aString copyWith: $*].
	classes := (aBrowserEnvironment classNames select: [:aSymbol | pattern match: aSymbol asString])
				asSortedCollection.
	classes isEmpty
		ifTrue: 
			[(MessageBox new
				headline: 'Find Class again?';
				confirm: 'There is no class matching <1p> in <2p>' << {aString. aBrowserEnvironment})
					ifTrue: [^nil]
					ifFalse: [OperationAborted signal]].
	className := classes size = 1
				ifTrue: [classes first]
				ifFalse: 
					[(ChoicePrompter choices: classes caption: 'Matching classes') ifNil: [OperationAborted signal]].
	global := aBrowserEnvironment bindingFor: className asSymbol.
	self assert: [global isClassBinding].
	^global value!

findSelectorValidationBlock
	^
	[:details |
	| mode pattern |
	mode := details searchMode.
	pattern := details pattern.
	mode == #wildcardExpression
		ifTrue: [pattern trimBlanks notEmpty]
		ifFalse: 
			[mode == #regularExpression
				ifTrue: [details hasValidRegularExpression]
				ifFalse: [Scanner isSelector: details pattern]]]!

formatterClass
	"Answer the <stParseNodeVisitor> that should be used for auto-formatting code in the system."

	formatterClass isNil ifTrue: [formatterClass := RBFormatter].
	^formatterClass!

formatterClass: aStParseNodeVisitor
	"Set the <stParseNodeVisitor> that should be used for auto-formatting code in the system."

	formatterClass := aStParseNodeVisitor!

hardResetGUI
	"Forcibly close all views to clean up if necessary"

	[View destroyAll] on: Error do: [:x | x notify].
	"CompiledExpressions maintain a reference to any pools in scope when they were compiled, e.g.
	workspace pools, and if these have been debugged through then they may well be ref'd from
	the debug info cache. The pools may have dead workspace variables that reference old views,
	preventing them from being GC'd."
	CompiledCode initializeInfoCache.
	self sessionManager mainShellClass reset!

hasTestBrowser
	^self testBrowserClass notNil!

helpContents
	"Open the contents page in the Education Centre"

	self openHelpTopic: self helpContentsTopic!

helpContentsTopic
	^'Welcome_to_Dolphin'!

helpGuidedTour
	"Open the Guided Tour page in the Education Centre"

	self openHelpTopic: self helpGuidedTourTopic!

helpGuidedTourTopic
	^'Guided_Tour'!

helpRootUrl
	^FileLocator installRelative localFileSpecFor: 'EducationCentre7.chm::/'!

helpTutorials
	"Open the Tutorials page in the Education Centre"

	self openHelpTopic: self helpTutorialsTopic!

helpTutorialsTopic
	^'Tutorials'!

helpWhatsNew
	"Open the What's New page in the Education Centre"

	self openHelpTopic: self helpWhatsNewTopic!

helpWhatsNewTopic
	^'Whats_New'!

helpWhatsThis
	"Displays a 'What This' help cursor and tracks the mouse until it is clicked over a particular object. 
	Then display the appropriate pop-up helpful that object (if available) based on its helpId."

	| finder tracker object |
	finder := VisualObjectFinder new.
	tracker := MouseTracker forPresenter: View active startingAt: 0 @ 0.
	Cursor help showWhile: [tracker startTracking: finder].
	object := finder value.
	(object class conformsToProtocol: #whatsThisHelp)
		ifFalse: [object := finder foundView ifNil: [^self]].
	self sessionManager whatsThis: object!

hierarchyBrowserClass
	"Answer the class of Class Hierarchy Browser (a <SmalltalkToolShell>)
	to be used by default in the development environment."

	hierarchyBrowserClass isNil 
		ifTrue: [hierarchyBrowserClass := #{ClassBrowserShell} value].
	^hierarchyBrowserClass!

hierarchyBrowserClass: toolClass 
	"Set the class of Class Hierarchy Browser (a <SmalltalkToolShell>)
	to be used by default in the development environment."

	hierarchyBrowserClass := toolClass!

iconForMethod: aCompiledMethod
	"Answer an icon that can be used to represent the <CompiledMethod> argument in a development environment."

	^aCompiledMethod isPrivate ifTrue: [self privateMethodIcon] ifFalse: [self publicMethodIcon]!

ideaSpaceFilesType
	"Private - Answer a two element array suitable for adding to the FileDialog
	with the fileTypes: message for loading/saving idea space templates."

	^#('IdeaSpace Template Files (*.ist)' '*.ist')!

imageFilesType
	"Private - Answer a two element array suitable for adding to the FileDialog
	with the fileTypes: message."

	| ext |
	ext := SessionManager current imageExtension.
	^{'Smalltalk Images (*.' , ext , ')'. '*.' , ext}!

includesImplementorsOf: aSymbol
	^self allSelectors includes: aSymbol!

initialize
	"Private - Initialize the receiver.

		self initialize.
	"

	super initialize.
	self registerSystemEvents.

	"Create and initialize the system folder"
	self buildSystemFolder.
	preferAlternateInspectors := false.

	"Set the development system Help/About dialog"
	Object owningPackage aboutBlock: [:package | self aboutDolphin].

	"Font for lists, trees, etc, in the dev tools - use the standard Windows icon title font.
	Note that there is a separate setting for code panes."
	self defaultFont: nil.

	"Default break key for interrupting non-responding operations during development."
	self interruptHotKey: (AcceleratorTable keyCodeFromInvariantString: 'CTRL+F12').
	self initializeArgumentClasses.

	"Choose a default maximum stack size that is a compromise between not being overly 
	small for recursive algorithms, and not too greedy with virtual memory space. 64K
	slots will mean that each process reserves 256Kb of virtual address space."
	self defaultMaxStack: 64!

initializeArgumentClasses
	argumentClasses := Set new.
	argumentClasses
		add: Integer;
		add: Boolean;
		add: Class;
		add: String;
		add: Symbol.
	argumentClasses shrink!

initializeFrom: aSmalltalkSystem 
	1 to: (self class instSize min: aSmalltalkSystem class instSize) do: [:i | self instVarAt: i put: (aSmalltalkSystem instVarAt: i)]!

initializeSystemFolder
	"Private - Create the system folder that holds the development tool launchers and
	image options. If you evaluate the following you will reset the system folder to its
	default state.

		SmalltalkSystem current initializeSystemFolder
	"

	self systemFolder clear.
	self
		addSystemFolderIcon: (SmalltalkSystemIcon
					icon: (Icon fromId: 'Panic.ico')
					description: 'Panic'
					openBlock: [:folder :item | self panic]
					helpId: 10540);
		addSystemFolderIcon: (SmalltalkSystemIcon
					show: TranscriptShell
					description: TranscriptShell displayString
					helpId: 10570);
		registerTool: TranscriptShell;
		addSystemFolderIcon: (SmalltalkSystemFolder
					icon: (Icon fromId: 'SmalltalkToolsFolder.ico')
					description: 'Additional Tools'
					helpId: 10530);
		addSystemFolderIcon: (SmalltalkSystemFolder
					icon: self samplesFolderIcon
					description: 'Sample Applications'
					helpId: 10560)!

inspect: anObject
	^((Keyboard default isShiftDown xor: self preferAlternateInspectors)
		ifTrue: [anObject alternateInspectorClass]
		ifFalse: [anObject inspectorClass]) shellOn: anObject!

inspectVisualObject
	| finder tracker |
	finder := VisualObjectFinder new.
	tracker := MouseTracker forPresenter: View active startingAt: 0 @ 0.
	Cursor help showWhile: [tracker startTracking: finder].
	finder value ifNotNil: [:object | object inspect]!

installPackage: aString
	| manager |
	manager := self packageManager.
	^[manager install: aString]
		on: manager duplicatePackageSignal
		do: 
			[:ex |
			| mb |
			mb := MessageBox new.
			mb beTaskModal.
			mb headline: 'Error installing <1p>' << aString.
			mb errorMsg: ex description.
			#()]
		on: manager prerequisiteNotFoundSignal
		do: [:ex | (self requestPackageFileName: ex messageText) ifNil: [#()] ifNotNil: [:path | ex resume: path]]
		on: Package clashSignal
		do: [:ex | (self overlappingObjectsError: ex) ifTrue: [ex resume] ifFalse: [#()]]
		on: Warning
		do: [:ex | (self packageInstallWarning: ex) ifTrue: [ex resume] ifFalse: [#()]]
		on: Compiler notificationClass
		do: 
			[:ex |
			ex toTrace.
			ex resume]
		on: Notification
		do: 
			[:ex |
			ex toTrace.
			self sourceManager logComment: ex description.
			ex resume]!

instVarAccessFilter: aString in: startClass
	^
	[:each |
	(each methodClass includesBehavior: startClass)
		and: [[each accessesInstVar: aString] on: NotFoundError do: [:e | false]]]!

instVarReaderFilter: aString in: startClass
	^
	[:each |
	(each methodClass includesBehavior: startClass)
		and: [[each readsInstVar: aString] on: NotFoundError do: [:e | false]]]!

interruptHotKey
	"Answer the <integer> HOTKEYF_XXX|VK_XXX code used by the VM as the break/interrupt key,
	e.g. VK_CANCEL (Ctrl+Break)"

	^VM registryAt: #interruptHotKey!

interruptHotKey: anInteger
	"Set the HOTKEYF_XXX|VK_XXX code to be used by the VM as the break/interrupt key to the
	<SmallInteger> argument, which must be a sensible VK value, e.g. VK_CANCEL, or things will
	go badly."

	VM registryAt: #interruptHotKey put: anInteger!

isOAD
	"Private - Is this an Object Arts Development version"

	^false!

isRegisteredTool: aClass
	"Answer true if aClass is registered as a tool with the receiver"

	^self class registeredTools includes: aClass!

keywordsAndArgsForSelector: aSymbol 
	| args argc |
	argc := aSymbol argumentCount.
	args := (1 to: argc) collect: [:each | 'arg' , each displayString].
	^aSymbol keywords -> args!

keywordsAndArgsOfMethod: aCompiledMethod
	^aCompiledMethod parseTreeNoError
		ifNil: [self keywordsAndArgsForSelector: aCompiledMethod selector]
		ifNotNil: [:ast | ast keywords -> ast argumentNames]!

loadViewResource: aResourceArray inContext: contextView
	^contextView loadViewResource: aResourceArray forEdit: true!

methodCategorizationPolicy
	"Private - Answer the <MethodCategorizationPolicy> used by the receiver."

	^MethodCategorizationPolicy default!

methodExplorerClass
	"Answer the class of browser to be used for browsing methods in the development system."

	^methodExplorerClass ifNil: [methodExplorerClass := MethodExplorerShell]!

methodExplorerClass: toolClass 
	"Set the class of browser to be used for browsing methods in the development system."
	
	methodExplorerClass := toolClass!

methodsContainingText: aString in: aBrowserEnvironment prompt: aBoolean
	| filter searchString search caption |
	searchString := aString isEmpty ifTrue: [Clipboard current getTextOrEmpty] ifFalse: [aString].
	self findDetails pattern: searchString.
	aBoolean
		ifTrue: [findDetails := self promptForSearchString: findDetails caption: 'Methods Containing…'].
	(findDetails isNil or: [findDetails pattern isEmpty]) ifTrue: [^nil].
	search := MethodSourceSearch newFindDetails: findDetails copy.
	filter := search referenceFilter.
	"Consolidate into a SelectorEnvironment, rather than keeping a dynamic PluggableEnvironment
	otherwise there is a danger the entire source file may be scanned again"
	caption := 'Finding Methods Containing <1p>' << search pattern.
	^(self
		selectMethods: filter
		in: aBrowserEnvironment
		withProgress: caption)
			ifNotNil: 
				[:env |
				env
					label: ((aBrowserEnvironment labelFormats at: #containing)
							<< { search pattern. aBrowserEnvironment. search searchMode asPhrase asLowercase }) yourself]!

methodsThatFailedToCompileIn: aBrowserEnvironment
	| failed |
	failed := aBrowserEnvironment forMethodCategories: {self compilationFailuresCategory}.
	failed label: ('Compilation failures in <1p>' expandMacrosWith: aBrowserEnvironment).
	^failed!

methodStylerClass
	^SmalltalkMethodStyler!

methodsWithBytecode: anInteger in: aBrowserEnvironment
	"Private - 
	
	Smalltalk developmentSystem methodsWithBytecode: OpcodePool.PushActiveFrame in: BrowserEnvironment new
	"

	| label |
	label := aBrowserEnvironment subEnvironmentLabel: #bytecode for: anInteger.
	^(self
		selectMethods: 
			[:each |
			each byteCodeSegments anySatisfy: [:eachInstruction | eachInstruction first = anInteger]]
		in: aBrowserEnvironment
		withProgress: 'Finding <1s>…' << label)
		label: label;
		yourself!

methodsWithCompilationIssuesIn: aBrowserEnvironment
	| caption env |
	caption := 'Finding methods with compilation issues in <1p>' expandMacrosWith: aBrowserEnvironment.
	env := self
				selectMethods: [:each | each hasCompilationIssues]
				in: aBrowserEnvironment
				withProgress: caption.
	env label: ('Compilation issues in <1p>' expandMacrosWith: aBrowserEnvironment).
	^env!

methodsWithNewBytecodes
	"Private - Answer a <BrowserEnvironment> containing all the methods that would have different bytecodes if recompiled with the current compiler."

	^self methodsWithNewBytecodesIn: self browserEnvironment!

methodsWithNewBytecodesIn: aBrowserEnvironment
	"Private - Answer a <BrowserEnvironment> containing all the methods in the
	<BrowserEnvironment> argument that would have different bytecodes if recompiled with the
	current compiler."

	^(self
		selectMethods: 
			[:each |
			| method |
			method := Compiler
						compile: each getSource
						in: each methodClass
						environment: each environment.
			method notNil and: [method byteCodes ~= each byteCodes or: [method extraIndex ~= each extraIndex]]]
		in: aBrowserEnvironment
		withProgress: 'Finding methods that recompile differently…')
		label: 'Methods that recompile differently in ' , aBrowserEnvironment label;
		yourself!

methodWorkspaceClass
	"Answer the class of presenter to be used for method source workspaces in the various tools
	(e.g. Debugger and method browser)."

	methodWorkspaceClass isNil ifTrue: [methodWorkspaceClass := #{MethodWorkspace} value].
	^methodWorkspaceClass!

minimizeAll
	"Minimize all views"

	View topLevelViews
		do: [:each | (each class canUnderstandProtocol: #topView) ifTrue: [each minimize]]!

modelClassFor: aBehavior
	^aBehavior ifNotNil: [aBehavior realClass]!

modelMethodFor: aCompiledMethod
	^aCompiledMethod!

nameForArgument: anObject
	| type answer name |
	answer := String writeStream.
	type := self typeForArgumentClass: anObject class.
	type == BlockClosure ifTrue: [^self nameForBlockOfArity: anObject argumentCount].
	name := type name.
	answer
		nextPutAll: (name first isVowel ifTrue: ['an'] ifFalse: ['a']);
		nextPutAll: name.
	((anObject isKindOf: Collection)
		and: [(anObject isKindOf: Interval) not and: [anObject notEmpty and: [anObject class isBytes not]]])
			ifTrue: 
				[| commonBase first |
				first := true.
				anObject do: 
						[:each |
						first
							ifTrue: 
								[commonBase := each class.
								first := false]
							ifFalse: [[each class includesBehavior: commonBase] whileFalse: [commonBase := commonBase superclass]]].
				(commonBase notNil and: [commonBase ~~ Object and: [commonBase ~~ UndefinedObject]])
					ifTrue: 
						[answer
							nextPutAll: 'Of';
							nextPutAll: (self typeForArgumentClass: commonBase) name]].
	^answer contents!

nameForBlockOfArity: anInteger
	^'a' , (#('Niladic' 'Monadic' 'Dyadic') at: anInteger + 1 ifAbsent: '') , 'Valuable'!

namespaceHierarchy
	"Answer a <NamespaceHierarchyModel> for the tree of Namespaced classes managed by the receiver."

	^NamespaceHierarchyModel new!

newCodeRefactoringToolFor: aMethodWorkspace 
	^nil!

newMethodRefactoringToolFor: aMethodBrowser 
	^nil!

newWorkspace
	"The user has selected the standard File/New command. For most of the Smalltalk
	tools the only appropriate action is to create a new workspace."

	^self workspaceShellClass show!

nonDefaultPublishedAspectsLiteralsMapOf: aTool 
	"Private - Answer a literal representation of the published aspects of aTool that have been changed from their default values"

	^aTool currentPublishedAspectsAsLiteralsMap 
		difference: (self defaultPublishedAspectsLiteralsMapOf: aTool)!

nonDefaultSystemOptionsLiteralsMap
	"Private - Answer a literal representation of the system options that have been changed from their default values"

	^self systemOptions inject: LookupTable new
		into: 
			[:map :each |
			| nonDefaults |
			nonDefaults := self nonDefaultPublishedAspectsLiteralsMapOf: each.
			nonDefaults notEmpty ifTrue: [map at: each put: nonDefaults].
			map]!

nukeChangeHistory
	self changeManager class nuke!

okToInstallPatchLevel: anInteger
	"Private - Check to see if an attempt to upgrade to a patch level of anInteger is valid. 
	If we are already at or above this level then the user notified. If additional patch levels 
	are needed then these are installed first. Answers true if it is okay to install the patch or
	signals an exception if not"

	| patchFiles |
	self patchLevel >= anInteger
		ifTrue: [self error: 'Image is already at Patch Level ' , anInteger displayString].
	patchFiles := (self patchLevel + 1 to: anInteger - 1)
				collect: [:level | File composeStem: 'Patch Level ' , level displayString extension: 'st'].

	"Check patch files exist and then file them in"
	patchFiles do: [:filename | (File exists: filename) ifFalse: [self errorNotFound: filename]].
	patchFiles do: [:filename | self sourceManager fileIn: filename].
	^true!

onAboutToDisplayMenu: aMenu
	"The pop-up <Menu> is about to be displayed. This is our opportunity to update it, e.g. to add/remove items.
	Note: Adding an item persists as the menu is not destroyed until the view is closed."

	self class commandAnnotations onAboutToDisplayMenu: aMenu for: self!

onClassAdded: aClass
	"The class aClass has been added to the system.
	Inform interested parties"

	self classChanged: aClass.
	self packageManager onClassAdded: aClass.
	self trigger: #classAdded: with: aClass!

onClassCategorized: aClass
	"The class aClass has been been recategorized.
	Inform interested parties"

	self classChanged: aClass.
	self trigger: #classCategorized: with: aClass!

onClassCommented: aClass
	"The comment associated with the specified <Class> has been updated."

	self classChanged: aClass.
	self trigger: #classCommented: with: aClass!

onClassRemoved: aClass
	"The class aClass has been removed. Inform interested parties"

	allSelectors := nil.
	aClass isChanged: false.
	self packageManager onClassRemoved: aClass.
	self trigger: #classRemoved: with: aClass!

onClassUpdated: aClass
	"The class aClass has been updated.
	Inform interested parties"

	self classChanged: aClass.
	self packageManager onClassUpdated: aClass.
	self trigger: #classUpdated: with: aClass!

onDragOverProtocol: session
	"The user is dragging over a method protocol pane.
	Set the operation of the <DragDropSession>, session,
	that would occur if a drop took place now of the objects in that session."

	| op formatOk |
	formatOk := (session isFormatAvailable: #CompiledMethod)
				or: [(session isFormatAvailable: #Class) or: [session isFormatAvailable: #MethodProtocol]].
	(session isTargetSameAsSource not
		and: [formatOk and: [session suggestedTarget notNil and: [session suggestedTarget isReadOnly not]]])
			ifTrue: 
				[op := session intendedOperation == #move
							ifTrue: 
								["moves not permitted"
								#copy]
							ifFalse: [session intendedOperation]].
	session operation: op!

onDropFiles: aDroppedFilesList over: aPresenter 
	aDroppedFilesList do: [:each | self onFileDropped: each over: aPresenter]!

onDropOverProtocol: session
	"The drag operation described by <DragDropSession>, session, would like to 
	do a drop into the protocols pane.
	Override this method to accept the dragObject(s)."

	| target methods |
	target := session suggestedTarget.
	target isNil
		ifTrue: 
			[Sound errorBeep.
			^false].
	methods := (session dragObjects select: [:each | each isFormatAvailable: #CompiledMethod])
				collect: [:each | each format: #CompiledMethod].
	session isCopy
		ifTrue: 
			[methods := methods reject: [:each | target includesSelector: each selector].
			methods do: [:each | self addMethod: each toProtocol: target]]
		ifFalse: 
			[session isLink
				ifTrue: 
					[self removeSelectors: ((methods select: [:each | target includesSelector: each selector])
								collect: [:each | each selector])
						fromProtocol: target]].
	session dragObjects do: 
			[:each |
			"See if the drop is a Class"
			(each isFormatAvailable: #Class)
				ifTrue: 
					[| class classPresent |
					class := each format: #Class.
					classPresent := target behaviors includes: class.

					"Check for a copy to additional protocol"
					(classPresent not and: [session isCopy]) ifTrue: [self addClass: class toProtocol: target].

					"Check for a removal from a protocol"
					(classPresent and: [session isLink]) ifTrue: [self removeClass: class fromProtocol: target]].

			"See if the drop is a Protocol"
			(each isFormatAvailable: #MethodProtocol)
				ifTrue: 
					[| protocol |
					protocol := each format: #MethodProtocol.

					"Check for a copy to additional protocol"
					session isCopy ifTrue: [self addProtocolSelectors: protocol toProtocol: target]]].
	session isMove
		ifTrue: 
			[self assert: [false].	"Moves into protocols are not permitted"
			"Operation must never be #move to avoid methods being removed"
			session operation: #copy].
	^true!

onFileDropped: aString over: aPresenter
	| selector |
	selector := FileDrops at: (File splitExtensionFrom: aString) ifAbsent: #dropFile:.
	aPresenter routeCommand: (CommandDescription command: (Message selector: selector argument: aString)
				description: ('Drop <1s>' expandMacrosWith: aString))!

onMethodAdded: aCompilationResult
	| method |
	method := aCompilationResult method.
	allSelectors isNil ifFalse: [allSelectors add: method selector].
	method methodClass isAnonymous
		ifFalse: 
			[self packageManager onMethodAdded: aCompilationResult.
			self trigger: #methodAdded: with: aCompilationResult]!

onMethodCategorized: aCompiledMethod
	"The method aCompiledMethod has been re-categorized.
	Inform interested parties"

	self packageManager onMethodCategorized: aCompiledMethod.
	self trigger: #methodCategorized: with: aCompiledMethod!

onMethodRemoved: aCompiledMethod 
	"The method aCompiledMethod has been removed from the system.
	Inform interested parties"

	allSelectors := nil.
	self packageManager onMethodRemoved: aCompiledMethod.
	self trigger: #methodRemoved: with: aCompiledMethod!

onMethodUpdated: aCompilationResult 
	"The method aCompiledMethod has been added to the system.
	Inform interested parties"

	self packageManager onMethodUpdated: aCompilationResult.
	self trigger: #methodUpdated: with: aCompilationResult!

onProtocolRemoved: protocol
	"The <MethodProtocol>, protocol, has been removed from the system."

	self trigger: #protocolRemoved: with: protocol
!

onProtocolUpdated: aMethodProtocol
	"The <MethodProtocol>, aMethodProtcol, has been updated in some manner
	(normally by having classes/selectors added/removed). Inform interested parties."

	self trigger: #protocolUpdated: with: aMethodProtocol.
!

onSessionStopped
	"Handler for session shutting down"

!

onTipTextRequired: aToolbarItem query: aCommandQuery
	"Tool tip text is required for the <ToolbarItem>, tool."

	| cmd |
	cmd := aToolbarItem command asSymbol.
	cmd == #saveImage
		ifTrue: [^'Save image to <1p>' expandMacrosWith: self sessionManager imageFileName].
	^aCommandQuery text ifNil: [aToolbarItem toolTipText]!

onVariableRemoved: aVariableBinding
	self packageManager onVariableRemoved: aVariableBinding.
	self trigger: #variableRemoved: with: aVariableBinding!

onVariableRenamed: aVariableBinding from: aBindingReference
	"Inform the system that the global object has changed name."

	self packageManager onVariableRenamed: aVariableBinding from: aBindingReference.
	self
		trigger: #variableRenamed:from:
		with: aVariableBinding
		with: aBindingReference!

openHelpTopic: topic
	"Open the <readableString> Education Centre topic"

	^self openHelpUrl: (File
				composePath: self helpRootUrl
				stem: topic
				extension: 'htm')!

openHelpTopicForTool: anObject
	"Open the HTML page in the Education Centre for anObject. The page
	with be the same name as the object's class"

	^self openHelpTopic: (anObject class displayString copyReplacing: Character space withObject: $_)!

openHelpUrl: url 
	"Open the url in the Education Centre. If the url cannot be opened by HTML help then
	a straightforward web browser will be used."

	^('*chm::*' match: url ignoreCase: true) 
		ifTrue: [self openLocalHelpUrl: url style: nil]
		ifFalse: [self openUrl: url]!

openLocalHelpUrl: aURLString style: aWindowStyleDescriptionString
	"Open the HTML Help URL identified in aURLString "

	^OS.HTMLHelpLibrary default htmlHelpUrl: aURLString style: aWindowStyleDescriptionString!

openTool: folderItem
	"Private - Open the <SmalltalkSystemIcon>, folderItem, which is an item
	in the system folder/Tools menu."

	folderItem openIn: self systemFolder!

openUrl: aURLString
	"Open the URL identified in aURLString in a browser"

	OS.Shell32 shellOpen: aURLString directory: self sessionManager installationDirectory!

openViewComposer
	"Open a new ViewComposer editing a new instance of ShellView."
	
	^self viewComposerClass show!

openViewComposerEmpty
	"Open a new empty ViewComposer."
	
	^self viewComposerClass show!

openViewComposerOn: aResourceIdentifier
	^self viewComposerClass openOn: aResourceIdentifier!

openViewComposerOnNewViewFor: aClass
	"Open a new ViewComposer editing a new default view for aClass."
	
	^aClass editNewDefaultView!

openViewComposerOnViewOf: aClass
	"Open the View Composer on one of the existing views of aClass.
	Allow the user to choose from a list if necessary"

	| resourceId |
	resourceId := self chooseViewOf: aClass.
	resourceId notNil ifTrue: [self openViewComposerOn: resourceId]!

openWorkspace
	"Create a new workspace window on a file"

	| ws |
	ws := self workspaceShellClass open.
	ws notNil ifTrue: [ws show].
	^ws!

openWorkspace: aString
	"Private - Opens a file identified by the <readableString> filename as a workspace file"

	self workspaceShellClass filename: aString!

openXmlFile: aString
	"Private - Open an XML file. Use the XmlPad for this, if available."

	#{UI.Examples.XmlPad} ifDefined: [:xmlpad | xmlpad filename: aString]
		ifNotDefined: [self openWorkspace: aString]!

overlappingObjectsError: anError
	"Private - The resumeable <Error>, anError, was raised when an attempt to install a new 
	package failed because existing packages in the image already contain global objects of the 
	same name as some of the objects in the new package. Answers true if the load should continue."

	| msg mb |
	msg := String writeStream.
	msg
		display: anError;
		cr;
		crtab.
	anError tag do: [:e | msg display: e] separatedBy: [msg nextPutAll: ', '].
	msg
		cr;
		cr.
	self sessionManager trace: msg contents.	"#2142"
	msg
		nextPutAll: 'If you proceed with installation the system will remove the clashing items from their existing packages (if any).
This may change existing packages, and if you later uninstall this package the clashing objects will be removed along with it.

Do you wish to continue with the installation?'.
	mb := MessageBox new.
	mb
		buttonStyle: #yesNo;
		defaultButton: 2;
		caption: anError description;
		beTaskModal.
	^(mb warning: msg contents) == #yes!

pacFileDialogType
	"Private - Answer a file types array for use with a FileDialog to save/load PAC packages."

	| pac |
	pac := '*.' , Package packageExtension.
	^{'Package (<1s>)' expandMacrosWith: pac. pac}!

packageBrowserClass
	"Answer the class of browser to be used for browsing packages in the development system."

	packageBrowserClass isNil ifTrue: [packageBrowserClass := #{PackageBrowserShell} value].
	^packageBrowserClass!

packageBrowserClass: toolClass
	"Set the class of <SmalltalkToolShell> to be used as the package browser (typically <PackageBrowserShell>)."

	packageBrowserClass := toolClass!

packagedResourceIdentifierDialogClass
	^self resourceIdentifierDialogClass!

packageFilesType
	"Private - Answer a two element array suitable for adding to the FileDialog
	with the fileTypes: message for loading/saving packages."

	^#('Package Files (*.pac,*.pax)' '*.pac;*.pax')!

packageInstallWarning: aWarning
	| mb |
	aWarning toTrace.	"#2142"
	mb := MessageBox new.
	mb
		buttonStyle: #okCancel;
		defaultButton: 2;
		beTaskModal.
	^(mb
		warning: ('<1s><n><n>Click OK to bypass this warning and continue with the installation, or Cancel to abort.'
				expandMacrosWith: aWarning description))
			== #ok!

packageManager
	"Answer the package manager to be used by the receiver."

	^Package manager!

packageOpenFileDialogTypes
	"Private - Answer a file types array for use with a FileDialog to save/load packages."

	| filter |
	filter := '*.<1s>;*.<2s>'
				expandMacrosWithArguments: {Package packageExtension. Package sourcePackageExtension}
				locale: Locale invariant.
	^{{'Packages (<1s>)' expandMacrosWithArguments: {filter} locale: Locale invariant. filter}.
		self pacFileDialogType.
		self paxFileDialogType.
		FileDialog allFilesType}!

panic
	"Forcibly close all views to clean up if necessary"

	| mb |
	mb := MessageBox new.
	mb beTaskModal.
	(mb
		confirm: 'Are you sure you wish to forcibly close all open windows?
If so, all windows will be destroyed and a new System Folder will be opened.

You should do this only if you believe you may have hidden or partially composed windows in your image that are preventing some objects from otherwise being garbage collected.')
			ifFalse: [^self].
	self hardResetGUI!

patchLevel
	"Answer the current patch level of this image"

	^self sessionManager patchLevel!

patchLevel: anInteger 
	"Private - Set the current patch level of this image to anInteger"

	self sessionManager patchLevel: anInteger!

paxFileDialogType
	"Private - Answer a file types array for use with a FileDialog to save/load PAX packages."

	| pax |
	pax := '*.' , Package sourcePackageExtension.
	^{'Multi-file Package (<1s>)' expandMacrosWith: pax. pax}!

playSaveImageSound
	"Private - Plays the registered save image sound, if any."

	self sessionManager playImageSaveSound!

poolDictionariesFolder
	"Private - Answer the <SmalltalkSystemFolder> that holds the available PoolDictionarys."

	^self systemFolder asOrderedCollection detect: [:each | each description='Pool Dictionaries'].!

populateFolderMenu: aMenu tree: folderModel items: folderItems
	"Private - Populate the menu, popup, with items from the system folder, folder."

	| accels aMonadicValuable |
	accels := PluggableSet searchPolicy: SearchPolicy ordinalCaseInsensitive.
	"Ensure any existing keyboard shortcuts are accounted for"
	aMonadicValuable := 
			[:each |
			| i |
			(i := each text indexOf: $&) ~= 0 ifTrue: [accels add: (each text at: i + 1)]].
	aMenu itemsDo: aMonadicValuable.
	(folderItems asSortedArray: [:a :b | a description < b description]) do: 
			[:each |
			| text i |
			"First generate the item text, with keyboard shortcut"
			text := each description.
			i := text findFirst: [:c | c isSeparator not and: [(accels includes: c) not]].
			i ~~ 0
				ifTrue: 
					[accels add: (text at: i).
					text := (text copyFrom: 1 to: i - 1) , '&' , (text copyFrom: i)].
			each isFolder
				ifTrue: 
					[| children |
					children := folderModel childrenOf: each.
					children notEmpty
						ifTrue: 
							[| subMenu |

							subMenu := aMenu addSubmenu: text image: each icon.
							self
								populateFolderMenu: subMenu
								tree: folderModel
								items: children]]
				ifFalse: 
					[aMenu
						addCommand: (Message selector: #openTool: argument: each)
						description: text
						image: each icon]]!

populateToolsMenu: toolsMenu
	"Private - Populate the Tools menu with the same hierarchy of items as the system folder.
	The menu is arranged in alphabetical order, with dynamically generated keyboard
	shortcuts using the earliest character not used as the shortcut for a previous item
	in the menu. All items will always be enabled. There is no default."

	| folder optionsMenu |
	toolsMenu clear.
	optionsMenu := Menu
				fromStrings: #('&Options' '&Inspect Options//inspectSystemOptions' '-' '&Remember this Layout and Size//rememberThisSize' '&Forget Layout and Size//forgetSize').
	optionsMenu image: self userPreferencesIcon.
	toolsMenu
		addItem: optionsMenu;
		addSeparator.
	((toolsMenu itemAt: 1) itemAt: 1) isDefault: true.
	folder := self systemFolder.
	self
		populateFolderMenu: toolsMenu
		tree: folder
		items: folder roots!

populateWindowMenu: windowMenu
	"Private - Populate the open windows menu"

	| openShells allOpenClasses toolClasses otherClasses viewComposers |
	windowMenu clear.
	openShells := (self sessionManager inputState topLevelWindows
				select: [:each | each class conformsToProtocol: #topView]) collect: [:each | each presenter].

	"Reject shells that are owned by a view composer"
	viewComposers := ViewComposer allInstances.
	openShells := openShells
				reject: [:each | viewComposers anySatisfy: [:vc | vc hasOwnedComposingView: each]].
	allOpenClasses := openShells asSet collect: [:each | each class].
	toolClasses := allOpenClasses select: [:each | self isRegisteredTool: each].
	otherClasses := allOpenClasses difference: toolClasses.

	"System shell is always first"
	toolClasses remove: self systemFolderClass ifAbsent: nil.
	(openShells detect: [:each | each class == self systemFolderClass] ifNone: nil)
		ifNotNil: 
			[:systemShell |
			windowMenu
				addCommand: (Message selector: #showShellWithHandle: argument: systemShell view handle)
				description: 'System Folder'
				image: systemShell icon].

	"Now tools"
	self
		populateWindowMenu: windowMenu
		withShells: openShells
		ofClasses: toolClasses.

	"Now others"
	self
		populateWindowMenu: windowMenu
		withShells: openShells
		ofClasses: otherClasses.

	"Finally the fixed commands"
	windowMenu addSeparator.
	windowMenu addCommand: (MessageSend receiver: self selector: #minimizeAll)
		description: '&Minimize All'.
	windowMenu
		addCommand: (MessageSend receiver: self selector: #closeAll)
		description: '&Close All'
		image: false icon!

populateWindowMenu: windowMenu withShells: openShells ofClasses: toolClasses
	toolClasses notEmpty ifTrue: [windowMenu addSeparator].
	toolClasses asSortedCollection do: 
			[:eachClass |
			| shells |
			shells := openShells select: [:each | each class == eachClass].
			shells do: 
					[:eachShell |
					| description |
					description := self sanitizeWindowTextForMenu: eachShell view text.
					eachShell view isWindowVisible ifFalse: [description := description , ' (hidden)'].
					windowMenu
						addCommand: (Message selector: #showShellWithHandle: argument: eachShell view handle)
						description: description
						image: eachShell icon]]!

preferAlternateInspectors
	^preferAlternateInspectors!

preferAlternateInspectors: aBoolean
	preferAlternateInspectors := aBoolean!

printBlockStatsOn: aStream
	"
		Smalltalk developmentSystem printBlockStatsOn: Transcript.
	"

	| fullBlocks needOuter methodsWithCleanBlocks totalMethods stackTemps blockCopy copiedValues methodsWithSharedTemps envTemps needSelf allBlockCopies argumentCounts copyingBlocks allLiteralBlocks instructions methodEnvTemps hybridBlocks methodsWithContext |
	argumentCounts := Bag new.
	copiedValues := Bag new.
	envTemps := Bag new.
	stackTemps := Bag new.
	fullBlocks := hybridBlocks := copyingBlocks := needOuter := needSelf := totalMethods := methodsWithCleanBlocks := 0.
	blockCopy := OpcodePool.BlockCopy.
	instructions := OrderedCollection new.
	allBlockCopies := instructions.
	allLiteralBlocks := OrderedCollection new.
	methodEnvTemps := Bag new.
	methodsWithContext := 0.
	Class allMethodsDo: 
			[:eachMethod |
			| hasCleanBlock |
			totalMethods := totalMethods + 1.
			methodEnvTemps add: eachMethod envTempCount.
			eachMethod needsContext ifTrue: [methodsWithContext := methodsWithContext + 1].
			instructions
				addAll: (eachMethod byteCodeSegments select: [:eachInstruction | eachInstruction first == blockCopy]).
			hasCleanBlock := false.
			eachMethod literalsDo: 
					[:lit |
					lit class == BlockClosure
						ifTrue: 
							[hasCleanBlock := true.
							allLiteralBlocks add: lit]].
			hasCleanBlock ifTrue: [methodsWithCleanBlocks := methodsWithCleanBlocks + 1]].
	allBlockCopies do: 
			[:each |
			| envs |
			argumentCounts add: (each at: 2).
			stackTemps add: (each at: 3).
			envs := (each at: 4) >> 1.
			envs > 0 ifTrue: [fullBlocks := fullBlocks + 1].
			envTemps add: envs.
			copiedValues add: (each at: 5) >> 1.
			((each at: 4) allMask: 1)
				ifTrue: 
					[needOuter := needOuter + 1.
					envs == 0 ifTrue: [hybridBlocks := hybridBlocks + 1]].
			((each at: 5) allMask: 1) ifTrue: [needSelf := needSelf + 1].
			((each at: 5) > 0 and: [(each at: 4) == 0]) ifTrue: [copyingBlocks := copyingBlocks + 1]].
	allLiteralBlocks do: 
			[:each |
			argumentCounts add: each argumentCount.
			stackTemps add: each stackTempCount.
			self assert: [each envTempCount == 0].
			self assert: [each size == 0].
			self assert: [each receiver isNil].
			self assert: [each outer isNil]].
	aStream
		cr;
		display: 'Method Statistics:';
		cr;
		display: 'Total number of methods: ';
		print: totalMethods;
		cr;
		display: 'Methods with literal (clean) blocks: ';
		print: methodsWithCleanBlocks;
		cr;
		display: 'Methods that require a context: ';
		print: methodsWithContext;
		cr;
		display: 'Shared Method Temps:'.
	methodsWithSharedTemps := 0.
	methodEnvTemps valuesAndCountsDo: 
			[:env :count |
			env > 0 ifTrue: [methodsWithSharedTemps := methodsWithSharedTemps + count].
			aStream
				crtab;
				print: count;
				display: ' with ';
				print: env;
				display: ' shared temp(s)'].
	aStream
		cr;
		display: 'Total Methods with Shared Temps: ';
		print: methodsWithSharedTemps;
		cr.
	aStream
		cr;
		display: 'Block Statistics:';
		cr;
		display: 'Total number of literal blocks: ';
		print: allLiteralBlocks size;
		cr;
		display: 'Total number of block copies: ';
		print: allBlockCopies size;
		cr;
		display: 'Copying Blocks: ';
		print: copyingBlocks;
		cr;
		display: 'Hybrid Blocks: ';
		print: hybridBlocks;
		cr;
		display: 'Full Blocks: ';
		print: fullBlocks;
		cr;
		display: 'Block Argument Counts:'.
	argumentCounts valuesAndCountsDo: 
			[:argc :count |
			aStream
				crtab;
				print: count;
				display: ' with ';
				print: argc;
				display: ' arg(s)'].
	aStream
		cr;
		display: 'Block Copied Values (block size):'.
	copiedValues valuesAndCountsDo: 
			[:copied :count |
			copied > 0 ifTrue: [copyingBlocks := copyingBlocks + count].
			aStream
				crtab;
				print: count;
				display: ' with ';
				print: copied;
				display: ' copied value(s)'].
	aStream
		cr;
		display: 'Block Stack Temps:'.
	stackTemps valuesAndCountsDo: 
			[:stack :count |
			aStream
				crtab;
				print: count;
				display: ' with ';
				print: stack;
				display: ' stack temp(s)'].
	aStream
		cr;
		display: 'Shared Block Temps:'.
	envTemps valuesAndCountsDo: 
			[:env :count |
			aStream
				crtab;
				print: count;
				display: ' with ';
				print: env;
				display: ' shared temp(s)']!

printSignatureForKeywordsAndArgs: keywordsAndArgs on: aWriteStream 
	| args |
	args := keywordsAndArgs value.
	keywordsAndArgs key keysAndValuesDo: 
			[:i :each | 
			aWriteStream
				nextPutAll: each;
				space.
			i <= args size 
				ifTrue: 
					[aWriteStream
						nextPutAll: (args at: i);
						space]].
	aWriteStream pop!

privateMethodIcon
	"Private - Answers an Icon that can be used to represent a private method."

	^##((TextTileIcon text: $\x2B25)
		textcolor: Color red;
		yourself)!

privatePrefix
	"Private - Answer the prefix to be used in the comments of private methods."

	^'Private - '!

privatizeMethod: aCompiledMethod
	"Private - Make the <CompiledMethod> argument private. This involves placing it in the
	private pseudo-category, and ensuring that its first comment (if any) starts with 'Private -
	'."

	| parseTree class |
	parseTree := aCompiledMethod parseTreeNoError.
	parseTree isNil ifTrue: [^self].
	class := aCompiledMethod methodClass.
	parseTree comments notEmpty
		ifTrue: 
			[| source commentStart start |
			source := aCompiledMethod getSource.
			start := parseTree comments first start.
			commentStart := source findString: '"' , self privatePrefix startingAt: start.
			commentStart == 0
				ifTrue: 
					[commentStart := source
								nextIndexOf: $"
								from: start
								to: source size.
					commentStart == 0
						ifFalse: 
							[| change |
							change := self
										compile: (source
												copyReplaceFrom: commentStart + 1
												to: commentStart
												with: self privatePrefix)
										in: class
										environment: aCompiledMethod environment
										categories: (aCompiledMethod categories
												remove: MethodCategory public ifAbsent: nil;
												add: MethodCategory private;
												yourself)
										package: nil
										extraFlags: 0.
							change name: ('Privatize <1p>' expandMacrosWith: aCompiledMethod).
							^self]]].

	"Doesn't contain a comment, or comment is already suitably endowed"
	aCompiledMethod isPrivate
		ifFalse: 
			[MethodCategory private addMethod: aCompiledMethod.
			aCompiledMethod storeCategories]!

promptForClass
	"Prompt for a, possibly wildcarded, class name. Answer the <Class> if it exists or nil 
	if it does not or if the user cancels the acion."

	^self promptForClassIn: self browserEnvironment!

promptForClassIn: aBrowserEnvironment
	| class className |
	class := nil.
	className := ''.
	
	[
	[className := self promptForClassName: className.
	className isNil ifTrue: [^nil].
	class := self findMatchingClass: className in: aBrowserEnvironment.
	class isNil]
			whileTrue]
			on: OperationAborted
			do: [:ex | ].
	^class!

promptForClassName: aString
	^((Prompter
		createOn: (self suggestedWord: aString)
		prompt: 'Enter a Class name (may be wildcarded): '
		caption: 'Find a Class')
		validater: 
				[:name |
				| trimmed result |
				result := ValidationResult new.
				trimmed := name trimBlanks.
				(trimmed notEmpty and: [(Scanner isVariable: trimmed) or: [trimmed includesAnyOf: '#*']])
					ifFalse: [result errorMessage: 'Invalid class name'].
				result];
		showHintWhenEmpty: false;
		showModal) ifNotNil: [:name | name trimBlanks]!

promptForClassVarName: nameString in: aClass prompt: promptString caption: captionString
	^(Prompter
		createOn: nameString
		prompt: promptString
		caption: captionString)
		validater: [:name | self validateNewClassVarName: name for: aClass];
		showHintWhenEmpty: false;
		showModal!

promptForDefinitionsOf: aString in: aBrowserEnvironment
	^self promptForSelector: aString caption: 'Definitions of message in <1p>…' << aBrowserEnvironment!

promptForExpression: promptString caption: captionString
	| value text |
	value := nil.
	text := '' asValue.
	
	[| expression |
	expression := (Prompter
				createOn: text
				prompt: promptString
				caption: captionString)
				validater: 
						[:expr |
						| result |
						result := ValidationResult new.
						result caption: 'Parse Error'.
						[(Parser parseExpression: expr) analyze] on: CompilerErrorNotification
							do: [:err | result errorMessage: err errorMessage].
						result];
				showHintWhenEmpty: false;
				showModal.
	expression notNil and: 
			[| error |
			
			[value := Compiler evaluate: expression.
			error := nil] on: Compiler errorClass , Error
					do: 
						[:ex |
						error := ex.
						ex return: nil].
			error notNil and: 
					[(MessageBox new
						buttonStyle: #yesNo;
						iconStyle: #error;
						caption: 'Error evaluating expression…';
						headline: error displayString;
						errorMsg: 'Try again?') == #yes]]]
			whileTrue.
	^value!

promptForInstVarName: nameString in: aClass prompt: promptString caption: captionString
	^(Prompter
		createOn: nameString
		prompt: promptString
		caption: captionString)
		validater: [:name | self validateNewInstanceVariableName: name for: aClass];
		showHintWhenEmpty: false;
		showModal!

promptForKeyValuePair: promptString caption: captionString
	| expressions pair |
	expressions := Association new.
	
	[| prompter |
	prompter := KeyValuePrompter
				createOn: expressions
				prompt: promptString
				caption: captionString.
	prompter validater: 
			[:assoc |
			| result |
			result := ValidationResult new.
			result caption: 'Parse Error'.
			{ prompter keyPresenter. prompter valuePresenter } allSatisfy: 
					[:each |
					[(Parser parseExpression: each value) analyze] on: CompilerErrorNotification
						do: 
							[:err |
							result
								errorMessage: err errorMessage;
								presenter: each].
					result value].
			result].
	prompter showModal notNil and: 
			[| error |
			error := nil.
			pair := [(Compiler evaluate: expressions key) -> (Compiler evaluate: expressions value)]
						on: Compiler errorClass , Error
						do: 
							[:ex |
							error := ex.
							ex return: nil].
			error notNil and: 
					[(MessageBox new
						buttonStyle: #yesNo;
						iconStyle: #error;
						caption: 'Error evaluating expression…';
						headline: error displayString;
						errorMsg: 'Try again?') == #yes]]]
			whileTrue.
	^pair!

promptForReferencesTo: aString in: aBrowserEnvironment
	^self promptForSelector: aString caption: 'References to message in <1p>…' << aBrowserEnvironment!

promptForReferencesToGlobal: aString in: aBrowserEnvironment
	^(self promptForSharedVariableName: aString)
		ifNotNil: [:globalName | aBrowserEnvironment referencesToVariable: globalName asQualifiedReference binding]!

promptForSearchString: aFindDetails caption: aString
	^(AdvancedFindDialog create: 'Directionless view' on: aFindDetails)
		isWildCardEnabled: true;
		caption: aString;
		showModal!

promptForSelector: suggestionString caption: captionString
	"Private - 
	"

	| details dialog |
	details := AdvancedFindDetails newPattern: (self suggestedWord: suggestionString).
	details isWholeWord: true.
	dialog := AdvancedFindDialog create: 'Selector view' on: details.
	dialog
		prompt: '&Pattern:';
		caption: captionString;
		isWildCardEnabled: true;
		validationBlock: self findSelectorValidationBlock.
	^dialog showModal ifNotNil: [:search | MethodSearch newFindDetails: search]!

promptForSharedVariableName: aString
	| suggestion |
	suggestion := aString isEmpty ifTrue: [Clipboard current getTextOrEmpty] ifFalse: [aString].
	^(Prompter
		createOn: suggestion
		prompt: 'Enter the name of a shared (static) variable:'
		caption: 'Browse References to Shared Variable…')
		validater: 
				[:value |
				| result |
				result := ValidationResult new.
				(BindingReference isValidQualifiedName: value)
					ifFalse: [result errorMessage: '<1p> is not a valid qualified name' << value]
					ifTrue: 
						[value asQualifiedReference isDefined ifFalse: [result errorMessage: '<1p> is undefined' << value]].
				result];
		showHintWhenEmpty: false;
		showModal!

protocolBrowserClass
	"Answer the class of browser to be used for browsing method protocols in the development system."

	protocolBrowserClass isNil ifTrue: [protocolBrowserClass := #{ProtocolBrowserShell} value].
	^protocolBrowserClass!

protocolBrowserClass: toolClass
	"Set the class of browser to be used for browsing method protocols in the development system."
	
	protocolBrowserClass := toolClass!

publicizeMethod: aCompiledMethod
	"Private - Make the <CompiledMethod> argument public. This involves placing it in the public
	pseudo-category, and ensuring that its first comment (if any) does not start with 'Private -
	'."

	| class parseTree public private |
	parseTree := aCompiledMethod parseTreeNoError.
	parseTree isNil ifTrue: [^self].
	class := aCompiledMethod methodClass.
	public := 'public' asMethodCategory.
	private := 'private' asMethodCategory.
	parseTree comments notEmpty
		ifTrue: 
			[| source commentStart |
			source := aCompiledMethod getSource.
			commentStart := source findString: '"' , self privatePrefix
						startingAt: parseTree comments first start.
			commentStart == 0
				ifFalse: 
					[| change |
					change := self
								compile: (source
										copyReplaceFrom: commentStart + 1
										to: commentStart + self privatePrefix size
										with: '')
								in: class
								environment: aCompiledMethod environment
								categories: (aCompiledMethod categories
										remove: private ifAbsent: nil;
										add: public;
										yourself)
								package: nil
								extraFlags: 0.
					change name: ('Publicize <1p>' expandMacrosWith: aCompiledMethod).
					^self]].
	"Comment is absent or doesn't start with the private prefix."
	aCompiledMethod isPrivate
		ifTrue: 
			[public addMethod: aCompiledMethod.
			aCompiledMethod storeCategories]!

publicMethodIcon
	"Private - Answers an Icon that can be used to represent a public method"

	^(TextTileIcon text: $\x25CF fontName: 'Segoe UI')
		textcolor: Color limeGreen;
		yourself!

queryCommand: aCommandQuery
	"Enter details about a potential command for the receiver  into the <CommandQuery> argument."

	(self class commandAnnotations queryCommand: aCommandQuery ofTarget: self) ifTrue: [^true].
	(aCommandQuery canPerformAgainst: self) ifTrue: [aCommandQuery beEnabled].
	^false	"There was no specific enablement of the command at this level"!

referencesTo: anObject 
	"Answer a <BrowserEnvironment> that includes all methods in the entire system that reference
	the <Object> argument from their literal frame."

	^self referencesTo: anObject in: self browserEnvironment!

referencesTo: anObject in: aBrowserEnvironment
	"Answer a <BrowserEnvironment> that includes all methods defined in the <BrowserEnvironment>
	argument that reference the <Object> argument from their literal frame."

	"Implementation Note: Rather than use BrowserEnvironment>>referencesTo: (which creates a SelectorEnvironment containing a snapshot of the references), we use our own FilteredEnvionment with a suitable filter block. This is slightly faster, and also the FilteredEnvironment is dynamically calculated, so it will include any subsequently defined references."

	^aBrowserEnvironment liveReferencesTo: anObject!

referencesToClass: aClass in: aBrowserEnvironment
	^{
		aBrowserEnvironment referencesToVariable: aClass binding.
		aBrowserEnvironment referencesToClass: aClass
	}!

referencesToClassVar: aString of: aClass within: aBrowserEnvironment
	"Private - Open a MethodBrowser on all the methods that reference the class variable named, aString, in the hierarchy of the <Behavior>, aClass."

	^self referencesToVariable: (aClass hierarchyBindingFor: aString) in: aBrowserEnvironment!

referencesToInstVar: aString inHierarchyOf: aBehavior within: aBrowserEnvironment
	| definingBehavior env |
	definingBehavior := aBehavior whichClassDefinesInstVar: aString.
	env := definingBehavior == aBehavior
				ifTrue: [aBrowserEnvironment]
				ifFalse: [aBrowserEnvironment forClassHierarchyOf: aBehavior instanceClass].
	#todo.	"VariableEnvironment caches list of methods that access an inst. var. It needs to flush this cache when a new method is defined (or drop it altogether)."
	^{env instVarRefsTo: aString in: definingBehavior.
		env instVarReadersTo: aString in: definingBehavior.
		env instVarWritersTo: aString in: definingBehavior}!

referencesToLiteral: anObject in: aBrowserEnvironment
	^aBrowserEnvironment referencesToLiteral: anObject!

referencesToVariable: binding in: aBrowserEnvironment
	| matched |
	matched := aBrowserEnvironment filterMethods: [:method | method refersToLiteral: binding].
	matched
		label: ('All methods that reference <1p>.<2s> in <3p>'
					expandMacrosWith: binding environment
					with: binding key
					with: aBrowserEnvironment);
		addSearchString: binding key.
	^binding isImmutable
		ifTrue: 
			[matched label: ('All methods that read constant <1p>.<2s> in <3p>'
						expandMacrosWith: binding environment
						with: binding key
						with: aBrowserEnvironment).
			{ matched }]
		ifFalse: 
			[| writers readers |
			matched label: ('All methods that reference <1p>.<2s> in <3p>'
						expandMacrosWith: binding environment
						with: binding key
						with: aBrowserEnvironment).
			writers := matched filterMethods: [:method | method byteCodeDispatcher writesStatic: binding].
			writers label: ('All methods that assign to <1p>.<2s> in <3p>'
						expandMacrosWith: binding environment
						with: binding key
						with: aBrowserEnvironment).
			readers := matched filterMethods: [:method | method byteCodeDispatcher readsStatic: binding].
			readers label: ('All methods that read <1p>.<2s> in <3p>'
						expandMacrosWith: binding environment
						with: binding key
						with: aBrowserEnvironment).
			{ matched. readers. writers }]!

reformatAllMethodsIn: aBrowserEnvironment
	| changes |
	changes := CompositeRefactoryChange new.
	changes name: ('Reformat <1p>' expandMacrosWith: aBrowserEnvironment).
	aBrowserEnvironment methodsDo: 
			[:each |
			(Parser parseExistingMethodNoError: each)
				ifNotNil: [:tree | changes compile: tree formattedCode in: each methodClass]].
	self changeManager performChange: changes!

reformatSource: aString in: aClass
	^(Parser parseMethod: aString in: aClass) ifNotNil: [:ast | ast formattedCode]!

registerSystemEvents
	"Private - Register interest with the 'standard' development environment. 
	Many of the receiver's events are just forwarding those from the SystemDictionary.
		SmalltalkSystem current registerSystemEvents
	"

	Smalltalk
		removeEventsTriggeredFor: self;
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
			to: self;
		when: #classAdded:
			send: #onClassAdded:
			to: self;
		when: #classUpdated:
			send: #onClassUpdated:
			to: self;
		when: #classCategorized:
			send: #onClassCategorized:
			to: self;
		when: #classCommented:
			send: #onClassCommented:
			to: self;
		when: #classRemoved:
			send: #onClassRemoved:
			to: self;
		when: #protocolUpdated:
			send: #onProtocolUpdated:
			to: self;
		when: #protocolRemoved:
			send: #onProtocolRemoved:
			to: self;
		when: #variableRemoved:
			send: #onVariableRemoved:
			to: self;
		when: #variableRenamed:from:
			send: #onVariableRenamed:from:
			to: self!

registerTool: aToolClass
	"Adds aToolClass to the collection of registered tools for the receiver"

	self class registerTool: aToolClass!

removeClass: aClassDescription fromProtocol: aMethodProtocol
	"Private - Remove the specified class from the specified <MethodProtocol>."

	| args |
	args := {aClassDescription. aMethodProtocol}.
	(MessageBox new
		headline: 'Remove <1p> from <2d>?' << args;
		detailsText: 'The class will not be deleted, but it and any subclasses will no longer conform to <2d>'
					<< args;
		confirm: 'Are you sure you would like to remove the class <1p> from method protocol <2d>?' << args)
			ifTrue: [aMethodProtocol removeClass: aClassDescription]!

removeClasses: aCollection
	"Removes aClass from the system, and any subclasses, regardless of whether they
	are still referenced. Answer whether the class was removed."

	| subclasses prompt removedGlobals references oldClassName scope mb changes |
	aCollection do: 
			[:eachClass |
			oldClassName := eachClass name asString.
			subclasses := eachClass allSubclasses.
			mb := MessageBox new.
			mb uniqueId: [self] method displayString.
			mb defaultButton: 1.
			scope := self browserEnvironment.
			changes := CompositeRefactoryChange new.
			subclasses isEmpty
				ifTrue: 
					[prompt := 'Are you sure you want to delete the class <1s>?' << oldClassName.
					changes name: 'Delete <1s>' << oldClassName]
				ifFalse: 
					[prompt := 'Are you sure you want to delete <1s> and its <2p> subclass(es)?'
								<< {oldClassName. subclasses size}.
					changes name: 'Delete <1s> and subclasses' << oldClassName].
			mb headline: changes name , '?'.
			(mb confirm: prompt
						, '<n><n>The change is undoable, but beware of deleting essential classes.' expandMacros)
				ifFalse: [^false].
			removedGlobals := OrderedCollection new.
			references := scope referencesToClass: eachClass.
			eachClass allSubclassesEndOrderDo: 
					[:each |
					removedGlobals add: each.
					changes removeClass: each].
			changes removeClass: eachClass.
			[self changeManager performChange: changes] on: ClassBuilder invalidRemoveError
				do: 
					[:e |
					MessageBox errorMsg: e description.
					^false].
			removedGlobals do: [:g | references addMethods: (scope referencesToClass: g) allMethods].
			references notEmpty
				ifTrue: 
					[references
						label: ('Class <1s> deleted' expandMacrosWith: oldClassName);
						addSearchString: oldClassName.
					self browseMethodsIn: references]].
	^true!

removeMethod: aCompiledMethod
	"Removes the <CompiledMethod>, method, from its class after first verifying with the user.
	If the method is implementing any protocols on behalf of its owner class or subclasses then 
	we must either remove the method from the protocol, or remove the protocol(s) from the class(es)."

	self removeMethods: {aCompiledMethod}!

removeMethod: aCompiledMethod changes: aCompositeRefactoryChange
	"Private - Removes the <CompiledMethod>, method, from its class. If the method is implementing any
	protocols on behalf of its owner class or subclasses then we must either remove the method
	from the protocol, or remove the protocol(s) from the class(es). Since a change to a
	protocol could have global effect, the user is asked to confirm what they want to do in that
	case."

	| prots sel |
	sel := aCompiledMethod selector.
	prots := IdentitySet withAll: aCompiledMethod protocols.
	"We must also consider all protocols of sub-classes dependent on this method"
	aCompiledMethod methodClass allSubclasses do: 
			[:eachClass |
			eachClass protocols
				do: [:eachProtocol | (eachProtocol includesSelector: sel) ifTrue: [prots add: eachProtocol]]].
	(prots isEmpty or: 
			[| s |
			(s := aCompiledMethod methodClass superclass) notNil and: [s canUnderstand: sel]])
		ifFalse: 
			[| stream desc plural response args |
			stream := String writeStream.
			(plural := prots size > 1)
				ifFalse: 
					[stream
						space;
						display: prots asArray first]
				ifTrue: 
					[stream nextPutAll: 's '.
					prots asSortedCollection do: [:p | p displayOn: stream] separatedBy: [stream nextPutAll: ', ']].
			desc := stream contents.
			args := {sel. desc. aCompiledMethod methodClass. plural ifTrue: ['s'] ifFalse: ['']}.
			response := MessageBox new
						iconStyle: #warning;
						buttonStyle: #yesNoCancel;
						defaultButton: 3;
						headline: 'Remove method from class and protocol?';
						text: '<1p> is part of the implementation of the protocol<2s> in <3p> and/or its subclasses.<n><n>Are you sure that you would like to remove <1p> from the protocol<4s> as well as from the class?'
									<< args;
						detailsText: 'Press Yes to remove the method from <3p>, and its selector from the protocol<2s>. <3p> will still conform to the reduced protocol<4s>, but contracting protocols can affect other conforming classes or the users of those classes.<n>
Press No to remove the method and the dependent protocol <2s> from <3p> and subclasses. <3p> will no longer conform to the protocol<4s>, which might affect the users of <3p> or its subclasses. The protocol<4s> will be unaffected.<n>
It is recommended that you press Cancel to abort deletion unless you are absolutely sure.'
									<< args;
						open.
			response == #cancel ifTrue: [^OperationAborted signal].
			response == #yes ifTrue: [prots do: [:p | p removeSelector: sel]]
			"Removing the selector from the class will remove protocols from the class and subclasses"].
	aCompositeRefactoryChange removeSelector: aCompiledMethod selector from: aCompiledMethod methodClass!

removeMethods: aCollectionOfMethods
	"Remove a collection of methods as a single-undoable action. The user is first prompted to
	confirm that they really want to remove the methods."

	| stream methods max |
	stream := String writeStream.
	stream
		nextPutAll: 'The following method(s) will be removed from the system:';
		cr.
	methods := aCollectionOfMethods asSortedArray: CompiledMethod defaultSortBlock.
	max := 40.
	methods
		from: 1
		to: (methods size min: max)
		do: 
			[:each |
			stream
				cr; nextPutAll: '    ';
				display: each].
	methods size > max
		ifTrue: 
			[stream
				crtab;
				nextPutAll: '[… ';
				print: methods size - max;
				nextPutAll: ' more methods …]'].
	stream
		cr;
		cr;
		nextPutAll: 'Are you sure that you wish to proceed?'.
	(MessageBox new
		headline: 'Remove methods?';
		confirm: stream contents) ifFalse: [^self].
	self basicRemoveMethods: methods!

removeSelector: sel fromProtocol: target
	"Remove the <Symbol> selectors, sels from the <MethodProtocol>,	target."

	self removeSelectors: {sel} fromProtocol: target!

removeSelectors: aCollection fromProtocol: aMethodProtocol
	"Remove the specified <collection> of selectors from the specified <MethodProtocol>."

	"Implementation Note: This is an important operation so we need to warn the user of its consequences."

	| count prompt response |
	count := aCollection size.
	count == 0 ifTrue: [^self].
	prompt := count == 1
				ifTrue: 
					['Are you sure that you would like to remove the selector <1p> from the protocol <2d>?'
						<< {aCollection anyOne. aMethodProtocol}]
				ifFalse: 
					[| stream |
					stream := String writeStream.
					stream
						nextPutAll: 'Are you sure that you would like to remove the following selectors from the protocol?';
						cr.
					aCollection asSortedArray do: 
							[:each |
							stream
								cr;
								nextPutAll: '    ';
								display: each].
					stream contents].
	response := MessageBox new
				defaultButton: 2;
				buttonStyle: #okCancel;
				iconStyle: #prompt;
				headline: 'Remove selectors from <1d>?' << aMethodProtocol;
				text: prompt;
				detailsText: 'Removing selectors from a protocol may also affect other conforming classes or the users of those classes.<n><n>It is recommended that you cancel this operation unless you are sure.'
							expandMacros;
				open.
	response == #ok
		ifTrue: 
			[Cursor wait showWhile: 
					[aMethodProtocol removeAllSelectors: aCollection.
					aMethodProtocol baseBehaviors do: [:each | self classChanged: each]]]!

removeSystemFolderIcon: aSmalltalkSystemIcon 
	"#deprecated." "6.0 - not marked as deprecated as otherwise causes error on deployment with third party tools installed"
	^self removeSystemFolderIconNamed: aSmalltalkSystemIcon description!

removeSystemFolderIconNamed: aString
	"Removes any <SmalltalkSystemIcon> whose name matches the <readableString> argument from the
	system folder hierarchy. Answers the icon removed, or nil if no match was found."

	"Implementation Note: This method may be called during stripping when classes are removed,
	but after the system folder has been cleared, therefore we try and avoid lazily
	re-initializing the system folder!!"

	systemFolder isNil ifTrue: [^self].
	^(systemFolder asOrderedCollection detect: [:each | each description = aString] ifNone: nil)
		ifNotNil: [:matchingIcon | systemFolder remove: matchingIcon]!

removeSystemFolderIconsForClass: aClass
	"Private - Removes any <SmalltalkSystemIcon> which is associated with the specified tool class."

	"Implementation Note: This method may be called during stripping when classes are removed, but after the system folder has been cleared, therefore we try and avoid lazily re-initializing the system folder!!"

	systemFolder isNil ifTrue: [^self].
	(systemFolder select: [:each | each tool == aClass]) do: [:each | 
		systemFolder remove: each].
	self unregisterTool: aClass!

renameClass: aClass
	"Rename aClass to a new name requested from the user."

	| oldClassName |
	oldClassName := aClass name asString.
	(Prompter
		on: oldClassName
		prompt: 'New name for ' , oldClassName
		caption: 'Rename Class') ifNotNil: [:newClassName | self renameClass: aClass to: newClassName]!

renameClass: aClass to: aString
	"Prompt for confirmation, and then if confirmed rename the <Class> first argument to have the new full-name specified by the second, <String> argument. Use the Rename Class refactoring when available."

	| prompter |
	prompter := self confirmRenameClass: aClass to: aString.
	prompter confirm ifFalse: [^self].
	"Queue deferred action as we can't delete the old item now while still in use (causes GPF in TreeView)"
	self
		renameClass: aClass
		to: aString
		showChanges: prompter isChecked!

renameClass: aClass to: newClassName showChanges: aBoolean
	"Rename aClass to newClassName. Also list all of the methods which reference
	the class. Their source must be modified to include the newClassName."

	| oldClassName references |
	oldClassName := aClass name asString.
	references := self browserEnvironment referencesToClass: aClass.
	ClassBuilder renameClass: aClass to: newClassName.
	references isEmpty
		ifTrue: [MessageBox notify: 'No methods referenced ' , oldClassName]
		ifFalse: 
			[references
				label: ('<1s> renamed to <2s>' expandMacrosWith: oldClassName with: newClassName);
				addSearchString: oldClassName.
			self browseMethodsIn: references]!

renameClassVariable: aString in: aClass 
	"Implements the Rename Class Variable refactoring."

	self 
		renameClassVariable: aString
		in: aClass
		within: self browserEnvironment!

renameClassVariable: aString in: aClass within: aBrowserEnvironment
	"Implements the Rename Class Variable refactoring."

	| newName |
	newName := self
				promptForClassVarName: aString
				in: aClass
				prompt: 'Please enter a new name for the variable:'
				caption: 'Rename Class Variable <1p>…' << aString.
	newName notNil
		ifTrue: 
			[self
				renameClassVariable: aString
				to: newName
				in: aClass
				within: aBrowserEnvironment]!

renameClassVariable: oldName to: newName in: definingBehavior
	^self
		renameClassVariable: oldName
		to: newName
		in: definingBehavior
		within: self browserEnvironment!

renameClassVariable: aString to: newName in: aClass within: aBrowserEnvironment
	aClass renameClassVar: aString to: newName.
	self
		browseReferencesToClassVar: newName
		of: aClass
		within: aBrowserEnvironment!

renameInstanceVariable: aString in: aClass 
	"Implements the Rename Instance Variable refactoring."

	self 
		renameInstanceVariable: aString
		in: aClass
		within: self browserEnvironment!

renameInstanceVariable: aString in: aClass within: aBrowserEnvironment
	| newName |
	newName := self
				promptForInstVarName: aString
				in: aClass
				prompt: 'Please enter a new name for the variable:'
				caption: 'Rename Instance Variable <1p>…' << aString.
	newName notNil
		ifTrue: 
			[self
				renameInstanceVariable: aString
				to: newName
				in: aClass
				within: aBrowserEnvironment]!

renameInstanceVariable: oldName to: newName in: definingBehavior
	^self
		renameInstanceVariable: oldName
		to: newName
		in: definingBehavior
		within: self browserEnvironment!

renameInstanceVariable: aString to: newName in: aClass within: aBrowserEnvironment
	aClass renameInstVar: aString to: newName.
	self
		browseReferencesToInstVar: newName
		inHierarchyOf: aClass
		within: aBrowserEnvironment.
	^newName!

renameVariable: oldSymbol to: newSymbol
	"Rename the global, informing the system of the change."

	Smalltalk renameVariable: oldSymbol to: newSymbol!

requestPackageFileName: aString
	"Private - Answer a <readableString> being a revised the path for the package,
	or nil if no suggestions are available (e.g. this is not an interactive session and so
	user input is not available)."

	| stem |
	stem := File splitStemFrom: aString.
	^FileOpenDialog new
		fileTypes: self packageOpenFileDialogTypes;
		defaultExtension: (File splitExtensionFrom: aString);
		value: stem;
		caption: ('Open prerequisite Package: <1p>' expandMacrosWith: stem);
		showModal!

requiresDolphinPro: aString
	MessageBox warning: ('<1s> is only available in Dolphin Professional' expandMacrosWith: aString)!

resaveViewResourcesMatching: matchBlock do: doBlock
	"Evaluate matchBlock for all <ResourceIdentifier>s, and when true open the corresponding
	resource in a ViewComposer and evalute the doBlock passing it the open <ViewComposer>. For
	each case that the doBlock answers true, resave the view resource. This is useful (for
	example) for resaving all view resources that reference a particular class in order to
	update the resource to reflect updates to the class layout that would otherwise need STB
	class conversion each time the resource is loaded. For example:

	Smalltalk developmentSystem resaveViewResourcesMatching: [:each | each compiledMethod refersToLiteral: ScintillaMargin] do: [:each | true]

	"

	| vc |
	vc := self openViewComposerEmpty.
	(vc allResourceIdentifiers select: matchBlock) do: 
			[:rid |
			vc openOn: rid.
			(doBlock value: vc) ifTrue: [vc fileSave].
			MemoryManager current
				collectGarbage;
				administerLastRites].
	vc exit!

resetPublishedAspectsToDefaultsFor: aTool 
	"Private - Resets the published aspect of aTool to the previously stored default values."

	self applyPublishedAspectsLiteralMap: (self defaultPublishedAspectsLiteralsMapOf: aTool) to: aTool!

resetSystemOptionsToDefaults
	"Private - Answer a literal representation of the system options that have been changed from their default values"

	^self systemOptions do: [:each | self resetPublishedAspectsToDefaultsFor: each]!

resourceBrowserClass
	"Answer the class of browser for browsing resources in the development system."

	resourceBrowserClass isNil 
		ifTrue: [resourceBrowserClass := #{ResourceBrowser} value].
	^resourceBrowserClass!

resourceBrowserClass: toolClass
	"Set the class of browser for browsing resources in the development system."

	resourceBrowserClass := toolClass!

resourceIdentifierDialogClass
	resourceIdentifierDialogClass isNil
		ifTrue: [resourceIdentifierDialogClass := #{ResourceIdentifierDialog} value].
	^resourceIdentifierDialogClass!

resourceIdentifierDialogClass: aDialogClass 
	resourceIdentifierDialogClass := aDialogClass!

resourceManager
	^self sessionManager resourceManager!

rootNamespace
	^Root!

samplesFolder
	"Private - Answer the <SmalltalkSystemFolder> that holds the available Sample Applications"

	^self systemFolderNamed: 'Sample Applications'!

samplesFolderIcon
	^Icon fromId: 'SampleApplicationsFolder.ico'!

sanitizeWindowTextForMenu: aString
	"Private - Control characters present in the window text (including tabs) may cause Windows to display a corrupt string, so replqce any control characters in the proposed menu text for a window with its Unicode display character. Also limit the maximum amount of text to something reasonable so the menu is not too wide."

	| sanitized original count |
	sanitized := String writeStream.
	original := aString readStream.
	count := 0.
	[original atEnd or: [count > 80 and: 
					[sanitized nextPutAll: ' …'.
					true]]]
		whileFalse: 
			[| ch code |
			count := count + 1.
			ch := original next.
			code := ch code.
			sanitized
				nextPut: ((code between: 0 and: 31) ifTrue: [Character codePoint: 16r2400 + code] ifFalse: [ch])].
	^sanitized contents!

saveDefaultPublishedAspectsOf: aTool 
	"Private - Saves the current state of aTools published aspects as its default values. These
	can later be used to find any publishes aspects that have been changed from their defaults"

	^aTool propertyAt: #_defaultPublishedAspectsLiteralsMap
		put: aTool currentPublishedAspectsAsLiteralsMap!

saveImage
	"Save the Smalltalk image."

	self playSaveImageSound.
	^self sessionManager saveImage!

saveImageAs
	"Save the Smalltalk image and sources to a user chosen filename."

	| fileName |
	fileName := FileSaveDialog new
				fileTypes: {self imageFilesType. FileDialog allFilesType};
				defaultExtension: '';
				value: self sessionManager imagePath;
				caption: 'Save Image As';
				showModal.
	fileName isNil ifTrue: [^self].
	fileName = self sessionManager imageFileName
		ifTrue: [self saveImage]
		ifFalse: 
			[((File exists: fileName) not or: 
					[MessageBox new
						beTaskModal;
						caption: self sessionManager applicationName;
						headline: 'Overwrite existing image?';
						text: 'The existing image <1p> will be overwritten.' << fileName;
						customButtons: #(#(#yes '&Overwrite') #(#no 'Cancel'));
						isCancellable: true;
						confirm])
				ifTrue: 
					[Cursor wait showWhile: 
							[self playSaveImageSound.
							self sessionManager saveImage: fileName]]]!

selectMethods: aMonadicValuable in: aBrowserEnvironment withProgress: aString
	| progress |
	progress := ProgressDialog create.
	progress
		text: aString;
		startMarquee.
	progress operation: 
			[:p |
			| matching |
			matching := aBrowserEnvironment filterMethods: aMonadicValuable.
			matching progressBlock: [:percentComplete | p value: percentComplete].
			(aBrowserEnvironment forMethods: matching allMethods)
				filter: aMonadicValuable;
				yourself].
	^progress showModal!

sessionManager
	"Private - Answer the receiver's default session manager."

	^SessionManager current!

setClassCustomDrawAttributes: anNMCUSTOMDRAW
	| aClass |
	aClass := anNMCUSTOMDRAW subItem.
	aClass isDeprecated ifTrue: [anNMCUSTOMDRAW font isStruckThrough: true].
	aClass isVisiblyAbstract ifTrue: [anNMCUSTOMDRAW font isItalic: true]!

showPrerequisitesForPackage: aPackage
	(self browsePackages: {aPackage}) showPrerequisitesFor: aPackage!

showShellWithHandle: aShellHandle
	"Private - Displays the open window identified by aShellHandle"

	(View withHandle: aShellHandle)
		show;
		zOrderTop!

showTranscript
	"Shows the transcript"

	TranscriptShell current
		show;
		setFocus!

signatureOfMethod: aCompiledMethod
	| stream |
	stream := String writeStream.
	self printSignatureForKeywordsAndArgs: (self keywordsAndArgsOfMethod: aCompiledMethod) on: stream.
	^stream contents!

smalltalkExit
	"Request system shutdown - may be cancelled by user."

	self sessionManager exit!

smalltalkFilesType
	"Private - Answer a two element array suitable for adding to the FileDialog
	with the fileTypes: message."

	^#('Smalltalk Files (*.st)' '*.st')!

sourceManager
	"Answer the default <SourceManager> used for change logging, etc."

	^self class sourceManager!

splashShowAtStartup
	^self sessionManager splashShowAtStartup!

splashShowAtStartup: aBoolean 
	self sessionManager splashShowAtStartup: aBoolean!

stbSaveOn: anSTxOutFiler
	"Output the singleton receiver to anSTxOutFiler."

	anSTxOutFiler saveObject: self as: (STBSingletonProxy forClass: self class)!

stonOn: stonWriter
	stonWriter writeObject: self listSingleton: #current!

suggestedWord: aString
	| start stream suggestion |
	suggestion := aString isEmpty ifTrue: [Clipboard current getTextOrEmpty] ifFalse: [aString].
	stream := suggestion readStream.
	stream skipSeparators.
	start := stream position + 1.
	stream skipWhile: [:c | c isSeparator not].
	^suggestion copyFrom: start to: stream position!

systemFolder
	"Answer the <TreeModel> that holds the system folder hierarchy.
	We'll lazily initialize this in order to avoid problems with the boot."

	systemFolder isNil ifTrue: [self buildSystemFolder].
	^systemFolder!

systemFolderClass
	"Answer the class of System Folder (a <SmalltalkToolShell>) to be used by default in the development environment."

	^systemFolderClass!

systemFolderClass: aSmalltalkToolShell
	"Set the class of System Folder (a <SmalltalkToolShell>) to be used by default in the development environment."

	systemFolderClass := aSmalltalkToolShell!

systemFolderNamed: name 
	^self systemFolder asOrderedCollection detect: [:each | each description = name]!

systemOptions
	^{self}
		, (self class registeredTools asSortedCollection: [:t1 :t2 | t1 displayString < t2 displayString])!

testBrowserClass
	testBrowserClass isNil ifTrue: [testBrowserClass := #{Smalltalk.SUnitBrowser} valueOrNil].
	^testBrowserClass!

toolBackgroundColor
	"Answer the background used in some of the system tools"

	^(Color named: #toolBackground) basicActualColor!

toolBackgroundColor: aColor
	(Color named: #toolBackground) actualColor: aColor!

toolbarBitmapSize: aPointOrNil
	toolbarBitmapSize := aPointOrNil!

toolbarImageSize
	^toolbarBitmapSize ifNil: [#smallIcons]!

toolsMenu
	<menuPopulator: #populateToolsMenu:>
	!

typeForArgumentClass: anObject 
	^self argumentClasses detect: [:each | anObject includesBehavior: each] ifNone: [anObject]!

unimplementedSelectorsIn: aBrowserEnvironment
	"Answer a <Set> of all the <Symbol>s which are selectors which are referenced from methods in the <BrowserEnvironment> argument but which have no corresponding implementation in that browser environment. N.B. This may not include any messages sent dynamically with #perform: and friends, and so should not be considered a guarantee that no send will ever result in a DNU (which, of course, cannot be guaranteed anyway because there is no way of knowing that the object to which the message is sent actually implements that message)."

	^aBrowserEnvironment unimplementedSelectors!

uninitialize
	"Private - Uninitialize the receiver."

	self clearSystemFolder.
	Smalltalk removeEventsTriggeredFor: self!

unregisterTool: aToolClass
	"Removes aToolClass from the collection of registered tools for the receiver."

	self class unregisterTool: aToolClass!

upgradeAllResourcesReferencingClassNamed: aSymbol
	"Load and resave all view resources referencing the named class. This will apply any pending STB version upgrade."

	| refs |
	refs := self browserEnvironment referencesToClass: aSymbol asQualifiedReference value.
	refs allMethods do: [:each | (ResourceIdentifier forMethod: each) ifNotNil: [:ri | ri reassign]]!

userPreferencesIcon
	^Icon fromId: 'SMALLTALKOPTIONSFOLDER.ICO'!

validateCreateSubclass: aClassDetails
	| result superclass |
	result := ValidationResult new.
	superclass := aClassDetails superclass.
	(ClassBuilder.Unsubclassable includes: superclass fullyQualifiedReference)
		ifTrue: 
			[^result
				errorMessage: ClassBuilder.ErrorUnsubclassable << superclass;
				yourself].
	aClassDetails isBytes
		ifTrue: 
			[superclass isPointers
				ifTrue: 
					[superclass instSize > 0
						ifTrue: 
							[^result
								errorMessage: ClassBuilder.ErrorByteSubclassOfFixed << superclass;
								yourself].
					superclass isVariable
						ifTrue: 
							[^result
								errorMessage: ClassBuilder.ErrorByteSubclassOfVariable << superclass;
								yourself]].
			^result].
	"Validate pointer class"
	superclass isBytes
		ifTrue: 
			[^result
				errorMessage: ClassBuilder.ErrorPointerSubclassOfBytes << superclass;
				yourself].
	(superclass isVariable and: [aClassDetails isVariable not])
		ifTrue: 
			[^result
				errorMessage: ClassBuilder.ErrorFixedSubclassOfVariable << superclass;
				yourself].
	^result!

validateNewClassVarName: aString for: aClass
	^ValidationResult
		value: ((ClassBuilder isValidClassName: aString) and: 
					[(aClass allClassVarNames includes: aString) not and: [aString asQualifiedReference isDefined not]])!

validateNewInstanceVariableName: name for: aClass
	^ValidationResult
		value: ((Compiler isAValidLocalIdentifier: name) and: [(aClass allInstanceVariableNames includes: name) not])!

validateRenameInstVar: oldString to: newString in: aClass
	| result |
	result := self validateNewInstanceVariableName: newString for: aClass.
	result value
		ifFalse: 
			[result
				errorMessage: ('<1s> is not a valid instance variable name in <2p>' expandMacrosWith: newString
						with: aClass)].
	^result!

viewComposerClass
	"Answer the class of ViewComposer to be used for editing view resources in the
	development system."
	
	viewComposerClass isNil ifTrue: [viewComposerClass := #{ViewComposer} value].
	^viewComposerClass!

viewComposerClass: toolClass
	"Set the class of ViewComposer to be used for editing view resources in the
	development system."
	
	viewComposerClass := toolClass!

viewResourcesMatching: matchBlock do: doBlock
	| vc |
	vc := self openViewComposerEmpty.
	(self allResourceIdentifiers select: matchBlock) do: 
			[:rid |
			vc openOn: rid.
			(doBlock value: vc) ifTrue: [vc fileSave].
			MemoryManager current
				collectGarbage;
				administerLastRites].
	vc exit!

warnOfUndefinedSelectorsSentBy: aCompiledMethod
	(aCompiledMethod messages difference: self allSelectors) do: 
			[:each |
			| source |
			source := aCompiledMethod getSource.
			aCompiledMethod parseTreeNoError
				ifNil: 
					[(self compilationWarningClass
						code: CWarnUndefinedSelector
						in: source
						for: aCompiledMethod methodClass
						selector: aCompiledMethod selector
						position: 1
						line: 1
						range: (1 to: source size)
						extras: {each}) signal]
				ifNotNil: 
					[:ast |
					| range |
					((MessageNodeCollector messagesSentBy: ast) detect: [:eachMsg | eachMsg selector == each]
						ifNone: nil) ifNil: [range := 1 to: 1] ifNotNil: [:value | range := value sourceInterval].
					(self compilationWarningClass
						code: CWarnUndefinedSelector
						in: source
						for: aCompiledMethod methodClass
						selector: aCompiledMethod selector
						position: 1
						line: 1
						range: range
						extras: {each}) signal]]!

windowMenu
	<menuPopulator: #populateWindowMenu:>
	!

workspaceClass
	"Answer the class of presenter to be used for non-method source workspaces in the various
	tools, and of course as the main pane of the workspace tool itself."

	workspaceClass isNil ifTrue: [workspaceClass := #{SmalltalkWorkspace} value].
	^workspaceClass!

workspaceClass: presenterClass
	"Set the class of presenter to be used for code workspaces."
	
	workspaceClass := presenterClass!

workspaceShellClass
	"Answer the class of presenter to be used for workspace shells."

	workspaceShellClass isNil ifTrue: [workspaceShellClass := #{SmalltalkWorkspaceDocument} value].
	^workspaceShellClass!

workspaceShellClass: toolClass
	"Set the class of presenter to be used for workspace shells."
	
	workspaceShellClass := toolClass!

wrapText: aString indent: colInteger tabWidth: tabInteger 
	"Left-justify the <String> argument to the current formatter's maximum line length, 
	indenting lines after the first to start at the specified column. Any 'words' which are too 
	long to fit within the available width are permitted to extend past the end of the line."

	^self 
		wrapText: aString
		toWidth: self formatterClass maxLineLength
		indent: colInteger
		tabWidth: tabInteger!

wrapText: aString toWidth: max indent: colInteger tabWidth: tabInteger
	"Left-justify the <String> argument to the specified line length, indenting lines after the
	first to start at the specified column. Any 'words' which are too long to fit within the
	available width are permitted to extend past the end of the line."

	| indent justified original column tabs spaces words newline |
	(aString isEmpty or: [max <= colInteger])
		ifTrue: 
			["No wrapping is possible"
			^aString].
	indent := colInteger - 1.
	tabs := indent // tabInteger.
	spaces := indent \\ tabInteger.
	justified := String writeStream.
	column := indent.
	original := aString readStream.
	original skipSeparators.
	words := 0.
	newline := 
			[justified crtab: tabs.
			spaces timesRepeat: [justified space].
			column := indent.
			words := 0].
	[original atEnd] whileFalse: 
			[| word lines |
			word := original nextWord.
			words > 0 ifTrue: [column + word size > max ifTrue: [newline value] ifFalse: [justified space]].
			justified nextPutAll: word.
			column := column + word size + 1.
			words := words + 1.
			"Skip whitespace, but preserve any blank lines"
			lines := 0.
			original skipWhile: 
					[:each |
					each = $\n ifTrue: [lines := lines + 1].
					each isSeparator].
			lines > 1
				ifTrue: 
					[lines - 1 timesRepeat: [justified cr].
					newline value]].
	^justified contents! !

!Tools.SmalltalkSystem categoriesForMethods!
aboutBoxClass!constants!private! !
aboutBoxClass:!constants!private! !
aboutDolphin!commands-actions!public! !
actualFont!accessing!options!public! !
add:toProtocolWarning:!operations!private!protocols! !
addAdditionalToolsFolderIcon:!operations!public! !
addAdditionalToolsFolderIconFor:description:!operations!public! !
addClass:toProtocol:!private!protocols! !
addGlobalName:!operations!public! !
additionalToolsFolder!accessing!private! !
addMethod:toProtocol:!operations!protocols!public! !
addProtocolSelectors:toProtocol:!operations!private!protocols! !
addSamplesFolderIcon:!operations!public! !
addSamplesFolderIconFor:description:!operations!public! !
addSamplesFolderIconFor:description:helpId:!operations!public! !
addSamplesFolderIconFor:helpId:!operations!public! !
addSelectors:toProtocol:!operations!protocols!public! !
addSystemFolderIcon:!operations!public! !
addSystemFolderIcon:to:!operations!public! !
allResourceIdentifiers!public! !
allSelectors!accessing!public! !
allSelectorsImplementedIn:!enquiries!public! !
allSelectorsSentIn:!enquiries!public! !
allSymbolsReferencedIn:!enquiries!public! !
allUnimplementedSelectors!enquiries!public! !
applyOptionsToTool:!private! !
applyPublishedAspectsLiteralMap:to:!operations!private!theming! !
argumentClasses!accessing!private! !
argumentClasses:!accessing!private! !
autoFormatMethodSource!options!public! !
autoFormatMethodSource:!options!public! !
availableNamespaces!accessing!public! !
backupOnImageSave!accessing!public! !
backupOnImageSave:!accessing!public! !
basicCreateSubclass:subclasses:!private!refactoring! !
basicRemoveMethods:!helpers!private! !
basicRemoveMethods:within:showChanges:!helpers!private! !
basicRemoveMethodsIn:within:showChanges:!helpers!private! !
beginDrag:methods:!event handling!helpers!private! !
beNotChanged!operations!private! !
binaryClassFilesType!constants!private! !
browseAllChangedMethods!browsing!commands-actions!public! !
browseAllUnimplementedSelectors!browsing!commands-actions!public! !
browseChangedMethodsOf:!browsing!public! !
browseChangedMethodsOfClasses:!browsing!public! !
browseClass!browsing!commands-actions!public! !
browseClass:!browsing!public! !
browseClass:with:!browsing!public! !
browseClassHierarchyOfMethod:!browsing!public! !
browseClassReferences:!browsing!public! !
browseClassReferences:in:!browsing!public! !
browseClassVariables:!browsing!public! !
browseCompilationFailures!browsing!public! !
browseCompilationFailuresIn:!browsing!public! !
browseCompilationIssues!public! !
browseCompilationIssuesIn:!public! !
browseContainingText!browsing!commands-actions!public! !
browseContainingText:!operations!public! !
browseContainingText:in:prompt:!browsing!private! !
browseContainingTextIn:!operations!public! !
browseDefinitionsMatching:in:!browsing!private! !
browseDefinitionsMatching:inHierarchyOf:within:!browsing!private! !
browseDefinitionsOf:!browsing!public! !
browseDefinitionsOfSelector:in:!browsing!public! !
browseEnvironment:!browsing!public! !
browseFolder:!browsing!public! !
browseHierarchy!browsing!commands-actions!public! !
browseHierarchy:!operations!public! !
browseInstanceVariables:!browsing!public! !
browseInstanceVariables:action:in:!browsing!private! !
browseMessageDefinitions:in:!operations!private! !
browseMessageDefinitionsIn:!operations!private! !
browseMessageReferences:in:!operations!private! !
browseMessageReferencesIn:!operations!private! !
browseMessageReferencesInHierarchyOf:within:!operations!private! !
browseMessagesMatching:in:!browsing!private! !
browseMessagesSentBy:in:!browsing!operations!private! !
browseMethod:!browsing!public! !
browseMethod:with:!browsing!private! !
browseMethodCategories:!browsing!public! !
browseMethodCategories:in:!browsing!public! !
browseMethodCategory!browsing!public! !
browseMethodHierarchyFrom:!browsing!public! !
browseMethodHierarchyFrom:in:!browsing!public! !
browseMethodProtocols:!browsing!public! !
browseMethodsIn:!browsing!public! !
browseMethodsIn:filter:!browsing!public! !
browseMethodsInEnvironments:!browsing!public! !
browseMethodsWithCompilationIssuesIn:!browsing!public! !
browseMethodsWithFullBlocks!public!utilities! !
browseMethodsWithNewBytecodes!browsing!public! !
browsePackages!browsing!commands-actions!public! !
browsePackages:!operations!public! !
browseProtocols!browsing!commands-actions!protocols!public! !
browseReferencesMatching:in:!browsing!private! !
browseReferencesTo:!browsing!public! !
browseReferencesToClassVar:of:within:!browsing!private! !
browseReferencesToClassVars:of:within:!browsing!private! !
browseReferencesToGlobal:!browsing!public! !
browseReferencesToGlobal:in:!browsing!public! !
browseReferencesToInstVar:inHierarchyOf:within:!browsing!private! !
browseReferencesToInstVars:inHierarchyOf:within:!browsing!private! !
browseReferencesToLiteral:in:!browsing!public! !
browseReferencesToVariable:!browsing!public! !
browserEnvFromDom:!public! !
browserEnvironment!accessing!public! !
browserEnvironmentForClasses:!browsing!public! !
browseResourceIdentifier:!operations!public! !
browseResources!browsing!commands-actions!public! !
browseResourcesReferencingView:!browsing!public! !
browseSelectors:caption:environment:!browsing!private! !
browseSharedVariableReferences:in:!browsing!public! !
browseSystem!browsing!commands-actions!public! !
browseSystem:!browsing!public! !
browseSystemOnMethod:!browsing!public! !
browseSystemPackages:!browsing!public! !
browseTests!browsing!commands-actions!public! !
browseVariableReferences:in:!browsing!public! !
browseViewHierarchy:!browsing!public! !
buildAllSelectors!helpers!private! !
buildMessageMenu:forMethods:browseSelector:extraArgs:browseOtherSelector:!helpers!menus!private! !
buildSimpleSignatureFor:!autocompletion!helpers!private! !
buildSystemFolder!accessing!private! !
canChangeClassNamespaces:!enquiries!public! !
canRefactor!public!testing! !
canRenameClass:!enquiries!public! !
changedIcon!constants!private! !
changedMethodCategory!constants!private! !
changedMethodsIn:!public!searching! !
changedMethodsOfClasses:!enquiries!public! !
changedResources!public!searching! !
changeHistorySize!accessing!public! !
changeHistorySize:!accessing!public! !
changeManager!accessing!public! !
chooseClass!helpers!public! !
chooseClass:caption:allowNil:!operations!public! !
chooseDefaultPackage!commands-actions!public! !
chooseSelectorsInProtocol:forClass:!operations!private!protocols! !
chooseViewOf:!operations!public! !
classBrowserClasses!accessing!public! !
classChanged:!accessing!private! !
classChooserClass!options!public! !
classChooserClass:!options!public! !
classFileIn:!public!source filing! !
classFileOut:!public!source filing! !
classFilesType!constants!private! !
classHierarchy!accessing!public! !
clearSystemFolder!initializing!private! !
cloneClass:as:under:in:!private!refactoring! !
closeAll!commands-actions!public! !
compilationFailuresCategory!constants!private! !
compilationWarningClass!constants!private! !
compile:in:environment:categories:package:extraFlags:!operations!public! !
compilerNotification:!exceptions!private! !
compressChanges!commands-actions!public! !
compressSources!commands-actions!public! !
confirmRenameClass:to:!event handling!private! !
copyAllMethodsOf:to:changes:!private!refactoring! !
copyClass:!public!refactoring! !
createClassVariableAccessors:in:within:!public!refactoring! !
createSubclass:subclasses:!public!refactoring! !
createSubclassOf:!public!refactoring! !
createSubclassOf:inPackage:!public!refactoring! !
createVariableAccessors:classVariables:within:!public!refactoring! !
debuggerClass!options!public! !
debuggerClass:!options!public! !
defaultBrowserClass!options!public! !
defaultBrowserClass:!options!public! !
defaultFont!accessing!options!public! !
defaultFont:!accessing!options!public! !
defaultInspectorClass!options!public! !
defaultInspectorClass:!options!public! !
defaultMaxStack!accessing!public! !
defaultMaxStack:!accessing!public! !
defaultMethodCategories!accessing!public! !
defaultPackage!accessing!public! !
defaultPackage:!accessing!public! !
defaultParseContext!accessing!public! !
defaultPublishedAspectsLiteralsMapOf:!accessing!private!theming! !
definitionsMatching:inHierarchyOf:within:!enquiries!private! !
definitionsOf:!enquiries!private! !
deleteResource:!commands-actions!public! !
deprecatedIcon!constants!private! !
disassembleMethod:!public! !
disassemblyStylerClass!constants!public! !
displayItLocale!options!public! !
displayItLocale:!options!public! !
displayOn:!displaying!public! !
dolphinHomePage!commands-actions!public! !
dolphinNewsgroup!commands-actions!public! !
dolphinNewsgroupUrl!public! !
dolphinSmalltalkUrl!constants!private! !
dolphinWikiUrl!public! !
dolphinWikiWeb!commands-actions!public! !
dpiAwareness!accessing!high DPI!public! !
dpiAwareness:!accessing!public! !
dropClassFile:!operations!private! !
dropFile:!operations!private! !
dropPackageFile:!operations!private! !
dropScriptFile:!operations!private! !
dropTextFile:!operations!private! !
dropXmlFile:!operations!private! !
educationCenter!commands-actions!public! !
environment!constants!public! !
expressionStylerClass!constants!public! !
fileFileIn!commands-actions!public! !
fileNew!commands-actions!public! !
fileOpen!commands-actions!public! !
findDetails!accessing!private! !
findMatchingClass:in:!helpers!private! !
findSelectorValidationBlock!accessing!private! !
formatterClass!accessing!public! !
formatterClass:!accessing!public! !
hardResetGUI!commands-actions!public! !
hasTestBrowser!browsing!commands-actions!private! !
helpContents!commands-actions!operations!public! !
helpContentsTopic!constants!public! !
helpGuidedTour!commands-actions!operations!public! !
helpGuidedTourTopic!public! !
helpRootUrl!constants!public! !
helpTutorials!commands-actions!operations!public! !
helpTutorialsTopic!constants!public! !
helpWhatsNew!commands-actions!operations!public! !
helpWhatsNewTopic!constants!public! !
helpWhatsThis!commands-actions!public! !
hierarchyBrowserClass!options!public! !
hierarchyBrowserClass:!options!public! !
iconForMethod:!helpers!public! !
ideaSpaceFilesType!constants!private! !
imageFilesType!constants!private! !
includesImplementorsOf:!enquiries!public! !
initialize!initializing!private! !
initializeArgumentClasses!initializing!private! !
initializeFrom:!public! !
initializeSystemFolder!initializing!private! !
inspect:!operations!public! !
inspectVisualObject!commands-actions!public! !
installPackage:!operations!private! !
instVarAccessFilter:in:!helpers!private! !
instVarReaderFilter:in:!helpers!private! !
interruptHotKey!options!public! !
interruptHotKey:!options!public! !
isOAD!accessing!private!product! !
isRegisteredTool:!public!testing! !
keywordsAndArgsForSelector:!autocompletion!helpers!private! !
keywordsAndArgsOfMethod:!autocompletion!helpers!private! !
loadViewResource:inContext:!helpers!private! !
methodCategorizationPolicy!constants!private! !
methodExplorerClass!options!public! !
methodExplorerClass:!options!public! !
methodsContainingText:in:prompt:!private!searching! !
methodsThatFailedToCompileIn:!enquiries!public! !
methodStylerClass!constants!public! !
methodsWithBytecode:in:!enquiries!private! !
methodsWithCompilationIssuesIn:!private!searching! !
methodsWithNewBytecodes!enquiries!private! !
methodsWithNewBytecodesIn:!enquiries!private! !
methodWorkspaceClass!options!public! !
minimizeAll!commands-actions!public! !
modelClassFor:!accessing/classes!public! !
modelMethodFor:!accessing/classes!public! !
nameForArgument:!helpers!private! !
nameForBlockOfArity:!helpers!private! !
namespaceHierarchy!accessing!public! !
newCodeRefactoringToolFor:!helpers!public!refactoring! !
newMethodRefactoringToolFor:!helpers!public!refactoring! !
newWorkspace!commands-actions!public! !
nonDefaultPublishedAspectsLiteralsMapOf:!private!theming! !
nonDefaultSystemOptionsLiteralsMap!private!theming! !
nukeChangeHistory!private!refactoring! !
okToInstallPatchLevel:!patching!private! !
onAboutToDisplayMenu:!event handling!public! !
onClassAdded:!event handling!public! !
onClassCategorized:!event handling!public! !
onClassCommented:!event handling!public! !
onClassRemoved:!event handling!public! !
onClassUpdated:!event handling!public! !
onDragOverProtocol:!event handling!operations!protocols!public! !
onDropFiles:over:!event handling!private! !
onDropOverProtocol:!event handling!operations!protocols!public! !
onFileDropped:over:!event handling!private! !
onMethodAdded:!event handling!public! !
onMethodCategorized:!event handling!public! !
onMethodRemoved:!event handling!public! !
onMethodUpdated:!event handling!public! !
onProtocolRemoved:!event handling!operations!protocols!public! !
onProtocolUpdated:!event handling!operations!protocols!public! !
onSessionStopped!event handling!public! !
onTipTextRequired:query:!event handling!public! !
onVariableRemoved:!event handling!private! !
onVariableRenamed:from:!events!public! !
openHelpTopic:!operations!public! !
openHelpTopicForTool:!operations!public! !
openHelpUrl:!operations!public! !
openLocalHelpUrl:style:!operations!public! !
openTool:!operations!private! !
openUrl:!operations!public! !
openViewComposer!commands-actions!public! !
openViewComposerEmpty!commands-actions!public! !
openViewComposerOn:!browsing!public! !
openViewComposerOnNewViewFor:!commands-actions!public! !
openViewComposerOnViewOf:!commands-actions!public! !
openWorkspace!commands-actions!public! !
openWorkspace:!operations-startup!private! !
openXmlFile:!operations!private! !
overlappingObjectsError:!exceptions!private! !
pacFileDialogType!constants!private! !
packageBrowserClass!options!public! !
packageBrowserClass:!options!public! !
packagedResourceIdentifierDialogClass!options!public! !
packageFilesType!constants!private! !
packageInstallWarning:!operations!private! !
packageManager!accessing!public! !
packageOpenFileDialogTypes!constants!private! !
panic!commands-actions!public! !
patchLevel!patching!public! !
patchLevel:!patching!private! !
paxFileDialogType!constants!private! !
playSaveImageSound!commands-actions!private! !
poolDictionariesFolder!accessing!private! !
populateFolderMenu:tree:items:!commands-menus!private! !
populateToolsMenu:!commands-menus!private! !
populateWindowMenu:!commands-menus!private! !
populateWindowMenu:withShells:ofClasses:!commands-menus!private! !
preferAlternateInspectors!accessing!public! !
preferAlternateInspectors:!accessing!public! !
printBlockStatsOn:!public!utilities! !
printSignatureForKeywordsAndArgs:on:!autocompletion!helpers!private! !
privateMethodIcon!constants!private! !
privatePrefix!constants!private! !
privatizeMethod:!operations!private! !
promptForClass!public! !
promptForClassIn:!public! !
promptForClassName:!helpers!private! !
promptForClassVarName:in:prompt:caption:!helpers!private!refactoring! !
promptForDefinitionsOf:in:!browsing!private! !
promptForExpression:caption:!public! !
promptForInstVarName:in:prompt:caption:!helpers!private! !
promptForKeyValuePair:caption:!public! !
promptForReferencesTo:in:!private! !
promptForReferencesToGlobal:in:!browsing!private! !
promptForSearchString:caption:!browsing!private! !
promptForSelector:caption:!helpers!private! !
promptForSharedVariableName:!browsing!private! !
protocolBrowserClass!options!public! !
protocolBrowserClass:!options!public! !
publicizeMethod:!operations!private! !
publicMethodIcon!constants!private! !
queryCommand:!commands-queries!public! !
referencesTo:!enquiries!public! !
referencesTo:in:!enquiries!public! !
referencesToClass:in:!browsing!public! !
referencesToClassVar:of:within:!enquiries!private! !
referencesToInstVar:inHierarchyOf:within:!enquiries!public! !
referencesToLiteral:in:!enquiries!public! !
referencesToVariable:in:!enquiries!public! !
reformatAllMethodsIn:!operations!private! !
reformatSource:in:!operations!private! !
registerSystemEvents!initializing!private! !
registerTool:!accessing!public! !
removeClass:fromProtocol:!operations!private!protocols! !
removeClasses:!operations!public! !
removeMethod:!operations!public! !
removeMethod:changes:!operations!private! !
removeMethods:!operations!public! !
removeSelector:fromProtocol:!operations!protocols!public! !
removeSelectors:fromProtocol:!operations!protocols!public! !
removeSystemFolderIcon:!operations!public! !
removeSystemFolderIconNamed:!operations!public! !
removeSystemFolderIconsForClass:!event handling!private! !
renameClass:!operations!public! !
renameClass:to:!public!refactoring! !
renameClass:to:showChanges:!operations!public! !
renameClassVariable:in:!public!refactoring! !
renameClassVariable:in:within:!public!refactoring! !
renameClassVariable:to:in:!private!refactoring! !
renameClassVariable:to:in:within:!private!refactoring! !
renameInstanceVariable:in:!public!refactoring! !
renameInstanceVariable:in:within:!public!refactoring! !
renameInstanceVariable:to:in:!private!refactoring! !
renameInstanceVariable:to:in:within:!private!refactoring! !
renameVariable:to:!operations!public! !
requestPackageFileName:!operations!private! !
requiresDolphinPro:!helpers!public! !
resaveViewResourcesMatching:do:!public! !
resetPublishedAspectsToDefaultsFor:!operations!private!theming! !
resetSystemOptionsToDefaults!operations!private!theming! !
resourceBrowserClass!options!public! !
resourceBrowserClass:!options!public! !
resourceIdentifierDialogClass!options!public! !
resourceIdentifierDialogClass:!accessing!public! !
resourceManager!private! !
rootNamespace!constants!public! !
samplesFolder!accessing!private! !
samplesFolderIcon!initializing!private! !
sanitizeWindowTextForMenu:!helpers!private! !
saveDefaultPublishedAspectsOf:!operations!private!theming! !
saveImage!commands-actions!public! !
saveImageAs!commands-actions!public! !
selectMethods:in:withProgress:!private!searching! !
sessionManager!accessing!private! !
setClassCustomDrawAttributes:!helpers!private! !
showPrerequisitesForPackage:!helpers!public! !
showShellWithHandle:!private! !
showTranscript!commands-actions!public! !
signatureOfMethod:!autocompletion!helpers!private! !
smalltalkExit!commands-actions!public! !
smalltalkFilesType!constants!private! !
sourceManager!accessing!public! !
splashShowAtStartup!accessing!public! !
splashShowAtStartup:!accessing!public! !
stbSaveOn:!binary filing!public! !
stonOn:!public!ston! !
suggestedWord:!helpers!private! !
systemFolder!accessing!public! !
systemFolderClass!constants!public! !
systemFolderClass:!constants!public! !
systemFolderNamed:!accessing!private! !
systemOptions!accessing!public! !
testBrowserClass!options!public! !
toolBackgroundColor!accessing!public! !
toolBackgroundColor:!accessing!public! !
toolbarBitmapSize:!accessing!public! !
toolbarImageSize!accessing!public! !
toolsMenu!commands-menus!public! !
typeForArgumentClass:!helpers!private! !
unimplementedSelectorsIn:!enquiries!public! !
uninitialize!class hierarchy-removing!private! !
unregisterTool:!accessing!public! !
upgradeAllResourcesReferencingClassNamed:!helpers!public! !
userPreferencesIcon!initializing!private! !
validateCreateSubclass:!helpers!private!refactoring! !
validateNewClassVarName:for:!helpers!private!refactoring! !
validateNewInstanceVariableName:for:!enquiries!helpers!private! !
validateRenameInstVar:to:in:!helpers!private! !
viewComposerClass!constants!public! !
viewComposerClass:!options!public! !
viewResourcesMatching:do:!private!utilities! !
warnOfUndefinedSelectorsSentBy:!helpers!private! !
windowMenu!commands-menus!public! !
workspaceClass!options!public! !
workspaceClass:!options!public! !
workspaceShellClass!options!public! !
workspaceShellClass:!options!public! !
wrapText:indent:tabWidth:!public!utilities! !
wrapText:toWidth:indent:tabWidth:!public!utilities! !
!

Tools.SmalltalkSystem methodProtocol: #commandTarget attributes: #(#readOnly) selectors: #(#queryCommand:)!
Tools.SmalltalkSystem methodProtocol: #systemModel attributes: #() selectors: #(#allResourceIdentifiers #allSelectors #browserEnvironment #includesImplementorsOf: #methodsWithCompilationIssuesIn: #modelClassFor:)!

!Tools.SmalltalkSystem class methodsFor!

changedIcon
	"Private - Answer the icon to mark source objects that have been changed: ✨"

	^ChangedIcon!

commandAnnotations
	^CommandAnnotationsRegister.Current annotationsFor: self!

current
	"Answer the singleton instance of the receiver.
	N.B. Special boot handling to create this."

	Current isNil ifTrue: [Current := self basicNew initialize; yourself].
	^Current!

help: educationPage
	"Displays the education page specified by the <readableString> educationPage"

	self current openHelpTopic: educationPage!

icon
	"Answers an Icon that can be used to represent this class: 🐬"

	^(TextTileIcon text: Character dolphin color: SmalltalkSystemShell backcolor)
		textcolor: SmalltalkSystemShell textcolor;
		yourself!

initialize
	self initializeFileDrops.
	self addClassConstant: 'ChangedIcon'
		value: ((TextTileIcon text: $\x2728)
				textcolor: Color gold;
				yourself).	"Sparkles"
	ThemeColor
		addNamed: #toolBackground color: Color face3d;
		addNamed: #workspaceSelection color: (Color highlight alpha: 60)!

initializeFileDrops
	| fileDrops |
	fileDrops := LookupTable new
				at: 'cls' put: #dropClassFile:;
				at: 'txt' put: #dropTextFile:;
				at: 'xml' put: #dropXmlFile:;
				yourself.
	#('pac' 'pax') do: [:each | fileDrops at: each put: #dropPackageFile:].
	#('st' 'chg' 'sml') do: [:each | fileDrops at: each put: #dropScriptFile:].
	self addClassConstant: 'FileDrops' value: fileDrops!

new
	"Private - The receiver is a Singleton class; use #current"

	self shouldNotImplement!

publishedAspectsOfInstances
	"Answer a <LookupTable> of the <Aspect>s published by instances of the receiver."

	| aspects |
	aspects := super publishedAspectsOfInstances.
	#(#hierarchyBrowserClass #protocolBrowserClass #debuggerClass #methodExplorerClass #packageBrowserClass #resourceBrowserClass #viewComposerClass #workspaceClass #workspaceShellClass #classChooserClass #resourceIdentifierDialogClass #defaultInspectorClass #testBrowserClass #aboutBoxClass)
		do: 
			[:each |
			aspects add: ((Aspect name: each type: Presenter class)
						icon: SmalltalkToolShell icon;
						yourself)].
	#(#autoFormatMethodSource #backupOnImageSave #preferAlternateInspectors #splashShowAtStartup)
		do: [:each | aspects add: (Aspect boolean: each)].
	^aspects
		add: ((Aspect font: #defaultFont) category: #appearance; yourself);
		add: (Aspect
					choice: #formatterClass
					from: [(ClassCategory name: 'System-Compiler-Formatters') classes]
					type: Class);
		add: (Aspect integer: #changeHistorySize);
		add: (Aspect color: #toolBackgroundColor);
		add: (Aspect hotkey: #interruptHotKey);
		add: ((Aspect
					choice: #toolbarBitmapSize
					from: Toolbar.ImageSizes asSortedCollection
					type: Point)
					icon: External.SIZE icon;
					yourself);
		add: (Aspect
					choice: #defaultMaxStack
					from: #(32 64 96 128)
					type: Integer);
		add: (Aspect
					choice: #displayItLocale
					from: [{Locale smalltalk. Locale userDefault. Locale invariant}]
					type: Locale);
		add: (Aspect choice: #dpiAwareness
					from: {DpiAwareness unaware. DpiAwareness system. DpiAwareness perMonitor. DpiAwareness gdiScaled});
		yourself!

publishedEventsOfInstances
	"Answer a <Set> of <Symbol>s, being the names of all events published 
	by instances of the receiver."

	^super publishedEventsOfInstances
		add: #methodAdded:;
		add: #methodUpdated:;
		add: #methodRemoved:;
		add: #methodCategorized:;
		add: #classAdded:;
		add: #classUpdated:;
		add: #classRemoved:;
		add: #classCategorized:;
		add: #classCommented:;
		add: #variableRenamed:from:;
		add: #variableRemoved:;
		add: #protocolUpdated:;
		add: #protocolRemoved:;
		yourself!

registeredTools
	"Answers the collection of tools registered for the receiver"

	RegisteredTools isNil ifTrue: [RegisteredTools := IdentitySet new].
	^RegisteredTools!

registerTool: aToolClass
	"Adds aToolClass to the collection of registered tools for the receiver"

	self registeredTools add: aToolClass.
	(aToolClass class conformsToProtocol: #installableSystemTool) 
		ifTrue: [aToolClass registerAsToolWith: self]!

reset
	Current notNil ifTrue: [Current uninitialize].
	Current := nil.
	RegisteredTools := nil!

toolBackgroundColor
	^self current toolBackgroundColor!

uninitialize
	"Private - Uninitialize the receiver as it is about to be removed from the system."

	self reset.
	Color removeNamed: #toolBackground!

unregisterTool: aToolClass
	"Removes aToolClass from the collection of registered tools for the receiver."

	(aToolClass class conformsToProtocol: #installableSystemTool)
		ifTrue: [aToolClass unregisterAsToolWith: self].
	self registeredTools remove: aToolClass ifAbsent: nil! !

!Tools.SmalltalkSystem class categoriesForMethods!
changedIcon!constants!private! !
commandAnnotations!accessing!public! !
current!instance creation!public! !
help:!operations!public! !
icon!constants!public! !
initialize!initializing!public! !
initializeFileDrops!initializing!private! !
new!instance creation!private! !
publishedAspectsOfInstances!constants!public! !
publishedEventsOfInstances!events!public! !
registeredTools!accessing!public! !
registerTool:!accessing!public! !
reset!initializing!public! !
toolBackgroundColor!accessing!public! !
uninitialize!class hierarchy-removing!private! !
unregisterTool:!accessing!public! !
!

