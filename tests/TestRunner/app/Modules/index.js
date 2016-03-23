describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    // This test is specific for the iOS runtime and cannot be shared
    it("Windows encoding file", function () {
        expect(() => require("./WindowsEncoding")).toThrowError(/character encoding/);
    });
});
