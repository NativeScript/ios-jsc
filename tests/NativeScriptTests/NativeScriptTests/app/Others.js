//
//
//// NSString toString method call
//it('NSStringToString1', function() {
//     var myNsString = NSString.alloc().initWithString('just string ');
//     var myJsFromNsString = myNsString.toString();
//     assert(typeof(myNsString) === 'object');
//     assert(typeof(myJsFromNsString) === 'string');
//});
//
//it('NSStringToString2', function() {
//     var myNsString = NSString.alloc().initWithString('just string ');
//     var myJsFromNsString = myNsString + 'concatenated';
//     assert(typeof(myJsFromNsString) === 'string');
//     TNSTLog(myJsFromNsString);
//
//    var actual = TNSGetOutput();
//    var expected = "just string concatenated"
//    expect(actual).toBe(expected);
//});
//
//it('OverridenVariadicCall', function() {
//    var actual;
//    var expected = "derived instance baseVariadicMethod: called"
//
//     TNSDerivedInterface.baseVariadicMethodWithArguments(undefined, []);
//
//    actual = TNSGetOutput();
//    expect(actual).toBe(expected);
//    TNSClearOutput();
//});
//
//it('InstanceMethodApply', function() {
//     var i = new NSMutableDictionary();
//     var f = i.setObjectForKey;
//     f.apply(i, ['X', 'X']);
//     TNSTLog(\"i['X']: \" + i.objectForKey(\"X\"));"]
//    var actual = TNSGetOutput();
//    var expected = "i['X']: X"
//    expect(actual).toBe(expected);
//});
//
//it('InstanceMethodCall', function() {
//     var i = new NSMutableDictionary();
//     var f = i.setObjectForKey;
//     f.call(i, 'X', 'X');
//     TNSTLog(\"i['X']: \" + i.objectForKey(\"X\"));"]
//    var actual = TNSGetOutput();
//    var expected = "i['X']: X"
//    expect(actual).toBe(expected);
//});
//
//it('InstanceMethodBind', function() {
//     var i = new NSMutableDictionary();
//     var f = i.setObjectForKey;
//     var b = f.bind(i);
//     b('X', 'X');
//     TNSTLog(\"i['X']: \" + i.objectForKey(\"X\"));"]
//    var actual = TNSGetOutput();
//    var expected = "i['X']: X"
//    expect(actual).toBe(expected);
//});
//
//it('PrototypeFunctionApply', function() {
//     var i = new NSMutableDictionary();
//     var f = NSMutableDictionary.prototype.setObjectForKey;
//     f.apply(i, ['X', 'X']);
//     TNSTLog(\"i['X']: \" + i.objectForKey(\"X\"));"]
//    var actual = TNSGetOutput();
//    var expected = "i['X']: X"
//    expect(actual).toBe(expected);
//});
//
//it('PrototypeFunctionCall', function() {
//     var i = new NSMutableDictionary();
//     var f = NSMutableDictionary.prototype.setObjectForKey;
//     f.call(i, 'X', 'X');
//     TNSTLog(\"i['X']: \" + i.objectForKey(\"X\"));"]
//    var actual = TNSGetOutput();
//    var expected = "i['X']: X"
//    expect(actual).toBe(expected);
//});
//
//it('PrototypeFunctionBind', function() {
//     var i = new NSMutableDictionary();
//     var f = NSMutableDictionary.prototype.setObjectForKey;
//     var b = f.bind(i);
//     b('X', 'X');
//     TNSTLog(\"i['X']: \" + i.objectForKey(\"X\"));"]
//    var actual = TNSGetOutput();
//    var expected = "i['X']: X"
//    expect(actual).toBe(expected);
//});





// - (void)testStructWithPointers {
//     [self evaluateScript:
//      @"var struct = TNSStructWithPointers.create();"

//      @"var a = NativePointer.create(function() { TNSTLog('a called'); });"
//      @"struct.a = a;"

//      @"var bufferX = NativePointer.create(PrimitiveType.INT, 1);"
//      @"bufferX[0] = 3;"
//      @"struct.x = bufferX;"

