"Filed out from Dolphin Smalltalk"!

Tools.ClassBrowserAbstract
	subclass: #'Tools.EnvironmentBrowserShell'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Tools.EnvironmentBrowserShell guid: (Core.GUID fromString: '{b6ccd231-d2fb-4d98-b006-6a3ba26a4849}')!

Tools.EnvironmentBrowserShell comment: ''!

!Tools.EnvironmentBrowserShell categoriesForClass!MVP-Presenters! !

!Tools.EnvironmentBrowserShell methodsFor!

browseExecutableManifest
	| filename |
	filename := FileOpenDialog new
				caption: 'Open Executable Manifest';
				fileTypes: #(#('XML Manifest Files (*.xml)' '*.xml') #('All Files (*.*)' '*.*'));
				defaultExtension: 'xml';
				showModal.
	filename isNil ifTrue: [^self].
	self browseExecutableManifestFile: filename!

browseExecutableManifestFile: filename
	self model: (self developmentSystem systemModelFromDeploymentLog: filename)!

browserEnvironment: aBrowserEnvironment 
	"Private - Set the <BrowserEnvironment> that defines the list of classes displayed in the receiver."

	classesPresenter
		browserEnvironment: aBrowserEnvironment;
		searchEnvironment: aBrowserEnvironment.
	methodBrowserPresenter searchEnvironment: aBrowserEnvironment.
	definitionPresenter searchEnvironment: aBrowserEnvironment.
	self caption: aBrowserEnvironment label!

browseUnimplemented
	"Open a method browser on all methods in the selected packages that themselves send a
	message which is not apparently implemented in any of those packages or their
	prerequisites."

	| environment unimplemented |
	environment := self searchEnvironment.
	unimplemented := environment unimplementedSelectors.
	self developmentSystem
		browseSelectors: unimplemented asSortedCollection
		caption: ('Unimplemented Selectors in <1p>' expandMacrosWith: environment)
		environment: environment!

createComponents
	"Create the presenters contained by the receiver"

	super createComponents.
	classesPresenter := self add: ClassListSelector new name: 'classes'!

createSchematicWiring
	super createSchematicWiring.
	classesPresenter
		when: #classCustomDrawAttributesRequired:
		send: #onClassCustomDrawAttributesRequired:
		to: self!

defaultHelpId
	^10895!

isMethodVisible: aCompiledMethod 
	^(self browserEnvironment includesMethod: aCompiledMethod) 
		and: [super isMethodVisible: aCompiledMethod]!

model: aSystemModel
	super model: aSystemModel.
	self browserEnvironment: aSystemModel browserEnvironment!

onClassCustomDrawAttributesRequired: anNMCUSTOMDRAW
	"Private - Reset the forecolor, as otherwise all classes will be drawn in the 'loose method' colour, which indicates that the class is included but not fully defined. Given that the purpose of the environment browser is to show a filtered view of full set of classes and their methods, it is not terribly useful to show all (or almost all) classes in the highlight colour. Instead we reserve the highlight colour for those classes that are in the hierarchy, but which are not installed in their namespace (i.e. unbound classes). These are also underlined to make them easier to identify."

	anNMCUSTOMDRAW forecolor: anNMCUSTOMDRAW view forecolor ?? Color.WindowText.
	(anNMCUSTOMDRAW subItem classInModel: model)
		ifNil: [(anNMCUSTOMDRAW
				forecolor: LooseMethodColor;
				font) isUnderlined: true]!

printBasicCaptionOn: aPuttableStream
	self browserEnvironment displayOn: aPuttableStream!

printCaptionForClass: aClass on: aWriteStream
	self printBasicCaptionOn: aWriteStream!

printCaptionForMethod: aCompiledMethod on: aWriteStream
	self printBasicCaptionOn: aWriteStream!

resetFor: aClass 
	"Reset the receiver to place it into a state required to display aClass"

	(self isLocalHierarchyMode 
		and: [(classesPresenter model filter value: aClass instanceClass) not]) 
			ifTrue: [self displayLocalHierarchyOf: aClass]!

saveStateOn: aWriteStream
	"Private - Write the source of a monadic block that will configure an instance of the receiver's class
	to match the state current receiver, to aWriteStream. The block expects a fresh instance of
	the receiver's class as it's parameter"

	aWriteStream nextPutAll: '[:anEnvironmentBrowser | anEnvironmentBrowser browserEnvironment: '.
	self browserEnvironment storeOn: aWriteStream.
	aWriteStream
		nextPut: $.;
		cr.
	super saveStateOn: aWriteStream.
	aWriteStream
		nextPutAll: ' value: anEnvironmentBrowser';
		cr.
	aWriteStream nextPut: $]!

searchEnvironment
	^model browserEnvironment! !

!Tools.EnvironmentBrowserShell categoriesForMethods!
browseExecutableManifest!commands-actions!public! !
browseExecutableManifestFile:!operations!public! !
browserEnvironment:!initializing!private! !
browseUnimplemented!commands-actions!public! !
createComponents!initializing!public! !
createSchematicWiring!initializing!public! !
defaultHelpId!constants!public! !
isMethodVisible:!private!testing! !
model:!accessing!public! !
onClassCustomDrawAttributesRequired:!helpers!private! !
printBasicCaptionOn:!private!updating! !
printCaptionForClass:on:!private!updating! !
printCaptionForMethod:on:!private!updating! !
resetFor:!operations!public! !
saveStateOn:!private!saved state! !
searchEnvironment!accessing!public! !
!

!Tools.EnvironmentBrowserShell class methodsFor!

displayOn: aStream
	"Append, to aStream, a String whose characters are a representation of the receiver as a user
	would want to see it."

	aStream nextPutAll: 'Environment Browser'!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

initializeTool
	"
	self initializeTool
	"

	SmalltalkSystem current
		addSystemFolderIcon: self toolsFolderIcon;
		registerTool: self!

