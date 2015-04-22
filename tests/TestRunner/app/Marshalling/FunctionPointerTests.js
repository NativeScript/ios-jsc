describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("SimpleFunctionPointerRead", function () {
        var func = functionWhichReturnsSimpleFunctionPointer();
        expect(func).toBeDefined();
        expect(func(1 << 15)).toBe(1 << 30);
    });

    it("SimpleFunctionPointerWrite", function () {
        var f = new interop.FunctionReference(function (x) {
            return x * x;
        });

        expect(f(2)).toBe(4);

        functionWithSimpleFunctionPointer(f);
        expect(TNSGetOutput()).toBe('4');
    });

    it("ComplexFunctionPointerWrite", function () {
        var f = new interop.FunctionReference(function (p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17) {
            expect(p1).toBe(127);
            expect(p2).toBe(32767);
            expect(p3).toBe(2147483647);
            expect(p4).toBe(2147483647);
//            expect(p5).toBe(0);
            expect(p6).toBe(255);
            expect(p7).toBe(65535);
            expect(p8).toBe(4294967295);
            expect(p9).toBe(4294967295);
//            expect(p10).toBe(0);
            expect(p11).toBe(3.4028234663852886e+38);
            expect(p12).toBe(1.7976931348623157e+308);
            expect(p13).toBe('init');
            expect(p14).toBe(NSObject);
            expect(p15).toBe(NSObjectProtocol);
            expect(p16.class()).toBe(NSObject.class());

            expect(p17.a.x).toBe(1);
            expect(p17.a.y).toBe(2);
            expect(p17.b.x).toBe(3);
            expect(p17.b.y).toBe(4);

            return {a: {x: 5, y: 6}, b: {x: 7, y: 8}};
        });

        TNSClearOutput();
        functionWithComplexFunctionPointer(f);
        expect(TNSGetOutput()).toBe('5 6 7 8');

        TNSClearOutput();
        functionWithComplexFunctionPointer(f);
        expect(TNSGetOutput()).toBe('5 6 7 8');
    });
});
