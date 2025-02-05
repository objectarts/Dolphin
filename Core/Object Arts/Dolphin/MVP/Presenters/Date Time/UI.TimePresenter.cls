﻿"Filed out from Dolphin Smalltalk"!

UI.ValuePresenter
	subclass: #'UI.TimePresenter'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

UI.TimePresenter guid: (Core.GUID fromString: '{87b4c6d3-026e-11d3-9fd7-00a0cc3e4a32}')!

UI.TimePresenter comment: 'TimePresenter is a <valuePresenter> that displays a <valueModel> onto <Time> value. A TimePresenter can be connected to any <valueView> capable of displaying <Time> values. When the ''Dolphin DateTimePicker Control'' package is installed this will be a <DateTimePicker>, but alternative views may be chosen with the installation of an appropriate <typeConverter>.'!

!UI.TimePresenter categoriesForClass!MVP-Presenters!MVP-Resources-Time fields! !

!UI.TimePresenter class methodsFor!

defaultView
	^'Picker view'!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	Tools.ViewComposer openOn: (UI.ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 6 2118 11 #{UI.STBViewProxy} #{UI.TextEdit} 38 #{Core.Array} 20 nil nil 50 2 8 1140916224 1025 32 nil 6 #{Graphics.Color} #default nil 5 nil nil nil 32 nil nil 1094 1 #{UI.TimeToText} nil nil 326 1 #{Core.Locale} #userDefault nil 1 #focusLost nil nil nil 262 #{Core.MessageSequence} 50 1 774 #{Core.MessageSend} #createWindow: 50 1 1030 #{UI.CreateWindow} 262 #{OS.RECTL} 8 #[255 14 0 0 10 0 0 0 129 15 0 0 29 0 0 0] 193 80 nil 32 3 8 #() 518 #{Graphics.Point} 193 193 nil 45)! !

!UI.TimePresenter class categoriesForMethods!
defaultView!constants!public!views! !
icon!constants!public! !
resource_Default_view!public!resources-views! !
!

