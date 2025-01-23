"Filed out from Dolphin Smalltalk"!

External.WindowsSystemLibrary
	subclass: #'OS.UserLibrary'
	instanceVariableNames: ''
	classVariableNames: 'DesiredDpiAwarenessContext DpiAwarenessContext'
	imports: #(#{OS.MessageBoxConstants private})
	classInstanceVariableNames: ''
	classConstants: {}!

OS.UserLibrary guid: (Core.GUID fromString: '{64674046-3a82-101b-8181-00aa003743d3}')!

OS.UserLibrary comment: 'UserLibrary is the <ExternalLibrary> class to represent the Windows system DLL, User32.DLL.

The default instance of this class provides access to most of the Win32 window management API. New functions may be added as required, but the external function naming convention should be followed.

All functions in this library use the stdcall calling convention.'!

!OS.UserLibrary categoriesForClass!External-Libraries-Win32! !

!OS.UserLibrary methodsFor!

blockInput: aBoolean
	"Blocks keyboard and mouse input events from reaching applications. 
		BOOL BlockInput(
			BOOL fBlockIt 	
		);"

	<stdcall: bool BlockInput bool>
	^self invalidCall: _failureCode!

createDialogParam: hInstance lpTemplate: template hWndParent: hParent lpDialogFunc: dlgProc dwInitParam: lParam
	"Create a modeless dialog box from a dialog box template resource. 
		HWND CreateDialog(
  			HINSTANCE hInstance,		// handle of module containing template
			LPCWSTR lpTemplate,			// resource identifier
			HWND hWndParent,			// handle of owner window
			DLGPROC lpDialogFunc, 		// address of dialog proc
			LPARAM dwInitParam 		// value passed to wmInitDialog:
		);"

	<stdcall: handle CreateDialogParamW handle lpvoid handle lpvoid int32>
	^self invalidCall: _failureCode!

defDlgProc: hWnd msg: msg wParam: wParam lParam: lParam
	"Call the default dialog procedure to provide default processing for 
	any window messages that an application does not process. 

		LRESULT DefDlgProc(
			HWND hDlg,	// handle to dialog box
			UINT Msg,	// message
			WPARAM wParam,	// first message parameter
			LPARAM lParam 	// second message parameter
		);"

	<stdcall: uintptr DefDlgProcW handle uint32 uintptr uintptr>
	^self invalidCall: _failureCode!

defWindowProc: hWnd msg: msg wParam: wParam lParam: lParam
	"Call the default window procedure to provide default processing for 
	any window messages that an application does not process. 
	
		LRESULT DefWindowProc(
			HWND hWnd,	// handle to window
			UINT Msg,	// message identifier
			WPARAM wParam,	// first message parameter
			LPARAM lParam 	// second message parameter
		);"

	<stdcall: uintptr DefWindowProcW handle uint32 uintptr uintptr>
	^self invalidCall: _failureCode!

destroyWindow: aWindowHandle
	"Destroys the specified window. WM_DESTROY and WM_NCDESTROY messages are sent
	to the window to deactivate it, and remove the keyboard focus. The window's menu
	is destroyed, the owning threads message queue flushed, outstanding timers are 
	destroyed, clipboard ownership is revoked, the clipboard viewer chain is broken 
	(if the window is at the top of the viewer chain). All owned and child windows
	are also destroyed. Can also be used to destroys modeless dialog boxes created 
	by the CreateDialog function. 
		BOOL DestroyWindow(
			HWND  hWnd 	// handle of window to destroy  
		);"

	<stdcall: bool DestroyWindow handle>
	^self invalidCall: _failureCode!

dispatchMessage: aMSG
	"Dispatch a message to a window procedure.
		LONG DispatchMessage(
  			CONST MSG *lpmsg 	// pointer to structure with message
		);"

	<stdcall: int32 DispatchMessageW MSG*>
	^self invalidCall: _failureCode!

enableWindow: aWindowHandle bEnable: aBoolean
	"Enable or disable mouse and keyboard input to the specified window.
		BOOL EnableWindow(
			HWND hWnd,	// handle to window
			BOOL bEnable 	// flag for enabling or disabling input
		);"

	<stdcall: bool EnableWindow handle bool>
	^self invalidCall: _failureCode!

