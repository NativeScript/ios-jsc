describe("Metadata", function () {
    it("where method in category is implemented with property, the property access and modification should work and the method should be 'hidden'.", function () {
        var object = TNSPropertyMethodConflictClass.alloc().init();
        expect(object.conflict).toBe(false);
    });

    it("Swift objects with uncached constructors should be marshalled correctly", function () {
        expect(global.TNSSwiftLikeFactory).toBeDefined();
        expect(global.TNSSwiftLikeFactory.name).toBe("TNSSwiftLikeFactory");
        const swiftLikeObj = TNSSwiftLikeFactory.create();
        expect(swiftLikeObj.constructor).toBe(global.TNSSwiftLike);
        expect(swiftLikeObj.constructor.name).toBe("NativeScriptTests.TNSSwiftLike");
        expect(NSString.stringWithUTF8String(class_getName(swiftLikeObj.constructor)).toString()).toBe("NativeScriptTests.TNSSwiftLike");
    });
});
