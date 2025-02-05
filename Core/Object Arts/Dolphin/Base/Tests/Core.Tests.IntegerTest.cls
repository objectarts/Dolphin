﻿"Filed out from Dolphin Smalltalk"!

Core.Tests.DolphinTest
	subclass: #'Core.Tests.IntegerTest'
	instanceVariableNames: ''
	classVariableNames: ''
	imports: #()
	classInstanceVariableNames: ''
	classConstants: {}!

Core.Tests.IntegerTest guid: (Core.GUID fromString: '{025b6e24-5e2b-49b1-9f4b-55b831a5aef3}')!

Core.Tests.IntegerTest isNonInstantiable: true!

Core.Tests.IntegerTest comment: ''!

!Core.Tests.IntegerTest methodsFor!

canonicalInstance
	^self subclassResponsibility!

testClassReadFromRadix
	| stream |
	0 to: 35
		do: 
			[:i |
			self assert: (Integer readFrom: (Character digitValue: i) asString readStream radix: 36) equals: i].
	2 to: 36 do: [:i | self assert: (Integer readFrom: '10' readStream radix: i) equals: i].
	"Not an error if digit out of range of radix, just terminates the integer"
	stream := '20' readStream.
	self assert: (Integer readFrom: stream radix: 2) equals: 0.
	self assert: stream position equals: 0.
	stream := '12' readStream.
	self assert: (Integer readFrom: stream radix: 2) equals: 1.
	self assert: stream position equals: 1!

testFactorial
	#(0 1 2 3 4 5 6 7 8 9 10 11 97 100 101 1000 1001) do: 
			[:each |
			| factorial |
			factorial := 1.
			2 to: each do: [:i | factorial := i * factorial].
			self assert: factorial equals: each factorial2p].
	self should: [-1 factorial] raise: Error!

testIndexedAccess
	"WARNING THIS TEST HANGS THE IMAGE when run for SmallInteger"

	| int matchBlock |
	int := self canonicalInstance.
	matchBlock := [:ex | (ex messageText findString: 'should not implement') ~= 0].
	self
		should: [int at: 1 put: 0]
		raise: Error
		matching: matchBlock.
	self
		should: [int size]
		raise: Error
		matching: matchBlock.
	self
		should: [int at: 1]
		raise: Error
		matching: matchBlock!

testIsInteger
	self assert: self canonicalInstance isInteger!

testIsPowerOfTwo
	| powersOfTwo nonPowersOfTwo |
	powersOfTwo := (0 to: 100) collect: [:each | 2 raisedTo: each].
	nonPowersOfTwo := (powersOfTwo collect: [:each | each negated])
				, #(0 3 -3 5 -5 6 -6 7 -7 9 -9 10 -10 100 -100 1000 -1000 12345678 -12345678 1234567890 -1234567890 12345678901234567890 -12345678901234567890).
	powersOfTwo do: [:each | self assert: each isPowerOfTwo].
	nonPowersOfTwo do: [:each | self deny: each isPowerOfTwo]!

testNew
	self should: [self canonicalInstance class new] raise: TestResult error!

testPrimesUpTo
	| primes |
	primes := Integer primesUpTo: 100.
	self assert: primes asArray
		equals: #(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97)!

testRoundUpToPowerOfTwo
	self assert: 0 roundUpToPowerOfTwo equals: 1.
	self assert: 1 roundUpToPowerOfTwo equals: 1.
	self assert: 2 roundUpToPowerOfTwo equals: 2.
	self assert: 3 roundUpToPowerOfTwo equals: 4.
	self assert: 4 roundUpToPowerOfTwo equals: 4.
	self assert: 1023 roundUpToPowerOfTwo equals: 1024.
	self assert: 1025 roundUpToPowerOfTwo equals: 2048.
	self assert: 16r3FFFFFFF roundUpToPowerOfTwo equals: 16r40000000.
	self should: [-1 roundUpToPowerOfTwo] raise: Error!

testSetBit
	1 to: 128 do: [:i | self assert: (0 setBit: i) equals: (2 raisedToInteger: i - 1)].
	0 to: 128
		do: 
			[:twoPower |
			| i |
			i := 2 raisedToInteger: twoPower.
			1 to: 128
				do: 
					[:j |
					| expected |
					expected := 2 raisedToInteger: j - 1.
					j - 1 = twoPower ifFalse: [expected := expected + i].
					self assert: (i setBit: j) equals: expected]]!

testTwoComplementRightShift
	| large small |
	small := 2 << 16.
	large := 2 << 32.
	self should: 
			[(small negated bitShift: -1) ~= ((small + 1) negated bitShift: -1) 
				== ((large negated bitShift: -1) ~= ((large + 1) negated bitShift: -1))].
	self should: 
			[(small bitShift: -1) ~= (small + 1 bitShift: -1) 
				== ((large bitShift: -1) ~= (large + 1 bitShift: -1))]! !

!Core.Tests.IntegerTest categoriesForMethods!
canonicalInstance!constants!private! !
testClassReadFromRadix!public!unit tests! !
testFactorial!public!unit tests! !
testIndexedAccess!public!unit tests! !
testIsInteger!public!unit tests! !
testIsPowerOfTwo!public!unit tests! !
testNew!public!unit tests! !
testPrimesUpTo!public!unit tests! !
testRoundUpToPowerOfTwo!public!unit tests! !
testSetBit!public!unit tests! !
testTwoComplementRightShift!public!unit tests! !
!

