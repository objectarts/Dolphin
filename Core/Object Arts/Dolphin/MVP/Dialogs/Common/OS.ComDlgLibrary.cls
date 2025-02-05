﻿"Filed out from Dolphin Smalltalk"!

External.WindowsSystemLibrary
	subclass: #'OS.ComDlgLibrary'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

OS.ComDlgLibrary guid: (Core.GUID fromString: '{6467405a-3a82-101b-8181-00aa003743d3}')!

OS.ComDlgLibrary comment: 'ComDlgLibrary is the <ExternalLibrary> class to represent the Win32 system DLL, COMDLG32.DLL.

This DLL implements Windows'' standard "common" dialogs, such as the File Open/Save, Find, Find/Replace, Font, Color and Print dialogs. See subclasses of <CommonDialog>, which wrap these behind a Smalltalk API in Dolphin.'!

!OS.ComDlgLibrary categoriesForClass!External-Libraries-Win32! !

!OS.ComDlgLibrary methodsFor!

commDlgExtendedError
	"The CommDlgExtendedError function returns a common dialog box error code.
	This code indicates the most recent error to occur during the execution of one of 
	the common dialog box functions."

	<stdcall: uint32 CommDlgExtendedError>
	^self invalidCall: _failureCode!

findText: aWinFINDREPLACE
	"Create a system-defined modeless dialog box that lets the user specify a string to search for and options to 
	use when searching for text in a document.

		HWND FindText(
			LPFINDREPLACE  lpfr 	// address of structure with initialization data
		);"

	<stdcall: handle FindTextW lpvoid>
	^self invalidCall: _failureCode!

getFileTitle: lpszFile lpszTitle: lpszTitle cbBuf: cbBuf
	"Answer the title of the file identified by the lpszFile parameter.
		short GetFileTitle(
			LPCWSTR lpszFile, 	// pointer to full path and filename for file 	
			LPWSTR lpszTitle, 	// pointer to buffer that receives filename 	
			WORD cbBuf 	// length of buffer 	
		);"

	<stdcall: int16 GetFileTitleW lpwstr lpwstr uint16>
	^self invalidCall: _failureCode!

getOpenFileName: aWinOPENFILENAME
	"Creates an Open common dialog box that lets the user specify the drive, directory, and the name 
	of a file or set of files to open. 

		BOOL GetOpenFileName(
			LPOPENFILENAME  lpofn 	// address of structure with initialization data
		);"

	<stdcall: bool GetOpenFileNameW lpvoid>
	^self invalidCall: _failureCode!

getSaveFileName: aWinOPENFILENAME
	"Creates a Save common dialog box that lets the user specify the drive, directory, 
	and name of a file to save.

		BOOL GetSaveFileName(
			LPOPENFILENAME  lpofn 	// address of structure with initialization data
		);"

	<stdcall: bool GetSaveFileNameW lpvoid>
	^self invalidCall: _failureCode!

systemError
	"Generate an error based on the last recorded host system error."

	^self systemError: self commDlgExtendedError! !

!OS.ComDlgLibrary categoriesForMethods!
commDlgExtendedError!primitives!private!win32 functions-common dialog box! !
findText:!primitives!private!win32 functions-common dialog box! !
getFileTitle:lpszTitle:cbBuf:!primitives!private!win32 functions-file! !
getOpenFileName:!primitives!private!win32 functions-common dialog box! !
getSaveFileName:!primitives!private!win32 functions-common dialog box! !
systemError!exceptions!public! !
!

!OS.ComDlgLibrary class methodsFor!

fileName
	"Answer the host system file name for the library"

	^'comdlg32'!

sharedVariableName
	^#{ComDlg32}! !

!OS.ComDlgLibrary class categoriesForMethods!
fileName!constants!public! !
sharedVariableName!constants!private! !
!

