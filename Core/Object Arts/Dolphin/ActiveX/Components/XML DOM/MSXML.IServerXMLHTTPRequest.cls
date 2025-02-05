﻿"Filed out from Dolphin Smalltalk"!

MSXML.IXMLHttpRequest
	subclass: #'MSXML.IServerXMLHTTPRequest'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

MSXML.IServerXMLHTTPRequest guid: (OS.COM.IID fromString: '{2e9196bf-13ba-4dd4-91ca-6c571f281495}')!

MSXML.IServerXMLHTTPRequest isEgressOnly: true!

MSXML.IServerXMLHTTPRequest comment: '<IServerXMLHTTPRequest> is a wrapper class for the COM interface ''MSXML2.IServerXMLHTTPRequest'' generated from type information in the ''Microsoft XML, v4.0'' library. It contains methods to invoke the member functions exposed by that interface.

The type library contains the following helpstring for this interface
	"IServerXMLHTTPRequest Interface"

Warning: This comment was automatically generated from the interface''s type information, but any changes made here will not be overwritten if the wrapper class is regenerated.

IDL definition follows:

[
	object, 
	uuid(2E9196BF-13BA-4DD4-91CA-6C571F281495), 
	helpstring("IServerXMLHTTPRequest Interface"), 
	dual
]
interface IServerXMLHTTPRequest : IXMLHTTPRequest
 {
	[id(0x0000000f), helpstring("Specify timeout settings (in milliseconds)")]
	HRESULT __stdcall setTimeouts(
		[in]long resolveTimeout,
		[in]long connectTimeout,
		[in]long sendTimeout,
		[in]long receiveTimeout);
	[id(0x00000010), helpstring("Wait for asynchronous send to complete, with optional timeout (in seconds)")]
	HRESULT __stdcall waitForResponse(
		[in, optional]VARIANT timeoutInSeconds,
		[out, retval]VARIANT_BOOL* isSuccessful);
	[id(0x00000011), helpstring("Get an option value")]
	HRESULT __stdcall getOption(
		[in]SERVERXMLHTTP_OPTION option,
		[out, retval]VARIANT* value);
	[id(0x00000012), helpstring("Set an option value")]
	HRESULT __stdcall setOption(
		[in]SERVERXMLHTTP_OPTION option,
		[in]VARIANT value);
};
'!

!MSXML.IServerXMLHTTPRequest categoriesForClass!COM-Interfaces!MSXML2-Interfaces! !

!MSXML.IServerXMLHTTPRequest methodsFor!

getOption: option
	"Answer the <variant> result of invoking the getOption() method of the COM object.
	Helpstring: Get an option value"

	| answer |
	answer := VARIANT new.
	self GetOption: option value: answer.
	^answer asObject!

GetOption: option value: value
	"Private - Invoke the getOption() method of the COM object.
	Helpstring: Get an option value

		HRESULT __stdcall getOption(
			[in]SERVERXMLHTTP_OPTION option,
			[out, retval]VARIANT* value);"

	<virtual stdcall: hresult 24 int32 variant*>
	^self invalidCall: _failureCode!

setOption: option value: value
	"Invoke the setOption() method of the COM object.
	Helpstring: Set an option value"

	^self SetOption: option value: value asVariant!

SetOption: option value: value
	"Private - Invoke the setOption() method of the COM object.
	Helpstring: Set an option value

		HRESULT __stdcall setOption(
			[in]SERVERXMLHTTP_OPTION option,
			[in]VARIANT value);"

	<virtual stdcall: hresult 25 int32 variant>
	^self invalidCall: _failureCode!

SetTimeouts: resolveTimeout connectTimeout: connectTimeout sendTimeout: sendTimeout receiveTimeout: receiveTimeout
	"Invoke the setTimeouts() method of the COM object.
	Helpstring: Specify timeout settings (in milliseconds)

		HRESULT __stdcall setTimeouts(
			[in]long resolveTimeout,
			[in]long connectTimeout,
			[in]long sendTimeout,
			[in]long receiveTimeout);"

	<virtual stdcall: hresult 22 int32 int32 int32 int32>
	^self invalidCall: _failureCode!

waitForResponse
	"Answer the <varbool> result of invoking the waitForResponse() method of the COM object.
	Default values are passed for all optional parameters."

	^self waitForResponse: VARIANT unspecified!

waitForResponse: timeoutInSeconds
	"Answer the <varbool> result of invoking the waitForResponse() method of the COM object.
	Helpstring: Wait for asynchronous send to complete, with optional timeout (in seconds)"

	| answer |
	answer := VARIANT_BOOL new.
	self WaitForResponse: timeoutInSeconds asVariant isSuccessful: answer.
	^answer asObject!

WaitForResponse: timeoutInSeconds isSuccessful: isSuccessful
	"Private - Invoke the waitForResponse() method of the COM object.
	Helpstring: Wait for asynchronous send to complete, with optional timeout (in seconds)

		HRESULT __stdcall waitForResponse(
			[in, optional]VARIANT timeoutInSeconds,
			[out, retval]VARIANT_BOOL* isSuccessful);"

	<virtual stdcall: hresult 23 variant varbool*>
	^self invalidCall: _failureCode! !

!MSXML.IServerXMLHTTPRequest categoriesForMethods!
getOption:!**auto generated**!methods!public! !
GetOption:value:!**auto generated**!COM Interfaces-IServerXMLHTTPRequest!private! !
setOption:value:!**auto generated**!methods!public! !
SetOption:value:!**auto generated**!COM Interfaces-IServerXMLHTTPRequest!private! !
SetTimeouts:connectTimeout:sendTimeout:receiveTimeout:!**auto generated**!COM Interfaces-IServerXMLHTTPRequest!public! !
waitForResponse!**auto generated**!methods!public! !
waitForResponse:!**auto generated**!methods!public! !
WaitForResponse:isSuccessful:!**auto generated**!COM Interfaces-IServerXMLHTTPRequest!private! !
!

!MSXML.IServerXMLHTTPRequest class methodsFor!

defineFunctions
	"Declare the virtual function table for the COM interface 'MSXML2.IServerXMLHTTPRequest'
		IServerXMLHTTPRequest defineTemplate"

	self
		defineFunction: #SetTimeouts:connectTimeout:sendTimeout:receiveTimeout:
			argumentTypes: 'sdword sdword sdword sdword';
		defineFunction: #WaitForResponse:isSuccessful:
			argumentTypes: 'variant varbool*';
		defineFunction: #GetOption:value:
			argumentTypes: 'sdword variant*';
		defineFunction: #SetOption:value:
			argumentTypes: 'sdword variant'
! !

!MSXML.IServerXMLHTTPRequest class categoriesForMethods!
defineFunctions!**auto generated**!initializing!private! !
!