onEnvironment: aBrowserEnvironment
	^self showOn: (RBModel onEnvironment: aBrowserEnvironment)!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ShellView} 38 #{Core.Array} 27 nil nil 8 #(13565952 65536) 32 nil 518 #{Graphics.ThemeColor} #toolBackground nil 533 nil nil nil 32 1798 #{UI.BorderLayout} 1 1 18 #{UI.Toolbar} 50 28 nil 32 50 2 8 1140853580 131073 160 nil nil nil 517 nil 1350 1 #{Graphics.Font} nil true 262 #{OS.LOGFONTW} 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 0 65 0 114 0 105 0 97 0 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 193 nil nil 160 6 #{Graphics.Color} #default nil 518 #{Kernel.STBIdentityDictionaryProxy} #{Core.IdentityDictionary} 50 10 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 384 nil nil nil 5 nil nil nil 384 582 1 #{UI.ResourceIdentifier} #{UI.Toolbar} #resource_Class_browser_tools nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[134 2 0 0 0 0 0 0 54 3 0 0 25 0 0 0] 193 416 8 '' 384 3 8 #() 518 #{Graphics.Point} 193 193 nil 27 8 'classBrowserTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 736 nil nil nil 5 nil nil nil 736 450 #{UI.Toolbar} #resource_Edit_tools nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[11 2 0 0 0 0 0 0 134 2 0 0 25 0 0 0] 193 768 8 '' 736 3 672 690 193 193 nil 27 8 'editTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 976 nil nil nil 5 nil nil nil 976 450 #{UI.Toolbar} #resource_Image_tools nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 31 0 0 0 25 0 0 0] 193 1008 8 '' 976 3 672 690 193 193 nil 27 8 'imageTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 1216 nil nil nil 5 nil nil nil 1216 450 #{UI.Toolbar} #resource_Search_tools nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[51 1 0 0 0 0 0 0 11 2 0 0 25 0 0 0] 193 1248 8 '' 1216 3 672 690 193 193 nil 27 8 'searchTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 1456 nil nil nil 5 nil nil nil 1456 450 #{UI.Toolbar} #resource_Smalltalk_tools nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[31 0 0 0 0 0 0 0 51 1 0 0 25 0 0 0] 193 1488 8 '' 1456 3 672 690 193 193 nil 27 8 'smalltalkTools' nil nil nil nil 550 #{Core.OrderedCollection} 0 nil nil 9 1645 #smallIcons nil nil 838 1 #{UI.FlowLayout} 1 1 1 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 81 3 0 0 25 0 0 0] 193 192 8 '' 160 3 50 5 976 1456 1216 736 384 690 193 193 nil 31 18 #{UI.StatusBar} 50 21 nil 32 50 2 8 1140853004 1 1920 nil nil nil 5 nil 226 nil true 258 8 #[245 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 0 77 0 105 0 99 0 114 0 111 0 115 0 111 0 102 0 116 0 32 0 83 0 97 0 110 0 115 0 32 0 83 0 101 0 114 0 105 0 102 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 193 nil nil 1920 nil nil 338 #{Core.IdentityDictionary} 50 6 1862 1 #{UI.StatusBarItem} 8193 -1 1920 nil 518 #{Core.Message} #displayString 8 #() 2098 #iconImageIndex 2128 nil 8 'message' 2066 8705 351 1920 nil 2098 #displayString 8 #() 2098 #iconImageIndex 8 #() 1382 3 #{Kernel.BlockClosure} 0 nil 1318 #{Kernel.CompiledExpression} 4 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:namespace | ''Method namespace: '', namespace fullName]' 8 #[32 105 29 226 1 178 106] 8 'Method namespace: ' #fullName #, 2272 7 257 nil 8 'namespace' 2066 8193 501 1920 nil 2112 2144 nil 8 'packageOfSelection' nil nil nil 50 3 2400 2080 2176 1094 1 #{UI.StatusBarNullItem} 8705 1 1920 nil nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 168 1 0 0 81 3 0 0 190 1 0 0] 193 1952 8 '' 1920 3 8 #() 690 193 193 nil 29 nil nil 18 #{UI.ContainerView} 50 15 nil 32 50 2 8 1140850688 131073 2640 nil nil nil 5 nil nil nil 2640 518 #{UI.ProportionalLayout} 518 #{Kernel.STBCollectionProxy} #{Core.Dictionary} 50 1 518 #{Core.Association} 18 #{UI.Splitter} 50 12 nil 2640 50 2 8 1140850688 1 2816 nil nil nil 517 nil nil nil 3142 1 #{UI.DraggableViewInteractor} 2816 nil 1 #left nil nil nil 690 1 1 690 9 9 nil 2912 nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 197 0 0 0 81 3 0 0 202 0 0 0] 193 2848 8 '' 2816 3 8 #() 690 193 193 nil 27 1 true 338 #{Core.IdentityDictionary} 50 2 18 #{UI.CardContainer} 50 16 nil 2640 50 2 8 1140850688 131073 3136 nil nil nil 5 nil nil nil 3136 1350 1 #{UI.CardLayout} 1698 2 2786 838 1 #{UI.CardLabel} 8 'Method Source' 2258 0 nil 2290 7 1 3264 8 'doIt' 8 '(CardLabel text: ''Method Source'' iconBlock: [Icon fromId: ''MethodSource.ico''])' 8 #[45 30 35 113 47 32 180 106 195 105] 1094 2 #{Kernel.VariableBinding} #CardLabel 3264 #{UI} 1 3296 3394 #Icon #{Graphics.Icon} #{Graphics} 1 8 'MethodSource.ico' #fromId: #text:iconBlock: 3312 11 1 nil nil 18 #{UI.ReferenceView} 50 14 nil 3136 50 2 8 1140850688 131073 3456 nil nil nil 5 nil nil nil 3456 450 #{Tools.MethodWorkspace} #resource_Default_view nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[4 0 0 0 24 0 0 0 77 3 0 0 193 0 0 0] 193 3488 8 '' 3456 3 672 690 193 193 nil 27 2786 3266 8 'Class definition' 2258 0 nil 2290 7 1 3264 8 'doIt' 8 '(CardLabel text: ''Class definition'' iconBlock: [Icon fromId: ''ClassDefinition.ico''])' 8 #[45 30 35 113 47 32 180 106 195 105] 3408 3712 3424 8 'ClassDefinition.ico' #fromId: #text:iconBlock: 3728 11 1 nil nil 18 #{UI.ReferenceView} 50 14 nil 3136 50 2 8 1140916224 131073 3824 nil 320 nil 21 nil nil nil 3824 450 #{Tools.SmalltalkWorkspace} #resource_Default_view nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[4 0 0 0 24 0 0 0 77 3 0 0 193 0 0 0] 193 3856 8 '' 3824 1 672 690 193 193 nil 27 3456 nil nil nil 338 #{Core.IdentityDictionary} 50 4 3824 8 'definition' 3456 8 'source' nil 18 #{UI.TabViewXP} 50 28 nil 3136 50 2 8 1140916736 1 4112 838 2 #{UI.ListModel} 1698 2 3280 3696 nil 6 #{Kernel.IdentitySearchPolicy} nil nil 1 nil nil nil 4112 nil nil 2112 2144 1350 1 #{Graphics.IconImageManager} nil nil nil nil nil #smallIcons nil nil nil nil nil 482 50 3 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 81 3 0 0 197 0 0 0] 193 4144 8 '' 4112 530 #setSingleSelection: 8 #(1) 4112 530 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4112 3 8 #() 690 193 193 nil 27 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 202 0 0 0 81 3 0 0 143 1 0 0] 193 3168 8 '' 3136 3 50 3 3456 3824 4112 690 193 193 nil 27 8 'cards' nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 25 0 0 0 81 3 0 0 168 1 0 0] 193 2672 8 '' 2640 3 50 3 18 #{UI.ContainerView} 50 15 nil 2640 50 2 8 1140850688 131073 4832 nil nil nil 5 nil nil nil 4832 2706 2738 #{Core.Dictionary} 50 2 2786 18 #{UI.Splitter} 50 12 nil 4832 50 2 8 1140850688 1 4960 nil nil nil 517 nil nil nil 2882 4960 nil 1 #left nil nil nil 2912 2928 nil 2912 nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[23 1 0 0 0 0 0 0 28 1 0 0 197 0 0 0] 193 4992 8 '' 4960 3 8 #() 690 193 193 nil 27 1 2786 18 #{UI.Splitter} 50 12 nil 4832 50 2 8 1140850688 1 5216 nil nil nil 517 nil nil nil 2882 5216 nil 1 #left nil nil nil 2912 2928 nil 2912 nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[51 2 0 0 0 0 0 0 56 2 0 0 197 0 0 0] 193 5248 8 '' 5216 3 8 #() 690 193 193 nil 27 1 false 338 #{Core.IdentityDictionary} 50 4 18 #{UI.ReferenceView} 50 14 nil 4832 50 2 8 1140850688 131073 5488 nil nil nil 29 2886 4 #{UI.Menu} nil true 50 17 1094 2 #{UI.CommandMenuItem} 1 1350 4 #{UI.CommandDescription} #findClass 8 'Find…' 1 1 838 4 #{Graphics.Icon} nil true 1030 #{Graphics.ImageFromStringResourceInitializer} 8 'FindClass.ico' 838 1 #{External.ResourceLibrary} 8 'dolphindr8.dll' 65541 nil nil nil 5554 nil true 50 10 5602 1 5634 #browseClassPackage 8 'Package <d>' 1 1 5682 nil true 5714 8 'Package.ico' 5776 65541 nil nil nil 326 1 #{UI.DividerMenuItem} 4097 5602 2097153 5634 #browseClassReferences 8 '&Class References' 1 1 nil nil nil 5554 nil true 8 #() 8 'Re&ferences To' #browseVariablesMenu 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #browseChangedMethods 8 'Changed &Methods' 1 1 nil nil nil 5602 1 5634 #browseMethodHistoryForClass 8 'Method &History' 1 1 nil nil nil 5938 4097 5602 1 5634 #browsePublishedEvents 8 'Published &events' 1 1 nil nil nil 5602 1 5634 #browsePublishedAspects 8 'Published &aspects' 1 1 nil nil nil 8 '&Browse' #browseMenu 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #newClass 8 '&New…' 1 1 5682 nil true 5714 8 'NewClass.ico' 5776 65541 nil nil nil 5602 1 5634 #removeClass 8 'Re&move' 1 1 5682 nil true 5714 8 'ClassDelete.ico' 5776 65541 nil nil nil 5554 nil true 50 17 5602 2097153 5634 #renameClass 8 'Re&name…' 1 1 nil nil nil 5938 4097 5602 1 5634 #addInstanceVariable 8 'Add <1s>&Instance Variable…' 1 1 nil nil nil 5602 1 5634 #addClassVariable 8 'Add &Class Variable…' 1 1 nil nil nil 5554 nil true 8 #() 8 'Re&move Variable' #removeVariables 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Ren&ame Variable' #renameVariables 134217729 nil nil nil nil nil 5938 4097 5554 nil true 8 #() 8 'Push &Down' #pushDownVariables 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Pull &Up' #pullUpVariables 134217729 nil nil nil nil nil 5938 4097 5554 nil true 8 #() 8 'Cr&eate Accessors' #createVariableAccessors 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'A&bstract' #abstractVariables 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 '&Protect/Concrete' #protectVariables 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #convertToSibling 8 'Con&vert to Sibling…' 1 1 nil nil nil 5938 4097 5602 1 5634 #removeDuplicateMethods 8 'Remove Dup&licate Methods' 1 1 nil nil nil 8 '&Refactorings' #classRefactoringsMenu 134217729 5682 nil true 5714 8 'Refactoring.ico' 5776 65541 nil nil nil nil nil 5938 4097 5602 1 5634 #createInstanceVariableAccessors 8 'Create &Accessors…' 1 1 nil nil nil 5602 1 5634 #reformatAll 8 'Re&format All' 1 1 nil nil nil 5938 4097 5602 1 5634 #fileInClass 8 'File &In…' 1 1 nil nil nil 5602 1 5634 #fileOutClass 8 'File &Out…' 1 1 nil nil nil 5938 4097 5602 1 5634 #classPackage 8 '&Package…' 1 1 5682 nil true 5714 8 'Package.ico' 5776 65541 nil nil nil 5602 1 5634 #categorizeClass 8 '&Category…' 1 1 nil nil nil 5938 4097 5554 nil true 50 4 5602 1 5634 #newView 8 '&New…' 1 1 nil nil nil 5938 4097 5554 nil true 8 #() 8 '&Edit' #viewsEditMenu 1 nil nil nil nil nil 5554 nil true 8 #() 8 '&Show' #viewsShowMenu 1 nil nil nil nil nil 8 '&Views' #viewsMenu 1 5682 nil true 5714 8 'View.ico' 5776 65541 nil nil nil nil nil 8 '&Class' nil 134217729 nil nil nil nil nil nil nil 5488 450 #{Tools.ClassListSelector} #resource_Default_view nil 482 50 2 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 23 1 0 0 197 0 0 0] 193 5520 8 '' 5488 530 #contextMenu: 50 1 5568 5488 3 672 690 193 193 nil 27 8 'classes' 18 #{UI.SlideyInneyOuteyThing} 50 23 nil 4832 50 2 8 1140850688 131073 8144 nil nil nil 517 nil nil nil 8144 3202 1698 3 2786 3266 8 'Categories' 2258 0 nil 2290 3 1 2256 8 'doIt' 8 '[MethodCategory icon] 
