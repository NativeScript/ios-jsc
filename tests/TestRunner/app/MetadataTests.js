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
    
    it("Objects from nested Swift classes should be marshalled correctly", function () {
        const swiftLikeInnerObj = TNSSwiftLikeFactory.createInner();
        expect(swiftLikeInnerObj.constructor).toBe(global.TNSSwiftLikeInner);
        expect(swiftLikeInnerObj.constructor.name).toBe("_TtCC17NativeScriptTests12TNSSwiftLike5Inner");
        expect(NSString.stringWithUTF8String(class_getName(swiftLikeInnerObj.constructor)).toString(), "_TtCC17NativeScriptTests12TNSSwiftLike5Inner");
    });
});