//      @"var bufferY = NativePointer.create(TNSSimpleStruct, 1);"
//      @"bufferY[0] = TNSSimpleStruct.create();"
//      @"bufferY[0].x = 4;"
//      @"bufferY[0].y = 5;"
//      @"struct.y = bufferY;"

//      @"var bufferZ = NativePointer.create(TNSStructWithPointers, 1);"
//      @"bufferZ[0] = TNSStructWithPointers.create();"

//      @"bufferZ[0].z = NativePointer.create(TNSStructWithPointers, 1);"
//      @"bufferZ[0].z[0] = TNSStructWithPointers.create();"

//      @"struct.z = bufferZ;"

//      @"assert(struct.x[0] === 3);"
//      @"assert(struct.y[0].x === 4); assert(struct.y[0].y === 5);"
//      @"assert(struct.z[0].z[0].z === null);"
//      ];


// DISABLED_TEST
//-(void)testVariadicNSLog {
//    [self evaluateScript:
//     @"NSLog('String: %@, Int: %d Double: %f Long: %d, Double: %f ULong: %d, String: %@', ["
//     @"{type: PrimitiveType.POINTER, value: 'First Name' },"
//     @"{type: PrimitiveType.INT, value: 17 },"
//     @"{type: PrimitiveType.DOUBLE, value: 3.4 },"
//     @"{type: PrimitiveType.INT, value: 1234567890 },"
//     @"{type: PrimitiveType.DOUBLE, value: 5.6 },"
//     @"{type: PrimitiveType.UNSIGNED_INT, value: 100 },"
//     @"{type: PrimitiveType.POINTER, value: 'Last Name' }"
//     @"]);"];
//    XCTAssertNil(TNSContext.exception, @"");
//}

-(void) testFunctionVariadicSum {
    [self evaluateScript:@"var sum = functionVariadicSum(3, [{type: PrimitiveType.INT, value: 2}, {type: PrimitiveType.INT, value: 3}, {type: PrimitiveType.INT, value: 4}]);"
     @"assert(sum === 9);"];
    int sum = [[self marshallJSValueToId:@"sum"] intValue];;
    XCTAssertEqual(sum, 9, @"");
}

// DISABLED_TEST
//-(void) testFunctionVariadicSumWithInvalidArguments {
//    [self evaluateScript:@"try {var sum = functionVariadicSum(3, [{type: PrimitiveType.FLOAT, value: 2}, {type: PrimitiveType.INT, value: 3}, {type: PrimitiveType.INT, value: 4}]); }"
//     @"catch(e) { TNSTLog(e.name); }"];
//    NSString *expected = TNSNativeError;
//    NSString *actual = TNSGetOutput();
//    XCTAssertEqualObjects(expected, actual, @"");
//}

-(void) testFunctionVariadicSumWithStructs {
    [self evaluateScript:
     @"var a = TNSSimpleStruct.create(); a.x = 1; a.y = 2;"
     @"var b = TNSSimpleStruct.create(); b.x = 3; b.y = 4;"
     @"var c = TNSSimpleStruct.create(); c.x = 5; c.y = 6;"
     @"var TNSSimpleStructType = [PrimitiveType.INT, PrimitiveType.INT];"
     @"var sum = functionVariadicSumWithStructs(3, [{type: TNSSimpleStructType, value: a}, {type: TNSSimpleStructType, value: b}, {type: TNSSimpleStructType, value: c}]);"
     @"assert(sum === 21);"];
    int sum = [[self marshallJSValueToId:@"sum"] intValue];
    XCTAssertEqual(sum, 21, @"");
}

-(void) testFunctionVariadicWithNestedStruct {
    [self evaluateScript:
     @"var a = TNSNestedAnonymousStruct.create(); a.x1 = 1; a.y1.x2 = 2; a.y1.y2.x3 = 3;"
     @"var b = TNSNestedAnonymousStruct.create(); b.x1 = 4; b.y1.x2 = 5; b.y1.y2.x3 = 6;"
     @"var TNSNestedAnonymousStructType = [PrimitiveType.INT, [PrimitiveType.INT, [PrimitiveType.INT]]];"
     @"var sum = functionVariadicSumWithNestedStructs(2, [{type: TNSNestedAnonymousStructType, value: a}, {type: TNSNestedAnonymousStructType, value: b}]);"
     @"assert(sum === 21);"];
    int sum = [[self marshallJSValueToId:@"sum"] intValue];
    XCTAssertEqual(sum, 21, @"");
}

