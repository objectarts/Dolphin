﻿"Filed out from Dolphin Smalltalk"!

External.WindowsSystemLibrary
	subclass: #'OS.WinInetLibrary'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

OS.WinInetLibrary guid: (Core.GUID fromString: '{96152a1d-1214-4ed9-82f2-10021d755f70}')!

OS.WinInetLibrary comment: ''!

!OS.WinInetLibrary categoriesForClass!External-Libraries-Win32! !

!OS.WinInetLibrary methodsFor!

internetCheckConnection: url dwFlags: flags dwReserved: reserved
	"Allows an application to check if a connection to the Internet can be established.

	BOOL InternetCheckConnection(
		IN LPCWSTR lpszUrl,
		IN DWORD dwFlags,
		IN DWORD dwReserved
		);"

	<stdcall: bool InternetCheckConnectionW lpwstr uint32 uint32>
	^self invalidCall: _failureCode!

internetGetConnectedState: flagsBuf dwReserved: reserved
	<stdcall: bool InternetGetConnectedState uint32* uint32>
	^self invalidCall: _failureCode!

internetGoOnline: url hwndParent: parent dwReserved: reserved
	"Prompts the user for permission to initiate connection to a URL.

	BOOL InternetGoOnline(
		IN LPTSTR lpszURL,
		IN HWND hwndParent,
		IN DWORD dwReserved
		);"

	<stdcall: bool InternetGoOnlineW lpwstr handle uint32>
	^self invalidCall: _failureCode!

internetOpen: agent dwAccessType: access lpszProxyName: proxyName lpszProxyBypass: proxyBypass dwFlags: flags
	"Initializes an application's use of the Win32 Internet functions.

	HINTERNET InternetOpen( IN LPCTSTR lpszAgent, 
		IN DWORD dwAccessType, 
		IN LPCTSTR lpszProxyName, 
		IN LPCTSTR lpszProxyBypass, 
		IN DWORD dwFlags ); "

	<stdcall: handle InternetOpenW lpwstr uint32 lpwstr lpwstr uint32>
	^self invalidCall: _failureCode!

ping: aURL
	"Attempts to ping aURL. Answers true if a reply is received."

	^self internetCheckConnection: aURL dwFlags: 1 dwReserved: 0! !

!OS.WinInetLibrary categoriesForMethods!
internetCheckConnection:dwFlags:dwReserved:!public!win32 functions-internet! !
internetGetConnectedState:dwReserved:!public!win32 functions-internet! !
internetGoOnline:hwndParent:dwReserved:!public!win32 functions-internet! !
internetOpen:dwAccessType:lpszProxyName:lpszProxyBypass:dwFlags:!public!win32 functions-internet! !
ping:!operations!public! !
!

!OS.WinInetLibrary class methodsFor!

fileName
	"Answer the file name of the external library which the receiver represents."

	^'wininet'! !

!OS.WinInetLibrary class categoriesForMethods!
fileName!constants!public! !
!

