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

     it("not strict by default", function(){
        let module = require("./strict-violation-default");
        expect(module).toBeDefined();
     });

     it("'use strict'; statement is respected", function(){
        let requireFunc = () => require("./strict-violation-use-strict");
        expect(requireFunc).toThrowError("Cannot delete unqualified property 'x' in strict mode.");
     });
         
     it("require non-existent module throws", function () {
        expect(()=> require("./non-existent")).toThrowError(/Could not find module '.\/non-existent'. Computed path '.*non-existent'. \(evaluating 'require\(".\/non-existent"\)'/);
     });
});
