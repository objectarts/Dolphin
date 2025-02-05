﻿"Filed out from Dolphin Smalltalk"!

Tools.SmalltalkToolShell
	subclass: #'Tools.ResourceBrowser'
	instanceVariableNames: 'resourceToolboxPresenter'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Tools.ResourceBrowser guid: (Core.GUID fromString: '{87b4c6c2-026e-11d3-9fd7-00a0cc3e4a32}')!

Tools.ResourceBrowser comment: 'ResourceBrowser is a <SmalltalkToolShell> that implements the Resource Browser tool. This provides an interface onto all the <Resource>s held by the current <ResourceManager>.

Instance Variables:
	resourceListPresenter		<ResourceListPresenter> displaying the current list of resources.
	resourceTree			<UndefinedObject> not used.
	packagesPresenter			<ListPresenter> displaying a list of all the current packages.
'!

!Tools.ResourceBrowser categoriesForClass!MVP-Presenters! !

!Tools.ResourceBrowser methodsFor!

canSaveState
	"Private - Answer true if the receiver can successfully have it's state saved by #saveStateOn:. Some
	tools may not be able to save their state and therefore will not be able to be exported as
	part of a IdeaSpace save operation"

	^true!

createComponents
	"Private - Create the presenters contained by the receiver"

	super createComponents.
	resourceToolboxPresenter := self add: ResourceToolboxPresenter new name: 'resourceToolbox'!

defaultHelpId
	^10847!

newView
	"Open the ViewComposer on an new default view resource for the
	selected class. If there are several possibilities allow the user to select
	the one to edit"

	| selection |
	(selection := self resource) notNil 
		ifTrue: [self model openViewComposerOnNewViewFor: selection owningClass]
		ifFalse: [self model openViewComposer]
 !

resource
	"Answer the selected resource identifier in the receiver or nil if there
	is none"

	^resourceToolboxPresenter selectionOrNil!

resource: aResourceIdentifierOrNil 
	resourceToolboxPresenter selectionOrNil: aResourceIdentifierOrNil!

resourceToolboxPresenter
	^resourceToolboxPresenter!

saveStateOn: aWriteStream
	"Private - Write the source of a monadic block that will configure an instance of the receiver's class
	to match the state current receiver, to aWriteStream. The block expects a fresh instance of
	the receiver's class as it's parameter"

	aWriteStream nextPutAll: '[ :aResourceBrowser | aResourceBrowser resource: '.
	self resource storeOn: aWriteStream.
	aWriteStream
		nextPut: $.;
		cr.
	super saveStateOn: aWriteStream.
	aWriteStream nextPutAll: ' value: aResourceBrowser.'.
	aWriteStream nextPutAll: ']'!

selectCategory: aString 
	^resourceToolboxPresenter selectCategory: aString!

setInitialFocus
	resourceToolboxPresenter view tabFirst!

shortCaption
	^'Views'!

showResourcesReferencingView: aResourceIdentifier
	resourceToolboxPresenter showResourcesReferencingView: aResourceIdentifier.
	self caption: ('Views referencing <1p>' expandMacrosWith: aResourceIdentifier)! !

!Tools.ResourceBrowser categoriesForMethods!
canSaveState!private!saved state! !
createComponents!**auto generated**!initializing!private! !
defaultHelpId!public! !
newView!commands!public! !
resource!accessing!public! !
resource:!accessing!public! !
resourceToolboxPresenter!private! !
saveStateOn:!private!saved state! !
selectCategory:!public! !
setInitialFocus!operations!public! !
shortCaption!accessing!public! !
showResourcesReferencingView:!public! !
!

!Tools.ResourceBrowser class methodsFor!

defaultOptionFlags
	^##(ReuseIfOpenMask | CanUseIdeaSpaceMask)!

displayOn: aPuttableStream
	"Append to the <puttableStream> first argument a String whose characters are a representation of the receiver that an end-user might want to see."

	aPuttableStream nextPutAll: 'View Browser'!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

initialize
	"Private - Register the receiver with SmalltalkSystem.
		self initialize
	"

	SmalltalkSystem current
		addSystemFolderIcon: self toolsFolderIcon;
		registerTool: self!

previewDpiAwareness
	^ResourcePreview dpiAwareness!