getActiveWindow
	"Answer the handle of Dolphin's active window (nil if none active)."

	<stdcall: handle GetActiveWindow>
	^self invalidCall: _failureCode!

getAsyncKeyState: virtualKeyCodeInteger
	<stdcall: int16 GetAsyncKeyState int32>
	^self invalidCall: _failureCode!

getDesktopWindow
	"Answer the handle of the desktop (ultimate parent) window. Answer that handle. 
	N.B. Although the desktop window is logically the parent
	of all top-level windows, its handle is not, sadly, that answered by GetParent()
	for such windows. View>>parentView does, however, return the desktop window as the
	parent of top level windows."

	<stdcall: handle GetDesktopWindow>
	^self invalidCall: _failureCode!

getDlgItem: aWindowHandle nIDDlgItem: anIntegerId
	"Retrieves the handle of a control in a dialog box. 
  
		HWND GetDlgItem(
  			HWND  hDlg,		// handle of dialog box
			int  nIDDlgItem 	// identifier of control
		);"

	<stdcall: handle GetDlgItem handle int32>
	^self invalidCall: _failureCode!

getKeyboardLayout: anInteger
	<stdcall: handle GetKeyboardLayout int32>
	^self invalidCall: _failureCode!

getKeyboardLayoutName: pwszKLID
	<stdcall: bool GetKeyboardLayoutNameW lpwstr>
	^self invalidCall: _failureCode!

getKeyboardState: a256ByteArray
	"Copies the status of the 256 virtual keys to the specified buffer. 
		BOOL GetKeyboardState(
			PBYTE lpKeyState 	// address of array to receive status data
		);"

	<stdcall: bool GetKeyboardState lpvoid>
	^self invalidCall: _failureCode!

getKeyNameText: lParam lpString: aString nSize: anInteger
	"Populate a string with the name of a virtual key code
		int GetKeyNameText( 
			LONG lParam,	// second parameter of keyboard message	
			LPWSTR lpString,	// address of buffer for key name	
			int nSize 	// maximum length of key-name string length	
		);"

	<stdcall: int32 GetKeyNameTextW uint32 lpwstr int32>
	^self invalidCall: _failureCode!

getKeyState: virtualKeyCodeInteger
	"Answer the status of the virtual key, virtualKeyCodeInteger. See the Keyboard class.

		SHORT GetKeyState(int  nVirtKey);"

	<stdcall: int16 GetKeyState int32>
	^self invalidCall: _failureCode!

getMessage: aMSG hWnd: aWindowHandle wMsgFilterMin: anIntFilterMin wMsgFilterMax: anIntFilterMax
	"Retrieves the next message from the Win32 input queue in the range integerFilterMin
	integerFilterMax, for the window with handle aWindowHandle (if Null then for all windows)
	into the Win32 MSG structure, aMSG.

	BOOL GetMessage(
		LPMSG  lpMsg,	// address of structure with message
		HWND  hWnd,	// handle of window
		UINT  wMsgFilterMin,	// first message
		UINT  wMsgFilterMax 	// last message
	);	

	Answers 1 if a message was retrieved, 0 if WM_QUIT was retrieved, or -1 if some
	error occurred. N.B. Though Win32 declares GetMessage() as returning a BOOL,
	it doesn't really (because of the error return value) so to avoid errors, as
	suggested in the help), we have it return a signed integer)"

	<stdcall: int32 GetMessageW MSG* handle uint32 uint32>
	^self invalidCall: _failureCode!

getParent: hWnd
	"Answer the handle of the parent window of the specified window.
	If the window is a top level window (whose parent is really the Desktop
	window) then answer 0 (which is not the handle of the real Desktop window, but
	is the handle of the Dolphin Desktop window). Confused? Me too."

	<stdcall: uint32 GetParent handle>
	^self invalidCall: _failureCode!

getQueueStatus: integerFlags
	"Answer a 32-bit set of flags which indicates the type of messages currently present in
	the in the calling thread's message queue. 
		DWORD GetQueueStatus(
			UINT  flags 	// queue-status flags
		);
	See MSDN for further details."

	<stdcall: uint32 GetQueueStatus uint32>
	^self invalidCall: _failureCode!

