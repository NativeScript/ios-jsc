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
        expect(NSString(TNSFunctionWithSimpleCFTypeRefReturn()).toString()).toBe('test');
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

    it("MethodWithNSArray", function () {
        var array = [1, 2, 'a', NSObject];
        var result = TNSObjCTypes.alloc().init().methodWithNSArray(array);
        expect(TNSGetOutput()).toBe(
            '1' +
            '2' +
            'a' +
            'NSObject');
        TNSClearOutput();

        expect(array[0]).toBe(result[0]);
        expect(array[1]).toBe(result[1]);
        expect(array[2]).toBe(result[2]);
        expect(result.class()).toBe(NSArray);

        array[0] = 3;
        array[1] = 4;
        array[2] = 5;
        TNSObjCTypes.alloc().init().methodWithNSArray(array);
        expect(TNSGetOutput()).toBe(
            '3' +
            '4' +
            '5' +
            'NSObject');
        TNSClearOutput();
    });

    it("MethodWithNSData", function () {
        var data = new Uint8Array([49, 50, 51, 52]);
        var expected = '1234';

        TNSObjCTypes.alloc().init().methodWithNSData(data);
        expect(TNSGetOutput()).toBe(expected);
        TNSClearOutput();

        TNSObjCTypes.alloc().init().methodWithNSData(data.buffer);
        expect(TNSGetOutput()).toBe(expected);
        TNSClearOutput();
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
});
