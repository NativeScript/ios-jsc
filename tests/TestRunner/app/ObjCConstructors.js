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

        var obj4 = NSObject.alloc().init();
        expect(obj4.retainCount()).toBe(1);
    });

    it('initializerResolving', function () {
        var arr = new NSArray([1, 2, 3]);
        expect(arr.objectAtIndex(0)).toBe(1);
        expect(arr.objectAtIndex(1)).toBe(2);
        expect(arr.objectAtIndex(2)).toBe(3);
    });

    describe("Swift-style initializers", () => {
        it("should work", () => {
            let obj = new NSObject();
            expect(obj).toEqual(jasmine.any(NSObject));
            expect(obj.retainCount()).toBe(1);
        });

        it("should support parameters", () => {
            let arr = new NSArray({
                array: [1, 2, 3]
            });
            expect(arr).toEqual(jasmine.any(NSArray));
            expect(arr.count).toEqual(3);
        });

        it("should support even more complex parameters", () => {
            let alertView = new UIAlertView({
                title: "About",
                message: "NativeScript Team",
                delegate: null,
                cancelButtonTitle: "OK",
                otherButtonTitles: null
            });
            expect(alertView.title).toEqual("About");
            expect(alertView.message).toEqual("NativeScript Team");
            expect(alertView.buttonTitleAtIndex(0)).toEqual("OK");
        });

        it("should support void initializers", () => {
            let object = new TNSCInterface({
                empty: void 0
            });
            expect(object).toEqual(jasmine.any(TNSCInterface));
            expect(TNSGetOutput()).toBe('initWithEmpty called');
        });

        it("should resolve NSError** initializers", () => {
            expect(() => new TNSCInterface({
                parameter1: "value1",
                parameter2: "value2"
            })).toThrowError(/TNSErrorDomain error 1/);
        });

        it("should resolve initializers that only begin with 'init'", () => {
            let url = new NSURL({
                fileURLWithPath: "/foo"
            });
            expect(url).toEqual(jasmine.any(NSURL));
        });
    })
});
