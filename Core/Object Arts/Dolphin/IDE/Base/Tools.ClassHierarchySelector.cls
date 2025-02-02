"Filed out from Dolphin Smalltalk"!

Tools.ClassSelector
	subclass: #'Tools.ClassHierarchySelector'
	instanceVariableNames: 'flags'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Tools.ClassHierarchySelector guid: (Core.GUID fromString: '{e11cf5f9-c2ec-47e1-ba1f-fa2fc4c88ad7}')!

Tools.ClassHierarchySelector comment: 'A ClassHierarchySelector is used to display a tree of classes. It implements the behaviour common to the class hierarchy panes in the <ClassBrowserShell> and <ClassHierarchyDiagram>.'!

!Tools.ClassHierarchySelector categoriesForClass!MVP-Presenters!MVP-Resources-IDE Tools! !

!Tools.ClassHierarchySelector methodsFor!

createComponents
	"Create the presenters contained by the receiver"

	super createComponents.
	classesPresenter := self add: TreePresenter new name: 'classes'!

customDrawClassTree: anNMTVCUSTOMDRAW
	"Private - Custom drawing to implement the emphasis in the class hierarchy tree."

	self developmentSystem setClassCustomDrawAttributes: anNMTVCUSTOMDRAW.
	self trigger: #classCustomDrawAttributesRequired: with: anNMTVCUSTOMDRAW!

expand: aClass
	"Expands aClass in the displayed hierarchy"

	classesPresenter expand: aClass!

expandAll: aClass
	"Expands aClass and all it's subclasses in the displayed hierarchy"

	classesPresenter expandAll: aClass!

flags
	^flags!

flags: anInteger
	flags := anInteger!

newClass
	"Create a new subclass of the selected class (or a subclass of nil if no class is actually selected)."

	<commandQuery: #queryNewClass:>
	| aClass package |
	aClass := self selectionOrNil.
	package := aClass isNil ifFalse: [aClass owningPackage].
	(self developmentSystem createSubclassOf: aClass inPackage: package)
		ifNotNil: [:newClass | self actualClass: newClass]! !

!Tools.ClassHierarchySelector categoriesForMethods!
createComponents!initializing!public! !
customDrawClassTree:!helpers!private! !
expand:!operations!public! !
expandAll:!operations!public! !
flags!accessing!private! !
flags:!accessing!private! !
newClass!commands-actions!public! !
!

!Tools.ClassHierarchySelector class methodsFor!