previewDpiAwareness: aSymbol
	self previewDpiAwareness == aSymbol ifTrue: [^self].
	ResourcePreview dpiAwareness: aSymbol.
	self persistOptions!

publishedAspects
	"Answer a <LookupTable> of the <Aspect>s published by the receiver."

	| aspects |
	aspects := super publishedAspects.
	(aspects at: #reuseIfOpen) defaultValue: true.
	^aspects
		add: self canUseIdeaSpaceAspect;
		add: ((Aspect choice: #previewDpiAwareness
					from: { DpiAwareness gdiScaled. DpiAwareness system. DpiAwareness unaware })
					defaultValue: DpiAwareness gdiScaled;
					yourself);
		yourself!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ShellView} 38 #{Core.Array} 27 nil nil 8 #(13565952 65536) 32 nil 518 #{Graphics.ThemeColor} #toolBackground nil 5 nil nil nil 32 1798 #{UI.BorderLayout} 1 1 18 #{UI.Toolbar} 50 28 nil 32 50 2 8 1140853580 131073 160 nil nil nil 517 nil 1350 1 #{Graphics.Font} nil true 262 #{OS.LOGFONTW} 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 0 65 0 114 0 105 0 97 0 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 193 nil nil 160 6 #{Graphics.Color} #default nil 518 #{Kernel.STBIdentityDictionaryProxy} #{Core.IdentityDictionary} 50 10 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 384 nil nil nil 5 nil nil nil 384 582 1 #{UI.ResourceIdentifier} #{UI.Toolbar} #resource_Image_tools nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[0 0 0 0 0 0 0 0 31 0 0 0 25 0 0 0] 193 416 8 '' 384 3 8 #() 518 #{Graphics.Point} 193 193 nil 27 8 'imageTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 736 nil nil nil 5 nil nil nil 736 450 #{UI.Toolbar} #resource_Resource_tools nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[11 2 0 0 0 0 0 0 65 2 0 0 25 0 0 0] 193 768 8 '' 736 3 672 690 193 193 nil 27 8 'resourceTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 976 nil nil nil 5 nil nil nil 976 450 #{UI.Toolbar} #resource_Search_tools nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[51 1 0 0 0 0 0 0 11 2 0 0 25 0 0 0] 193 1008 8 '' 976 3 672 690 193 193 nil 27 8 'searchTools' 18 #{UI.ReferenceView} 50 14 nil 160 50 2 8 1140850688 131073 1216 nil nil nil 5 nil nil nil 1216 450 #{UI.Toolbar} #resource_Smalltalk_tools nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[31 0 0 0 0 0 0 0 51 1 0 0 25 0 0 0] 193 1248 8 '' 1216 3 672 690 193 193 nil 27 8 'smalltalkTools' 18 #{UI.Toolbar} 50 28 nil 160 50 2 8 1140853612 131137 1456 nil nil nil 517 nil nil nil 1456 320 nil 338 #{Core.IdentityDictionary} 672 nil nil nil nil 50 1 1606 2 #{UI.ToolbarIconButton} 1456 17 1350 4 #{UI.CommandDescription} #viewModeSelect 8 'Views' 1 1 838 4 #{Graphics.Icon} nil true 1030 #{Graphics.ImageFromStringResourceInitializer} 8 'ViewMode.ico' 838 1 #{External.ResourceLibrary} 8 'dolphindr8.dll' 65541 nil nil nil nil nil nil 9 1 nil nil nil nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[65 2 0 0 0 0 0 0 103 2 0 0 25 0 0 0] 193 1488 8 '' 1456 3 8 #() 690 193 193 nil 31 8 'viewTools' nil nil nil nil 8 #() nil nil 9 1231 #smallIcons nil nil 838 1 #{UI.FlowLayout} 1 1 1 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 0 0 0 0 187 2 0 0 25 0 0 0] 193 192 8 '' 160 3 50 5 384 1216 976 736 1456 690 193 193 nil 31 nil nil nil 18 #{UI.ReferenceView} 50 14 nil 32 50 2 8 1140850688 131073 2144 nil nil nil 13 nil nil nil 2144 450 #{Tools.ResourceToolboxPresenter} #resource_Default_view nil 482 50 1 530 #createWindow: 50 1 578 610 8 #[0 0 0 0 25 0 0 0 187 2 0 0 39 2 0 0] 193 2176 8 '' 2144 3 672 690 193 193 nil 27 338 #{Core.IdentityDictionary} 50 4 2144 8 'resourceToolbox' 160 8 'toolbar' nil 2886 4 #{UI.MenuBar} nil true 50 4 2886 4 #{UI.Menu} nil true 50 9 1094 2 #{UI.CommandMenuItem} 1 1586 #browseHierarchy 8 '&Browse <1s>' 1 1 1634 nil true 1666 8 'ClassBrowserShell.ico' 1728 65541 nil nil nil 326 1 #{UI.DividerMenuItem} 4097 2530 1 1586 #newView 8 '&New' 1 1 nil nil nil 2530 1 1586 #deleteResource 8 '&Delete…' 1 1 1634 nil true 1666 8 'EditClear.ico' 1728 65541 nil nil nil 2642 4097 2530 1 1586 #editResource 8 '&Open' 9349 1 1634 nil true 1666 8 'ViewComposer.ico' 1728 65541 nil nil nil 2642 4097 2530 1 1586 #resourcePackage 8 '&Package…' 1 1 1634 nil true 1666 8 'Package.ico' 1728 65541 nil nil nil 2530 1 1586 #categorizeResource 8 'Category…' 1 1 nil nil nil 8 '&View' nil 134217729 nil nil nil nil nil 2482 nil true 8 #() 8 '&Tools' #toolsMenu 134217729 nil nil nil nil nil 2482 nil true 8 #() 8 'Wi&ndow' #windowMenu 134217729 nil nil nil nil nil 2482 nil true 50 15 2530 1 1586 #helpContents 8 '&Contents' 1025 1 1634 nil true 1666 8 'Help.ico' 1728 65541 nil nil nil 2530 1 1586 #help 8 'On this &Tool' 1249 1 nil nil nil 2530 1 1586 #helpWhatsThis 8 'What''s This?' 5345 1 nil nil nil 2642 4097 2530 1 1586 #learnSmalltalk 8 'Learn Smalltalk' 1 1 2374 2 #{Graphics.TextTileIcon} 8 $🎓 nil 306 #orchid 306 #white nil nil 1 nil nil nil nil 2642 4097 2530 1 1586 #helpWhatsNew 8 'What''s &New' 1 1 nil nil nil 2530 1 1586 #helpGuidedTour 8 '&Guided Tour' 1 1 nil nil nil 2530 1 1586 #helpTutorials 8 'Tutorials' 1 1 nil nil nil 2642 4097 2530 1 1586 #dolphinHomePage 8 'Dolphin Homepage' 1 1 1634 nil true 1666 8 '!!APPLICATION' 1728 65541 nil nil nil 2530 1 1586 #dolphinNewsgroup 8 'Dolphin Newsgroup/Forum' 1 1 nil nil nil 2530 1 1586 #dolphinWikiWeb 8 'Dolphin WikiWeb' 1 1 nil nil nil 2642 4097 2530 1 1586 #aboutDolphin 8 '&About Dolphin Smalltalk' 1 1 3490 8 $🐬 nil nil 306 #darkSlateBlue nil nil 1 nil nil nil nil 8 '&Help' #help 134217729 nil nil nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil nil nil 193 482 50 1 530 #createWindow: 50 1 578 518 #{Graphics.Rectangle} 690 7679 21 690 9109 1241 193 80 8 'View Browser' 32 1 50 2 160 2144 690 193 193 nil 27)!

showAsToolboxFor: aView at: aPoint
	"Creates an instance of the receiver in a toolbox view attached to aView
	and displayed at aPoint relative to the origin of this view"

	| toolbox toolboxView position |
	toolboxView := (self loadViewResource: 'Toolbox' inContext: View desktop) bePopupFor: aView.
	position := aView mapPointToScreen: aPoint.
	toolboxView position: position.

	toolbox := self new.
	toolbox view: toolboxView.

	^toolbox show!

toolsFolderHelpId
	^10594! !

!Tools.ResourceBrowser class categoriesForMethods!
defaultOptionFlags!constants!options!private! !
displayOn:!displaying!public! !
icon!constants!public! !
initialize!initializing!private! !
previewDpiAwareness!accessing!public! !
previewDpiAwareness:!accessing!public! !
publishedAspects!public! !
resource_Default_view!public!resources-views! !
showAsToolboxFor:at:!instance creation!public! !
toolsFolderHelpId!public! !
!

