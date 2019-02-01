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

    it("Pointer from a wrapped Number", function () {
        const number = 0x12abcdef;
        var pointer = new interop.Pointer(new Number(number));
        expect(pointer instanceof interop.Pointer).toBe(true);
        expect(pointer.toNumber()).toBe(number);
        expect(pointer.toString()).toBe(`<Pointer: 0x${number.toString(16)}>`);
        expect(pointer.toDecimalString()).toBe(number.toString());
    });

    it("Pointer limits and construction from the decimal representation of another pointer", function () {
        const additions = [0, 3, 5, 100, Math.pow(2, 10)];
        let numbers = [1, 2, Math.pow(2, 20), Math.pow(2, 31)];
        if (interop.sizeof(interop.types.id) > 4) {
            //64-bit pointers up to 2^50 should work correctly
            numbers = numbers.concat([Math.pow(2, 40), Math.pow(2, 50)]);
        }
        numbers.forEach((num, idx) => {
            additions.forEach(add => {
                // add and subtract each addend
                for (let addFactor = -1; addFactor <= 1; addFactor += 2) {
                    // try both positive and negative values
                    for (let factor = -1; factor <= 1; factor += 2) {
                        // Create a pointer from the calculated number
                        const number = (num + add * addFactor) * factor;
                        let expectedDecimal = number;
                        if (interop.sizeof(interop.types.id) == 4) {
                            // Handle 32-bit architecture overflows in pointer.toDecimalString
                            if (number >= 0x80000000) {
                                expectedDecimal = number - 0x100000000;
                            } else if (number < -0x80000000) {
                                expectedDecimal = number - -0x100000000;
                            }
                        }
                        const p = new interop.Pointer(number);
                        //                        console.log(idx + 1, number, p, p.toDecimalString(), new Number(p.toDecimalString()), `${add * addFactor}`);

                        // Create another pointer from the decimal representation of the previous number
                        // This is the only way (we're aware of) that allows to accurately tranfer
                        // any valid 64-bit pointer (and it's negative value) as a string to a worker
                        // (toNumber converts negative values to `double`s because they are treated as
                        // very large unsigned 64-bit integers. As such they can no longer be represented
                        // in a JSValue as integers.)
                        const pointer = new interop.Pointer(new Number(p.toDecimalString()));
                        expect(pointer instanceof interop.Pointer).toBe(true);
                        expect(pointer.toDecimalString()).toBe(expectedDecimal.toString(10), "Decimal string mismatch");
                        if (number > 0) {
                            expect(pointer.toNumber()).toBe(number, "Number mismatch");
                            expect(pointer.toString()).toBe(`<Pointer: 0x${number.toString(16)}>`, "String mismatch");
                            expect(pointer.toHexString()).toBe(`0x${number.toString(16)}`, "Hex string mismatch");
                        }
                    }
                }
            });
        });
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
