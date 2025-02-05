﻿"Filed out from Dolphin Smalltalk"!

WinHttpServer.HTTP_PROPERTY_FLAGS
	subclass: #'WinHttpServer.HTTP_BINDING_INFO'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: { '_HTTP_BINDING_INFO_Size' -> 16r8. '_OffsetOf_RequestQueueHandle' -> 16r4 }!

WinHttpServer.HTTP_BINDING_INFO guid: (Core.GUID fromString: '{b253697c-f239-4fb6-b474-b35db2c4848f}')!

WinHttpServer.HTTP_BINDING_INFO comment: '`HTTP_BINDING_INFO` is an `External.Structure` class to wrap the struct ''WinHttpServer.HTTP_BINDING_INFO'' from type information in the ''Windows Http Server API'' library.

The type library contains the following helpstring for this struct
	"The HTTP_BINDING_INFO structure is used to associate a URL Group with a request queue. This structure must be used when setting or querying the HttpServerBindingProperty on a URL Group."

** This comment was automatically generated from a type library. Delete this line to prevent any manual edits from being overwritten if the wrapper class is regenerated.

IDL definition follows:
```
typedef [uuid(b253697c-f239-4fb6-b474-b35db2c4848f), helpstring("The HTTP_BINDING_INFO structure is used to associate a URL Group with a request queue. This structure must be used when setting or querying the HttpServerBindingProperty on a URL Group.")]
struct tagHTTP_BINDING_INFO {
	[nonbrowsable, helpstring("Specifies whether the RequestQueueHandle property is present.")] HTTP_PROPERTY_FLAGS;
	[helpstring("The request queue that is associated with the URL group. The structure can be used to remove an existing binding by setting this parameter to NULL.")] HANDLE RequestQueueHandle;
} HTTP_BINDING_INFO;
```
'!

!WinHttpServer.HTTP_BINDING_INFO categoriesForClass!Win32-Structs! !

!WinHttpServer.HTTP_BINDING_INFO methodsFor!

requestQueueHandle
	^self Present ifTrue: [self RequestQueueHandle]!

RequestQueueHandle
	"Answer the <Handle> value of the receiver's 'RequestQueueHandle' field."

	^(bytes uintPtrAtOffset: _OffsetOf_RequestQueueHandle) asExternalHandle!

requestQueueHandle: anExternalHandle
	anExternalHandle
		ifNil: 
			[self
				Present: false;
				RequestQueueHandle: 0]
		ifNotNil: 
			[self
				Present: true;
				RequestQueueHandle: anExternalHandle]!

RequestQueueHandle: aHandle
	"Set the receiver's 'RequestQueueHandle' field to the value of the argument, aHandle"

	bytes uintPtrAtOffset: _OffsetOf_RequestQueueHandle put: aHandle! !

!WinHttpServer.HTTP_BINDING_INFO categoriesForMethods!
requestQueueHandle!accessing!public! !
RequestQueueHandle!**compiled accessors**!public! !
requestQueueHandle:!accessing!public! !
RequestQueueHandle:!**compiled accessors**!public! !
!

!WinHttpServer.HTTP_BINDING_INFO class methodsFor!

byteSize
	^_HTTP_BINDING_INFO_Size!

defineFields
	"Define the fields of the HTTP_BINDING_INFO structure.

	HTTP_BINDING_INFO compileDefinition

		typedef [uuid(b253697c-f239-4fb6-b474-b35db2c4848f), helpstring('The HTTP_BINDING_INFO structure is used to associate a URL Group with a request queue. This structure must be used when setting or querying the HttpServerBindingProperty on a URL Group.')]
		struct tagHTTP_BINDING_INFO {
			[nonbrowsable, helpstring('Specifies whether the RequestQueueHandle property is present.')] HTTP_PROPERTY_FLAGS;
			[helpstring('The request queue that is associated with the URL group. The structure can be used to remove an existing binding by setting this parameter to NULL.')] HANDLE RequestQueueHandle;
		} HTTP_BINDING_INFO;
"

	super defineFields.
	self
		defineField: #RequestQueueHandle type: HANDLEField new offset: 4.
	self byteSize: 8!

getFieldNames
	^#(#Present #RequestQueueHandle)!

propertyId
	^HttpServerBindingProperty! !

!WinHttpServer.HTTP_BINDING_INFO class categoriesForMethods!
byteSize!**compiled accessors**!constants!public! !
defineFields!**auto generated**!private!template definition! !
getFieldNames!**compiled accessors**!constants!private! !
propertyId!public! !
!