getSysColor: index
	"Answer the current color of the specified display element. Display elements are 
	the parts of a window and the Windows display that appear on the system display screen
	(configurable from DisplayProperties/Appearance)
		DWORD GetSysColor(
			int nIndex 	// display element
		);"

	<stdcall: uint32 GetSysColor int32>
	^self invalidCall: _failureCode!

getSysColorBrush: anInteger
	"Answer the handle of one of the standard system colour brushes
		HBRUSH GetSysColorBrush(
  			int index
		);"

	<stdcall: handle GetSysColorBrush int32>
	^self invalidCall: _failureCode!

getSystemMetrics: index
	"Answer the dimension of some display elememnt (in pels) or system configuration setting.
		int GetSystemMetrics(
			int nIndex 	// system metric or configuration setting to retrieve  
		);"

	<stdcall: int32 GetSystemMetrics int32>
	^self invalidCall: _failureCode!

inSendMessage
	<stdcall: bool InSendMessage>
	^self invalidCall: _failureCode!

isWindow: hWnd
	"Answer whether the window handle, hWnd, is currently valid"

	<stdcall: bool IsWindow handle>
	^self invalidCall: _failureCode!

isWindowEnabled: hWnd
	"Answer whether the window with handle, hWnd, is currently enabled (i.e.
	prepared to accept user input"

	<stdcall: bool IsWindowEnabled handle>
	^self invalidCall: _failureCode!

isWindowVisible: hWnd
	"Answer whether the window with handle, hWnd, is currently visible (i.e. not hidden)."

	<stdcall: bool IsWindowVisible handle>
	^self invalidCall: _failureCode!

killTimer: aWindowHandle uIDEvent: anInteger
	"Destroy the specified timer. Any pending wmTimer: messages for the receiver
	are also removed.
		BOOL KillTimer(
			HWND hWnd,	// handle of window that installed timer
			UINT uIDEvent 	// timer identifier
		);"

	<stdcall: bool KillTimer handle uint32>
	^self invalidCall: _failureCode!

loadCursor: anInstanceHandle lpCursorName: anIntegerID
	"Loads the specified cursor resource from the module with the specified handle
	Under Win32 it is not necessary to destroy cursors loaded in this manner.

		HCURSOR LoadCursor(
  			HINSTANCE  hInstance,	// handle of application instance
			LPCWSTR  lpCursorName 	// name string or cursor resource identifier  
		);"

	<stdcall: handle LoadCursorW handle lpvoid>
	^self invalidCall: _failureCode!

loadKeyboardLayout: pwszKLID flags: flags
	<stdcall: handle LoadKeyboardLayoutW lpwstr uint32>
	^self invalidCall: _failureCode!

loadString: anExternalHandle uID: anIntegerID lpBuffer: aString nBufferMax: anIntegerLength
	"Load a string resource from the executable file associated with 
	the specified module, into the specified buffer appending
	a terminating null character. Answer the length of the string, or 0 
	if it does not exist.
		int LoadString(
			HINSTANCE hInstance,	// handle of module containing string resource 
			UINT uID,				// resource identifier 
			LPTSTR lpBuffer,		// address of buffer for resource 
			int nBufferMax 		// size of buffer
		);"

	<stdcall: int32 LoadStringW handle uint32 lpvoid int32>
	^self invalidCall: _failureCode!

mapVirtualKey: keyCode uMapType: mapType
	"Map a virtual-key code into a scan code or character value, or translate a scan code into a virtual-key code. 

	The Meaning of keycode and the result of the translation depends on the maptype:

		keyCode					Answer
	0	virtual key code		->	scan code
	1	scan code				->	virtual key code
	2	virtual key code		->	character value
	3	scan code				->	virtual key code	

		UINT	MapVirtualKey(
			UINT uCode,
			UINT uMapType);"

	<stdcall: uint32 MapVirtualKeyW uint32 uint32>
	^self invalidCall: _failureCode!

messageBeep: anInteger
	"Plays a waveform identified by the argument, anInteger, in the registry.
			BOOL MessageBeep(
			UINT uType 	// sound type  
			);"

	<stdcall: bool MessageBeep uint32>
	^self invalidCall: _failureCode!

