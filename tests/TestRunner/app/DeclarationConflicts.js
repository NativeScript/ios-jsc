describe(module.id, function() {
    afterEach(function () {
        TNSClearOutput();
    });

    it("Interface-Protocol", function() {
        expect(TNSInterfaceProtocolConflict instanceof NSObject).toBe(true);
        expect(NSProtocolFromString("TNSInterfaceProtocolConflict")).toBe(TNSInterfaceProtocolConflictProtocol2);
        expect(NSProtocolFromString("TNSInterfaceProtocolConflictProtocol")).toBe(TNSInterfaceProtocolConflictProtocol);
    });

    it("Struct-Function", function() {
        TNSStructFunctionConflict(new TNSStructFunctionConflictStruct({ x: 3 }));
        expect(TNSGetOutput()).toBe("3");
    });

    it("Struct-Var", function() {
        expect(new TNSStructVarConflictStruct({ x: 3 }).x).toBe(3);
        expect(TNSStructVarConflict).toBe(42);
    });
});
