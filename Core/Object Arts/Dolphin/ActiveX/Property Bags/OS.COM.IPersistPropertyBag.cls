﻿"Filed out from Dolphin Smalltalk"!

OS.COM.IPersist
	subclass: #'OS.COM.IPersistPropertyBag'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

OS.COM.IPersistPropertyBag guid: (OS.COM.IID fromString: '{37d84f60-42cb-11ce-8135-00aa004bb851}')!

OS.COM.IPersistPropertyBag comment: '`OS.COM.IPersistPropertyBag` is a wrapper class for the COM interface ''OCIDL.IPersistPropertyBag'' generated from type information in the ''OCIDL Library'' library. It contains methods to invoke the member functions exposed by that interface.

IPersistPropertyBag provides persistence storage onto an OLE property bag object (IPropertyBag). A property bag is a text based storage mechanism using name value pairs. See <IPropertyBag> for further details.'!

!OS.COM.IPersistPropertyBag categoriesForClass!COM-Interfaces! !

!OS.COM.IPersistPropertyBag methodsFor!

initNew  
	"Initialize a new object instance. Either this or Load() (not both) should be invoked against
	 a new object."

	self InitNew
!

InitNew
	"Private - Invoke the InitNew() method of the COM object wrapped by the receiver.

		HRESULT __stdcall InitNew();
	"

	<virtual stdcall: hresult 5>
	^self invalidCall: _failureCode!

Load: pPropBag pErrorLog: pErrorLog
	"Private - Invoke the Load() method of the COM object wrapped by the receiver.

		HRESULT __stdcall Load(
			[in] IPropertyBag* pPropBag,
			[in] IErrorLog* pErrorLog);
	"

	<virtual stdcall: int32 6 IPropertyBag* IErrorLog*>
	^self invalidCall: _failureCode!

save: pPropBag fClearDirty: fClearDirty fSaveAllProperties: fSaveAllProperties 
	"Save the object's properties into the <IPropertyBag>, pPropBag, optionally clearing
	the object's dirty flag depending on the value of the <boolean>, fClearDirty, and
	optionally saving all the object's properties depending on the value of the <boolean>,
	fSaveAllProperties."

	self
		Save: pPropBag
		fClearDirty: fClearDirty
		fSaveAllProperties: fSaveAllProperties
!

Save: pPropBag fClearDirty: fClearDirty fSaveAllProperties: fSaveAllProperties
	"Private - Invoke the Save() method of the COM object wrapped by the receiver.

		HRESULT __stdcall Save(
			[in] IPropertyBag* pPropBag,
			[in] BOOL fClearDirty,
			[in] BOOL fSaveAllProperties);
	"

	<virtual stdcall: hresult 7 IPropertyBag* bool bool>
	^self invalidCall: _failureCode! !

!OS.COM.IPersistPropertyBag categoriesForMethods!
initNew!methods!public! !
InitNew!**auto generated**!COM Interfaces-IPersistPropertyBag!private! !
Load:pErrorLog:!COM Interfaces-IPersistPropertyBag!private! !
save:fClearDirty:fSaveAllProperties:!methods!public! !
Save:fClearDirty:fSaveAllProperties:!COM Interfaces-IPersistPropertyBag!private! !
!

OS.COM.IPersistPropertyBag methodProtocol: #IPersistPropertyBag attributes: #(#readOnly) selectors: #(#InitNew #Load:pErrorLog: #Save:fClearDirty:fSaveAllProperties:)!

!OS.COM.IPersistPropertyBag class methodsFor!

defineFunctions
	"Declare the virtual function table for the COM interface 'OCIDL.IPersistPropertyBag'
		IPersistPropertyBag defineTemplate
	"

	self
		defineFunction: #InitNew;
		defineFunction: #Load:pErrorLog:
			returnType: 'int32'		"Really an HRESULT, but want to suppress auto-exceptions"
			argumentTypes: 'IPropertyBag* IErrorLog*';
		defineFunction: #Save:fClearDirty:fSaveAllProperties:
			argumentTypes: 'IPropertyBag* bool bool'
! !

!OS.COM.IPersistPropertyBag class categoriesForMethods!
defineFunctions!initializing!public! !
!