messageBox: anExternalHandle text: textString caption: captionString style: styleInteger icon: iconIdentifier instance: hInstance
	| iconId struct wasDisabled hWnd response isTaskModal dwStyle |
	isTaskModal := styleInteger allMask: MB_TASKMODAL.
	hWnd := isTaskModal
				ifTrue: [0]
				ifFalse: 
					["#2107: getActiveWindow may return nil, e.g. in a headless app with no windows"
					anExternalHandle ifNil: [User32 getActiveWindow ?? 0]].
	struct := MSGBOXPARAMSW new.
	dwStyle := styleInteger.
	struct text: textString.
	struct caption: captionString.
	iconId := iconIdentifier.
	iconId isNil
		ifFalse: 
			[iconId := iconId asResourceId.
			struct lpszIcon: iconId asUIntPtr.
			hInstance notNil ifTrue: [struct hInstance: hInstance asParameter]].
	struct dwStyle: dwStyle.
	struct hwndOwner: hWnd.
	isTaskModal
		ifTrue: 
			["If taskModal, then the owner will be the desktop so we need to get actual active view"
			hWnd := self getActiveWindow.
			"Ensure owner is (temporarily) enabled to prevent losing activation when box is closed"
			(wasDisabled := (self isWindowEnabled: hWnd) not) ifTrue: [self enableWindow: hWnd bEnable: true].
			response := 
					[SessionManager.Current inputState startIdleTimer.
					"Task modal only disables windows in the calling thread, so we can't use an
					overlapped call here."
					self messageBoxIndirect: struct]
							ensure: [SessionManager.Current inputState stopIdleTimer]]
		ifFalse: 
			[wasDisabled := (self isWindowEnabled: hWnd) not.
			"MessageBoxIndirect is called using an overlapped call on a separate thread to avoid
			losing control of the message loop. If the initiating process is the UI process then its
			priority is boosted so that the operation requested by the user completes more quickly 
			when the dialog is closed."
			Processor forkMainIfMain
				ifTrue: 
					[| proc |
					proc := Processor activeProcess.
					proc priority: proc priority + 1].
			response := self overlappedMsgBoxIndirect: struct].

	"The message box will unhelpfully re-enable the window regardless of whether previously disabled"
	wasDisabled ifTrue: [self enableWindow: hWnd bEnable: false].
	response == 0 ifTrue: [self systemError].
	^response!

messageBoxIndirect: aMSGBOXPARAMS
	"Open a message box with the details specified in the structure.

		int MessageBox(
			LPMSGBOXPARRAMS lpMsgBoxParams;
		);"

	<stdcall: int32 MessageBoxIndirectW MSGBOXPARAMSW*>
	^self invalidCall: _failureCode!

