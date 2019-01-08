describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it('Methods', function () {
        var object = NSObject.extend({
            baseProtocolMethod1: function () {
                TNSLog('baseProtocolMethod1 called');
            }
        }, {
            protocols: [TNSBaseProtocol1]
        }).alloc().init();

        var actual;
        var expected = "baseProtocolMethod1 called";

        object.baseProtocolMethod1();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.protocolImplementationMethods(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('Properties', function () {
        var object = NSObject.extend({
            get baseProtocolProperty1() {
                TNSLog('baseProtocolProperty1 called');
            },
            set baseProtocolProperty1(x) {
                TNSLog('setBaseProtocolProperty1: called');
            },

            get baseProtocolProperty1Optional() {
                TNSLog('baseProtocolProperty1Optional called');
            },
            set baseProtocolProperty1Optional(x) {
                TNSLog('setBaseProtocolProperty1Optional: called');
            },
        }, {
            protocols: [TNSBaseProtocol1]
        }).alloc().init();

        var actual;
        var expected =
            "setBaseProtocolProperty1: called" +
            "baseProtocolProperty1 called" +
            "setBaseProtocolProperty1Optional: called" +
            "baseProtocolProperty1Optional called";

        object.baseProtocolProperty1 = 0;
        UNUSED(object.baseProtocolProperty1);
        object.baseProtocolProperty1Optional = 0;
        UNUSED(object.baseProtocolProperty1Optional);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.protocolImplementationProperties(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it("ProtocolInheritance", function () {
        var object = NSObject.extend({
            baseProtocolMethod1: function () {
                TNSLog('baseProtocolMethod1 called');
            },
            baseProtocolMethod2: function () {
                TNSLog('baseProtocolMethod2 called');
            },
        }, {
            protocols: [TNSBaseProtocol2]
        }).alloc().init();

        var actual;
        var expected =
            "baseProtocolMethod1 called" +
            "baseProtocolMethod2 called";

        object.baseProtocolMethod1();
        object.baseProtocolMethod2();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.protocolImplementationProtocolInheritance(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('OptionalMethods', function () {
        var object = NSObject.extend({
            baseProtocolMethod1Optional: function () {
                TNSLog('baseProtocolMethod1Optional called');
            },
        }, {
            protocols: [TNSBaseProtocol2]
        }).alloc().init();

        var actual;
        var expected = "baseProtocolMethod1Optional called";

        object.baseProtocolMethod1Optional();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.protocolImplementationOptionalMethods(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('AlreadyImplementedProtocol', function () {
        TNSDerivedInterface.extend({}, {
            protocols: [TNSBaseProtocol1]
        });
    });

    it('Two protocols', function () {
        var object = NSObject.extend({
            baseProtocolMethod1: function () {
                TNSLog('baseProtocolMethod1 called');
            },
            baseCategoryProtocolMethod1: function () {
                TNSLog('baseCategoryProtocolMethod1 called');
            }
        }, {
            protocols: [TNSBaseProtocol1, TNSBaseCategoryProtocol1]
        }).alloc().init();

        var actual;
        var expected =
            'baseProtocolMethod1 called' +
            'baseCategoryProtocolMethod1 called';

        object.baseProtocolMethod1();
        object.baseCategoryProtocolMethod1();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.protocolImplementationMethods(object);
        TNSTestNativeCallbacks.categoryProtocolImplementationMethods(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
    });
});
