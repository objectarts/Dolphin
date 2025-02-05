﻿"Filed out from Dolphin Smalltalk"!

Database.DBSchemaStatement
	subclass: #'Database.DBSpecialColumnsStatement'
	instanceVariableNames: 'columnType scope nullable'
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Database.DBSpecialColumnsStatement guid: (Core.GUID fromString: '{11e39b07-10d8-43b0-8a5c-43c2eecf5eb9}')!

Database.DBSpecialColumnsStatement comment: ''!

!Database.DBSpecialColumnsStatement categoriesForClass!ODBC Interface! !

!Database.DBSpecialColumnsStatement methodsFor!

columnType
	^columnType!

columnType: anInteger
	columnType := anInteger!

executeStatement
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^self dbCheckException: (OS.Odbc32
				sqlSpecialColumns: self allocatedHandle
				identifierType: self columnType
				catalogName: self catalogName
				nameLength1: SQL_NTS
				schemaName: self schemaName
				nameLength2: SQL_NTS
				tableName: self tableName
				nameLength3: SQL_NTS
				scope: self scope
				nullable: (self nullable ifTrue: [SQL_NULLABLE] ifFalse: [SQL_NO_NULLS]))
		function: 'SQLSpecialColumns'!

nullable
	^nullable!

nullable: aBoolean
	nullable := aBoolean!

scope
	^scope!

scope: anInteger
	scope := anInteger! !

!Database.DBSpecialColumnsStatement categoriesForMethods!
columnType!accessing!public! !
columnType:!accessing!public! !
executeStatement!operations!private! !
nullable!accessing!public! !
nullable:!accessing!public! !
scope!accessing!public! !
scope:!accessing!public! !
!

