describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("SimplePointer", function () {
        var pointer = new interop.Pointer(1);
        expect(pointer instanceof interop.Pointer).toBe(true);
        expect(pointer.toString()).toBe('<Pointer: 0x1>');
    });

    it("SimplePointer -1", function () {
        var pointer = new interop.Pointer(-1);
        expect(pointer instanceof interop.Pointer).toBe(true);
        const hexMinusOneForCurrentBitness = "0x" + "f".repeat(interop.sizeof(interop.types.id)*2);
        // Subtraction used as a workaround for expect(<p>).toBe(<n>) failing due to rounding of 64-bit numbers
        expect(pointer.toNumber() - new Number(hexMinusOneForCurrentBitness)).toBe(0);
        expect(pointer.toString()).toBe(`<Pointer: ${hexMinusOneForCurrentBitness}>`);
    });

    it("PointerArithmetic", function () {
        var pointer = new interop.Pointer(0xFFFFFFFE);
        expect(pointer.toNumber()).toBe(0xFFFFFFFE);

        pointer = pointer.subtract(4);
        expect(pointer.toNumber()).toBe(0xFFFFFFFA);

        pointer = pointer.add(4);
        expect(pointer.toNumber()).toBe(0xFFFFFFFE);
    });

    it("NullPointer", function () {
        expect(new interop.Pointer()).toBeNull();
        expect(new interop.Pointer(0)).toBeNull();
        expect(new interop.Pointer(4).subtract(4)).toBeNull();
    });

    it("PointerEquality", function () {
        expect(new interop.Pointer(4)).toBe(new interop.Pointer(2).add(2));
    });

    it("Handleof", function () {
        expect(interop.handleof(NSObject) instanceof interop.Pointer).toBe(true);
        expect(interop.handleof(NSObject.alloc().init()) instanceof interop.Pointer).toBe(true);

        expect(interop.handleof(NSObject.extend({})) instanceof interop.Pointer).toBe(true);
        expect(interop.handleof(NSObject.extend({}).alloc().init()) instanceof interop.Pointer).toBe(true);

        expect(interop.handleof(TNSBaseProtocol1) instanceof interop.Pointer).toBe(true);
        expect(interop.handleof(functionWithInt) instanceof interop.Pointer).toBe(true);
        expect(interop.handleof(TNSObjCTypes.alloc().init().methodWithBlockScope(4)) instanceof interop.Pointer).toBe(true);

        expect(interop.handleof(new TNSSimpleStruct()) instanceof interop.Pointer).toBe(true);
        expect(interop.handleof(interop.alloc(4)) instanceof interop.Pointer).toBe(true);

        var reference = new interop.Reference();
        expect(function () {
            interop.handleof(reference);
        }).toThrowError();
        functionWithIntPtr(reference);
        expect(interop.handleof(reference) instanceof interop.Pointer).toBe(true);

        var functionReference = new interop.FunctionReference(function () {
        });
        expect(function () {
            interop.handleof(functionReference);
        }).toThrowError();
        functionWithSimpleFunctionPointer(functionReference);
        expect(interop.handleof(functionReference) instanceof interop.Pointer).toBe(true);

        expect(interop.handleof(null)).toBe(null);
    });

    it("Sizeof", function () {
        expect(interop.sizeof(NSObject)).toBeGreaterThan(0);
        expect(interop.sizeof(NSObject.alloc().init())).toBeGreaterThan(0);

        expect(interop.sizeof(NSObject.extend({}))).toBeGreaterThan(0);
        expect(interop.sizeof(NSObject.extend({}).alloc().init())).toBeGreaterThan(0);

        expect(interop.sizeof(TNSBaseProtocol1)).toBeGreaterThan(0);
        expect(interop.sizeof(functionWithInt)).toBeGreaterThan(0);
        expect(interop.sizeof(TNSObjCTypes.alloc().init().methodWithBlockScope(4))).toBeGreaterThan(0);

        expect(interop.sizeof(interop.Reference)).toBeGreaterThan(0);
        expect(interop.sizeof(new interop.Reference())).toBeGreaterThan(0);

        expect(interop.sizeof(interop.FunctionReference)).toBeGreaterThan(0);
        expect(interop.sizeof(new interop.FunctionReference(function () {
        }))).toBeGreaterThan(0);

        expect(interop.sizeof(interop.Pointer)).toBeGreaterThan(0);
        expect(interop.sizeof(new interop.Pointer(0xFFFFFF))).toBeGreaterThan(0);

        expect(interop.sizeof(TNSSimpleStruct)).toBeGreaterThan(0);
        expect(interop.sizeof(new TNSSimpleStruct())).toBeGreaterThan(0);
    });
});
