describe("Constructing Objective-C classes with new operator", function () {
    afterEach(function () {
        TNSClearOutput();
    });
    
    it("should not release the result of alloc", function () {
        var obj = new TNSClassWithPlaceholder();
        
        expect(obj.description).toBe("real");
        expect(TNSGetOutput()).toBe("");
    }) 
});