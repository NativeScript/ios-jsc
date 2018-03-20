describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    // This test is specific for the iOS runtime and cannot be shared
    it("Windows encoding file", function () {
        expect(() => require("./WindowsEncoding")).toThrowError(/character encoding/);
    });

    // TODO: [2017-04-20] Delete deprecated module search functionality
    it("core-module", function () {
        require("core-module");
        expect(TNSGetOutput()).toBe('core-module loaded');
    });
    it("core-module-dir", function () {
        require("core-module-dir");
        expect(TNSGetOutput()).toBe('core-module-dir loaded');
    });

    it("load-empty-file", function(){
       let emptyModule = require("./empty-file");
       expect(emptyModule !== undefined).toBe(true);
    });
});