-(void) testFunctionVariadicWithFixedStruct {
    [self evaluateScript:
     @"var fixed = TNSNestedAnonymousStruct.create(); fixed.x1 = 1; fixed.y1.x2 = 2; fixed.y1.y2.x3 = 3;"
     @"var a = TNSNestedAnonymousStruct.create(); a.x1 = 1; a.y1.x2 = 2; a.y1.y2.x3 = 3;"
     @"var b = TNSNestedAnonymousStruct.create(); b.x1 = 4; b.y1.x2 = 5; b.y1.y2.x3 = 6;"
     @"var TNSNestedAnonymousStructType = [PrimitiveType.INT, [PrimitiveType.INT, [PrimitiveType.INT]]];"
     @"var sum = functionVariadicSumWithFixedStruct(fixed, 2, [{type: TNSNestedAnonymousStructType, value: a}, {type: TNSNestedAnonymousStructType, value: b}]);"
     @"assert(sum === 27);"];
    int sum = [[self marshallJSValueToId:@"sum"] intValue];
    XCTAssertEqual(sum, 27, @"");
}

-(void) testFunctionVariadicWithTNSPowerfulStruct {
    [self evaluateScript:
     @"var a = TNSPowerfulStruct.create(); a.intNum = 1; a.floatNum = 2.2; a.doubleNum = 3.3; a.charNum = 4; a.shortNum = 5; a.longNum = 6; a.charPointer = 0;"
     @"var b = TNSPowerfulStruct.create(); b.intNum = 1; b.floatNum = 2.2; b.doubleNum = 3.3; b.charNum = 4; b.shortNum = 5; b.longNum = 6; b.charPointer = 0;"
     @"var TNSPowerfulStructType = [PrimitiveType.INT, PrimitiveType.FLOAT, PrimitiveType.DOUBLE, PrimitiveType.CHAR, PrimitiveType.SHORT, PrimitiveType.LONG, PrimitiveType.POINTER];"
     @"var sum = functionVariadicSumWithPowerfulStructs(2, "
        @"[{type: TNSPowerfulStructType, value: a},"
        @" {type: TNSPowerfulStructType, value: b}]);"
     @"assert(sum === 43.00000009536743);"];
    int sum = [[self marshallJSValueToId:@"sum"] intValue];
    XCTAssertEqual(sum, 43, @"");
}

-(void) testFunctionWithBlockArgument {
    [self evaluateScript:
     @"var sumator = function(a, b, c){ return (a + b + c); };"
     @"var sumDoubled = functionWithBlockArgument(sumator)"];
    int sum = [[self marshallJSValueToId:@"sumDoubled"] intValue];
    XCTAssertEqual(sum, 12, @"");
}

-(void) testFunctionWithBlockReturn {
    [self evaluateScript:
     @"var sumator = functionWithBlockReturn();"
     @"var sum = sumator(1, 2, 3);"];
    int sum = [[self marshallJSValueToId:@"sum"] intValue];
    XCTAssertEqual(sum, 6, @"");
}

-(void) testVariadicStringFormat {
    [self evaluateScript:
     @"var text = functionVariadicStringFormat('Int: %d, Double: %f, String: %@, Int: %d', [{type: PrimitiveType.INT, value: 2}, {type: PrimitiveType.DOUBLE, value: 3.3}, {type: PrimitiveType.POINTER, value: 'string'}, {type: PrimitiveType.INT, value: 123456789}]);"
     @"TNSTLog(text);"];

    NSString *expected = [NSString stringWithFormat:@"Int: %d, Double: %f, String: %@, Int: %d", 2, 3.3, @"string", 123456789];
    NSString *actual = TNSGetOutput();
    XCTAssertEqualObjects(actual, expected, @"");
}

- (void)testFunctionWithBlockScope {
    [self evaluateScript:
     @"var sumator = functionWithBlockScope(10);"
     @"var sum = sumator(1, 2, 3);"
     @"assert(sum === 16);"
     ];

    int sum = [[self marshallJSValueToId:@"sum"] intValue];
    XCTAssertEqual(sum, 16, @"");
}
