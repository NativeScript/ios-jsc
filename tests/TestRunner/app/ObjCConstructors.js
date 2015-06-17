describe("Constructing Objective-C classes with new operator", function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("should not release the result of alloc", function () {
        var obj = new TNSClassWithPlaceholder();

        expect(obj.description).toBe("real");
        expect(TNSGetOutput()).toBe("");
    });

    it("ParameterlessConstructor", function () {
        var instance1 = new TNSCInterface();
        var instance2 = new (TNSCInterface.extend({}))();

        var actual = TNSGetOutput();
        expect(actual).toBe("init calledinit called");
    });

    it("WithPrimitive", function () {
        var instance1 = new TNSCInterface(7);
        var instance2 = new (TNSCInterface.extend({}))(7);

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithPrimitive:7 calledinitWithPrimitive:7 called");
    });

    it("WithStructure", function () {
        var struct = {
            x: 1,
            y: 2,
        };
        var instance1 = new TNSCInterface(struct);
        var instance2 = new (TNSCInterface.extend({}))(struct);

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithStructure:1.2 calledinitWithStructure:1.2 called");
    });

    it("WithString", function () {
        var instance1 = new TNSCInterface('str');
        var instance2 = new (TNSCInterface.extend({}))('str');

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithString:str calledinitWithString:str called");
    });

    it("NSArray with JS array constructor", function () {
        var nsarray = new NSArray([1, 2, 3]);
        expect(nsarray.class()).toBe(NSArray);
    });

    it("Invalid empty constructor args", function () {
        expect(function() {
            var nsarray = new NSObject({});
        }).toThrowError();
    });

    it('allocAndNewMethodsRetaining', function () {
        var obj1 = new NSObject();
        expect(obj1.retainCount()).toBe(1);

        var obj2 = NSObject.alloc();
        expect(obj2.retainCount()).toBe(1);

        var obj3 = NSObject.new();
        expect(obj3.retainCount()).toBe(1);
    });
    it('initializerResolving', function () {
        var arr = new NSArray([1, 2, 3]);
        expect(arr.objectAtIndex(0)).toBe(1);
        expect(arr.objectAtIndex(1)).toBe(2);
        expect(arr.objectAtIndex(2)).toBe(3);
    });
});