defaultModel
	"Answer a default model to be assigned to the receiver when it
	is initialized."

	^SmalltalkSystem current classHierarchy!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ContainerView} 38 #{Core.Array} 15 nil nil 50 2 8 1409286144 131073 32 nil 6 #{Graphics.Color} #default nil 5 2886 4 #{UI.Menu} nil true 50 15 1094 2 #{UI.CommandMenuItem} 2097153 1350 4 #{UI.CommandDescription} #findClass 8 'Find…' 1 1 838 4 #{Graphics.Icon} nil true 1030 #{Graphics.ImageFromStringResourceInitializer} 8 'FindClass.ico' 838 1 #{External.ResourceLibrary} 8 'dolphindr8.dll' 65541 nil nil nil 146 nil true 50 10 194 1 226 #browseClassPackage 8 'Package <d>' 1 17 274 nil true 306 8 'PackageBrowserShell.ico' 368 65541 nil nil nil 326 1 #{UI.DividerMenuItem} 4097 194 2097153 226 #browseClassReferences 8 '&Class References' 1 1 nil nil nil 146 nil true 8 #() 8 'Re&ferences To' #browseVariablesMenu 134217729 nil nil nil nil nil 530 4097 194 1 226 #browseChangedMethods 8 'Changed &Methods' 1 1 nil nil nil 194 1 226 #browseMethodHistoryForClass 8 'Method &History' 1 1 274 nil true 306 8 'MethodHistory.ico' 368 65541 nil nil nil 530 4097 194 1 226 #browsePublishedEvents 8 'Published &events' 1 1 274 nil true 306 8 'Event.ico' 368 65541 nil nil nil 194 1 226 #browsePublishedAspects 8 'Published &aspects' 1 1 nil nil nil 8 '&Browse' #browseMenu 134217729 nil nil nil nil nil 530 4097 194 1 226 #newClass 8 '&New…' 1 1 274 nil true 306 8 'NewClass.ico' 368 65541 nil nil nil 194 1 226 #removeClass 8 'Re&move' 1 1 274 nil true 306 8 'ClassDelete.ico' 368 65541 nil nil nil 146 nil true 50 22 194 2097153 226 #renameClass 8 'Re&name…' 1 1 274 nil true 306 8 'Rename.ico' 368 65541 nil nil nil 194 1 226 #changeClassNamespace 8 'C&hange Namespace…' 1 1 274 nil true 306 8 'Namespace.ico' 368 65541 nil nil nil 530 4097 194 1 226 #addInstanceVariable 8 'Add <1s>&Instance Variable…' 1 17 nil nil nil 194 1 226 #addClassVariable 8 'Add &Class Variable…' 1 1 nil nil nil 146 nil true 8 #() 8 'Re&move Variable' #removeVariables 134217729 nil nil nil nil nil 146 nil true 8 #() 8 'Ren&ame Variable' #renameVariables 134217729 nil nil nil nil nil 530 4097 146 nil true 8 #() 8 'Push &Down' #pushDownVariables 134217729 nil nil nil nil nil 146 nil true 8 #() 8 'Pull &Up' #pullUpVariables 134217729 nil nil nil nil nil 530 4097 146 nil true 8 #() 8 'Cr&eate Accessors' #createVariableAccessors 134217729 nil nil nil nil nil 146 nil true 8 #() 8 'A&bstract' #abstractVariables 134217729 nil nil nil nil nil 146 nil true 8 #() 8 '&Protect/Concrete' #protectVariables 134217729 nil nil nil nil nil 530 4097 194 1 226 #addImport 8 'Add Impor&t…' 1 1 nil nil nil 194 1 226 #removeImport 8 '&Remove Import…' 1 1 nil nil nil 530 4097 194 1 226 #copyClass 8 'Cl&one…' 1 1 nil nil nil 194 1 226 #convertToSibling 8 'Con&vert to Sibling…' 1 1 nil nil nil 530 4097 194 1 226 #removeDuplicateMethods 8 'Remove Dup&licate Methods' 1 1 nil nil nil 8 '&Refactorings' #classRefactoringsMenu 134217729 274 nil true 306 8 'Refactoring.ico' 368 65541 nil nil nil nil nil 194 1 226 #reformatAll 8 'Re&format All' 1 1 nil nil nil 530 4097 194 1 226 #fileInClass 8 'File &In…' 1 1 274 nil true 306 8 'FileIn.ico' 368 65541 nil nil nil 194 1 226 #fileOutClass 8 'File &Out…' 1 1 nil nil nil 530 4097 194 1 226 #classPackage 8 '&Package…' 1 1 274 nil true 306 8 'Package.ico' 368 65541 nil nil nil 194 1 226 #categorizeClass 8 '&Category…' 1 1 274 nil true 306 8 'Category.ico' 368 65541 nil nil nil 530 4097 146 nil true 50 4 194 1 226 #newView 8 '&New…' 1 1 nil nil nil 530 4097 146 nil true 8 #() 8 '&Edit' #viewsEditMenu 1 274 nil true 306 8 'ViewComposer.ico' 368 65541 nil nil nil nil nil 146 nil true 8 #() 8 '&Show' #viewsShowMenu 1 274 nil true 306 8 'TestView.ico' 368 65541 nil nil nil nil nil 8 '&Views' #viewsMenu 134217729 274 nil true 306 8 'View.ico' 368 65541 nil nil nil nil nil 8 '&Class' nil 134217729 nil nil nil nil nil nil nil 32 1798 #{UI.BorderLayout} 1 1 nil nil nil nil 18 #{UI.TreeView} 50 35 nil 32 50 2 8 1140918827 1 3088 1094 3 #{UI.TreeModel} nil 6 #{Kernel.IdentitySearchPolicy} 774 #{UI.TreeNode} nil nil nil 550 #{Core.IdentityDictionary} 0 128 nil 29 nil nil nil 3088 nil nil 518 #{Core.Message} #name 8 #() 3282 #iconImageIndex 8 #() 1350 1 #{Graphics.IconImageManager} nil 3282 #fullName 8 #() 1382 3 #{Kernel.BlockClosure} 0 nil 1318 #{Kernel.CompiledExpression} 5 1 3424 8 'doIt' 8 '[:ctx | ctx view parentView presenter  customDrawClassTree: ctx]' 8 #[33 105 226 0 159 160 17 179 106] #view #parentView #presenter #customDrawClassTree: 3440 7 257 nil nil nil 550 #{Core.LookupTable} 0 nil #smallIcons 1 3250 0 1 262 #{UI.TreeViewDynamicUpdateMode} 3088 nil nil nil nil nil nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[0 0 0 0 0 0 0 0 94 1 0 0 250 0 0 0] 193 3120 8 '' 3088 3 8 #() 518 #{Graphics.Point} 193 193 nil 29 518 #{Kernel.STBIdentityDictionaryProxy} 3248 50 2 3088 8 'classes' nil 3618 50 2 3666 #createWindow: 50 1 3714 3746 8 #[255 14 0 0 10 0 0 0 93 16 0 0 4 1 0 0] 193 80 8 '' 32 3666 #contextMenu: 50 1 160 32 1 50 1 3088 3826 193 193 nil 27)!

