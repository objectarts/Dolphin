﻿"Filed out from Dolphin Smalltalk"!

WebView2.ICoreWebView2EventArgs
	subclass: #'WebView2.ICoreWebView2MoveFocusRequestedEventArgs'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

WebView2.ICoreWebView2MoveFocusRequestedEventArgs guid: (OS.COM.IID fromString: '{2d6aa13b-3839-4a15-92fc-d88b3c0d9c9d}')!

WebView2.ICoreWebView2MoveFocusRequestedEventArgs isEgressOnly: true!

WebView2.ICoreWebView2MoveFocusRequestedEventArgs comment: '`ICoreWebView2MoveFocusRequestedEventArgs` is a wrapper class for the COM interface ''WebView2.ICoreWebView2MoveFocusRequestedEventArgs'' generated from type information in the '''' library. It contains methods to invoke the member functions exposed by that interface.

The type library contains no documentation for this interface

** This comment was automatically generated from a type library. Delete this line to prevent any manual edits from being overwritten if the wrapper class is regenerated.

IDL definition follows:
```
[
	object, 
	uuid(2d6aa13b-3839-4a15-92fc-d88b3c0d9c9d)
]
interface ICoreWebView2MoveFocusRequestedEventArgs : IUnknown
 {
	[id(0x60010000), propget]
	HRESULT __stdcall reason(
		[out, retval]COREWEBVIEW2_MOVE_FOCUS_REASON* reason);
	[id(0x60010001), propget]
	HRESULT __stdcall Handled(
		[out, retval]long* value);
	[id(0x60010001), propput]
	HRESULT __stdcall Handled(
		[in]long value);
};
```
'!

!WebView2.ICoreWebView2MoveFocusRequestedEventArgs categoriesForClass!COM-Interfaces!WebView2-Interfaces! !

!WebView2.ICoreWebView2MoveFocusRequestedEventArgs methodsFor!

get_Handled: value
	"Private - Get the value of the 'Handled' property of the receiver.

		HRESULT __stdcall Handled(
			[out, retval]long* value);"

	<virtual stdcall: hresult 5 int32*>
	^self invalidCall: _failureCode!

get_reason: reason
	"Private - Get the value of the 'reason' property of the receiver.

		HRESULT __stdcall reason(
			[out, retval]COREWEBVIEW2_MOVE_FOCUS_REASON* reason);"

	<virtual stdcall: hresult 4 int32*>
	^self invalidCall: _failureCode!

put_Handled: value
	"Private - Set the value of the 'Handled' property of the object wrapped by the 
	 receiver to the <sdword> argument, value.

		HRESULT __stdcall Handled(
			[in]long value);"

	<virtual stdcall: hresult 6 int32>
	^self invalidCall: _failureCode!

reason
	"Answer the COREWEBVIEW2_MOVE_FOCUS_REASON enum value of the 'reason' property of the receiver."

	| buf |
	buf := UInt32Bytes new.
	self get_reason: buf.
	^buf asSignedInteger! !

!WebView2.ICoreWebView2MoveFocusRequestedEventArgs categoriesForMethods!
get_Handled:!**auto generated**!COM Interfaces-ICoreWebView2MoveFocusRequestedEventArgs!private! !
get_reason:!**auto generated**!COM Interfaces-ICoreWebView2MoveFocusRequestedEventArgs!private! !
put_Handled:!**auto generated**!COM Interfaces-ICoreWebView2MoveFocusRequestedEventArgs!private! !
reason!properties!public! !
!

!WebView2.ICoreWebView2MoveFocusRequestedEventArgs class methodsFor!

defineFunctions
	"Declare the virtual function table for the COM interface 'WebView2.ICoreWebView2MoveFocusRequestedEventArgs'
		ICoreWebView2MoveFocusRequestedEventArgs defineTemplate"

	self
		defineFunction: #get_reason:
			argumentTypes: 'sdword*';
		defineFunction: #get_Handled:
			argumentTypes: 'sdword*';
		defineFunction: #put_Handled:
			argumentTypes: 'sdword'
! !

!WebView2.ICoreWebView2MoveFocusRequestedEventArgs class categoriesForMethods!
defineFunctions!**auto generated**!initializing!public!template definition! !
!

