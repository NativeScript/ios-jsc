describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("Enumeration", function () {
        expect(TNSEnums.TNSEnum1).toBe(-1);
        expect(TNSEnums.TNSEnum2).toBe(0);
        expect(TNSEnums.TNSEnum3).toBe(1);

        expect(TNSEnums[-1]).toBe('TNSEnum1');
        expect(TNSEnums[0]).toBe('TNSEnum2');
        expect(TNSEnums[1]).toBe('TNSEnum3');
    });

    it("Options", function () {
        expect(TNSOptions.TNSOption1).toBe(1);
        expect(TNSOptions.TNSOption2).toBe(2);
        expect(TNSOptions.TNSOption3).toBe(4);

        expect(TNSOptions[1]).toBe('TNSOption1');
        expect(TNSOptions[2]).toBe('TNSOption2');
        expect(TNSOptions[4]).toBe('TNSOption3');
    });

    it("AnonymousEnum", function () {
        expect(AnonymousEnumField).toBe(-1);
    });
});