msgWaitForMultipleObjectsEx: countInteger pHandles: handles dwMilliseconds: millisecsInteger dwWakeMask: maskInteger dwFlags: aBoolean
	"Waits until when one of the following occurs: 
		·	either any one of, or all of (the number of handles being specified 
			by the argument, countInteger, and whether to wait for a single object
			or all of the objects being specified by the argument, waitBoolean), 
			the objects whose handles are specified by the argument, handles 
			(which may be a single handle, or a UInt32Array) are 
			in the signaled state; or
		·	A Win32 message of a type which matches the type mask specified by
			the argument, maskInteger, becomes available in the message queue (
			uses the same flags as #getQueueStatus:); or
		·	the number of milliseconds specified by the argument, millisecsInteger,
			elapses.

	MsgWaitForMultipleObjects should only be called when there are no further messages
	waiting in the input queue, because it only detects the arrival of new messages (this is fixed
	in Win98 and NT5 with the addition of the MWMO_INPUTAVAILABLE flag).

	N.B. Under NT, the handles in the argument, handles, must have SYNCHRONIZE access.

	If successful, answer the event that cause the function to return. See Win32 documentation
	for specific return values. If the function fails, answers -1. KernelLibrary>>getLastError
	can be used to get extended error information

		DWORD MsgWaitForMultipleObjectsEx(
			DWORD nCount,
			LPHANDLE pHandles,
			DWORD dwMilliseconds,
			DWORD dwWakeMask,
			DWORD dwFlags)
	"

	<stdcall: int32 MsgWaitForMultipleObjectsEx uint32 lpvoid uint32 uint32 uint32>
	^self invalidCall: _failureCode!

overlappedMsgBoxIndirect: aMSGBOXPARAMS
	"Private - Open a message box with the details specified in the structure
	as an overlapped call (i.e. on a separate thread).
	N.B. Don't use for MB_TASKMODAL message boxes.

		int MessageBox(
			LPMSGBOXPARRAMS lpMsgBoxParams;
		);"

	<overlap stdcall: int32 MessageBoxIndirectW MSGBOXPARAMSW*>
	^self invalidCall: _failureCode!

peekMessage: aMSG hWnd: aWindowHandle uMsgFilterMin: anIntFilterMin uMsgFilterMax: uMsgFilterMax wRemoveMsg: anIntFlags
	"Check the threads message queue for messages for the Window with
	handle aWindowHandle (all windows if nil/0, app messages if -1) in the range
	anIntFilterMin..anIntFilterMax (all messages if 0..0), retrieving 
	the first (if any) of such messages into aMSG, answering whether 
	a message was found. The message is optionally removed from the 
	queue depending on the value of the argument, anIntFlags (PM_REMOVE/
	PM_NOREMOVE). The flag value PmNoYield is obsolete, and has no effect
	in Win32.

		BOOL PeekMessage(
			LPMSG  lpMsg,			// address of structure for message
			HWND  hWnd,			// handle of window
			UINT  uMsgFilterMin,	// first message
			UINT  uMsgFilterMax,	// last message
			UINT  wRemoveMsg 		// removal flags
		);"

	<stdcall: bool PeekMessageW MSG* handle uint32 uint32 uint32>
	^self invalidCall: _failureCode!

postMessage: aWindowHandle msg: msg wParam: wParam lParam: lParam
	"Post a message to aWindowHandle.

	LRESULT PostMessage(
		HWND hWnd, 		// handle of destination window
		UINT Msg, 		// message to send
		WPARAM wParam, 	// first message parameter
		LPARAM lParam 		// second message parameter
	   );"

	<stdcall: intptr PostMessageW handle uint32 uintptr intptr>
	^self invalidCall: _failureCode!

postQuitMessage: anInteger
	"Post a WM_QUIT message to the current thread, initiating system shutdown.
		VOID PostQuitMessage(
			int  nExitCode 	// exit code
		);"

	<stdcall: void PostQuitMessage int32>
	^self invalidCall: _failureCode!

postThreadMessage: anIntegerId msg: msg wParam: wParam lParam: lParam
	"Post a message to the message queue of the specified thread for asynchronous processing.
		BOOL PostThreadMessage(
  			DWORD  idThread,	// thread identifier
			UINT  Msg,		// message to post
			WPARAM  wParam,	// first message parameter
			LPARAM  lParam 	// second message parameter);"

	<stdcall: bool PostThreadMessageW handle uint32 uintptr uintptr>
	^self invalidCall: _failureCode!

sendMessage: aWindowHandle msg: msg wParam: wParam lParam: lParam
	"The SendMessage function sends the specified message to a window or windows.
	The function calls the window procedure for the specified window and does not
	return until the window procedure has processed the message. The PostMessage
	function, in contrast, posts a message to a thread's message queue and returns
	immediately. 

	Implementation Note: Although LPARAM is defined as a signed parameter, more often
	than not it is used to pass an unsigned 32-bit value. As we have a strict definition
	of what can be passed to a signed integer parameter (i.e. only valid two's complement 
	values that fit within the required size), we used the slightly more relaxed unsigned 
	specification. This allows LargeIntegers > the maximum positive signed value for
	the machine word size to be passed.

	LRESULT SendMessage(
		HWND hWnd, 		// handle of destination window
		UINT Msg, 		// message to send
		WPARAM wParam, 	// first message parameter
		LPARAM lParam 		// second message parameter
	   );"

	<stdcall: intptr SendMessageW handle uint32 uintptr uintptr>
	^self invalidCall: _failureCode!

setActiveWindow: aHandle
	"Makes the specified top-level window associated with the current thread the active window. 
		HWND SetActiveWindow( HWND hWnd);"

	<stdcall: handle SetActiveWindow handle>
	^self invalidCall: _failureCode!

setCursor: aWindowHandle
	"Set the current system cursor to the argument. N.B. This has only a temporary effect, as the system will
	change the cursor whenever it moves over a window which either has a class Cursor set, or responds to the
	the WM_SETCURSOR message. See the Cursor class.

		HCURSOR SetCursor(
  			HCURSOR  hCursor 	// handle of cursor
		);"

	<stdcall: handle SetCursor handle>
	^self invalidCall: _failureCode!

setDlgItemText: aWindowHandle nIDDlgItem: anIntegerId lpString: aString
	"Sets the title or text of a control in a dialog box. 
		BOOL SetDlgItemText(
  			HWND  hDlg,		// handle of dialog box
			int  nIDDlgItem,	// identifier of control
			LPCWSTR  lpString 	// text to set
			);"

	<stdcall: bool SetDlgItemTextW handle int32 lpwstr>
	^self invalidCall: _failureCode!

setKeyboardState: a256ByteArray
	"Copy the specified 256-byte array of keyboard key states into the 
	keyboard-input state table (also accessed by the GetKeyboardState and 
	GetKeyState functions). Changes made to the table affect only the calling
	thread.
		BOOL SetKeyboardState(
  			LPBYTE lpKeyState 	// address of array with virtual-key codes
		   );"

	<stdcall: bool SetKeyboardState lpvoid>
	^self invalidCall: _failureCode!

setTimer: aWindowHandle nIDEvent: anIntegerId uElapse: anInteger lpTimerFunc: callbackProc
	"Create a timer with the specified time-out value.
	N.B. The preferred method of performing time triggered activities in Dolphin is to make
	use of Delays in conjunction with Processes. These are more portable, powerful, flexible, 
	and have a higher resolution capability.
		UINT SetTimer(
			HWND hWnd,	// handle of window for timer messages
			UINT nIDEvent,	// timer identifier
			UINT uElapse,	// time-out value
			TIMERPROC lpTimerFunc 	// address of timer procedure
		);"

	<stdcall: uint32 SetTimer handle uint32 uint32 lpvoid>
	^self invalidCall: _failureCode!

setWindowText: aWindowHandle lpString: aString
	"Set the 'text' of the specified window.
		BOOL SetWindowText(
			HWND hWnd,		// handle of window or control
			LPCWSTR lpString 	// address of string
		);"

	"Note that we can always pass a UTF16 string - Windows will translate automatically for non-Unicode windows."

	<stdcall: bool SetWindowTextW handle lpwstr>
	^self invalidCall: _failureCode!

showWindow: aWindowHandle nCmdShow: flags
	"Set the specified window's show state. 
		BOOL ShowWindow(
			HWND hWnd,	// handle of window
			int nCmdShow 	// show state of window
		);"

	<stdcall: bool ShowWindow handle int32>
	^self invalidCall: _failureCode!

translateMessage: aMSG
	"Translates virtual-key messages into character messages, posting them to the message queue to
	be read by subsequent calls to #getMessage:etc or #peekMessage:etc.

		BOOL TranslateMessage(
			CONST MSG *lpMsg 	// address of structure with message
		);"

	<stdcall: bool TranslateMessage MSG*>
	^self invalidCall: _failureCode!

updateWindow: hWnd
	"Repaint the client area of the specified window by sending a wmPaint: directly to
	the window if its update region is not empty.
		BOOL UpdateWindow(
			HWND hWnd 	// handle of window  
		);"

	<stdcall: bool UpdateWindow handle>
	^self invalidCall: _failureCode!

vkKeyScan: aChar
	"Translate a character to the corresponding virtual-key code 
	and shift state for the current keyboard.
		SHORT VkKeyScan(
			WCHAR ch 	// character to translate
	   );"

	<stdcall: int16 VkKeyScanW char>
	^self invalidCall: _failureCode! !

!OS.UserLibrary categoriesForMethods!
blockInput:!public!win32 functions-window! !
createDialogParam:lpTemplate:hWndParent:lpDialogFunc:dwInitParam:!public!win32 functions-dialog box! !
defDlgProc:msg:wParam:lParam:!public!win32 functions-window procedure! !
defWindowProc:msg:wParam:lParam:!public!win32 functions-window procedure! !
destroyWindow:!public!win32 functions-window! !
dispatchMessage:!public!win32 functions-message and message queue! !
enableWindow:bEnable:!public!win32 functions-keyboard input! !
getActiveWindow!public!win32 functions-keyboard input! !
getAsyncKeyState:!public!win32 functions-keyboard input! !
getDesktopWindow!public!win32 functions-window! !
getDlgItem:nIDDlgItem:!public!win32 functions-dialog box! !
getKeyboardLayout:!public!win32 functions-keyboard input! !
getKeyboardLayoutName:!public!win32 functions-keyboard input! !
getKeyboardState:!public!win32 functions-keyboard input! !
getKeyNameText:lpString:nSize:!public!win32 functions-keyboard input! !
getKeyState:!public!win32 functions-keyboard input! !
getMessage:hWnd:wMsgFilterMin:wMsgFilterMax:!public!win32 functions-message and message queue! !
getParent:!public!win32 functions-window! !
getQueueStatus:!public!win32 functions-message and message queue! !
getSysColor:!public!win32 functions-system information! !
getSysColorBrush:!public!win32 functions-cursor! !
getSystemMetrics:!public!win32 functions-system information! !
inSendMessage!public!win32 functions-message and message queue! !
isWindow:!public!win32 functions-window! !
isWindowEnabled:!public!win32 functions-window! !
isWindowVisible:!public!win32 functions-window! !
killTimer:uIDEvent:!public!win32 functions-timer! !
loadCursor:lpCursorName:!public!win32 functions-cursor! !
loadKeyboardLayout:flags:!public!win32 functions-keyboard input! !
loadString:uID:lpBuffer:nBufferMax:!public!win32 functions-string manipulation! !
mapVirtualKey:uMapType:!public!win32 functions-keyboard input! !
messageBeep:!public!win32 functions-error! !
messageBox:text:caption:style:icon:instance:!displaying!private! !
messageBoxIndirect:!public!win32 functions-dialog box! !
msgWaitForMultipleObjectsEx:pHandles:dwMilliseconds:dwWakeMask:dwFlags:!public!win32 functions-synchronization! !
overlappedMsgBoxIndirect:!private!win32 functions-dialog box! !
peekMessage:hWnd:uMsgFilterMin:uMsgFilterMax:wRemoveMsg:!public!win32 functions-message and message queue! !
postMessage:msg:wParam:lParam:!public!win32 functions-message and message queue! !
postQuitMessage:!public!win32 functions-message and message queue! !
postThreadMessage:msg:wParam:lParam:!public!win32 functions-message and message queue! !
sendMessage:msg:wParam:lParam:!public!win32 functions-message and message queue! !
setActiveWindow:!public!win32 functions-keyboard input! !
setCursor:!public!win32 functions-cursor! !
setDlgItemText:nIDDlgItem:lpString:!public!win32 functions-dialog box! !
setKeyboardState:!public!win32 functions-keyboard input! !
setTimer:nIDEvent:uElapse:lpTimerFunc:!public!win32 functions-timer! !
setWindowText:lpString:!public!win32 functions-window! !
showWindow:nCmdShow:!public!win32 functions-window! !
translateMessage:!public!win32 functions-message and message queue! !
updateWindow:!public!win32 functions-painting and drawing! !
vkKeyScan:!public!win32 functions-keyboard input! !
!

!OS.UserLibrary class methodsFor!

clear
	"Private - Clear down cached external function addresses and any default 
	instances of the receiver from previous runs. etc."

	super clear.
	#(#{OS.SystemMetrics} #{UI.DisplayMonitor}) do: [:each | each ifDefined: [:c | c reset]]!

fileName
	"Answer the host system file name of the external library which 
	the receiver represents."

	^'USER32'!

initialize
	DesiredDpiAwarenessContext := DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2!

sharedVariableName
	^#{User32}! !

!OS.UserLibrary class categoriesForMethods!
clear!initializing!private! !
fileName!constants!public! !
initialize!class initialization!public! !
sharedVariableName!constants!private! !
!

