describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("FunctionWithCFTypeRefArgument", function () {
        TNSFunctionWithCFTypeRefArgument(NSString.stringWithString('test'));

        var actual = TNSGetOutput();
        expect(actual).toBe("test");
    });

    it("FunctionWithSimpleCFTypeRefReturn", function () {
        expect(TNSFunctionWithSimpleCFTypeRefReturn()).toBe('test');
    });

    it("OutParameter", function () {
        var refValue = new interop.Reference();
        expect(refValue instanceof interop.Reference).toBe(true);
        TNSObjCTypes.alloc().init().methodWithIdOutParameter(refValue);
        expect(refValue.value).toBe('test');
        expect(TNSGetOutput()).toBe('(null)');
    });

    it("OutParameterWithValue", function () {
        var refValue = new interop.Reference('in');
        TNSObjCTypes.alloc().init().methodWithIdOutParameter(refValue);
        expect(refValue.value).toBe('test');
        expect(TNSGetOutput()).toBe('in');
    });

    it("OutParameterWithValueAndType", function () {
        var refValue = new interop.Reference(interop.types.id, 'in');
        TNSObjCTypes.alloc().init().methodWithIdOutParameter(refValue);
        expect(refValue.value).toBe('test');
        expect(TNSGetOutput()).toBe('in');
    });

    it("OutParameterLongLong", function () {
        var refValue = new interop.Reference(3);
        TNSObjCTypes.alloc().init().methodWithLongLongOutParameter(refValue);
        expect(refValue.value).toBe(1);
        expect(TNSGetOutput()).toBe('3');
    });

    it("OutParameterStruct", function () {
        var refValue = new interop.Reference({x: 1, y: 2, z: 3});
        TNSObjCTypes.alloc().init().methodWithStructOutParameter(refValue);
        expect(refValue.value.x).toBe(4);
        expect(refValue.value.y).toBe(5);
        expect(refValue.value.z).toBe(6);
        expect(TNSGetOutput()).toBe('1 2 3');
    });

    it("NilBlock", function () {
        expect(TNSObjCTypes.alloc().init().methodWithBlock(null)).toBe(null);
    });

    it("SimpleBlock", function () {
        TNSObjCTypes.alloc().init().methodWithSimpleBlock(function () {
            TNSLog('simple block called');
        });

        var actual = TNSGetOutput();
        expect(actual).toBe("simple block called");
    });

    it("InstanceComplexBlock", function () {
        function block(i, id, sel, obj, str) {
            expect(i).toBe(1);
            expect(id).toBe(2);
            expect(sel).toBe('init');
            expect(obj.description).toBeTruthy();
            expect(str.x).toBe(5);
            expect(str.y).toBe(6);
            expect(str.z).toBe(7);
            TNSLog('complex block called');
            return new TNSObjCTypes();
        }

        TNSObjCTypes.alloc().init().methodWithComplexBlock(block);

        var actual = TNSGetOutput();
        expect(actual).toBe("complex block called\nTNSObjCTypes");
    });

    it("StaticComplexBlock", function () {
        function block(i, id, sel, obj, str) {
            expect(i).toBe(1);
            expect(id).toBe(2);
            expect(sel).toBe('init');
            expect(obj.description).toBeTruthy();
            expect(str.x).toBe(5);
            expect(str.y).toBe(6);
            expect(str.z).toBe(7);
            TNSLog('complex block called');
            return new TNSObjCTypes();
        }

        TNSObjCTypes.methodWithComplexBlock(block);

        var actual = TNSGetOutput();
        expect(actual).toBe("complex block called\nTNSObjCTypes");
    });

    it("MethodWithBlockReturn", function () {
        var block = TNSObjCTypes.alloc().init().methodWithBlockScope(4);
        expect(block.length).toBe(3);
        expect(block(1, 2, 3)).toBe(10);
    });

    it("MethodWithNSDate", function () {
        expect(TNSObjCTypes.alloc().init().methodWithNSDate(new Date(1e12))).toEqual(new Date(1e12));
        expect(TNSGetOutput()).toBe('2001-09-09 01:46:40 +0000');
    });

    it('javascript functions round trip through the native as blocks preserving equality', function() {
        function f() {
            TNSLog('called');
        }

        var returnBlock = TNSObjCTypes.alloc().init().methodWithBlock(f);

        expect(returnBlock).toBe(f);
        expect(TNSGetOutput()).toBe('called');
    });

    it("should be possible to marshal a JavaScript Array exotic to NSArray", function () {
        var array = [1, [2, 'a'], NSObject];
        var result = TNSObjCTypes.alloc().init().methodWithNSArray(array);
        expect(TNSGetOutput()).toBe(
            '1(\n' +
            '    2,\n' +
            '    a\n' +
            ')NSObject');
        TNSClearOutput();

        expect(array[0]).toBe(result[0]);
        expect(array[1]).toBe(result[1]);
        expect(array[2]).toBe(result[2]);
        expect(result).toBe(array);

        array[0] = 3;
        array[1] = 4;
        TNSObjCTypes.alloc().init().methodWithNSArray(array);
        expect(TNSGetOutput()).toBe(
            '3' +
            '4' +
            'NSObject');
        TNSClearOutput();
    });

    it("should be possible to marshal an array-like object to NSArray", function () {
        var expected = "";
        var arrayLike = { length: 256 };
        for (var i = 0; i < arrayLike.length; i++) {
            arrayLike[i] = i;
            expected += String(i);
        }

        TNSObjCTypes.alloc().init().methodWithNSArray(arrayLike);

        expect(TNSGetOutput()).toBe(expected);
        TNSClearOutput();
    });

    it("MethodWithNSDictionaryObject", function () {
        var dictionary = { a: 3, b: { "-1": [4, 5] }, d: 6 };
        var result = TNSObjCTypes.alloc().init().methodWithNSDictionary(dictionary);
        expect(TNSGetOutput()).toBe("a 3b {\n    \"-1\" =     (\n        4,\n        5\n    );\n}d 6");
        expect(result).toBe(dictionary);
    });

    it("MethodWithNSDictionaryMap", function () {
        var map = new Map();
        map.set("a", 3);
        var innerMap = new Map();
        innerMap.set("-1", [4, 5]);
        map.set("b", innerMap);
        map.set("d", 6);
        var result = TNSObjCTypes.alloc().init().methodWithNSDictionary(map);
        expect(TNSGetOutput()).toBe("a 3b {\n    \"-1\" =     (\n        4,\n        5\n    );\n}d 6");
        expect(result).toBe(map);
    });

    it("should be possible to wrap an ArrayBuffer in NSData", function () {
        var data = new Uint8Array([49, 50, 51, 52]);
        var buffer = data.buffer;
        var expected = '1234';

        var wrappedArrayBufferViewData = TNSObjCTypes.alloc().init().methodWithNSData(data);
        expect(TNSGetOutput()).toBe(expected);
        expect(wrappedArrayBufferViewData).toBe(data);
        TNSClearOutput();

        var wrappedArrayBufferData = TNSObjCTypes.alloc().init().methodWithNSData(buffer);
        expect(TNSGetOutput()).toBe(expected);
        expect(wrappedArrayBufferData).toBe(buffer);
        TNSClearOutput();
    });

    it("should be possible to wrap NSData in an ArrayBuffer", function () {
        var data = NSString.stringWithString("test").dataUsingEncoding(NSUTF8StringEncoding);

        var buffer = interop.bufferFromData(data);

        expect(buffer).toEqual(jasmine.any(ArrayBuffer));
        expect(interop.handleof(buffer)).toBe(data.bytes);
    })

    it("MethodWithNSDecimalNumber", function () {
        expect(NSDecimalNumber.maximumDecimalNumber instanceof NSDecimalNumber).toBe(true);

        var returned = TNSObjCTypes.alloc().init().methodWithNSDecimalNumber(NSDecimalNumber.maximumDecimalNumber);
        expect(returned.isEqualToNumber(NSDecimalNumber.maximumDecimalNumber)).toBe(true);
        expect(TNSGetOutput()).toBe('3402823669209384634633746074317682114550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000');
    });

    it("MethodWithNSCFBool", function () {
        expect(TNSObjCTypes.alloc().init().methodWithNSCFBool()).toBe(true);
    });

    it("MethodWithNSNull", function () {
        expect(TNSObjCTypes.alloc().init().methodWithNSNull()).toBe(null);
    });

    it("NSNull", function () {
        expect(NSNull.null() instanceof NSObject).toBe(true);
    });

    it("Initialize a class(NSTimer) whose init deallocates the result from alloc", function () {
       var actionCalled = false;

       var JSObject = NSObject.extend({
           action: function () {
               actionCalled = true;
           }
       }, {
           exposedMethods: {
               action: { returns: interop.types.void }
           }
       });

       var timer = NSTimer.alloc().initWithFireDateIntervalTargetSelectorUserInfoRepeats(new Date(), 0, new JSObject(), "action", null, true);
       timer.fire();
       expect(actionCalled).toBe(true);
    });
    
    it("String boxed", function () {
        var string = "hello";
        var boxedString = new String(string);
        
        var array = NSArray.arrayWithObject(boxedString);
        
        expect(typeof array.firstObject).toEqual("string");
        expect(array.firstObject).toEqual(string);
    });
    
    it("Number boxed", function () {
        var number = 42;
        var boxedNumber = new Number(number);
        
        var array = NSArray.arrayWithObject(boxedNumber);
        
        expect(typeof array.firstObject).toEqual("number");
        expect(array.firstObject).toEqual(number);
    });
    
    it("Boolean boxed", function () {
        var bool = true;
        var boxedBool = new Boolean(bool);
        
        var array = NSArray.arrayWithObject(boxedBool);
        
        expect(typeof array.firstObject).toEqual("boolean");
        expect(array.firstObject).toEqual(bool);
    });
});
