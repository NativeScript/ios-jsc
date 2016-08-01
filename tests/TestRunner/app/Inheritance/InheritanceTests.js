describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    // Should be first
    it("StaticPropertyNames", function () {
        expect('baseMethod' in TNSBaseInterface).toBe(true);
        expect(TNSBaseInterface.hasOwnProperty('baseCategoryMethod')).toBe(true);

        expect(Object.getOwnPropertyNames(TNSBaseInterface).sort()).toEqual([
            'baseCategoryMethod',
            'baseCategoryProperty',
            'baseCategoryProtocolMethod1',
            'baseCategoryProtocolMethod1Optional',
            'baseCategoryProtocolMethod2',
            'baseCategoryProtocolMethod2Optional',
            'baseCategoryProtocolProperty1',
            'baseCategoryProtocolProperty1Optional',
            'baseCategoryProtocolProperty2',
            'baseCategoryProtocolProperty2Optional',
            'baseMethod',
            'baseProperty',
            'baseProtocolMethod1',
            'baseProtocolMethod1Optional',
            'baseProtocolMethod2',
            'baseProtocolMethod2Optional',
            'baseProtocolProperty1',
            'baseProtocolProperty1Optional',
            'baseProtocolProperty2',
            'baseProtocolProperty2Optional',
            'name'
        ]);
    });

    it("InstancePropertyNames", function () {
        expect('baseMethod' in TNSBaseInterface.prototype).toBe(true);
        expect(TNSBaseInterface.prototype.hasOwnProperty('baseCategoryMethod')).toBe(true);

        expect(Object.getOwnPropertyNames(TNSBaseInterface.prototype).sort()).toEqual([
            'baseCategoryMethod',
            'baseCategoryProperty',
            'baseCategoryProtocolMethod1',
            'baseCategoryProtocolMethod1Optional',
            'baseCategoryProtocolMethod2',
            'baseCategoryProtocolMethod2Optional',
            'baseCategoryProtocolProperty1',
            'baseCategoryProtocolProperty1Optional',
            'baseCategoryProtocolProperty2',
            'baseCategoryProtocolProperty2Optional',
            'baseMethod',
            'baseProperty',
            'baseProtocolMethod1',
            'baseProtocolMethod1Optional',
            'baseProtocolMethod2',
            'baseProtocolMethod2Optional',
            'baseProtocolProperty1',
            'baseProtocolProperty1Optional',
            'baseProtocolProperty2',
            'baseProtocolProperty2Optional',
            'constructor',
            'initBaseCategoryMethod',
            'initBaseCategoryProtocolMethod1',
            'initBaseCategoryProtocolMethod1Optional',
            'initBaseCategoryProtocolMethod2',
            'initBaseCategoryProtocolMethod2Optional',
            'initBaseMethod',
            'initBaseProtocolMethod1',
            'initBaseProtocolMethod1Optional',
            'initBaseProtocolMethod2',
            'initBaseProtocolMethod2Optional'
        ]);
    });

    it("SimpleInheritance", function () {
        var JSObject = NSObject.extend({});
        var object = new JSObject();
        expect(object.class()).toBe(JSObject);
        expect(object.superclass).toBe(NSObject);
        expect(object.constructor).toBe(JSObject);
    });

    it("StaticCalls", function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({});
        JSDerivedInterface.baseMethod();
        JSDerivedInterface.baseProtocolMethod2();
        JSDerivedInterface.baseProtocolMethod2Optional();
        JSDerivedInterface.baseProtocolMethod1();
        JSDerivedInterface.baseProtocolMethod1Optional();
        JSDerivedInterface.baseCategoryMethod();
        JSDerivedInterface.baseCategoryProtocolMethod2();
        JSDerivedInterface.baseCategoryProtocolMethod2Optional();
        JSDerivedInterface.baseCategoryProtocolMethod1();
        JSDerivedInterface.baseCategoryProtocolMethod1Optional();
        JSDerivedInterface.derivedMethod();
        JSDerivedInterface.derivedProtocolMethod2();
        JSDerivedInterface.derivedProtocolMethod2Optional();
        JSDerivedInterface.derivedProtocolMethod1();
        JSDerivedInterface.derivedProtocolMethod1Optional();
        JSDerivedInterface.derivedCategoryMethod();
        JSDerivedInterface.derivedCategoryProtocolMethod2();
        JSDerivedInterface.derivedCategoryProtocolMethod2Optional();
        JSDerivedInterface.derivedCategoryProtocolMethod1();
        JSDerivedInterface.derivedCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe(
            'static baseMethod called' +
            'static baseProtocolMethod2 called' +
            'static baseProtocolMethod2Optional called' +
            'static baseProtocolMethod1 called' +
            'static baseProtocolMethod1Optional called' +
            'static baseCategoryMethod called' +
            'static baseCategoryProtocolMethod2 called' +
            'static baseCategoryProtocolMethod2Optional called' +
            'static baseCategoryProtocolMethod1 called' +
            'static baseCategoryProtocolMethod1Optional called' +
            'static derivedMethod called' +
            'static derivedProtocolMethod2 called' +
            'static derivedProtocolMethod2Optional called' +
            'static derivedProtocolMethod1 called' +
            'static derivedProtocolMethod1Optional called' +
            'static derivedCategoryMethod called' +
            'static derivedCategoryProtocolMethod2 called' +
            'static derivedCategoryProtocolMethod2Optional called' +
            'static derivedCategoryProtocolMethod1 called' +
            'static derivedCategoryProtocolMethod1Optional called'
        );
    });

    it("MethodCalls", function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({});
        var object = JSDerivedInterface.alloc().init();
        object.baseMethod();
        object.baseProtocolMethod2();
        object.baseProtocolMethod2Optional();
        object.baseProtocolMethod1();
        object.baseProtocolMethod1Optional();
        object.baseCategoryMethod();
        object.baseCategoryProtocolMethod2();
        object.baseCategoryProtocolMethod2Optional();
        object.baseCategoryProtocolMethod1();
        object.baseCategoryProtocolMethod1Optional();
        object.derivedMethod();
        object.derivedProtocolMethod2();
        object.derivedProtocolMethod2Optional();
        object.derivedProtocolMethod1();
        object.derivedProtocolMethod1Optional();
        object.derivedCategoryMethod();
        object.derivedCategoryProtocolMethod2();
        object.derivedCategoryProtocolMethod2Optional();
        object.derivedCategoryProtocolMethod1();
        object.derivedCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe(
            'instance baseMethod called' +
            'instance baseProtocolMethod2 called' +
            'instance baseProtocolMethod2Optional called' +
            'instance baseProtocolMethod1 called' +
            'instance baseProtocolMethod1Optional called' +
            'instance baseCategoryMethod called' +
            'instance baseCategoryProtocolMethod2 called' +
            'instance baseCategoryProtocolMethod2Optional called' +
            'instance baseCategoryProtocolMethod1 called' +
            'instance baseCategoryProtocolMethod1Optional called' +
            'instance derivedMethod called' +
            'instance derivedProtocolMethod2 called' +
            'instance derivedProtocolMethod2Optional called' +
            'instance derivedProtocolMethod1 called' +
            'instance derivedProtocolMethod1Optional called' +
            'instance derivedCategoryMethod called' +
            'instance derivedCategoryProtocolMethod2 called' +
            'instance derivedCategoryProtocolMethod2Optional called' +
            'instance derivedCategoryProtocolMethod1 called' +
            'instance derivedCategoryProtocolMethod1Optional called'
        );
    });

    it("ConstructorCalls", function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({});
        JSDerivedInterface.alloc().initBaseMethod();
        JSDerivedInterface.alloc().initBaseProtocolMethod2();
        JSDerivedInterface.alloc().initBaseProtocolMethod2Optional();
        JSDerivedInterface.alloc().initBaseProtocolMethod1();
        JSDerivedInterface.alloc().initBaseProtocolMethod1Optional();
        JSDerivedInterface.alloc().initBaseCategoryMethod();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod2();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod2Optional();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod1();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod1Optional();
        JSDerivedInterface.alloc().initDerivedMethod();
        JSDerivedInterface.alloc().initDerivedProtocolMethod2();
        JSDerivedInterface.alloc().initDerivedProtocolMethod2Optional();
        JSDerivedInterface.alloc().initDerivedProtocolMethod1();
        JSDerivedInterface.alloc().initDerivedProtocolMethod1Optional();
        JSDerivedInterface.alloc().initDerivedCategoryMethod();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2Optional();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe(
            'constructor initBaseMethod called' +
            'constructor initBaseProtocolMethod2 called' +
            'constructor initBaseProtocolMethod2Optional called' +
            'constructor initBaseProtocolMethod1 called' +
            'constructor initBaseProtocolMethod1Optional called' +
            'constructor initBaseCategoryMethod called' +
            'constructor initBaseCategoryProtocolMethod2 called' +
            'constructor initBaseCategoryProtocolMethod2Optional called' +
            'constructor initBaseCategoryProtocolMethod1 called' +
            'constructor initBaseCategoryProtocolMethod1Optional called' +
            'constructor initDerivedMethod called' +
            'constructor initDerivedProtocolMethod2 called' +
            'constructor initDerivedProtocolMethod2Optional called' +
            'constructor initDerivedProtocolMethod1 called' +
            'constructor initDerivedProtocolMethod1Optional called' +
            'constructor initDerivedCategoryMethod called' +
            'constructor initDerivedCategoryProtocolMethod2 called' +
            'constructor initDerivedCategoryProtocolMethod2Optional called' +
            'constructor initDerivedCategoryProtocolMethod1 called' +
            'constructor initDerivedCategoryProtocolMethod1Optional called'
        );
    });

    it("PropertiesCalls", function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({});
        var object = JSDerivedInterface.alloc().init();
        object.baseProtocolProperty1 = 0;
        UNUSED(object.baseProtocolProperty1);
        object.baseProtocolProperty1Optional = 0;
        UNUSED(object.baseProtocolProperty1Optional);
        object.baseProtocolProperty2 = 0;
        UNUSED(object.baseProtocolProperty2);
        object.baseProtocolProperty2Optional = 0;
        UNUSED(object.baseProtocolProperty2Optional);
        object.baseProperty = 0;
        UNUSED(object.baseProperty);
        object.baseCategoryProtocolProperty1 = 0;
        UNUSED(object.baseCategoryProtocolProperty1);
        object.baseCategoryProtocolProperty1Optional = 0;
        UNUSED(object.baseCategoryProtocolProperty1Optional);
        object.baseCategoryProtocolProperty2 = 0;
        UNUSED(object.baseCategoryProtocolProperty2);
        object.baseCategoryProtocolProperty2Optional = 0;
        UNUSED(object.baseCategoryProtocolProperty2Optional);
        object.baseCategoryProperty = 0;
        UNUSED(object.baseCategoryProperty);
        object.derivedProtocolProperty1 = 0;
        UNUSED(object.derivedProtocolProperty1);
        object.derivedProtocolProperty1Optional = 0;
        UNUSED(object.derivedProtocolProperty1Optional);
        object.derivedProtocolProperty2 = 0;
        UNUSED(object.derivedProtocolProperty2);
        object.derivedProtocolProperty2Optional = 0;
        UNUSED(object.derivedProtocolProperty2Optional);
        object.derivedProperty = 0;
        UNUSED(object.derivedProperty);
        object.derivedCategoryProtocolProperty1 = 0;
        UNUSED(object.derivedCategoryProtocolProperty1);
        object.derivedCategoryProtocolProperty1Optional = 0;
        UNUSED(object.derivedCategoryProtocolProperty1Optional);
        object.derivedCategoryProtocolProperty2 = 0;
        UNUSED(object.derivedCategoryProtocolProperty2);
        object.derivedCategoryProtocolProperty2Optional = 0;
        UNUSED(object.derivedCategoryProtocolProperty2Optional);
        object.derivedCategoryProperty = 0;
        UNUSED(object.derivedCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe(
            'instance setBaseProtocolProperty1: called' +
            'instance baseProtocolProperty1 called' +
            'instance setBaseProtocolProperty1Optional: called' +
            'instance baseProtocolProperty1Optional called' +
            'instance setBaseProtocolProperty2: called' +
            'instance baseProtocolProperty2 called' +
            'instance setBaseProtocolProperty2Optional: called' +
            'instance baseProtocolProperty2Optional called' +
            'instance setBaseProperty: called' +
            'instance baseProperty called' +
            'instance setBaseCategoryProtocolProperty1: called' +
            'instance baseCategoryProtocolProperty1 called' +
            'instance setBaseCategoryProtocolProperty1Optional: called' +
            'instance baseCategoryProtocolProperty1Optional called' +
            'instance setBaseCategoryProtocolProperty2: called' +
            'instance baseCategoryProtocolProperty2 called' +
            'instance setBaseCategoryProtocolProperty2Optional: called' +
            'instance baseCategoryProtocolProperty2Optional called' +
            'instance setBaseCategoryProperty: called' +
            'instance baseCategoryProperty called' +
            'instance setDerivedProtocolProperty1: called' +
            'instance derivedProtocolProperty1 called' +
            'instance setDerivedProtocolProperty1Optional: called' +
            'instance derivedProtocolProperty1Optional called' +
            'instance setDerivedProtocolProperty2: called' +
            'instance derivedProtocolProperty2 called' +
            'instance setDerivedProtocolProperty2Optional: called' +
            'instance derivedProtocolProperty2Optional called' +
            'instance setDerivedProperty: called' +
            'instance derivedProperty called' +
            'instance setDerivedCategoryProtocolProperty1: called' +
            'instance derivedCategoryProtocolProperty1 called' +
            'instance setDerivedCategoryProtocolProperty1Optional: called' +
            'instance derivedCategoryProtocolProperty1Optional called' +
            'instance setDerivedCategoryProtocolProperty2: called' +
            'instance derivedCategoryProtocolProperty2 called' +
            'instance setDerivedCategoryProtocolProperty2Optional: called' +
            'instance derivedCategoryProtocolProperty2Optional called' +
            'instance setDerivedCategoryProperty: called' +
            'instance derivedCategoryProperty called'
        );
    });

    it("MethodOverrides: prototype", function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({
            baseMethod: function () {
                TNSLog('js baseMethod called');
                TNSDerivedInterface.prototype.baseMethod.apply(this, arguments);
            },
            baseProtocolMethod2: function () {
                TNSLog('js baseProtocolMethod2 called');
                TNSDerivedInterface.prototype.baseProtocolMethod2.apply(this, arguments);
            },
            baseProtocolMethod2Optional: function () {
                TNSLog('js baseProtocolMethod2Optional called');
                TNSDerivedInterface.prototype.baseProtocolMethod2Optional.apply(this, arguments);
            },
            baseProtocolMethod1: function () {
                TNSLog('js baseProtocolMethod1 called');
                TNSDerivedInterface.prototype.baseProtocolMethod1.apply(this, arguments);
            },
            baseProtocolMethod1Optional: function () {
                TNSLog('js baseProtocolMethod1Optional called');
                TNSDerivedInterface.prototype.baseProtocolMethod1Optional.apply(this, arguments);
            },
            baseCategoryMethod: function () {
                TNSLog('js baseCategoryMethod called');
                TNSDerivedInterface.prototype.baseCategoryMethod.apply(this, arguments);
            },
            baseCategoryProtocolMethod2: function () {
                TNSLog('js baseCategoryProtocolMethod2 called');
                TNSDerivedInterface.prototype.baseCategoryProtocolMethod2.apply(this, arguments);
            },
            baseCategoryProtocolMethod2Optional: function () {
                TNSLog('js baseCategoryProtocolMethod2Optional called');
                TNSDerivedInterface.prototype.baseCategoryProtocolMethod2Optional.apply(this, arguments);
            },
            baseCategoryProtocolMethod1: function () {
                TNSLog('js baseCategoryProtocolMethod1 called');
                TNSDerivedInterface.prototype.baseCategoryProtocolMethod1.apply(this, arguments);
            },
            baseCategoryProtocolMethod1Optional: function () {
                TNSLog('js baseCategoryProtocolMethod1Optional called');
                TNSDerivedInterface.prototype.baseCategoryProtocolMethod1Optional.apply(this, arguments);
            },
            derivedMethod: function () {
                TNSLog('js derivedMethod called');
                TNSDerivedInterface.prototype.derivedMethod.apply(this, arguments);
            },
            derivedProtocolMethod2: function () {
                TNSLog('js derivedProtocolMethod2 called');
                TNSDerivedInterface.prototype.derivedProtocolMethod2.apply(this, arguments);
            },
            derivedProtocolMethod2Optional: function () {
                TNSLog('js derivedProtocolMethod2Optional called');
                TNSDerivedInterface.prototype.derivedProtocolMethod2Optional.apply(this, arguments);
            },
            derivedProtocolMethod1: function () {
                TNSLog('js derivedProtocolMethod1 called');
                TNSDerivedInterface.prototype.derivedProtocolMethod1.apply(this, arguments);
            },
            derivedProtocolMethod1Optional: function () {
                TNSLog('js derivedProtocolMethod1Optional called');
                TNSDerivedInterface.prototype.derivedProtocolMethod1Optional.apply(this, arguments);
            },
            derivedCategoryMethod: function () {
                TNSLog('js derivedCategoryMethod called');
                TNSDerivedInterface.prototype.derivedCategoryMethod.apply(this, arguments);
            },
            derivedCategoryProtocolMethod2: function () {
                TNSLog('js derivedCategoryProtocolMethod2 called');
                TNSDerivedInterface.prototype.derivedCategoryProtocolMethod2.apply(this, arguments);
            },
            derivedCategoryProtocolMethod2Optional: function () {
                TNSLog('js derivedCategoryProtocolMethod2Optional called');
                TNSDerivedInterface.prototype.derivedCategoryProtocolMethod2Optional.apply(this, arguments);
            },
            derivedCategoryProtocolMethod1: function () {
                TNSLog('js derivedCategoryProtocolMethod1 called');
                TNSDerivedInterface.prototype.derivedCategoryProtocolMethod1.apply(this, arguments);
            },
            derivedCategoryProtocolMethod1Optional: function () {
                TNSLog('js derivedCategoryProtocolMethod1Optional called');
                TNSDerivedInterface.prototype.derivedCategoryProtocolMethod1Optional.apply(this, arguments);
            },
        });

        var actual;
        var expected =
            'js baseMethod called' +
            'instance baseMethod called' +
            'js baseProtocolMethod2 called' +
            'instance baseProtocolMethod2 called' +
            'js baseProtocolMethod2Optional called' +
            'instance baseProtocolMethod2Optional called' +
            'js baseProtocolMethod1 called' +
            'instance baseProtocolMethod1 called' +
            'js baseProtocolMethod1Optional called' +
            'instance baseProtocolMethod1Optional called' +
            'js baseCategoryMethod called' +
            'instance baseCategoryMethod called' +
            'js baseCategoryProtocolMethod2 called' +
            'instance baseCategoryProtocolMethod2 called' +
            'js baseCategoryProtocolMethod2Optional called' +
            'instance baseCategoryProtocolMethod2Optional called' +
            'js baseCategoryProtocolMethod1 called' +
            'instance baseCategoryProtocolMethod1 called' +
            'js baseCategoryProtocolMethod1Optional called' +
            'instance baseCategoryProtocolMethod1Optional called' +
            'js derivedMethod called' +
            'instance derivedMethod called' +
            'js derivedProtocolMethod2 called' +
            'instance derivedProtocolMethod2 called' +
            'js derivedProtocolMethod2Optional called' +
            'instance derivedProtocolMethod2Optional called' +
            'js derivedProtocolMethod1 called' +
            'instance derivedProtocolMethod1 called' +
            'js derivedProtocolMethod1Optional called' +
            'instance derivedProtocolMethod1Optional called' +
            'js derivedCategoryMethod called' +
            'instance derivedCategoryMethod called' +
            'js derivedCategoryProtocolMethod2 called' +
            'instance derivedCategoryProtocolMethod2 called' +
            'js derivedCategoryProtocolMethod2Optional called' +
            'instance derivedCategoryProtocolMethod2Optional called' +
            'js derivedCategoryProtocolMethod1 called' +
            'instance derivedCategoryProtocolMethod1 called' +
            'js derivedCategoryProtocolMethod1Optional called' +
            'instance derivedCategoryProtocolMethod1Optional called';

        var object = JSDerivedInterface.alloc().init();
        object.baseMethod();
        object.baseProtocolMethod2();
        object.baseProtocolMethod2Optional();
        object.baseProtocolMethod1();
        object.baseProtocolMethod1Optional();
        object.baseCategoryMethod();
        object.baseCategoryProtocolMethod2();
        object.baseCategoryProtocolMethod2Optional();
        object.baseCategoryProtocolMethod1();
        object.baseCategoryProtocolMethod1Optional();
        object.derivedMethod();
        object.derivedProtocolMethod2();
        object.derivedProtocolMethod2Optional();
        object.derivedProtocolMethod1();
        object.derivedProtocolMethod1Optional();
        object.derivedCategoryMethod();
        object.derivedCategoryProtocolMethod2();
        object.derivedCategoryProtocolMethod2Optional();
        object.derivedCategoryProtocolMethod1();
        object.derivedCategoryProtocolMethod1Optional();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritanceMethodCalls(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it("MethodOverrides: super", function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({
            baseMethod: function () {
                TNSLog('js baseMethod called');
                this.super.baseMethod();
            },
            baseProtocolMethod2: function () {
                TNSLog('js baseProtocolMethod2 called');
                this.super.baseProtocolMethod2();
            },
            baseProtocolMethod2Optional: function () {
                TNSLog('js baseProtocolMethod2Optional called');
                this.super.baseProtocolMethod2Optional();
            },
            baseProtocolMethod1: function () {
                TNSLog('js baseProtocolMethod1 called');
                this.super.baseProtocolMethod1();
            },
            baseProtocolMethod1Optional: function () {
                TNSLog('js baseProtocolMethod1Optional called');
                this.super.baseProtocolMethod1Optional();
            },
            baseCategoryMethod: function () {
                TNSLog('js baseCategoryMethod called');
                this.super.baseCategoryMethod();
            },
            baseCategoryProtocolMethod2: function () {
                TNSLog('js baseCategoryProtocolMethod2 called');
                this.super.baseCategoryProtocolMethod2();
            },
            baseCategoryProtocolMethod2Optional: function () {
                TNSLog('js baseCategoryProtocolMethod2Optional called');
                this.super.baseCategoryProtocolMethod2Optional();
            },
            baseCategoryProtocolMethod1: function () {
                TNSLog('js baseCategoryProtocolMethod1 called');
                this.super.baseCategoryProtocolMethod1();
            },
            baseCategoryProtocolMethod1Optional: function () {
                TNSLog('js baseCategoryProtocolMethod1Optional called');
                this.super.baseCategoryProtocolMethod1Optional();
            },
            derivedMethod: function () {
                TNSLog('js derivedMethod called');
                this.super.derivedMethod();
            },
            derivedProtocolMethod2: function () {
                TNSLog('js derivedProtocolMethod2 called');
                this.super.derivedProtocolMethod2();
            },
            derivedProtocolMethod2Optional: function () {
                TNSLog('js derivedProtocolMethod2Optional called');
                this.super.derivedProtocolMethod2Optional();
            },
            derivedProtocolMethod1: function () {
                TNSLog('js derivedProtocolMethod1 called');
                this.super.derivedProtocolMethod1();
            },
            derivedProtocolMethod1Optional: function () {
                TNSLog('js derivedProtocolMethod1Optional called');
                this.super.derivedProtocolMethod1Optional();
            },
            derivedCategoryMethod: function () {
                TNSLog('js derivedCategoryMethod called');
                this.super.derivedCategoryMethod();
            },
            derivedCategoryProtocolMethod2: function () {
                TNSLog('js derivedCategoryProtocolMethod2 called');
                this.super.derivedCategoryProtocolMethod2();
            },
            derivedCategoryProtocolMethod2Optional: function () {
                TNSLog('js derivedCategoryProtocolMethod2Optional called');
                this.super.derivedCategoryProtocolMethod2Optional();
            },
            derivedCategoryProtocolMethod1: function () {
                TNSLog('js derivedCategoryProtocolMethod1 called');
                this.super.derivedCategoryProtocolMethod1();
            },
            derivedCategoryProtocolMethod1Optional: function () {
                TNSLog('js derivedCategoryProtocolMethod1Optional called');
                this.super.derivedCategoryProtocolMethod1Optional();
            },
        });

        var actual;
        var expected =
            'js baseMethod called' +
            'instance baseMethod called' +
            'js baseProtocolMethod2 called' +
            'instance baseProtocolMethod2 called' +
            'js baseProtocolMethod2Optional called' +
            'instance baseProtocolMethod2Optional called' +
            'js baseProtocolMethod1 called' +
            'instance baseProtocolMethod1 called' +
            'js baseProtocolMethod1Optional called' +
            'instance baseProtocolMethod1Optional called' +
            'js baseCategoryMethod called' +
            'instance baseCategoryMethod called' +
            'js baseCategoryProtocolMethod2 called' +
            'instance baseCategoryProtocolMethod2 called' +
            'js baseCategoryProtocolMethod2Optional called' +
            'instance baseCategoryProtocolMethod2Optional called' +
            'js baseCategoryProtocolMethod1 called' +
            'instance baseCategoryProtocolMethod1 called' +
            'js baseCategoryProtocolMethod1Optional called' +
            'instance baseCategoryProtocolMethod1Optional called' +
            'js derivedMethod called' +
            'instance derivedMethod called' +
            'js derivedProtocolMethod2 called' +
            'instance derivedProtocolMethod2 called' +
            'js derivedProtocolMethod2Optional called' +
            'instance derivedProtocolMethod2Optional called' +
            'js derivedProtocolMethod1 called' +
            'instance derivedProtocolMethod1 called' +
            'js derivedProtocolMethod1Optional called' +
            'instance derivedProtocolMethod1Optional called' +
            'js derivedCategoryMethod called' +
            'instance derivedCategoryMethod called' +
            'js derivedCategoryProtocolMethod2 called' +
            'instance derivedCategoryProtocolMethod2 called' +
            'js derivedCategoryProtocolMethod2Optional called' +
            'instance derivedCategoryProtocolMethod2Optional called' +
            'js derivedCategoryProtocolMethod1 called' +
            'instance derivedCategoryProtocolMethod1 called' +
            'js derivedCategoryProtocolMethod1Optional called' +
            'instance derivedCategoryProtocolMethod1Optional called';

        var object = JSDerivedInterface.alloc().init();
        object.baseMethod();
        object.baseProtocolMethod2();
        object.baseProtocolMethod2Optional();
        object.baseProtocolMethod1();
        object.baseProtocolMethod1Optional();
        object.baseCategoryMethod();
        object.baseCategoryProtocolMethod2();
        object.baseCategoryProtocolMethod2Optional();
        object.baseCategoryProtocolMethod1();
        object.baseCategoryProtocolMethod1Optional();
        object.derivedMethod();
        object.derivedProtocolMethod2();
        object.derivedProtocolMethod2Optional();
        object.derivedProtocolMethod1();
        object.derivedProtocolMethod1Optional();
        object.derivedCategoryMethod();
        object.derivedCategoryProtocolMethod2();
        object.derivedCategoryProtocolMethod2Optional();
        object.derivedCategoryProtocolMethod1();
        object.derivedCategoryProtocolMethod1Optional();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritanceMethodCalls(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('ConstructorOverrides: prototype', function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({
            initBaseProtocolMethod1: function () {
                TNSDerivedInterface.prototype.initBaseProtocolMethod1.apply(this, arguments);
                TNSLog('js initBaseProtocolMethod1 called');
                return this;
            },
            initBaseProtocolMethod1Optional: function () {
                TNSDerivedInterface.prototype.initBaseProtocolMethod1Optional.apply(this, arguments);
                TNSLog('js initBaseProtocolMethod1Optional called');
                return this;
            },
            initBaseProtocolMethod2: function () {
                TNSDerivedInterface.prototype.initBaseProtocolMethod2.apply(this, arguments);
                TNSLog('js initBaseProtocolMethod2 called');
                return this;
            },
            initBaseProtocolMethod2Optional: function () {
                TNSDerivedInterface.prototype.initBaseProtocolMethod2Optional.apply(this, arguments);
                TNSLog('js initBaseProtocolMethod2Optional called');
                return this;
            },
            initBaseMethod: function () {
                TNSDerivedInterface.prototype.initBaseMethod.apply(this, arguments);
                TNSLog('js initBaseMethod called');
                return this;
            },
            initBaseCategoryProtocolMethod1: function () {
                TNSDerivedInterface.prototype.initBaseCategoryProtocolMethod1.apply(this, arguments);
                TNSLog('js initBaseCategoryProtocolMethod1 called');
                return this;
            },
            initBaseCategoryProtocolMethod1Optional: function () {
                TNSDerivedInterface.prototype.initBaseCategoryProtocolMethod1Optional.apply(this, arguments);
                TNSLog('js initBaseCategoryProtocolMethod1Optional called');
                return this;
            },
            initBaseCategoryProtocolMethod2: function () {
                TNSDerivedInterface.prototype.initBaseCategoryProtocolMethod2.apply(this, arguments);
                TNSLog('js initBaseCategoryProtocolMethod2 called');
                return this;
            },
            initBaseCategoryProtocolMethod2Optional: function () {
                TNSDerivedInterface.prototype.initBaseCategoryProtocolMethod2Optional.apply(this, arguments);
                TNSLog('js initBaseCategoryProtocolMethod2Optional called');
                return this;
            },
            initBaseCategoryMethod: function () {
                TNSDerivedInterface.prototype.initBaseCategoryMethod.apply(this, arguments);
                TNSLog('js initBaseCategoryMethod called');
                return this;
            },
            initDerivedProtocolMethod1: function () {
                TNSDerivedInterface.prototype.initDerivedProtocolMethod1.apply(this, arguments);
                TNSLog('js initDerivedProtocolMethod1 called');
                return this;
            },
            initDerivedProtocolMethod1Optional: function () {
                TNSDerivedInterface.prototype.initDerivedProtocolMethod1Optional.apply(this, arguments);
                TNSLog('js initDerivedProtocolMethod1Optional called');
                return this;
            },
            initDerivedProtocolMethod2: function () {
                TNSDerivedInterface.prototype.initDerivedProtocolMethod2.apply(this, arguments);
                TNSLog('js initDerivedProtocolMethod2 called');
                return this;
            },
            initDerivedProtocolMethod2Optional: function () {
                TNSDerivedInterface.prototype.initDerivedProtocolMethod2Optional.apply(this, arguments);
                TNSLog('js initDerivedProtocolMethod2Optional called');
                return this;
            },
            initDerivedMethod: function () {
                TNSDerivedInterface.prototype.initDerivedMethod.apply(this, arguments);
                TNSLog('js initDerivedMethod called');
                return this;
            },
            initDerivedCategoryProtocolMethod1: function () {
                TNSDerivedInterface.prototype.initDerivedCategoryProtocolMethod1.apply(this, arguments);
                TNSLog('js initDerivedCategoryProtocolMethod1 called');
                return this;
            },
            initDerivedCategoryProtocolMethod1Optional: function () {
                TNSDerivedInterface.prototype.initDerivedCategoryProtocolMethod1Optional.apply(this, arguments);
                TNSLog('js initDerivedCategoryProtocolMethod1Optional called');
                return this;
            },
            initDerivedCategoryProtocolMethod2: function () {
                TNSDerivedInterface.prototype.initDerivedCategoryProtocolMethod2.apply(this, arguments);
                TNSLog('js initDerivedCategoryProtocolMethod2 called');
                return this;
            },
            initDerivedCategoryProtocolMethod2Optional: function () {
                TNSDerivedInterface.prototype.initDerivedCategoryProtocolMethod2Optional.apply(this, arguments);
                TNSLog('js initDerivedCategoryProtocolMethod2Optional called');
                return this;
            },
            initDerivedCategoryMethod: function () {
                TNSDerivedInterface.prototype.initDerivedCategoryMethod.apply(this, arguments);
                TNSLog('js initDerivedCategoryMethod called');
                return this;
            },
        }, {
            name: 'JSDerivedInterface_Prototype'
        });

        var actual;
        var expected =
            'constructor initBaseProtocolMethod1 called' +
            'js initBaseProtocolMethod1 called' +
            'constructor initBaseProtocolMethod1Optional called' +
            'js initBaseProtocolMethod1Optional called' +
            'constructor initBaseProtocolMethod2 called' +
            'js initBaseProtocolMethod2 called' +
            'constructor initBaseProtocolMethod2Optional called' +
            'js initBaseProtocolMethod2Optional called' +
            'constructor initBaseMethod called' +
            'js initBaseMethod called' +
            'constructor initBaseCategoryProtocolMethod1 called' +
            'js initBaseCategoryProtocolMethod1 called' +
            'constructor initBaseCategoryProtocolMethod1Optional called' +
            'js initBaseCategoryProtocolMethod1Optional called' +
            'constructor initBaseCategoryProtocolMethod2 called' +
            'js initBaseCategoryProtocolMethod2 called' +
            'constructor initBaseCategoryProtocolMethod2Optional called' +
            'js initBaseCategoryProtocolMethod2Optional called' +
            'constructor initBaseCategoryMethod called' +
            'js initBaseCategoryMethod called' +
            'constructor initDerivedProtocolMethod1 called' +
            'js initDerivedProtocolMethod1 called' +
            'constructor initDerivedProtocolMethod1Optional called' +
            'js initDerivedProtocolMethod1Optional called' +
            'constructor initDerivedProtocolMethod2 called' +
            'js initDerivedProtocolMethod2 called' +
            'constructor initDerivedProtocolMethod2Optional called' +
            'js initDerivedProtocolMethod2Optional called' +
            'constructor initDerivedMethod called' +
            'js initDerivedMethod called' +
            'constructor initDerivedCategoryProtocolMethod1 called' +
            'js initDerivedCategoryProtocolMethod1 called' +
            'constructor initDerivedCategoryProtocolMethod1Optional called' +
            'js initDerivedCategoryProtocolMethod1Optional called' +
            'constructor initDerivedCategoryProtocolMethod2 called' +
            'js initDerivedCategoryProtocolMethod2 called' +
            'constructor initDerivedCategoryProtocolMethod2Optional called' +
            'js initDerivedCategoryProtocolMethod2Optional called' +
            'constructor initDerivedCategoryMethod called' +
            'js initDerivedCategoryMethod called';

        JSDerivedInterface.alloc().initBaseProtocolMethod1();
        JSDerivedInterface.alloc().initBaseProtocolMethod1Optional();
        JSDerivedInterface.alloc().initBaseProtocolMethod2();
        JSDerivedInterface.alloc().initBaseProtocolMethod2Optional();
        JSDerivedInterface.alloc().initBaseMethod();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod1();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod1Optional();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod2();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod2Optional();
        JSDerivedInterface.alloc().initBaseCategoryMethod();
        JSDerivedInterface.alloc().initDerivedProtocolMethod1();
        JSDerivedInterface.alloc().initDerivedProtocolMethod1Optional();
        JSDerivedInterface.alloc().initDerivedProtocolMethod2();
        JSDerivedInterface.alloc().initDerivedProtocolMethod2Optional();
        JSDerivedInterface.alloc().initDerivedMethod();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1Optional();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2Optional();
        JSDerivedInterface.alloc().initDerivedCategoryMethod();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritanceConstructorCalls(JSDerivedInterface);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    // This appears to crash the test runner
    it('ConstructorOverrides: super', function () {

        var JSDerivedInterface = TNSDerivedInterface.extend({

            initBaseProtocolMethod1: function () {
                this.super.initBaseProtocolMethod1();
                TNSLog('js initBaseProtocolMethod1 called');
                return this;
            },
            initBaseProtocolMethod1Optional: function () {
                this.super.initBaseProtocolMethod1Optional();
                TNSLog('js initBaseProtocolMethod1Optional called');
                return this;
            },
            initBaseProtocolMethod2: function () {
                this.super.initBaseProtocolMethod2();
                TNSLog('js initBaseProtocolMethod2 called');
                return this;
            },
            initBaseProtocolMethod2Optional: function () {
                this.super.initBaseProtocolMethod2Optional();
                TNSLog('js initBaseProtocolMethod2Optional called');
                return this;
            },
            initBaseMethod: function () {
                this.super.initBaseMethod();
                TNSLog('js initBaseMethod called');
                return this;
            },
            initBaseCategoryProtocolMethod1: function () {
                this.super.initBaseCategoryProtocolMethod1();
                TNSLog('js initBaseCategoryProtocolMethod1 called');
                return this;
            },
            initBaseCategoryProtocolMethod1Optional: function () {
                this.super.initBaseCategoryProtocolMethod1Optional();
                TNSLog('js initBaseCategoryProtocolMethod1Optional called');
                return this;
            },
            initBaseCategoryProtocolMethod2: function () {
                this.super.initBaseCategoryProtocolMethod2();
                TNSLog('js initBaseCategoryProtocolMethod2 called');
                return this;
            },
            initBaseCategoryProtocolMethod2Optional: function () {
                this.super.initBaseCategoryProtocolMethod2Optional();
                TNSLog('js initBaseCategoryProtocolMethod2Optional called');
                return this;
            },
            initBaseCategoryMethod: function () {
                this.super.initBaseCategoryMethod();
                TNSLog('js initBaseCategoryMethod called');
                return this;
            },
            initDerivedProtocolMethod1: function () {
                this.super.initDerivedProtocolMethod1();
                TNSLog('js initDerivedProtocolMethod1 called');
                return this;
            },
            initDerivedProtocolMethod1Optional: function () {
                this.super.initDerivedProtocolMethod1Optional();
                TNSLog('js initDerivedProtocolMethod1Optional called');
                return this;
            },
            initDerivedProtocolMethod2: function () {
                this.super.initDerivedProtocolMethod2();
                TNSLog('js initDerivedProtocolMethod2 called');
                return this;
            },
            initDerivedProtocolMethod2Optional: function () {
                this.super.initDerivedProtocolMethod2Optional();
                TNSLog('js initDerivedProtocolMethod2Optional called');
                return this;
            },
            initDerivedMethod: function () {
                this.super.initDerivedMethod();
                TNSLog('js initDerivedMethod called');
                return this;
            },
            initDerivedCategoryProtocolMethod1: function () {
                this.super.initDerivedCategoryProtocolMethod1();
                TNSLog('js initDerivedCategoryProtocolMethod1 called');
                return this;
            },
            initDerivedCategoryProtocolMethod1Optional: function () {
                this.super.initDerivedCategoryProtocolMethod1Optional();
                TNSLog('js initDerivedCategoryProtocolMethod1Optional called');
                return this;
            },
            initDerivedCategoryProtocolMethod2: function () {
                this.super.initDerivedCategoryProtocolMethod2();
                TNSLog('js initDerivedCategoryProtocolMethod2 called');
                return this;
            },
            initDerivedCategoryProtocolMethod2Optional: function () {
                this.super.initDerivedCategoryProtocolMethod2Optional();
                TNSLog('js initDerivedCategoryProtocolMethod2Optional called');
                return this;
            },
            initDerivedCategoryMethod: function () {
                this.super.initDerivedCategoryMethod();
                TNSLog('js initDerivedCategoryMethod called');
                return this;
            },
        }, {
            name: 'JSDerivedInterface_Super'
        });

        var actual;
        var expected =
            'constructor initBaseProtocolMethod1 called' +
            'js initBaseProtocolMethod1 called' +
            'constructor initBaseProtocolMethod1Optional called' +
            'js initBaseProtocolMethod1Optional called' +
            'constructor initBaseProtocolMethod2 called' +
            'js initBaseProtocolMethod2 called' +
            'constructor initBaseProtocolMethod2Optional called' +
            'js initBaseProtocolMethod2Optional called' +
            'constructor initBaseMethod called' +
            'js initBaseMethod called' +
            'constructor initBaseCategoryProtocolMethod1 called' +
            'js initBaseCategoryProtocolMethod1 called' +
            'constructor initBaseCategoryProtocolMethod1Optional called' +
            'js initBaseCategoryProtocolMethod1Optional called' +
            'constructor initBaseCategoryProtocolMethod2 called' +
            'js initBaseCategoryProtocolMethod2 called' +
            'constructor initBaseCategoryProtocolMethod2Optional called' +
            'js initBaseCategoryProtocolMethod2Optional called' +
            'constructor initBaseCategoryMethod called' +
            'js initBaseCategoryMethod called' +
            'constructor initDerivedProtocolMethod1 called' +
            'js initDerivedProtocolMethod1 called' +
            'constructor initDerivedProtocolMethod1Optional called' +
            'js initDerivedProtocolMethod1Optional called' +
            'constructor initDerivedProtocolMethod2 called' +
            'js initDerivedProtocolMethod2 called' +
            'constructor initDerivedProtocolMethod2Optional called' +
            'js initDerivedProtocolMethod2Optional called' +
            'constructor initDerivedMethod called' +
            'js initDerivedMethod called' +
            'constructor initDerivedCategoryProtocolMethod1 called' +
            'js initDerivedCategoryProtocolMethod1 called' +
            'constructor initDerivedCategoryProtocolMethod1Optional called' +
            'js initDerivedCategoryProtocolMethod1Optional called' +
            'constructor initDerivedCategoryProtocolMethod2 called' +
            'js initDerivedCategoryProtocolMethod2 called' +
            'constructor initDerivedCategoryProtocolMethod2Optional called' +
            'js initDerivedCategoryProtocolMethod2Optional called' +
            'constructor initDerivedCategoryMethod called' +
            'js initDerivedCategoryMethod called';


        JSDerivedInterface.alloc().initBaseProtocolMethod1();
        JSDerivedInterface.alloc().initBaseProtocolMethod1Optional();
        JSDerivedInterface.alloc().initBaseProtocolMethod2();
        JSDerivedInterface.alloc().initBaseProtocolMethod2Optional();
        JSDerivedInterface.alloc().initBaseMethod();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod1();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod1Optional();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod2();
        JSDerivedInterface.alloc().initBaseCategoryProtocolMethod2Optional();
        JSDerivedInterface.alloc().initBaseCategoryMethod();
        JSDerivedInterface.alloc().initDerivedProtocolMethod1();
        JSDerivedInterface.alloc().initDerivedProtocolMethod1Optional();
        JSDerivedInterface.alloc().initDerivedProtocolMethod2();
        JSDerivedInterface.alloc().initDerivedProtocolMethod2Optional();
        JSDerivedInterface.alloc().initDerivedMethod();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1Optional();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2();
        JSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2Optional();
        JSDerivedInterface.alloc().initDerivedCategoryMethod();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritanceConstructorCalls(JSDerivedInterface);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);

        TNSClearOutput();
    });

    it('PropertyOverrides: prototype', function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({
            get baseProtocolProperty1() {
                TNSLog('js baseProtocolProperty1 called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty1').get.call(this);
            },
            set baseProtocolProperty1(x) {
                TNSLog('js setBaseProtocolProperty1 called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty1').set.apply(this, arguments);
            },
            get baseProtocolProperty1Optional() {
                TNSLog('js baseProtocolProperty1Optional called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty1Optional').get.call(this);
            },
            set baseProtocolProperty1Optional(x) {
                TNSLog('js setBaseProtocolProperty1Optional called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty1Optional').set.apply(this, arguments);
            },
            get baseProtocolProperty2() {
                TNSLog('js baseProtocolProperty2 called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty2').get.call(this);
            },
            set baseProtocolProperty2(x) {
                TNSLog('js setBaseProtocolProperty2 called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty2').set.apply(this, arguments);
            },
            get baseProtocolProperty2Optional() {
                TNSLog('js baseProtocolProperty2Optional called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty2Optional').get.call(this);
            },
            set baseProtocolProperty2Optional(x) {
                TNSLog('js setBaseProtocolProperty2Optional called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProtocolProperty2Optional').set.apply(this, arguments);
            },
            get baseProperty() {
                TNSLog('js baseProperty called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProperty').get.call(this);
            },
            set baseProperty(x) {
                TNSLog('js setBaseProperty called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProperty').set.apply(this, arguments);
            },
            get baseCategoryProtocolProperty1() {
                TNSLog('js baseCategoryProtocolProperty1 called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty1').get.call(this);
            },
            set baseCategoryProtocolProperty1(x) {
                TNSLog('js setBaseCategoryProtocolProperty1 called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty1').set.apply(this, arguments);
            },
            get baseCategoryProtocolProperty1Optional() {
                TNSLog('js baseCategoryProtocolProperty1Optional called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty1Optional').get.call(this);
            },
            set baseCategoryProtocolProperty1Optional(x) {
                TNSLog('js setBaseCategoryProtocolProperty1Optional called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty1Optional').set.apply(this, arguments);
            },
            get baseCategoryProtocolProperty2() {
                TNSLog('js baseCategoryProtocolProperty2 called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty2').get.call(this);
            },
            set baseCategoryProtocolProperty2(x) {
                TNSLog('js setBaseCategoryProtocolProperty2 called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty2').set.apply(this, arguments);
            },
            get baseCategoryProtocolProperty2Optional() {
                TNSLog('js baseCategoryProtocolProperty2Optional called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty2Optional').get.call(this);
            },
            set baseCategoryProtocolProperty2Optional(x) {
                TNSLog('js setBaseCategoryProtocolProperty2Optional called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProtocolProperty2Optional').set.apply(this, arguments);
            },
            get baseCategoryProperty() {
                TNSLog('js baseCategoryProperty called');
                return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProperty').get.call(this);
            },
            set baseCategoryProperty(x) {
                TNSLog('js setBaseCategoryProperty called');
                Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseCategoryProperty').set.apply(this, arguments);
            },
            get derivedProtocolProperty1() {
                TNSLog('js derivedProtocolProperty1 called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty1').get.call(this);
            },
            set derivedProtocolProperty1(x) {
                TNSLog('js setDerivedProtocolProperty1 called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty1').set.apply(this, arguments);
            },
            get derivedProtocolProperty1Optional() {
                TNSLog('js derivedProtocolProperty1Optional called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty1Optional').get.call(this);
            },
            set derivedProtocolProperty1Optional(x) {
                TNSLog('js setDerivedProtocolProperty1Optional called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty1Optional').set.apply(this, arguments);
            },
            get derivedProtocolProperty2() {
                TNSLog('js derivedProtocolProperty2 called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty2').get.call(this);
            },
            set derivedProtocolProperty2(x) {
                TNSLog('js setDerivedProtocolProperty2 called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty2').set.apply(this, arguments);
            },
            get derivedProtocolProperty2Optional() {
                TNSLog('js derivedProtocolProperty2Optional called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty2Optional').get.call(this);
            },
            set derivedProtocolProperty2Optional(x) {
                TNSLog('js setDerivedProtocolProperty2Optional called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProtocolProperty2Optional').set.apply(this, arguments);
            },
            get derivedProperty() {
                TNSLog('js derivedProperty called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProperty').get.call(this);
            },
            set derivedProperty(x) {
                TNSLog('js setDerivedProperty called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProperty').set.apply(this, arguments);
            },
            get derivedCategoryProtocolProperty1() {
                TNSLog('js derivedCategoryProtocolProperty1 called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty1').get.call(this);
            },
            set derivedCategoryProtocolProperty1(x) {
                TNSLog('js setDerivedCategoryProtocolProperty1 called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty1').set.apply(this, arguments);
            },
            get derivedCategoryProtocolProperty1Optional() {
                TNSLog('js derivedCategoryProtocolProperty1Optional called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty1Optional').get.call(this);
            },
            set derivedCategoryProtocolProperty1Optional(x) {
                TNSLog('js setDerivedCategoryProtocolProperty1Optional called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty1Optional').set.apply(this, arguments);
            },
            get derivedCategoryProtocolProperty2() {
                TNSLog('js derivedCategoryProtocolProperty2 called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty2').get.call(this);
            },
            set derivedCategoryProtocolProperty2(x) {
                TNSLog('js setDerivedCategoryProtocolProperty2 called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty2').set.apply(this, arguments);
            },
            get derivedCategoryProtocolProperty2Optional() {
                TNSLog('js derivedCategoryProtocolProperty2Optional called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty2Optional').get.call(this);
            },
            set derivedCategoryProtocolProperty2Optional(x) {
                TNSLog('js setDerivedCategoryProtocolProperty2Optional called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProtocolProperty2Optional').set.apply(this, arguments);
            },
            get derivedCategoryProperty() {
                TNSLog('js derivedCategoryProperty called');
                return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProperty').get.call(this);
            },
            set derivedCategoryProperty(x) {
                TNSLog('js setDerivedCategoryProperty called');
                Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedCategoryProperty').set.apply(this, arguments);
            },
        });

        var actual;
        var expected =
            'js setBaseProtocolProperty1 called' +
            'instance setBaseProtocolProperty1: called' +
            'js baseProtocolProperty1 called' +
            'instance baseProtocolProperty1 called' +
            'js setBaseProtocolProperty1Optional called' +
            'instance setBaseProtocolProperty1Optional: called' +
            'js baseProtocolProperty1Optional called' +
            'instance baseProtocolProperty1Optional called' +
            'js setBaseProtocolProperty2 called' +
            'instance setBaseProtocolProperty2: called' +
            'js baseProtocolProperty2 called' +
            'instance baseProtocolProperty2 called' +
            'js setBaseProtocolProperty2Optional called' +
            'instance setBaseProtocolProperty2Optional: called' +
            'js baseProtocolProperty2Optional called' +
            'instance baseProtocolProperty2Optional called' +
            'js setBaseProperty called' +
            'instance setBaseProperty: called' +
            'js baseProperty called' +
            'instance baseProperty called' +
            'js setBaseCategoryProtocolProperty1 called' +
            'instance setBaseCategoryProtocolProperty1: called' +
            'js baseCategoryProtocolProperty1 called' +
            'instance baseCategoryProtocolProperty1 called' +
            'js setBaseCategoryProtocolProperty1Optional called' +
            'instance setBaseCategoryProtocolProperty1Optional: called' +
            'js baseCategoryProtocolProperty1Optional called' +
            'instance baseCategoryProtocolProperty1Optional called' +
            'js setBaseCategoryProtocolProperty2 called' +
            'instance setBaseCategoryProtocolProperty2: called' +
            'js baseCategoryProtocolProperty2 called' +
            'instance baseCategoryProtocolProperty2 called' +
            'js setBaseCategoryProtocolProperty2Optional called' +
            'instance setBaseCategoryProtocolProperty2Optional: called' +
            'js baseCategoryProtocolProperty2Optional called' +
            'instance baseCategoryProtocolProperty2Optional called' +
            'js setBaseCategoryProperty called' +
            'instance setBaseCategoryProperty: called' +
            'js baseCategoryProperty called' +
            'instance baseCategoryProperty called' +
            'js setDerivedProtocolProperty1 called' +
            'instance setDerivedProtocolProperty1: called' +
            'js derivedProtocolProperty1 called' +
            'instance derivedProtocolProperty1 called' +
            'js setDerivedProtocolProperty1Optional called' +
            'instance setDerivedProtocolProperty1Optional: called' +
            'js derivedProtocolProperty1Optional called' +
            'instance derivedProtocolProperty1Optional called' +
            'js setDerivedProtocolProperty2 called' +
            'instance setDerivedProtocolProperty2: called' +
            'js derivedProtocolProperty2 called' +
            'instance derivedProtocolProperty2 called' +
            'js setDerivedProtocolProperty2Optional called' +
            'instance setDerivedProtocolProperty2Optional: called' +
            'js derivedProtocolProperty2Optional called' +
            'instance derivedProtocolProperty2Optional called' +
            'js setDerivedProperty called' +
            'instance setDerivedProperty: called' +
            'js derivedProperty called' +
            'instance derivedProperty called' +
            'js setDerivedCategoryProtocolProperty1 called' +
            'instance setDerivedCategoryProtocolProperty1: called' +
            'js derivedCategoryProtocolProperty1 called' +
            'instance derivedCategoryProtocolProperty1 called' +
            'js setDerivedCategoryProtocolProperty1Optional called' +
            'instance setDerivedCategoryProtocolProperty1Optional: called' +
            'js derivedCategoryProtocolProperty1Optional called' +
            'instance derivedCategoryProtocolProperty1Optional called' +
            'js setDerivedCategoryProtocolProperty2 called' +
            'instance setDerivedCategoryProtocolProperty2: called' +
            'js derivedCategoryProtocolProperty2 called' +
            'instance derivedCategoryProtocolProperty2 called' +
            'js setDerivedCategoryProtocolProperty2Optional called' +
            'instance setDerivedCategoryProtocolProperty2Optional: called' +
            'js derivedCategoryProtocolProperty2Optional called' +
            'instance derivedCategoryProtocolProperty2Optional called' +
            'js setDerivedCategoryProperty called' +
            'instance setDerivedCategoryProperty: called' +
            'js derivedCategoryProperty called' +
            'instance derivedCategoryProperty called';

        var object = JSDerivedInterface.alloc().init();
        object.baseProtocolProperty1 = 0;
        UNUSED(object.baseProtocolProperty1);
        object.baseProtocolProperty1Optional = 0;
        UNUSED(object.baseProtocolProperty1Optional);
        object.baseProtocolProperty2 = 0;
        UNUSED(object.baseProtocolProperty2);
        object.baseProtocolProperty2Optional = 0;
        UNUSED(object.baseProtocolProperty2Optional);
        object.baseProperty = 0;
        UNUSED(object.baseProperty);
        object.baseCategoryProtocolProperty1 = 0;
        UNUSED(object.baseCategoryProtocolProperty1);
        object.baseCategoryProtocolProperty1Optional = 0;
        UNUSED(object.baseCategoryProtocolProperty1Optional);
        object.baseCategoryProtocolProperty2 = 0;
        UNUSED(object.baseCategoryProtocolProperty2);
        object.baseCategoryProtocolProperty2Optional = 0;
        UNUSED(object.baseCategoryProtocolProperty2Optional);
        object.baseCategoryProperty = 0;
        UNUSED(object.baseCategoryProperty);
        object.derivedProtocolProperty1 = 0;
        UNUSED(object.derivedProtocolProperty1);
        object.derivedProtocolProperty1Optional = 0;
        UNUSED(object.derivedProtocolProperty1Optional);
        object.derivedProtocolProperty2 = 0;
        UNUSED(object.derivedProtocolProperty2);
        object.derivedProtocolProperty2Optional = 0;
        UNUSED(object.derivedProtocolProperty2Optional);
        object.derivedProperty = 0;
        UNUSED(object.derivedProperty);
        object.derivedCategoryProtocolProperty1 = 0;
        UNUSED(object.derivedCategoryProtocolProperty1);
        object.derivedCategoryProtocolProperty1Optional = 0;
        UNUSED(object.derivedCategoryProtocolProperty1Optional);
        object.derivedCategoryProtocolProperty2 = 0;
        UNUSED(object.derivedCategoryProtocolProperty2);
        object.derivedCategoryProtocolProperty2Optional = 0;
        UNUSED(object.derivedCategoryProtocolProperty2Optional);
        object.derivedCategoryProperty = 0;
        UNUSED(object.derivedCategoryProperty);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritancePropertyCalls(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('PropertyOverrides: super', function () {
        var JSDerivedInterface = TNSDerivedInterface.extend({

            get baseProtocolProperty1() {
                TNSLog('js baseProtocolProperty1 called');
                return this.super.baseProtocolProperty1;
            },
            set baseProtocolProperty1(x) {
                TNSLog('js setBaseProtocolProperty1 called');
                this.super.baseProtocolProperty1 = x;
            },
            get baseProtocolProperty1Optional() {
                TNSLog('js baseProtocolProperty1Optional called');
                return this.super.baseProtocolProperty1Optional;
            },
            set baseProtocolProperty1Optional(x) {
                TNSLog('js setBaseProtocolProperty1Optional called');
                this.super.baseProtocolProperty1Optional = x;
            },
            get baseProtocolProperty2() {
                TNSLog('js baseProtocolProperty2 called');
                return this.super.baseProtocolProperty2;
            },
            set baseProtocolProperty2(x) {
                TNSLog('js setBaseProtocolProperty2 called');
                this.super.baseProtocolProperty2 = x;
            },
            get baseProtocolProperty2Optional() {
                TNSLog('js baseProtocolProperty2Optional called');
                return this.super.baseProtocolProperty2Optional;
            },
            set baseProtocolProperty2Optional(x) {
                TNSLog('js setBaseProtocolProperty2Optional called');
                this.super.baseProtocolProperty2Optional = x;
            },
            get baseProperty() {
                TNSLog('js baseProperty called');
                return this.super.baseProperty;
            },
            set baseProperty(x) {
                TNSLog('js setBaseProperty called');
                this.super.baseProperty = x;
            },
            get baseCategoryProtocolProperty1() {
                TNSLog('js baseCategoryProtocolProperty1 called');
                return this.super.baseCategoryProtocolProperty1;
            },
            set baseCategoryProtocolProperty1(x) {
                TNSLog('js setBaseCategoryProtocolProperty1 called');
                this.super.baseCategoryProtocolProperty1 = x;
            },
            get baseCategoryProtocolProperty1Optional() {
                TNSLog('js baseCategoryProtocolProperty1Optional called');
                return this.super.baseCategoryProtocolProperty1Optional;
            },
            set baseCategoryProtocolProperty1Optional(x) {
                TNSLog('js setBaseCategoryProtocolProperty1Optional called');
                this.super.baseCategoryProtocolProperty1Optional = x;
            },
            get baseCategoryProtocolProperty2() {
                TNSLog('js baseCategoryProtocolProperty2 called');
                return this.super.baseCategoryProtocolProperty2;
            },
            set baseCategoryProtocolProperty2(x) {
                TNSLog('js setBaseCategoryProtocolProperty2 called');
                this.super.baseCategoryProtocolProperty2 = x;
            },
            get baseCategoryProtocolProperty2Optional() {
                TNSLog('js baseCategoryProtocolProperty2Optional called');
                return this.super.baseCategoryProtocolProperty2Optional;
            },
            set baseCategoryProtocolProperty2Optional(x) {
                TNSLog('js setBaseCategoryProtocolProperty2Optional called');
                this.super.baseCategoryProtocolProperty2Optional = x;
            },
            get baseCategoryProperty() {
                TNSLog('js baseCategoryProperty called');
                return this.super.baseCategoryProperty;
            },
            set baseCategoryProperty(x) {
                TNSLog('js setBaseCategoryProperty called');
                this.super.baseCategoryProperty = x;
            },
            get derivedProtocolProperty1() {
                TNSLog('js derivedProtocolProperty1 called');
                return this.super.derivedProtocolProperty1;
            },
            set derivedProtocolProperty1(x) {
                TNSLog('js setDerivedProtocolProperty1 called');
                this.super.derivedProtocolProperty1 = x;
            },
            get derivedProtocolProperty1Optional() {
                TNSLog('js derivedProtocolProperty1Optional called');
                return this.super.derivedProtocolProperty1Optional;
            },
            set derivedProtocolProperty1Optional(x) {
                TNSLog('js setDerivedProtocolProperty1Optional called');
                this.super.derivedProtocolProperty1Optional = x;
            },
            get derivedProtocolProperty2() {
                TNSLog('js derivedProtocolProperty2 called');
                return this.super.derivedProtocolProperty2;
            },
            set derivedProtocolProperty2(x) {
                TNSLog('js setDerivedProtocolProperty2 called');
                this.super.derivedProtocolProperty2 = x;
            },
            get derivedProtocolProperty2Optional() {
                TNSLog('js derivedProtocolProperty2Optional called');
                return this.super.derivedProtocolProperty2Optional;
            },
            set derivedProtocolProperty2Optional(x) {
                TNSLog('js setDerivedProtocolProperty2Optional called');
                this.super.derivedProtocolProperty2Optional = x;
            },
            get derivedProperty() {
                TNSLog('js derivedProperty called');
                return this.super.derivedProperty;
            },
            set derivedProperty(x) {
                TNSLog('js setDerivedProperty called');
                this.super.derivedProperty = x;
            },
            get derivedCategoryProtocolProperty1() {
                TNSLog('js derivedCategoryProtocolProperty1 called');
                return this.super.derivedCategoryProtocolProperty1;
            },
            set derivedCategoryProtocolProperty1(x) {
                TNSLog('js setDerivedCategoryProtocolProperty1 called');
                this.super.derivedCategoryProtocolProperty1 = x;
            },
            get derivedCategoryProtocolProperty1Optional() {
                TNSLog('js derivedCategoryProtocolProperty1Optional called');
                return this.super.derivedCategoryProtocolProperty1Optional;
            },
            set derivedCategoryProtocolProperty1Optional(x) {
                TNSLog('js setDerivedCategoryProtocolProperty1Optional called');
                this.super.derivedCategoryProtocolProperty1Optional = x;
            },
            get derivedCategoryProtocolProperty2() {
                TNSLog('js derivedCategoryProtocolProperty2 called');
                return this.super.derivedCategoryProtocolProperty2;
            },
            set derivedCategoryProtocolProperty2(x) {
                TNSLog('js setDerivedCategoryProtocolProperty2 called');
                this.super.derivedCategoryProtocolProperty2 = x;
            },
            get derivedCategoryProtocolProperty2Optional() {
                TNSLog('js derivedCategoryProtocolProperty2Optional called');
                return this.super.derivedCategoryProtocolProperty2Optional;
            },
            set derivedCategoryProtocolProperty2Optional(x) {
                TNSLog('js setDerivedCategoryProtocolProperty2Optional called');
                this.super.derivedCategoryProtocolProperty2Optional = x;
            },
            get derivedCategoryProperty() {
                TNSLog('js derivedCategoryProperty called');
                return this.super.derivedCategoryProperty;
            },
            set derivedCategoryProperty(x) {
                TNSLog('js setDerivedCategoryProperty called');
                this.super.derivedCategoryProperty = x;
            },

        });

        var actual;
        var expected =
            'js setBaseProtocolProperty1 called' +
            'instance setBaseProtocolProperty1: called' +
            'js baseProtocolProperty1 called' +
            'instance baseProtocolProperty1 called' +
            'js setBaseProtocolProperty1Optional called' +
            'instance setBaseProtocolProperty1Optional: called' +
            'js baseProtocolProperty1Optional called' +
            'instance baseProtocolProperty1Optional called' +
            'js setBaseProtocolProperty2 called' +
            'instance setBaseProtocolProperty2: called' +
            'js baseProtocolProperty2 called' +
            'instance baseProtocolProperty2 called' +
            'js setBaseProtocolProperty2Optional called' +
            'instance setBaseProtocolProperty2Optional: called' +
            'js baseProtocolProperty2Optional called' +
            'instance baseProtocolProperty2Optional called' +
            'js setBaseProperty called' +
            'instance setBaseProperty: called' +
            'js baseProperty called' +
            'instance baseProperty called' +
            'js setBaseCategoryProtocolProperty1 called' +
            'instance setBaseCategoryProtocolProperty1: called' +
            'js baseCategoryProtocolProperty1 called' +
            'instance baseCategoryProtocolProperty1 called' +
            'js setBaseCategoryProtocolProperty1Optional called' +
            'instance setBaseCategoryProtocolProperty1Optional: called' +
            'js baseCategoryProtocolProperty1Optional called' +
            'instance baseCategoryProtocolProperty1Optional called' +
            'js setBaseCategoryProtocolProperty2 called' +
            'instance setBaseCategoryProtocolProperty2: called' +
            'js baseCategoryProtocolProperty2 called' +
            'instance baseCategoryProtocolProperty2 called' +
            'js setBaseCategoryProtocolProperty2Optional called' +
            'instance setBaseCategoryProtocolProperty2Optional: called' +
            'js baseCategoryProtocolProperty2Optional called' +
            'instance baseCategoryProtocolProperty2Optional called' +
            'js setBaseCategoryProperty called' +
            'instance setBaseCategoryProperty: called' +
            'js baseCategoryProperty called' +
            'instance baseCategoryProperty called' +
            'js setDerivedProtocolProperty1 called' +
            'instance setDerivedProtocolProperty1: called' +
            'js derivedProtocolProperty1 called' +
            'instance derivedProtocolProperty1 called' +
            'js setDerivedProtocolProperty1Optional called' +
            'instance setDerivedProtocolProperty1Optional: called' +
            'js derivedProtocolProperty1Optional called' +
            'instance derivedProtocolProperty1Optional called' +
            'js setDerivedProtocolProperty2 called' +
            'instance setDerivedProtocolProperty2: called' +
            'js derivedProtocolProperty2 called' +
            'instance derivedProtocolProperty2 called' +
            'js setDerivedProtocolProperty2Optional called' +
            'instance setDerivedProtocolProperty2Optional: called' +
            'js derivedProtocolProperty2Optional called' +
            'instance derivedProtocolProperty2Optional called' +
            'js setDerivedProperty called' +
            'instance setDerivedProperty: called' +
            'js derivedProperty called' +
            'instance derivedProperty called' +
            'js setDerivedCategoryProtocolProperty1 called' +
            'instance setDerivedCategoryProtocolProperty1: called' +
            'js derivedCategoryProtocolProperty1 called' +
            'instance derivedCategoryProtocolProperty1 called' +
            'js setDerivedCategoryProtocolProperty1Optional called' +
            'instance setDerivedCategoryProtocolProperty1Optional: called' +
            'js derivedCategoryProtocolProperty1Optional called' +
            'instance derivedCategoryProtocolProperty1Optional called' +
            'js setDerivedCategoryProtocolProperty2 called' +
            'instance setDerivedCategoryProtocolProperty2: called' +
            'js derivedCategoryProtocolProperty2 called' +
            'instance derivedCategoryProtocolProperty2 called' +
            'js setDerivedCategoryProtocolProperty2Optional called' +
            'instance setDerivedCategoryProtocolProperty2Optional: called' +
            'js derivedCategoryProtocolProperty2Optional called' +
            'instance derivedCategoryProtocolProperty2Optional called' +
            'js setDerivedCategoryProperty called' +
            'instance setDerivedCategoryProperty: called' +
            'js derivedCategoryProperty called' +
            'instance derivedCategoryProperty called';

        var object = JSDerivedInterface.alloc().init();
        object.baseProtocolProperty1 = 0;
        UNUSED(object.baseProtocolProperty1);
        object.baseProtocolProperty1Optional = 0;
        UNUSED(object.baseProtocolProperty1Optional);
        object.baseProtocolProperty2 = 0;
        UNUSED(object.baseProtocolProperty2);
        object.baseProtocolProperty2Optional = 0;
        UNUSED(object.baseProtocolProperty2Optional);
        object.baseProperty = 0;
        UNUSED(object.baseProperty);
        object.baseCategoryProtocolProperty1 = 0;
        UNUSED(object.baseCategoryProtocolProperty1);
        object.baseCategoryProtocolProperty1Optional = 0;
        UNUSED(object.baseCategoryProtocolProperty1Optional);
        object.baseCategoryProtocolProperty2 = 0;
        UNUSED(object.baseCategoryProtocolProperty2);
        object.baseCategoryProtocolProperty2Optional = 0;
        UNUSED(object.baseCategoryProtocolProperty2Optional);
        object.baseCategoryProperty = 0;
        UNUSED(object.baseCategoryProperty);
        object.derivedProtocolProperty1 = 0;
        UNUSED(object.derivedProtocolProperty1);
        object.derivedProtocolProperty1Optional = 0;
        UNUSED(object.derivedProtocolProperty1Optional);
        object.derivedProtocolProperty2 = 0;
        UNUSED(object.derivedProtocolProperty2);
        object.derivedProtocolProperty2Optional = 0;
        UNUSED(object.derivedProtocolProperty2Optional);
        object.derivedProperty = 0;
        UNUSED(object.derivedProperty);
        object.derivedCategoryProtocolProperty1 = 0;
        UNUSED(object.derivedCategoryProtocolProperty1);
        object.derivedCategoryProtocolProperty1Optional = 0;
        UNUSED(object.derivedCategoryProtocolProperty1Optional);
        object.derivedCategoryProtocolProperty2 = 0;
        UNUSED(object.derivedCategoryProtocolProperty2);
        object.derivedCategoryProtocolProperty2Optional = 0;
        UNUSED(object.derivedCategoryProtocolProperty2Optional);
        object.derivedCategoryProperty = 0;
        UNUSED(object.derivedCategoryProperty);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritancePropertyCalls(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('ConstructorOverrideAndVirtualCall: prototype', function () {
        var JSObject = TNSIConstructorVirtualCalls.extend({
            initWithXAndY: function initWithXAndY(x, y) {
                var self = TNSIConstructorVirtualCalls.prototype.initWithXAndY.apply(this, arguments);
                TNSLog('js initWithX:' + x + 'andY:' + y + ' called');
                TNSLog('virtual: ' + self.description);
                return self;
            },
            get description() {
                return 'virtual: ' + Object.getOwnPropertyDescriptor(NSObject.prototype, 'description').get.call(this);
            }
        });

        var expected = "constructor initWithX:3andY:4 calledjs initWithX:3andY:4 calledvirtual: virtual: x: 3; y: 4virtual: x: 3; y: 4";
        var actual;

        (function () {
            var object = new JSObject(3, 4);
            TNSLog(object.description);
        }());
        actual = TNSGetOutput();
        expect(actual).toBe(expected);

        TNSClearOutput();

        (function () {
            var object = JSObject.alloc().initWithXAndY(3, 4);
            TNSLog(object.description);
        }());
        actual = TNSGetOutput();
        expect(actual).toBe(expected);
    });

    it('ConstructorOverrideAndVirtualCall: super', function () {
        var JSObject = TNSIConstructorVirtualCalls.extend({
            initWithXAndY: function initWithXAndY(x, y) {
                var self = this.super.initWithXAndY(x, y);
                TNSLog('js initWithX:' + x + 'andY:' + y + ' called');
                TNSLog('virtual: ' + self.description);
                return self;
            },
            get description() {
                return 'virtual: ' + this.super.description;
            }
        });

        var expected = "constructor initWithX:3andY:4 calledjs initWithX:3andY:4 calledvirtual: virtual: x: 3; y: 4virtual: x: 3; y: 4";
        var actual;

        (function () {
            var object = new JSObject(3, 4);
            TNSLog(object.description);
        }());
        actual = TNSGetOutput();
        expect(actual).toBe(expected);

        TNSClearOutput();

        (function () {
            var object = JSObject.alloc().initWithXAndY(3, 4);
            TNSLog(object.description);
        }());
        actual = TNSGetOutput();
        expect(actual).toBe(expected);
    });

    it('NativeName', function () {
        var JSObject = NSObject.extend({}, {
            name: 'JSObject'
        });
        var object = new JSObject();
        expect(object.isMemberOfClass(NSClassFromString('JSObject'))).toBe(true);
    });

    it('ExposeVoidSelector', function () {
        var JSObject = NSObject.extend({
            voidSelector: function () {
                TNSLog('voidSelector called');
            }
        }, {
            exposedMethods: {
                voidSelector: {returns: interop.types.void}
            }
        });
        var object = new JSObject();

        var actual;
        var expected = 'voidSelector called';

        object.voidSelector();

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritanceVoidSelector(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('ExposeVariadicSelector', function () {
        var JSObject = NSObject.extend({
            "variadicSelector:x:": function (a, b) {
                TNSLog('variadicSelector:' + a + ' x:' + b + ' called');
                return this;
            }
        }, {
            exposedMethods: {
                'variadicSelector:x:': {returns: NSObject, params: [NSString, interop.types.int32]}
            }
        });
        var object = new JSObject();

        expect(object['variadicSelector:x:']('js', 8)).toBe(object);

        expect(TNSGetOutput()).toBe('variadicSelector:js x:8 called');
        TNSClearOutput();

        expect(TNSTestNativeCallbacks.inheritanceVariadicSelector(object)).toBe(object);

        expect(TNSGetOutput()).toBe('variadicSelector:native x:9 called');
        TNSClearOutput();
    });

    it("InheritanceWithSameOverrideObject", function () {
        var overrides = {
            myNewMethod: function () {
                return 'myNewMethodCalled';
            }
        };
        NSObject.extend(overrides);
        expect(function () {
            NSObject.extend(overrides);
        }).toThrowError();
    });

    it('ExposeWithoutImplementation', function () {
        NSObject.extend({}, {
            exposedMethods: {
                'nonExistingSelector': {returns: interop.types.void, params: [interop.types.selector]}
            }
        });
    });

    it('ClassName', function () {
        var MyPrivateClass = NSObject.extend({}, {
            name: 'MyPrivateClassName'
        });
        expect(NSStringFromClass(MyPrivateClass)).toBe('MyPrivateClassName');

        var MyPrivateClass1 = NSObject.extend({}, {
            name: 'MyPrivateClassName'
        });
        expect(NSStringFromClass(MyPrivateClass1)).toBe('MyPrivateClassName1');
    });

    it('ExtendDerivedClass', function () {
        expect(function () {
            NSObject.extend({}).extend({});
        }).toThrowError();
    });

    it('OptionalProtocolMethodsAndCategories', function () {
        var object = TNSIDerivedInterface.extend({
            baseImplementedOptionalMethod: function () {
                TNSLog('js baseImplementedOptionalMethod called');
                TNSIDerivedInterface.prototype.baseImplementedOptionalMethod.apply(this, arguments);
            },
            baseNotImplementedOptionalMethodImplementedInJavaScript: function () {
                TNSLog('js baseNotImplementedOptionalMethodImplementedInJavaScript called');
            },
            baseImplementedCategoryMethod: function () {
                TNSLog('js baseImplementedCategoryMethod called');
                TNSIDerivedInterface.prototype.baseImplementedCategoryMethod.apply(this, arguments);
            },
            baseNotImplementedNativeCategoryMethodOverridenInJavaScript: function () {
                TNSLog('js baseNotImplementedNativeCategoryMethodOverridenInJavaScript called');
            },
            derivedImplementedOptionalMethod: function () {
                TNSLog('js derivedImplementedOptionalMethod called');
                TNSIDerivedInterface.prototype.derivedImplementedOptionalMethod.apply(this, arguments);
            },
            derivedNotImplementedOptionalMethodImplementedInJavaScript: function () {
                TNSLog('js derivedNotImplementedOptionalMethodImplementedInJavaScript called');
            },
            derivedImplementedCategoryMethod: function () {
                TNSLog('js derivedImplementedCategoryMethod called');
                TNSIDerivedInterface.prototype.derivedImplementedCategoryMethod.apply(this, arguments);
            },
            derivedNotImplementedNativeCategoryMethodOverridenInJavaScript: function () {
                TNSLog('js derivedNotImplementedNativeCategoryMethodOverridenInJavaScript called');
            }
        }).alloc().init();

        object.baseImplementedOptionalMethod();
        object.baseNotImplementedOptionalMethodImplementedInJavaScript();
        object.baseImplementedCategoryMethod();
        object.baseNotImplementedNativeCategoryMethodOverridenInJavaScript();
        object.derivedImplementedOptionalMethod();
        object.derivedNotImplementedOptionalMethodImplementedInJavaScript();
        object.derivedImplementedCategoryMethod();
        object.derivedNotImplementedNativeCategoryMethodOverridenInJavaScript();

        var actual;
        var expected =
            "js baseImplementedOptionalMethod called" +
            "baseImplementedOptionalMethod called" +
            "js baseNotImplementedOptionalMethodImplementedInJavaScript called" +
            "js baseImplementedCategoryMethod called" +
            "baseImplementedCategoryMethod called" +
            "js baseNotImplementedNativeCategoryMethodOverridenInJavaScript called" +
            "js derivedImplementedOptionalMethod called" +
            "derivedImplementedOptionalMethod called" +
            "js derivedNotImplementedOptionalMethodImplementedInJavaScript called" +
            "js derivedImplementedCategoryMethod called" +
            "derivedImplementedCategoryMethod called" +
            "js derivedNotImplementedNativeCategoryMethodOverridenInJavaScript called";

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();

        TNSTestNativeCallbacks.inheritanceOptionalProtocolMethodsAndCategories(object);

        actual = TNSGetOutput();
        expect(actual).toBe(expected);
        TNSClearOutput();
    });

    it('AddedNewProperty', function () {
        var MyObject = NSObject.extend({
            property: 1,
            method: function () {
                return this.property;
            }
        });
        var object = new MyObject();
        expect(object.method()).toBe(1);
    });

    it('CompilerEncodingOfOverridenMethod', function () {
        var MyObject = TNSBaseInterface.extend({
            baseMethod: function () {
                return this.super.baseMethod();
            }
        });
        var method = class_getInstanceMethod(MyObject.class(), "baseMethod");
        var encoding = method_getTypeEncoding(method);
        expect(NSString.stringWithCString(encoding).toString()).toBe("v@:");
    });

    it("should project Symbol.iterable as NSFastEnumeration", function() {
        var start = 1;
        var end = 10;
        var lastStep = 0;
        var IterableClass = NSObject.extend({
            [Symbol.iterator]() {
                return {
                    step: start,

                        next() {
                        if (this.step <= end) {
                            return { value : this.step++, done : false };
                        } else {
                            return { done : true };
                        }
                    }
                    ,

                        return () {
                        lastStep = this.step;
                        return {};
                    }
                }
            }
        });

        var expected = "12345678910";
        TNSIterableConsumer.consumeIterable(IterableClass.alloc().init());
        var actual = TNSGetOutput();

        expect(IterableClass.conformsToProtocol(NSFastEnumeration)).toBe(true);
        expect(actual).toEqual(expected);
        expect(lastStep).toEqual(end + 1);

        TNSClearOutput();
    });

    it("Method and property with the same name", function() {
        var JSObject = NSObject.extend({ get conflict() { return true; } },
                                       { protocols : [ TNSPropertyMethodConflictProtocol ] });

        var derived = JSObject.new();
        var result = TNSTestNativeCallbacks.protocolWithNameConflict(derived);

        expect(result).toBe(true);
    });
});
