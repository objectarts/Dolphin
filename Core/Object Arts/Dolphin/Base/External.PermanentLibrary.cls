"Filed out from Dolphin Smalltalk"!

External.DynamicLinkLibrary
	subclass: #'External.PermanentLibrary'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

External.PermanentLibrary guid: (Core.GUID fromString: '{87b4c583-026e-11d3-9fd7-00a0cc3e4a32}')!

External.PermanentLibrary isNonInstantiable: true!

External.PermanentLibrary comment: '`PermanentLibrary` is the class of `ExternalLibrary`s which are expected to remain permanently open in order for the system to continue functioning, and/or to avoid some sequencing issues initializing the system on system. The set of permanent libraries includes a minimal set of the basic Win32 system DLLs (Kernel32 and User32), the C runtime library, and the Virtual Machine itself.'!

!External.PermanentLibrary categoriesForClass!External-Libraries! !

!External.PermanentLibrary methodsFor!

close
	"Release the reference the receiver has to the External Library it represents. This may
	not cause the library to be unloaded, so it may still function.
	It is really not a good idea to do this for the default instances of permanent libraries 
	because it will break the VM and everything else."

	^self ~~ self class default and: [super close]!

isSelfEvaluating
	^true!

loadFlags
	"Private - Only ever load Windows system libraries from %windows%\system32. The VM library is not a system library, but cannot be loaded from the image in any case."

	^LOAD_LIBRARY_SEARCH_SYSTEM32! !

!External.PermanentLibrary categoriesForMethods!
close!public!realizing/unrealizing! !
isSelfEvaluating!public!testing! !
loadFlags!constants!private! !
!

!External.PermanentLibrary class methodsFor!

clear
	"Private - Clear down cached external function addresses from previous runs."

	self clearProcAddresses!

closeDefault
	"Private - Close the default instance of the receiver (if there is one).
	In the case of the receiver, we ignore this request because the default 
	is not lazily opened."!

default
	"Answer the default instance of the receiver. Override because the PermanentLibraries
	must always be open, and because speed of access to it is important to overall system
	performance."

	^default!

default: anExternalLibrary
	"Set the default instance of the receiver.
	The 'default' instance of permanent libraries cannot be changed."!

initializeSubclasses
	"Private - Perform session startup processing for the receiver and its subclasses.
	The permanent libraries have already been initialized."
!

onStartup2
	"Private - Perform system startup processing for all subclasses. PermanentLibrary subclasses have a default instance that is always opened on startup."

	"Implementation Note: The permanent libraries must be cleared down before they are re-opened, otherwise invalid function addresses may get called."

	self allSubclassesDo: [:c | c openDefault].
	"Add VM folder to DLL search path for libraries that specify LOAD_LIBRARY_SEARCH_DEFAULT_DIRS/LOAD_LIBRARY_SEARCH_USER_DIRS in #loadFlags"
	Kernel32 addDllDirectory: (File splitPathFrom: VM fileName)! !

!External.PermanentLibrary class categoriesForMethods!
clear!initializing!private! !
closeDefault!private!realizing/unrealizing! !
default!accessing!public! !
default:!accessing!public! !
initializeSubclasses!initializing!private! !
onStartup2!event handling!private! !
!