resource_Moen_view
	"Answer the literal data from which the 'Moen view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Moen_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.ScrollingDecorator} 38 #{Core.Array} 18 nil nil 50 2 8 1412431872 131073 32 nil 6 #{Graphics.Color} #default nil 5 2886 4 #{UI.Menu} nil true 50 2 1094 2 #{UI.CommandMenuItem} 1 1350 4 #{UI.CommandDescription} #findClass 8 'Find…' 1 1 838 4 #{Graphics.Icon} nil true 1030 #{Graphics.ImageFromStringResourceInitializer} 8 'FindClass.ico' 838 1 #{External.ResourceLibrary} 8 'dolphindr8.dll' 65541 nil nil nil 146 nil true 50 4 194 1 226 #browseClassPackage 8 'Package <d>' 1 1 274 nil true 306 8 'Package.ico' 368 65541 nil nil nil 326 1 #{UI.DividerMenuItem} 4097 194 1 226 #browseClass 8 '&Class' 1 1 274 nil true 306 8 'ClassBrowserShell.ico' 368 65541 nil nil nil 194 2097153 226 #browseClassReferences 8 'Class &References' 1 1 nil nil nil 8 '&Browse' #browse 134217729 nil nil nil nil nil 8 '&Class' nil 134217729 nil nil nil nil nil nil nil 32 326 1 #{UI.ScrollingDecoratorLayout} true 518 #{Kernel.STBIdentityDictionaryProxy} #{Core.IdentityDictionary} 50 2 18 #{UI.MoenTreeView} 50 30 nil 32 50 2 8 1140916224 1 816 1094 3 #{UI.TreeModel} nil 6 #{Kernel.IdentitySearchPolicy} 774 #{UI.TreeNode} nil nil nil 550 #{Core.IdentityDictionary} 0 128 nil 541 nil nil nil 816 2566 #{UI.MoenTreeNode} nil 1030 #{UI.MoenContour} nil nil nil nil 518 #{Graphics.Point} 1 1 1088 nil nil nil nil nil 7 518 #{Core.Message} #unqualifiedName 8 #() 1106 #iconImageIndex 8 #() 3 3 1350 1 #{Graphics.IconImageManager} 1074 21 21 41 nil 774 #{Graphics.Pen} nil true 262 #{OS.LOGPEN} 8 #[0 0 0 0 1 0 0 0 0 0 0 0 212 208 200 0] 1074 33 33 1074 19999 19999 65609 1074 1 1 1074 35 1 nil nil nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[0 0 0 0 0 0 0 0 129 1 0 0 4 1 0 0] 193 848 8 '' 816 3 8 #() 1074 193 193 nil 27 8 'classes' nil 1074 1 1 true 1074 33 33 1378 50 2 1426 #createWindow: 50 1 1474 1506 8 #[255 14 0 0 10 0 0 0 128 16 0 0 14 1 0 0] 193 80 8 '' 32 1426 #contextMenu: 50 1 160 32 1 50 1 816 1074 193 193 nil 27)! !

!Tools.ClassHierarchySelector class categoriesForMethods!
defaultModel!models!public! !
resource_Default_view!public!resources-views! !
resource_Moen_view!public!resources-views! !
!