' 8 #[31 105 45 159 106] 3394 #MethodCategory #{Core.MethodCategory} #{Core} 1 #icon 8288 7 1 nil 21481 18 #{UI.TreeView} 50 35 nil 18 #{UI.SlidingCardTray} 50 22 nil 8144 50 2 8 1140850688 131073 8416 nil nil nil 5 nil nil nil 8416 8208 338 #{Core.IdentityDictionary} 50 6 8384 8 'categories' 18 #{UI.ListView} 50 45 nil 8416 50 2 8 1140936777 1 8528 4178 1698 0 nil 4240 320 nil 29 5554 nil true 50 7 5602 1 5634 #browseSelectorsInProtocol 8 '&Selectors' 1 1 nil nil nil 5602 1 5634 #toggleProtocolReadOnly 8 '&Read Only' 1 1 nil nil nil 5938 4097 5602 1 5634 #addMethodProtocol 8 '&Add…' 1 1 nil nil nil 5554 nil true 50 2 5602 1 5634 #removeMethodProtocol 8 'Protocol' 1 1 nil nil nil 5602 1 5634 #removeMethodsInProtocol 8 'Methods' 1 1 nil nil nil 8 'Remove' nil 1 nil nil nil nil nil 5602 1 5634 #renameMethodProtocol 8 'Rename…' 1 1 nil nil nil 5602 1 5634 #browseMethodProtocol 8 'Browse' 1 1 nil nil nil 8 'Protocols' nil 134217729 nil nil nil nil nil nil nil 8528 nil nil 2098 #name 8 #() 2098 #iconImageIndex 8 #() 4272 nil nil 2258 0 nil 2290 5 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:ctx | ctx view presenter parentPresenter customDrawProtocols: ctx]' 8 #[33 105 226 0 159 160 17 179 106] #view #presenter #parentPresenter #customDrawProtocols: 9136 7 257 nil 690 65 65 nil nil 1698 1 3142 5 #{UI.ListViewColumn} 8 'Protocols' 451 #left 2098 #name 8 #() 2098 #<= 8 #() nil nil 8528 nil 3 nil 2258 0 nil 2290 5 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:ctx | ctx view presenter parentPresenter customDrawProtocols: ctx]' 8 #[33 105 226 0 159 160 17 179 106] #view #presenter #parentPresenter #customDrawProtocols: 9360 7 257 nil #report 8 #() nil 133217 nil 1 nil nil nil nil 1 262 #{UI.ListViewVirtualUpdateMode} 8528 nil nil nil nil nil nil nil nil nil 482 50 2 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 18 0 0 0 225 0 0 0 189 0 0 0] 193 8560 8 'Protocols' 8528 530 #contextMenu: 50 1 8624 8528 1 8 #() 690 193 193 nil 35 8 'protocols' 18 #{UI.ListView} 50 45 nil 8416 50 2 8 1140920395 1 9696 4178 1698 0 nil 4240 320 nil 13 5554 nil true 50 10 5602 2097153 5634 #browseInstanceVariableReferences 8 'Browse &References' 1 1 nil nil nil 5938 4097 5602 1 5634 #addInstanceVariable 8 '&Add…' 1 1 nil nil nil 5602 1 5634 #removeInstanceVariables 8 'Remo&ve' 1 1 nil nil nil 5602 1 5634 #renameInstanceVariable 8 'Re&name' 1 1 nil nil nil 5938 4097 5602 1 5634 #pushDownInstanceVariables 8 'Push &Down' 1 1 nil nil nil 5602 1 5634 #createAccessors 8 '&Create Accessors' 1 1 nil nil nil 5602 1 5634 #abstractInstanceVariables 8 'Ab&stract' 1 1 nil nil nil 5602 1 5634 #protectInstanceVariables 8 '&Protect/Concrete' 1 1 nil nil nil nil nil 134217729 nil nil nil nil nil nil nil 9696 nil nil 2098 #value 8 #() 2258 0 nil 2290 4 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a | a key icon imageIndex]' 8 #[32 105 17 158 159 160 106] #key #icon #imageIndex 10272 7 257 nil 4272 nil 2258 0 nil 2290 5 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:a | a key name, ''.'', a value]' 8 #[33 105 17 158 159 31 179 17 142 179 106] #key #name 8 '.' #, 10352 7 257 nil nil 690 65 65 nil nil 1698 1 9250 8 '' 201 #left 2098 #displayString 9120 2098 #<= 8 #() nil nil 9696 nil 1 nil nil #list 9440 nil 133217 nil 1 nil nil nil nil 1 9458 9696 nil nil nil nil nil nil nil nil nil 482 50 2 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 18 0 0 0 225 0 0 0 189 0 0 0] 193 9728 8 '' 9696 530 #contextMenu: 50 1 9792 9696 1 8 #() 690 193 193 nil 35 8 'variables' nil 18 #{UI.TabViewXP} 50 28 nil 8144 50 2 8 1140916864 1 10784 4178 1698 3 8256 3266 8 'Protocols' 2258 0 nil 2290 3 1 2256 8 'doIt' 8 '[MethodProtocol icon]' 8 #[31 105 45 159 106] 3394 #MethodProtocol #{Kernel.MethodProtocol} #{Kernel} 1 #icon 10912 7 1 nil 21487 3266 8 'Variables' nil 21491 nil 4240 nil nil 1 nil nil nil 10784 nil nil 10512 9104 4272 nil nil nil nil nil #smallIcons nil nil nil nil nil 482 50 3 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 23 1 0 0 197 0 0 0] 193 10816 8 '' 10784 530 #setSingleSelection: 8 #(1) 10784 530 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 10784 3 8 #() 690 193 193 nil 27 nil 8144 690 33 33 1606 1 #{UI.ButtonInteractor} 8416 nil 1 518 #{Graphics.Rectangle} 690 415 3 690 447 35 nil 5634 #togglePin 8 'Pin or Unpin the tray' 1 1 nil nil nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[50 0 0 0 4 0 0 0 19 1 0 0 193 0 0 0] 193 8448 8 '' 8416 3 50 3 8384 8528 9696 690 193 193 nil 27 50 2 8 1140916771 1 8384 1094 3 #{UI.TreeModel} nil 4240 774 #{UI.TreeNode} nil nil nil 550 #{Core.IdentityDictionary} 0 320 nil 29 5554 nil true 50 4 5602 1 5634 #addMethodCategory 8 '&Add…' 1 1 nil nil nil 5554 nil true 50 2 5602 1 5634 #removeMethodCategory 8 'Category' 1 1 nil nil nil 5602 1 5634 #removeMethodsInCategory 8 'Methods' 1 1 nil nil nil 8 'Remove' nil 1 nil nil nil nil nil 5602 1 5634 #renameMethodCategory 8 'Rename…' 1 1 nil nil nil 5602 1 5634 #browseMethodCategory 8 'Browse' 1 1 nil nil nil 8 'Categories' nil 134217729 nil nil nil nil nil nil nil 8384 nil nil 2098 #localName 8 #() 9104 4272 nil nil 2258 0 nil 2290 5 1 #{Core.UndefinedObject} 8 'doIt' 8 '[:ctx | ctx view presenter parentPresenter customDrawCategoryTree: ctx]' 8 #[33 105 226 0 159 160 17 179 106] #view #presenter #parentPresenter #customDrawCategoryTree: 12064 7 257 nil nil nil 550 #{Core.LookupTable} 0 nil #noIcons 1 11666 0 1 262 #{UI.TreeViewDynamicUpdateMode} 8384 nil nil nil nil nil nil 482 50 2 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 18 0 0 0 225 0 0 0 189 0 0 0] 193 11568 8 '' 8384 530 #contextMenu: 50 1 11696 8384 3 8 #() 690 193 193 nil 29 2786 10880 8528 2786 11008 9696 8384 nil nil nil 338 11664 50 2 8416 8 'filters' nil 10784 8416 690 201 201 401 1 524319 nil nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[28 1 0 0 0 0 0 0 51 2 0 0 197 0 0 0] 193 8176 8 '' 8144 3 50 2 8416 10784 690 193 193 nil 27 8 'filtersSlidey' nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 81 3 0 0 197 0 0 0] 193 4864 8 '' 4832 3 50 5 5488 4960 8144 5216 18 #{UI.ContainerView} 50 15 nil 4832 50 2 8 1140850688 131073 12832 nil nil nil 5 nil nil nil 12832 130 1 1 nil 18 #{UI.ContainerView} 50 15 nil 12832 50 2 8 1140850688 131073 12912 nil nil nil 533 nil nil nil 12912 1730 11 1 1 338 11664 50 4 18 #{UI.RadioButton} 50 16 nil 12912 50 2 8 1141055497 1 13024 1094 2 #{UI.ValueHolder} nil nil 518 #{Kernel.PluggableSearchPolicy} 2098 #= 8 #() 2098 #hash 8 #() false nil nil 517 nil nil nil 13024 nil nil 518 #{UI.NullConverter} nil nil nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[77 0 0 0 3 0 0 0 122 0 0 0 20 0 0 0] 193 13056 8 'C&lass' 13024 3 8 #() 690 193 193 nil 27 8 'classMode' 18 #{UI.RadioButton} 50 16 nil 12912 50 2 8 1141055497 1 13424 13090 nil nil 13122 2098 #= 8 #() 2098 #hash 8 #() false nil nil 517 nil nil nil 13424 nil nil 13218 nil nil nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[10 0 0 0 3 0 0 0 72 0 0 0 20 0 0 0] 193 13456 8 'In&stance' 13424 3 8 #() 690 193 193 nil 27 8 'instanceMode' 11314 690 21 7 690 1 7 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 174 0 0 0 25 1 0 0 197 0 0 0] 193 12944 8 '' 12912 3 50 2 13424 13024 690 193 193 nil 27 nil nil 18 #{UI.ReferenceView} 50 14 nil 12832 50 2 8 1140850688 131073 13984 nil nil nil 29 nil nil nil 13984 450 #{Tools.MethodBrowser} #resource_Class_browser_method_list nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 25 1 0 0 174 0 0 0] 193 14016 8 '' 13984 3 672 690 193 193 nil 27 338 11664 50 4 13984 8 'methods' 12912 8 'mode' nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[56 2 0 0 0 0 0 0 81 3 0 0 197 0 0 0] 193 12864 8 '' 12832 3 50 2 12912 13984 690 193 193 nil 27 690 193 193 nil 27 2816 3136 690 193 193 nil 27 338 11664 50 4 1920 8 'statusbar' 160 8 'toolbar' nil 2886 4 #{UI.MenuBar} nil true 50 9 5554 nil true 50 10 5602 1 5634 #fileNew 8 '&New Workspace' 9373 1 5682 nil true 5714 8 'NewWorkspace.ico' 5776 65541 nil nil nil 5602 1 5634 #fileOpen 8 '&Open Workspace…' 9375 1 5682 nil true 5714 8 'OpenWorkspace.ico' 5776 65541 nil nil nil 5602 1 5634 #fileFileIn 8 '&File In…' 1 1 5682 nil true 5714 8 'FileIn.ico' 5776 65541 nil nil nil 5938 4097 5602 1 5634 #browseExecutableManifest 8 'Open &Executable Manifest…' 1 1 5682 nil true 5714 8 'FileOpen.ico' 5776 65541 nil nil nil 5938 4097 5602 1 5634 #saveImage 8 'Sa&ve Image' 1 1 5682 nil true 5714 8 'Snapshot.ico' 5776 65541 nil nil nil 5602 1 5634 #smalltalkExit 8 'E&xit Dolphin' 1 1 5682 nil true 5714 8 'PowerSwitch.ico' 5776 65541 nil nil nil 5938 4097 5602 1 5634 #exit 8 '&Close' 17639 1 2374 2 #{Graphics.TextTileIcon} 8 $✖ nil nil nil nil nil 1 nil nil nil nil 8 '&File' nil 134217729 nil nil nil nil nil 5554 nil true 50 13 5602 1 5634 #undo 8 '&Undo' 9397 1 5682 nil true 5714 8 'EditUndo.ico' 5776 65541 nil nil nil 5938 4097 5602 1 5634 #cutSelection 8 'Cu&t' 9393 1 5682 nil true 5714 8 'EditCut.ico' 5776 65541 nil nil nil 5602 1 5634 #copySelection 8 '&Copy' 9351 1 5682 nil true 5714 8 'EditCopy.ico' 5776 65541 nil nil nil 5602 1 5634 #pasteClipboard 8 '&Paste' 9389 1 5682 nil true 5714 8 'EditPaste.ico' 5776 65541 nil nil nil 5602 1 5634 #editDelete 8 '&Delete' 1 1 5682 nil true 5714 8 'EditClear.ico' 5776 65541 nil nil nil 5554 nil true 50 2 5602 1 5634 #reformatSource 8 '&Source' 9391 1 nil nil nil 5602 1 5634 #reformatComment 8 '&Comment' 9367 1 nil nil nil 8 'Ref&ormat' nil 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #selectAll 8 'Select &All' 9347 1 nil nil nil 5938 4097 5602 1 5634 #editFind 8 '&Find…' 9357 1 5682 nil true 1030 #{Graphics.ImageFromResourceInitializer} 47 262 #{OS.ShellLibrary} 65541 nil nil nil 5602 1 5634 #findNext 8 'Find &Next' 1253 1 5682 nil true 5714 8 'FindNext.ico' 5776 65541 nil nil nil 5602 1 5634 #findReplace 8 '&Replace…' 9361 1 nil nil nil 8 '&Edit' nil 134217729 nil nil nil nil nil 5554 nil true 50 15 5602 1 5634 #browseIt 8 '&Browse <d:It>' 9349 17 5682 nil true 5714 8 'ClassBrowserShell.ico' 5776 65541 nil nil nil 5602 1 5634 #displayIt 8 '&Display It' 9353 1 5682 nil true 5714 8 'DisplayIt.ico' 5776 65541 nil nil nil 5602 1 5634 #printIt 8 '&Print It' 9377 1 5682 nil true 5714 8 'PrintIt.ico' 5776 65541 nil nil nil 5602 1 5634 #evaluateIt 8 '&Evaluate It' 9355 1 5682 nil true 5714 8 'EvaluateIt.ico' 5776 65541 nil nil nil 5602 1 5634 #inspectIt 8 '&Inspect It' 9363 1 5682 nil true 5714 8 'InspectIt.ico' 5776 65541 nil nil nil 5602 1 5634 #debugIt 8 'Deb&ug It' 1269 1 5682 nil true 5714 8 'Debugger.ico' 5776 65541 nil nil nil 5602 1 5634 #fileItIn 8 'Fi&le It In' 1 1 nil nil nil 5938 4097 5602 1 5634 #browseDefinitions 8 'Defi&nitions' 1271 1 nil nil nil 5602 1 5634 #browseReferences 8 '&References' 5367 1 nil nil nil 5938 4097 5602 2097153 5634 #accept 8 '&Accept' 9383 1 nil nil nil 5602 1 5634 #reformatAccept 8 'Refor&mat/Accept' 13479 1 nil nil nil 5938 4097 5554 nil true 50 13 5602 1 5634 #renameVariable 8 'Re&name <d:Variable>…' 1 17 5682 nil true 5714 8 'Rename.ico' 5776 65541 nil nil nil 5938 4097 5602 1 5634 #extractToTemporary 8 'Extract to &Temporary…' 9385 1 nil nil nil 5602 1 5634 #extractMethod 8 'E&xtract Method…' 9371 1 nil nil nil 5602 1 5634 #extractToComponent 8 'Extract to &Component…' 1 1 nil nil nil 5602 1 5634 #inlineMessage 8 'Inline &Message' 13467 1 nil nil nil 5938 4097 5602 1 5634 #inlineTemporary 8 '&Inline Temporary' 13481 1 nil nil nil 5602 1 5634 #moveTempToInnerScope 8 'Move to Inner &Scope' 9655 1 nil nil nil 5602 1 5634 #convertTempToInstVar 8 'Con&vert to Instance Variable' 1 1 nil nil nil 5938 4097 5602 1 5634 #inlineParameter 8 'In&line Parameter' 1 1 nil nil nil 5602 1 5634 #removeParameter 8 'Remove &Parameter' 1 1 nil nil nil 8 'Re&factorings' #codeRefactoringsMenu 134217729 5682 nil true 5714 8 'Refactoring.ico' 5776 65541 nil nil nil nil nil 8 '&Workspace' nil 134217729 nil nil nil nil nil 5554 nil true 50 17 5602 2097153 5634 #findClass 8 'Find…' 1 1 5682 nil true 5714 8 'FindClass.ico' 5776 65541 nil nil nil 5554 nil true 50 10 5602 1 5634 #browseClassPackage 8 'Package <d>' 1 17 5682 nil true 5714 8 'Package.ico' 5776 65541 nil nil nil 5938 4097 5602 2097153 5634 #browseClassReferences 8 '&Class References' 1 1 nil nil nil 5554 nil true 8 #() 8 'Re&ferences To' #browseVariablesMenu 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #browseChangedMethods 8 'Changed &Methods' 1 1 nil nil nil 5602 1 5634 #browseMethodHistoryForClass 8 'Method &History' 1 1 5682 nil true 5714 8 'MethodHistory.ico' 5776 65541 nil nil nil 5938 4097 5602 1 5634 #browsePublishedEvents 8 'Published &events' 1 1 5682 nil true 5714 8 'Event.ico' 5776 65541 nil nil nil 5602 1 5634 #browsePublishedAspects 8 'Published &aspects' 1 1 nil nil nil 8 '&Browse' #browseMenu 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #newClass 8 '&New…' 1 1 5682 nil true 5714 8 'NewClass.ico' 5776 65541 nil nil nil 5602 1 5634 #removeClass 8 'Re&move' 1 1 5682 nil true 5714 8 'ClassDelete.ico' 5776 65541 nil nil nil 5554 nil true 50 18 5602 2097153 5634 #renameClass 8 'Re&name…' 1 1 5682 nil true 5714 8 'Rename.ico' 5776 65541 nil nil nil 5602 1 5634 #copyClass 8 'Cl&one…' 1 1 nil nil nil 5938 4097 5602 1 5634 #addInstanceVariable 8 'Add <1s>&Instance Variable…' 1 17 nil nil nil 5602 1 5634 #addClassVariable 8 'Add &Class Variable…' 1 1 nil nil nil 5554 nil true 8 #() 8 'Re&move Variable' #removeVariables 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Ren&ame Variable' #renameVariables 134217729 nil nil nil nil nil 5938 4097 5554 nil true 8 #() 8 'Push &Down' #pushDownVariables 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Pull &Up' #pullUpVariables 134217729 nil nil nil nil nil 5938 4097 5554 nil true 8 #() 8 'Cr&eate Accessors' #createVariableAccessors 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'A&bstract' #abstractVariables 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 '&Protect/Concrete' #protectVariables 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #convertToSibling 8 'Con&vert to Sibling…' 1 1 nil nil nil 5938 4097 5602 1 5634 #removeDuplicateMethods 8 'Remove Dup&licate Methods' 1 1 nil nil nil 8 '&Refactorings' #classRefactoringsMenu 134217729 5682 nil true 5714 8 'Refactoring.ico' 5776 65541 nil nil nil nil nil 5938 4097 5602 1 5634 #createInstanceVariableAccessors 8 'Create &Accessors…' 1 1 nil nil nil 5602 1 5634 #reformatAll 8 'Re&format All' 1 1 nil nil nil 5938 4097 5602 1 5634 #fileInClass 8 'File &In…' 1 1 5682 nil true 5714 8 'FileIn.ico' 5776 65541 nil nil nil 5602 1 5634 #fileOutClass 8 'File &Out…' 1 1 nil nil nil 5938 4097 5602 1 5634 #classPackage 8 '&Package…' 1 1 5682 nil true 5714 8 'Package.ico' 5776 65541 nil nil nil 5602 1 5634 #categorizeClass 8 '&Category…' 1 1 5682 nil true 5714 8 'Category.ico' 5776 65541 nil nil nil 5938 4097 5554 nil true 50 4 5602 1 5634 #newView 8 '&New…' 1 1 nil nil nil 5938 4097 5554 nil true 8 #() 8 '&Edit' #viewsEditMenu 134217729 5682 nil true 5714 8 'ViewComposer.ico' 5776 65541 nil nil nil nil nil 5554 nil true 8 #() 8 '&Show' #viewsShowMenu 1 5682 nil true 5714 8 'TestView.ico' 5776 65541 nil nil nil nil nil 8 '&Views' #viewsMenu 134217729 5682 nil true 5714 8 'View.ico' 5776 65541 nil nil nil nil nil 8 '&Class' #classMenu 134217729 nil nil nil nil nil 5554 nil true 50 15 5554 nil true 8 #() 8 '&Definitions of' #definitionsMenu 1 nil nil nil nil nil 5554 nil true 8 #() 8 'Re&ferences to' #referencesMenu 1 nil nil nil nil nil 5554 nil true 50 16 5602 1 5634 #browseReferencesToGlobal 8 'References to Global…' 1 1 nil nil nil 5602 1 5634 #browseContainingText 8 'C&ontaining Text…' 1 1 5682 nil true 5714 8 'SearchText.ico' 5776 65541 nil nil nil 5602 1 5634 #browseMethodCategory 8 'Cate&gory…' 1 1 5682 nil true 5714 8 'Category.ico' 5776 65541 nil nil nil 5602 1 5634 #browseCompilationFailures 8 'Compilation &Failures' 1 1 nil nil nil 5602 1 5634 #browseCompilationIssues 8 'Compilation Iss&ues' 1 1 nil nil nil 5938 4097 5602 1 5634 #browseMethodPackages 8 '&Package <s>' 1 17 5682 nil true 5714 8 'Package.ico' 5776 65541 nil nil nil 5602 1 5634 #browseMethodClasses 8 'C&lass <s>' 1 17 nil nil nil 5938 4097 5602 1 5634 #browseMethodHistory 8 '&Change History' 1 1 5682 nil true 5714 8 'MethodHistory.ico' 5776 65541 nil nil nil 5602 1 5634 #browseAllChangedMethods 8 '&All Changed Methods' 1 1 nil nil nil 5938 4097 5602 1 5634 #browseMethodInheritanceChain 8 '&Inheritance Chain' 1 1 nil nil nil 5602 1 5634 #browseOverriddenMethod 8 'Goto &Superclass Definition' 1 1 nil nil nil 5938 4097 5602 1 5634 #browseUnimplemented 8 'All U&nimplemented' 1 1 nil nil nil 8 '&Browse other' nil 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #newMethod 8 '&New <s:Method>' 1 17 5682 nil true 5714 8 'NewMethod.ico' 5776 65541 nil nil nil 5602 1 5634 #removeMethod 8 'Re&move' 1 1 5682 nil true 5714 8 'MethodDelete.ico' 5776 65541 nil nil nil 5554 nil true 50 16 5602 1 5634 #renameMethod 8 'Re&name' 1 1 nil nil nil 5602 1 5634 #renameMethodReferences 8 'Rename Re&ferences…' 1 1 nil nil nil 5938 4097 5602 1 5634 #addParameter 8 'Add &Parameter…' 1 1 nil nil nil 5554 nil true 8 #() 8 'Remo&ve Parameter' #removeParameterMenu 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Rena&me Parameter' #renameParameterMenu 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 '&Inline Parameter' #inlineParameterMenu 134217729 nil nil nil nil nil 5938 4097 5554 nil true 8 #() 8 'Rename &Temporary' #renameTempMenu 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Convert Temp to Inst. Var.' #convertTempToInstVarMenu 134217729 nil nil nil nil nil 5938 4097 5602 1 5634 #inlineAllSelfSends 8 'Inline &Self Sends' 1 1 nil nil nil 5602 1 5634 #pushUpMethods 8 'Push &Up' 9325 1 nil nil nil 5602 1 5634 #pushDownMethods 8 'Push &Down' 9327 1 nil nil nil 5602 1 5634 #overrideMethods 8 'Ove&rride <d:Methods>' 1 17 nil nil nil 5602 1 5634 #moveMethod 8 'Move to &Component…' 1 1 nil nil nil 8 '&Refactorings' #methodRefactoringsMenu 134217729 5682 nil true 5714 8 'Refactoring.ico' 5776 65541 nil nil nil nil nil 5938 4097 5602 1 5634 #methodPackage 8 '&Package…' 1 1 5682 nil true 5714 8 'Package.ico' 5776 65541 nil nil nil 5554 nil true 8 #() 8 'Add to &Category' #addCategoryMenu 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Remo&ve from Category' #removeCategoryMenu 134217729 nil nil nil nil nil 5602 1 5634 #togglePrivate 8 'Priva&te' 1 1 nil nil nil 5938 4097 5602 1 5634 #toggleFilterObjectMethods 8 'Filter &Object Methods' 1 1 nil nil nil 5602 1 5634 #toggleShowInheritedMethods 8 'Show &Inherited Methods' 1 1 nil nil nil 8 '&Method' #methodMenu 134217729 nil nil nil nil nil 5554 nil true 50 7 5602 1 5634 #undoChange 8 '&Undo <d>' 1 17 5682 nil true 5714 8 'EditUndo.ico' 5776 65541 nil nil nil 5602 1 5634 #redoChange 8 '&Redo <d>' 1 17 5682 nil true 5714 8 'EditRedo.ico' 5776 65541 nil nil nil 5602 1 5634 #clearChangeHistory 8 'Clear Change &History' 1 1 5682 nil true 5714 8 'MethodHistoryErase.ico' 5776 65541 nil nil nil 5938 4097 5602 1 5634 #historyBack 8 'Back to <d:…>' 1 17 5682 nil true 5714 8 'HistoryBack.ico' 5776 65541 nil nil nil 5602 1 5634 #historyForward 8 'Forward to <d:…>' 1 17 5682 nil true 5714 8 'HistoryForward.ico' 5776 65541 nil nil nil 5602 1 5634 #historyClear 8 'Clear Visit History' 1 1 5682 nil true 5714 8 'HistoryErase.ico' 5776 65541 nil nil nil 8 'H&istory' nil 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 '&Tools' #toolsMenu 134217729 nil nil nil nil nil 5554 nil true 8 #() 8 'Wi&ndow' #windowMenu 134217729 nil nil nil nil nil 5554 nil true 50 15 5602 1 5634 #helpContents 8 '&Contents' 1025 1 5682 nil true 5714 8 'Help.ico' 5776 65541 nil nil nil 5602 1 5634 #help 8 'On this &Tool' 1249 1 nil nil nil 5602 1 5634 #helpWhatsThis 8 'What''s This?' 5345 1 nil nil nil 5938 4097 5602 1 5634 #learnSmalltalk 8 'Learn Smalltalk' 1 1 15282 8 $🎓 nil 306 #orchid 306 #white nil nil 1 nil nil nil nil 5938 4097 5602 1 5634 #helpWhatsNew 8 'What''s &New' 1 1 nil nil nil 5602 1 5634 #helpGuidedTour 8 '&Guided Tour' 1 1 nil nil nil 5602 1 5634 #helpTutorials 8 'Tutorials' 1 1 nil nil nil 5938 4097 5602 1 5634 #dolphinHomePage 8 'Dolphin Homepage' 1 1 5682 nil true 5714 8 '!!APPLICATION' 5776 65541 nil nil nil 5602 1 5634 #dolphinNewsgroup 8 'Dolphin Newsgroup/Forum' 1 1 nil nil nil 5602 1 5634 #dolphinWikiWeb 8 'Dolphin WikiWeb' 1 1 nil nil nil 5938 4097 5602 1 5634 #aboutDolphin 8 '&About Dolphin Smalltalk' 1 1 15282 8 $🐬 nil nil 306 #darkSlateBlue nil nil 1 nil nil nil nil 8 '&Help' #help 134217729 nil nil nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil 193 482 50 1 530 #createWindow: 50 1 578 11314 690 7679 21 690 9409 1031 193 80 8 '' 32 1 50 3 160 2640 1920 690 193 193 nil 27)!

toolDescription
	"Answer the description of this tool that should be displayed in, for example,
	the system shell window."

	^'Executable Browser'!

toolsFolderHelpId
	^10601!

toolsFolderIcon
	| desc |
	desc := self toolDescription.
	^SmalltalkSystemIcon
		tool: self
		icon: nil
		description: desc
		openBlock: 
			[:folder :sysicon |
			sysicon tool create
				caption: desc;
				show]
		helpId: self toolsFolderHelpId! !

!Tools.EnvironmentBrowserShell class categoriesForMethods!
displayOn:!displaying!public! !
icon!constants!public! !
initializeTool!initializing!private! !
onEnvironment:!instance creation!public! !
resource_Default_view!public!resources-views! !
toolDescription!constants!public! !
toolsFolderHelpId!constants!public! !
toolsFolderIcon!constants!public! !
!

