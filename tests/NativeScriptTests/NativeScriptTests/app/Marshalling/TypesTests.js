describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("Types", function () {
        expect(interop.types.void).toBeDefined();
        expect(interop.types.void.toString()).toBe('[object void]');
        expect(function () {
            interop.sizeof(interop.types.void);
        }).toThrowError();

        expect(interop.types.bool).toBeDefined();
        expect(interop.types.bool.toString()).toBe('[object bool]');
        expect(interop.sizeof(interop.types.bool)).toBe(1);

        expect(interop.types.UTF8CString).toBeDefined();
        expect(interop.types.UTF8CString.toString()).toBe('[object UTF8CString]');
        expect(interop.sizeof(interop.types.UTF8CString)).toBe(interop.sizeof(interop.Pointer));

        expect(interop.types.unichar).toBeDefined();
        expect(interop.types.unichar.toString()).toBe('[object unichar]');
        expect(interop.sizeof(interop.types.unichar)).toBe(2);

        expect(interop.types.int8).toBeDefined();
        expect(interop.types.int8.toString()).toBe('[object int8]');
        expect(interop.sizeof(interop.types.int8)).toBe(1);

        expect(interop.types.uint8).toBeDefined();
        expect(interop.types.uint8.toString()).toBe('[object uint8]');
        expect(interop.sizeof(interop.types.uint8)).toBe(1);

        expect(interop.types.int16).toBeDefined();
        expect(interop.types.int16.toString()).toBe('[object int16]');
        expect(interop.sizeof(interop.types.int16)).toBe(2);

        expect(interop.types.uint16).toBeDefined();
        expect(interop.types.uint16.toString()).toBe('[object uint16]');
        expect(interop.sizeof(interop.types.uint16)).toBe(2);

        expect(interop.types.int32).toBeDefined();
        expect(interop.types.int32.toString()).toBe('[object int32]');
        expect(interop.sizeof(interop.types.int32)).toBe(4);

        expect(interop.types.uint32).toBeDefined();
        expect(interop.types.uint32.toString()).toBe('[object uint32]');
        expect(interop.sizeof(interop.types.uint32)).toBe(4);

        expect(interop.types.int64).toBeDefined();
        expect(interop.types.int64.toString()).toBe('[object int64]');
        expect(interop.sizeof(interop.types.int64)).toBe(8);

        expect(interop.types.uint64).toBeDefined();
        expect(interop.types.uint64.toString()).toBe('[object uint64]');
        expect(interop.sizeof(interop.types.uint64)).toBe(8);

        expect(interop.types.float).toBeDefined();
        expect(interop.types.float.toString()).toBe('[object float]');
        expect(interop.sizeof(interop.types.float)).toBe(4);

        expect(interop.types.double).toBeDefined();
        expect(interop.types.double.toString()).toBe('[object double]');
        expect(interop.sizeof(interop.types.double)).toBe(8);

        expect(interop.types.id).toBeDefined();
        expect(interop.types.id.toString()).toBe(NSObject.toString());
        expect(interop.sizeof(interop.types.id)).toBe(interop.sizeof(interop.Pointer));

        expect(interop.types.protocol).toBeDefined();
        expect(interop.types.protocol.toString()).toBe('[object protocol]');
        expect(interop.sizeof(interop.types.protocol)).toBe(interop.sizeof(interop.Pointer));

        expect(interop.types.class).toBeDefined();
        expect(interop.types.class.toString()).toBe('[object class]');
        expect(interop.sizeof(interop.types.class)).toBe(interop.sizeof(interop.Pointer));

        expect(interop.types.selector).toBeDefined();
        expect(interop.types.selector.toString()).toBe('[object selector]');
        expect(interop.sizeof(interop.types.selector)).toBe(interop.sizeof(interop.Pointer));
    });

    function pointerTo(type, value) {
        var outerPtr = interop.alloc(interop.sizeof(interop.Pointer));
        var outerRef = new interop.Reference(type, outerPtr);
        outerRef.value = value;
        return outerPtr;
    }

    it("ReferenceType", function () {
        var ptr = interop.alloc(3 * interop.sizeof(interop.types.int32));
        var ref = new interop.Reference(new interop.types.ReferenceType(interop.types.int32), ptr);
        ref[0] = interop.alloc(2 * interop.sizeof(interop.types.int32));
        ref[1] = interop.alloc(2 * interop.sizeof(interop.types.int32));

        ref[0][0] = 0;
        ref[0][1] = 1;
        ref[1][0] = 2;
        ref[1][1] = 3;
        expect(ref[0][0]).toBe(0);
        expect(ref[0][1]).toBe(1);
        expect(ref[1][0]).toBe(2);
        expect(ref[1][1]).toBe(3);
    });

    it("ReferenceTypeUniqueness", function () {
        expect(interop.types.ReferenceType(interop.types.int32) === interop.types.ReferenceType(interop.types.int32)).toBe(true);
    });

    it("ReferenceTypeReadingFromPointer", function () {
        var number = 4224;
        var intPtr = pointerTo(interop.types.int32, number);
        var intPtrPtr = pointerTo(interop.Pointer, intPtr);
        var refType = interop.types.ReferenceType(interop.types.int32);
        var result = refType(intPtrPtr);
        expect(result[0]).toBe(number);
    });

    it("NestedReferenceTypeUniqueness", function () {
        var type1 = interop.types.ReferenceType(interop.types.ReferenceType(interop.types.ReferenceType(interop.types.int32)));
        var type2 = interop.types.ReferenceType(interop.types.ReferenceType(interop.types.ReferenceType(interop.types.int32)));
        expect(type1 === type2).toBe(true);
    });

    it("FunctionReferenceTypeReadingFromPointer", function () {
        var funcPtr = functionReturningFunctionPtrAsVoidPtr();
        var funcType = new interop.types.FunctionReferenceType(interop.types.int64, interop.types.int64);
        var func = funcType(pointerTo(interop.Pointer, funcPtr));
        var x = func(90);
        expect(x).toBe(8100);
    });

    it("FunctionReferenceTypeUniqueness", function () {
        expect(interop.types.FunctionReferenceType(interop.types.int32, interop.types.int64) === interop.types.FunctionReferenceType(interop.types.int32, interop.types.int64)).toBe(true);
    });

    it("NestedFunctionReferenceTypeUniqueness", function () {
        var type1 = interop.types.FunctionReferenceType(interop.types.FunctionReferenceType(interop.types.ReferenceType(interop.types.int32)), interop.types.int32);
        var type2 = interop.types.FunctionReferenceType(interop.types.FunctionReferenceType(interop.types.ReferenceType(interop.types.int32)), interop.types.int32);
        expect(type1 === type2).toBe(true);
    });

    it("BlockType", function () {
        var id = TNSObjCTypes.alloc().init().methodReturningBlockAsId(10);
        var blockType = new interop.types.BlockType(interop.types.int32, interop.types.int32, interop.types.int32, interop.types.int32);
        var block = blockType(pointerTo(interop.Pointer, id));
        var x = block(20, 30, 40);
        expect(x).toBe(100);
    });

    it("BlockTypeUniqueness", function () {
        expect(interop.types.BlockType(interop.types.int32, interop.types.int64) === interop.types.BlockType(interop.types.int32, interop.types.int64)).toBe(true);
    });

    it("NestedBlockTypeUniqueness", function () {
        var type1 = interop.types.BlockType(interop.types.BlockType(interop.types.ReferenceType(interop.types.int32)), interop.types.int32);
        var type2 = interop.types.BlockType(interop.types.BlockType(interop.types.ReferenceType(interop.types.int32)), interop.types.int32);
        expect(type1 === type2).toBe(true);
    });

    it("BoolTypeReadingFromPointer", function () {
        var flag = true;
        var boolPtr = pointerTo(interop.types.bool, flag);
        var result = interop.types.bool(boolPtr);
        expect(result === flag).toBe(true);
    });

    it("FloatTypeReadingFromPointer", function () {
        var number = 3.14;
        var doublePtr = pointerTo(interop.types.double, number);
        var result = interop.types.double(doublePtr);
        expect(result === number).toBe(true);
    });
});
