﻿"Filed out from Dolphin Smalltalk"!

WebView2.ICoreWebView2Interface
	subclass: #'WebView2.ICoreWebView2Profile'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

WebView2.ICoreWebView2Profile guid: (OS.COM.IID fromString: '{79110ad3-cd5d-4373-8bc3-c60658f17a5f}')!

WebView2.ICoreWebView2Profile isEgressOnly: true!

WebView2.ICoreWebView2Profile comment: '`ICoreWebView2Profile` is a wrapper class for the COM interface ''WebView2.ICoreWebView2Profile'' generated from type information in the '''' library. It contains methods to invoke the member functions exposed by that interface.

The type library contains no documentation for this interface

** This comment was automatically generated from a type library. Delete this line to prevent any manual edits from being overwritten if the wrapper class is regenerated.

IDL definition follows:
```
[
	object, 
	uuid(79110ad3-cd5d-4373-8bc3-c60658f17a5f)
]
interface ICoreWebView2Profile : IUnknown
 {
	[id(0x60010000), propget]
	HRESULT __stdcall ProfileName(
		[out, retval]LPWSTR* value);
	[id(0x60010001), propget]
	HRESULT __stdcall IsInPrivateModeEnabled(
		[out, retval]long* value);
	[id(0x60010002), propget]
	HRESULT __stdcall ProfilePath(
		[out, retval]LPWSTR* value);
	[id(0x60010003), propget]
	HRESULT __stdcall DefaultDownloadFolderPath(
		[out, retval]LPWSTR* value);
	[id(0x60010003), propput]
	HRESULT __stdcall DefaultDownloadFolderPath(
		[in]LPWSTR value);
	[id(0x60010005), propget]
	HRESULT __stdcall PreferredColorScheme(
		[out, retval]COREWEBVIEW2_PREFERRED_COLOR_SCHEME* value);
	[id(0x60010005), propput]
	HRESULT __stdcall PreferredColorScheme(
		[in]COREWEBVIEW2_PREFERRED_COLOR_SCHEME value);
};
```
'!

!WebView2.ICoreWebView2Profile categoriesForClass!COM-Interfaces!WebView2-Interfaces! !

!WebView2.ICoreWebView2Profile methodsFor!

Add_Deleted: eventHandler token: token
	"Private - Invoke the add_Deleted() method of the COM object.

		HRESULT __stdcall add_Deleted(
			[in]ICoreWebView2ProfileDeletedEventHandler* eventHandler,
			[out]EventRegistrationToken* token);"

	^E_NOTIMPL!

AddBrowserExtension: extensionFolderPath handler: handler
	"Invoke the AddBrowserExtension() method of the COM object.

		HRESULT __stdcall AddBrowserExtension(
			[in]LPWSTR extensionFolderPath,
			[in]ICoreWebView2ProfileAddBrowserExtensionCompletedHandler* handler);"

	^E_NOTIMPL!

addBrowserExtension: extensionFolderPath thenDo: aDyadicValuable
	"Add a browser extension to be loaded from the specified path. When done, invoke the completion handler passing an hresult success/failure code as the first argument, and an <ICoreWebView2BrowserExtension> on the new extension, if successfully loaded."

	| handler |
	handler := (WebView2CompletionHandler completionBlock: aDyadicValuable)
				queryInterface: ICoreWebView2ProfileAddBrowserExtensionCompletedHandler.
	self AddBrowserExtension: extensionFolderPath asUtf16String handler: handler.
	handler free!

clearBrowsingData: dataKinds from: startTime to: endTime thenDo: aMonadicValuable
	"Clear browsing data of the kinds indicated by the flags in the <integer> dataKinds argument in a range specified by the <DateAndTime> startTime and endTime arguments. When done invoke the <monadicValuable> argument passing an integer HRESULT indicating success/failure."

	| handler |
	handler := (WebView2CompletionHandler completionBlock: aMonadicValuable)
				queryInterface: ICoreWebView2ClearBrowsingDataCompletedHandler.
	self
		ClearBrowsingDataInTimeRange: dataKinds
		startTime: startTime asUnixTime asFloat
		endTime: endTime asUnixTime asFloat
		handler: handler.
	handler free!

ClearBrowsingData: dataKinds handler: handler
	"Private - Invoke the ClearBrowsingData() method of the COM object.

		HRESULT __stdcall ClearBrowsingData(
			[in]COREWEBVIEW2_BROWSING_DATA_KINDS dataKinds,
			[in]ICoreWebView2ClearBrowsingDataCompletedHandler* handler);"

	handler Invoke: E_NOTIMPL.
	^E_NOTIMPL!

clearBrowsingData: dataKinds startTime: startTime endTime: endTime handler: aMonadicValuable
	| handler |
	handler := (WebView2CompletionHandler completionBlock: aMonadicValuable)
				queryInterface: ICoreWebView2ClearBrowsingDataCompletedHandler.
	self ClearBrowsingDataInTimeRange: dataKinds startTime: startTime endTime: endTime handler: handler.
	handler free!

clearBrowsingData: dataKinds thenDo: aMonadicValuable
	"Clear browsing data of the kinds indicated by the flags in the <integer> dataKinds argument and when done invoke the <monadicValuable> argument passing an integer HRESULT indicating success/failure."

	| handler |
	handler := (WebView2CompletionHandler completionBlock: aMonadicValuable)
				queryInterface: ICoreWebView2ClearBrowsingDataCompletedHandler.
	self ClearBrowsingData: dataKinds handler: handler.
	handler free!

ClearBrowsingDataAll: handler
	"Private - Invoke the ClearBrowsingDataAll() method of the COM object.

		HRESULT __stdcall ClearBrowsingDataAll(
			[in]ICoreWebView2ClearBrowsingDataCompletedHandler* handler);"

	handler Invoke: E_NOTIMPL.
	^E_NOTIMPL!

clearBrowsingDataAllThenDo: aMonadicValuable
	| handler |
	handler := (WebView2CompletionHandler completionBlock: aMonadicValuable)
				queryInterface: ICoreWebView2ClearBrowsingDataCompletedHandler.
	self ClearBrowsingDataAll: handler.
	handler free!

ClearBrowsingDataInTimeRange: dataKinds startTime: startTime endTime: endTime handler: handler
	"Private - Invoke the ClearBrowsingDataInTimeRange() method of the COM object.

		HRESULT __stdcall ClearBrowsingDataInTimeRange(
			[in]COREWEBVIEW2_BROWSING_DATA_KINDS dataKinds,
			[in]double startTime,
			[in]double endTime,
			[in]ICoreWebView2ClearBrowsingDataCompletedHandler* handler);"

	handler Invoke: E_NOTIMPL.
	^E_NOTIMPL!

clearBrowsingDataThenDo: aMonadicValuable
	"Clear all browsing data (history, cookies, etc) and when done invoke the <monadicValuable> argument passing an integer HRESULT indicating success/failure."

	| handler |
	handler := (WebView2CompletionHandler completionBlock: aMonadicValuable)
				queryInterface: ICoreWebView2ClearBrowsingDataCompletedHandler.
	self ClearBrowsingDataAll: handler.
	handler free!

cookieManager
	"Answer the <ICoreWebView2CookieManager> value of the 'CookieManager' property of the receiver."

	| answer |
	answer := ICoreWebView2CookieManager newPointer.
	self get_CookieManager: answer.
	^answer asObject!

defaultDownloadFolderPath
	"Answer the <readableString> value of the 'DefaultDownloadFolderPath' property of the receiver."

	| ptr answer |
	ptr := TaskMemory new.
	self get_DefaultDownloadFolderPath: ptr.
	answer := Utf16String fromAddress: ptr.
	ptr free.
	^answer!

defaultDownloadFolderPath: value
	"Set the 'DefaultDownloadFolderPath' property of the receiver to the <lpwstr> value of the argument."

	self put_DefaultDownloadFolderPath: value asUtf16String!

defaultTrackingPreventionLevel
	^COREWEBVIEW2_TRACKING_PREVENTION_LEVEL_BALANCED!

Delete
	"Invoke the Delete() method of the COM object.

		HRESULT __stdcall Delete();"

	^E_NOTIMPL!

displayOn: aStream
	| name |
	self isNull ifTrue: [^super displayOn: aStream].
	name := self profileName.
	aStream nextPutAll: (name isEmpty ifTrue: ['Default profile'] ifFalse: [name])!

get_CookieManager: cookieManager
	"Private - Get the value of the 'CookieManager' property of the receiver.

		HRESULT __stdcall CookieManager(
			[out, retval]ICoreWebView2CookieManager** CookieManager);"

	^E_NOTIMPL!

get_DefaultDownloadFolderPath: value
	"Private - Get the value of the 'DefaultDownloadFolderPath' property of the receiver.

		HRESULT __stdcall DefaultDownloadFolderPath(
			[out, retval]LPWSTR* value);"

	<virtual stdcall: hresult 7 lpwstr*>
	^self invalidCall: _failureCode!

get_IsGeneralAutofillEnabled: value
	"Private - Get the value of the 'IsGeneralAutofillEnabled' property of the receiver.

		HRESULT __stdcall IsGeneralAutofillEnabled(
			[out, retval]long* value);"

	value value: 0.
	^S_FALSE!

get_IsInPrivateModeEnabled: value
	"Private - Get the value of the 'IsInPrivateModeEnabled' property of the receiver.

		HRESULT __stdcall IsInPrivateModeEnabled(
			[out, retval]long* value);"

	<virtual stdcall: hresult 5 bool*>
	^self invalidCall: _failureCode!

get_IsPasswordAutosaveEnabled: value
	"Private - Get the value of the 'IsPasswordAutosaveEnabled' property of the receiver.

		HRESULT __stdcall IsPasswordAutosaveEnabled(
			[out, retval]long* value);"

	value value: 1.
	^S_FALSE!

get_PreferredColorScheme: value
	"Private - Get the value of the 'PreferredColorScheme' property of the receiver.

		HRESULT __stdcall PreferredColorScheme(
			[out, retval]COREWEBVIEW2_PREFERRED_COLOR_SCHEME* value);"

	<virtual stdcall: hresult 9 int32*>
	^self invalidCall: _failureCode!

get_PreferredTrackingPreventionLevel: value
	"Private - Get the value of the 'PreferredTrackingPreventionLevel' property of the receiver.

		HRESULT __stdcall PreferredTrackingPreventionLevel(
			[out, retval]COREWEBVIEW2_TRACKING_PREVENTION_LEVEL* value);"

	value value: self defaultTrackingPreventionLevel.
	^S_OK!

get_ProfileName: value
	"Private - Get the value of the 'ProfileName' property of the receiver.

		HRESULT __stdcall ProfileName(
			[out, retval]LPWSTR* value);"

	<virtual stdcall: hresult 4 lpwstr*>
	^self invalidCall: _failureCode!

get_ProfilePath: value
	"Private - Get the value of the 'ProfilePath' property of the receiver.

		HRESULT __stdcall ProfilePath(
			[out, retval]LPWSTR* value);"

	<virtual stdcall: hresult 6 lpwstr*>
	^self invalidCall: _failureCode!

GetBrowserExtensions: handler
	"Invoke the GetBrowserExtensions() method of the COM object.

		HRESULT __stdcall GetBrowserExtensions(
			[in]ICoreWebView2ProfileGetBrowserExtensionsCompletedHandler* handler);"

	^E_NOTIMPL!

getBrowserExtensionsThenDo: aDyadicValuable
	| handler |
	handler := (WebView2CompletionHandler completionBlock: aDyadicValuable)
				queryInterface: ICoreWebView2ProfileGetBrowserExtensionsCompletedHandler.
	self GetBrowserExtensions: handler.
	handler free!

GetNonDefaultPermissionSettings: completedHandler
	"Invoke the GetNonDefaultPermissionSettings() method of the COM object.

		HRESULT __stdcall GetNonDefaultPermissionSettings(
			[in]ICoreWebView2GetNonDefaultPermissionSettingsCompletedHandler* completedHandler);"

	completedHandler Invoke: E_NOTIMPL arg: nil.
	^E_NOTIMPL!

getNonDefaultPermissionSettingsThenDo: aDyadicValuable
	| handler |
	handler := (WebView2CompletionHandler completionBlock: aDyadicValuable)
				queryInterface: ICoreWebView2GetNonDefaultPermissionSettingsCompletedHandler.
	self GetNonDefaultPermissionSettings: handler.
	handler free!

icon
	self isNull ifTrue: [^super icon].
	^self isInPrivateModeEnabled
		ifTrue: [Graphics.TextTileIcon text: $\xE727 fontName: 'Segoe Fluent Icons']
		ifFalse: [Graphics.Icon null]!

isGeneralAutofillEnabled
	"Answer the <Boolean> value of the 'IsGeneralAutofillEnabled' property of the receiver."

	| buf |
	buf := UInt32Bytes new.
	self get_IsGeneralAutofillEnabled: buf.
	^buf asBoolean!

isGeneralAutofillEnabled: aBoolean
	"Set the 'IsGeneralAutofillEnabled' property of the receiver to the argument."

	self put_IsGeneralAutofillEnabled: aBoolean asParameter!

isInPrivateModeEnabled
	"Answer the <Boolean> value of the 'IsInPrivateModeEnabled' property of the receiver."

	| buf |
	buf := UInt32Bytes new.
	self get_IsInPrivateModeEnabled: buf.
	^buf asBoolean!

isPasswordAutosaveEnabled
	"Answer the <Boolean> value of the 'IsPasswordAutosaveEnabled' property of the receiver."

	| buf |
	buf := UInt32Bytes new.
	self get_IsPasswordAutosaveEnabled: buf.
	^buf asBoolean!

isPasswordAutosaveEnabled: aBoolean
	"Set the 'IsPasswordAutosaveEnabled' property of the receiver to the  the argument."

	self put_IsPasswordAutosaveEnabled: aBoolean asParameter!

preferredColorScheme
	"Answer the COREWEBVIEW2_PREFERRED_COLOR_SCHEME enumeration value of the 'PreferredColorScheme' property of the receiver."

	| buf |
	buf := UInt32Bytes new.
	self get_PreferredColorScheme: buf.
	^buf asSignedInteger!

preferredColorScheme: value
	"Set the 'PreferredColorScheme' property of the receiver to the COREWEBVIEW2_PREFERRED_COLOR_SCHEME enumeration value of the argument."

	self put_PreferredColorScheme: value!

preferredTrackingPreventionLevel
	"Answer the <int32> value of the 'PreferredTrackingPreventionLevel' property of the receiver."

	| buf |
	buf := UInt32Bytes new.
	self get_PreferredTrackingPreventionLevel: buf.
	^buf asSignedInteger!

preferredTrackingPreventionLevel: value
	"Set the 'PreferredTrackingPreventionLevel' property of the receiver to the <int32> value of the argument."

	self put_PreferredTrackingPreventionLevel: value!

printableProperties
	| propertyNames |
	propertyNames := OrderedCollection new.
	self profileName isEmpty ifFalse: [propertyNames addLast: #profileName].
	self preferredColorScheme isZero ifFalse: [propertyNames addLast: #preferredColorScheme].
	self isInPrivateModeEnabled ifTrue: [propertyNames addLast: #isInPrivateModeEnabled].
	self preferredTrackingPreventionLevel = self defaultTrackingPreventionLevel
		ifFalse: [propertyNames add: #preferredTrackingPreventionLevel].
	propertyNames addAll: #(#profilePath #defaultDownloadFolderPath).
	^propertyNames!

profileName
	"Answer the <readableString> value of the 'ProfileName' property of the receiver."

	| ptr answer |
	ptr := TaskMemory new.
	self get_ProfileName: ptr.
	answer := Utf16String fromAddress: ptr.
	ptr free.
	^answer!

profilePath
	"Answer the <readableString> value of the 'ProfilePath' property of the receiver."

	| ptr answer |
	ptr := TaskMemory new.
	self get_ProfilePath: ptr.
	answer := Utf16String fromAddress: ptr.
	ptr free.
	^answer!

put_DefaultDownloadFolderPath: value
	"Private - Set the value of the 'DefaultDownloadFolderPath' property of the object wrapped by the 
	 receiver to the <lpwstr> argument, value.

		HRESULT __stdcall DefaultDownloadFolderPath(
			[in]LPWSTR value);"

	<virtual stdcall: hresult 8 lpwstr>
	^self invalidCall: _failureCode!

put_IsGeneralAutofillEnabled: value
	"Private - Set the value of the 'IsGeneralAutofillEnabled' property of the object wrapped by the 
	 receiver to the <int32> argument, value.

		HRESULT __stdcall IsGeneralAutofillEnabled(
			[in]long value);"

	^E_NOTIMPL!

put_IsPasswordAutosaveEnabled: value
	"Private - Set the value of the 'IsPasswordAutosaveEnabled' property of the object wrapped by the 
	 receiver to the <int32> argument, value.

		HRESULT __stdcall IsPasswordAutosaveEnabled(
			[in]long value);"

	^E_NOTIMPL!

put_PreferredColorScheme: value
	"Private - Set the value of the 'PreferredColorScheme' property of the object wrapped by the 
	 receiver to the <sdword> argument, value.

		HRESULT __stdcall PreferredColorScheme(
			[in]COREWEBVIEW2_PREFERRED_COLOR_SCHEME value);"

	<virtual stdcall: hresult 10 int32>
	^self invalidCall: _failureCode!

put_PreferredTrackingPreventionLevel: value
	"Private - Set the value of the 'PreferredTrackingPreventionLevel' property of the object wrapped by the 
	 receiver to the <int32> argument, value.

		HRESULT __stdcall PreferredTrackingPreventionLevel(
			[in]COREWEBVIEW2_TRACKING_PREVENTION_LEVEL value);"

	^E_NOTIMPL!

Remove_Deleted: token
	"Invoke the remove_Deleted() method of the COM object.

		HRESULT __stdcall remove_Deleted(
			[in]EventRegistrationToken token);"

	^E_NOTIMPL!

SetPermissionState: permissionKind origin: origin state: state completedHandler: completedHandler
	"Invoke the SetPermissionState() method of the COM object.

		HRESULT __stdcall SetPermissionState(
			[in]COREWEBVIEW2_PERMISSION_KIND PermissionKind,
			[in]LPWSTR origin,
			[in]COREWEBVIEW2_PERMISSION_STATE State,
			[in]ICoreWebView2SetPermissionStateCompletedHandler* completedHandler);"

	completedHandler invoke: E_NOTIMPL.
	^E_NOTIMPL!

setPermissionState: permissionKindInteger origin: originString state: stateInteger thenDo: aMonadicValuable
	| handler |
	handler := (WebView2CompletionHandler completionBlock: aMonadicValuable)
				queryInterface: ICoreWebView2SetPermissionStateCompletedHandler.
	self
		SetPermissionState: permissionKindInteger
		origin: originString
		state: stateInteger
		completedHandler: handler.
	handler free! !

!WebView2.ICoreWebView2Profile categoriesForMethods!
Add_Deleted:token:!COM Interfaces-ICoreWebView2Profile8!private! !
AddBrowserExtension:handler:!COM Interfaces-ICoreWebView2Profile7!public! !
addBrowserExtension:thenDo:!async requests!public! !
clearBrowsingData:from:to:thenDo:!methods!public! !
ClearBrowsingData:handler:!COM Interfaces-ICoreWebView2Profile2!private! !
clearBrowsingData:startTime:endTime:handler:!methods!public! !
clearBrowsingData:thenDo:!async requests!public! !
ClearBrowsingDataAll:!COM Interfaces-ICoreWebView2Profile2!private! !
clearBrowsingDataAllThenDo:!async requests!public! !
ClearBrowsingDataInTimeRange:startTime:endTime:handler:!COM Interfaces-ICoreWebView2Profile2!private! !
clearBrowsingDataThenDo:!async requests!public! !
cookieManager!properties!public! !
defaultDownloadFolderPath!properties!public! !
defaultDownloadFolderPath:!**auto generated**!properties!public! !
defaultTrackingPreventionLevel!constants!private! !
Delete!COM Interfaces-ICoreWebView2Profile8!public! !
displayOn:!displaying!public! !
get_CookieManager:!COM Interfaces-ICoreWebView2Profile5!private! !
get_DefaultDownloadFolderPath:!**auto generated**!COM Interfaces-ICoreWebView2Profile!private! !
get_IsGeneralAutofillEnabled:!COM Interfaces-ICoreWebView2Profile6!private! !
get_IsInPrivateModeEnabled:!**auto generated**!COM Interfaces-ICoreWebView2Profile!private! !
get_IsPasswordAutosaveEnabled:!COM Interfaces-ICoreWebView2Profile6!private! !
get_PreferredColorScheme:!**auto generated**!COM Interfaces-ICoreWebView2Profile!private! !
get_PreferredTrackingPreventionLevel:!COM Interfaces-ICoreWebView2Profile3!private! !
get_ProfileName:!**auto generated**!COM Interfaces-ICoreWebView2Profile!private! !
get_ProfilePath:!**auto generated**!COM Interfaces-ICoreWebView2Profile!private! !
GetBrowserExtensions:!COM Interfaces-ICoreWebView2Profile7!public! !
getBrowserExtensionsThenDo:!async requests!public! !
GetNonDefaultPermissionSettings:!COM Interfaces-ICoreWebView2Profile4!public! !
getNonDefaultPermissionSettingsThenDo:!async requests!public! !
icon!displaying!public! !
isGeneralAutofillEnabled!properties!public! !
isGeneralAutofillEnabled:!properties!public! !
isInPrivateModeEnabled!properties!public! !
isPasswordAutosaveEnabled!properties!public! !
isPasswordAutosaveEnabled:!properties!public! !
preferredColorScheme!properties!public! !
preferredColorScheme:!properties!public! !
preferredTrackingPreventionLevel!properties!public! !
preferredTrackingPreventionLevel:!properties!public! !
printableProperties!printing!private! !
profileName!properties!public! !
profilePath!properties!public! !
put_DefaultDownloadFolderPath:!**auto generated**!COM Interfaces-ICoreWebView2Profile!private! !
put_IsGeneralAutofillEnabled:!COM Interfaces-ICoreWebView2Profile6!private! !
put_IsPasswordAutosaveEnabled:!COM Interfaces-ICoreWebView2Profile6!private! !
put_PreferredColorScheme:!**auto generated**!COM Interfaces-ICoreWebView2Profile!private! !
put_PreferredTrackingPreventionLevel:!COM Interfaces-ICoreWebView2Profile3!private! !
Remove_Deleted:!COM Interfaces-ICoreWebView2Profile8!public! !
SetPermissionState:origin:state:completedHandler:!COM Interfaces-ICoreWebView2Profile4!public! !
setPermissionState:origin:state:thenDo:!async requests!public! !
!

!WebView2.ICoreWebView2Profile class methodsFor!

defineFunctions
	"Declare the virtual function table for the COM interface 'WebView2.ICoreWebView2Profile'
		ICoreWebView2Profile defineTemplate"

	self
		defineFunction: #get_ProfileName:
			argumentTypes: 'lpwstr*';
		defineFunction: #get_IsInPrivateModeEnabled:
			argumentTypes: 'sdword*';
		defineFunction: #get_ProfilePath:
			argumentTypes: 'lpwstr*';
		defineFunction: #get_DefaultDownloadFolderPath:
			argumentTypes: 'lpwstr*';
		defineFunction: #put_DefaultDownloadFolderPath:
			argumentTypes: 'lpwstr';
		defineFunction: #get_PreferredColorScheme:
			argumentTypes: 'sdword*';
		defineFunction: #put_PreferredColorScheme:
			argumentTypes: 'sdword'
!

latestDerivation
	^##(super latestDerivation)! !

!WebView2.ICoreWebView2Profile class categoriesForMethods!
defineFunctions!**auto generated**!initializing!public!template definition! !
latestDerivation!enquiries!public! !
!

