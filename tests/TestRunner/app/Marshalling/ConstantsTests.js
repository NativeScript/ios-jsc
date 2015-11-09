describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("SimpleNSStringConstant", function () {
        expect(NSRangeException).toBe('NSRangeException');
    });

    it("ConstantsEquality", function () {
        expect(TNSConstant).toBe(TNSConstant);
        expect(TNSConstant).toBe("TNSConstant");
    });

    it("CompileTimeConstant", function () {
        expect(TNSStaticConstant).toBe(-42);
    });

// TODO
//    it("ChangeConstantValue", function () {
//        global.TNSConstant = null;
//        expect(TNSConstant).not.toBeNull();
//    });
//
//    it("DeleteConstant", function () {
//        expect(delete global.TNSConstant).toBe(false);
//    });
});
