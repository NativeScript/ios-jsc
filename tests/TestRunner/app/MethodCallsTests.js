describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it('Base_StaticBaseProtocolMethod1', function () {
        TNSBaseInterface.baseProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod1 called");
    });
    it('Base_StaticBaseProtocolMethod2', function () {
        TNSBaseInterface.baseProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod2 called");
    });
    it('Base_StaticBaseMethod', function () {
        TNSBaseInterface.baseMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseMethod called");
    });
    it('Base_OverloadedStaticBaseMethod', function () {
        TNSBaseInterface.baseMethod(1);

        var actual = TNSGetOutput();
       expect(actual).toBe("overloaded static baseMethod: called");
    });
    it('Base_StaticBaseCategoryProtocolMethod1', function () {
        TNSBaseInterface.baseCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod1 called");
    });
    it('Base_StaticBaseCategoryProtocolMethod2', function () {
        TNSBaseInterface.baseCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod2 called");
    });
    it('Base_StaticBaseCategoryMethod', function () {
        TNSBaseInterface.baseCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryMethod called");
    });


    it('Derived_StaticBaseProtocolMethod1', function () {
        TNSDerivedInterface.baseProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod1 called");
    });
    it('Derived_StaticBaseProtocolMethod2', function () {
        TNSDerivedInterface.baseProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod2 called");
    });
    it('Derived_StaticBaseMethod', function () {
        TNSDerivedInterface.baseMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseMethod called");
    });
    it('Derived_OverloadedStaticBaseMethod', function () {
        TNSDerivedInterface.baseMethod(1);

        var actual = TNSGetOutput();
       expect(actual).toBe("overloaded static baseMethod: called");
    });
    it('Derived_StaticBaseCategoryProtocolMethod1', function () {
        TNSDerivedInterface.baseCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod1 called");
    });
    it('Derived_StaticBaseCategoryProtocolMethod2', function () {
        TNSDerivedInterface.baseCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod2 called");
    });
    it('Derived_StaticBaseCategoryMethod', function () {
        TNSDerivedInterface.baseCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryMethod called");
    });
    it('Derived_StaticDerivedProtocolMethod1', function () {
        TNSDerivedInterface.derivedProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedProtocolMethod1 called");
    });
    it('Derived_StaticDerivedProtocolMethod2', function () {
        TNSDerivedInterface.derivedProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedProtocolMethod2 called");
    });
    it('Derived_StaticDerivedMethod', function () {
        TNSDerivedInterface.derivedMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedMethod called");
    });
    it('Derived_StaticDerivedCategoryProtocolMethod1', function () {
        TNSDerivedInterface.derivedCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedCategoryProtocolMethod1 called");
    });
    it('Derived_StaticDerivedCategoryProtocolMethod2', function () {
        TNSDerivedInterface.derivedCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedCategoryProtocolMethod2 called");
    });
    it('Derived_StaticDerivedCategoryMethod', function () {
        TNSDerivedInterface.derivedCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedCategoryMethod called");
    });

    // Instance

    it('Base_InstanceBaseProtocolMethod1', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod1 called");
    });
    it('Base_InstanceBaseProtocolMethod2', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod2 called");
    });
    it('Base_InstanceBaseMethod', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseMethod called");
    });
    it('Base_OverloadedInstanceBaseMethod', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseMethod(1);

        var actual = TNSGetOutput();
       expect(actual).toBe("overloaded instance baseMethod: called");
    });
    it('Base_InstanceBaseCategoryProtocolMethod1', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod1 called");
    });
    it('Base_InstanceBaseCategoryProtocolMethod2', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod2 called");
    });
    it('Base_InstanceBaseCategoryMethod', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryMethod called");
    });


    it('Derived_InstanceBaseProtocolMethod1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod1 called");
    });
    it('Derived_InstanceBaseProtocolMethod2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod2 called");
    });
    it('Derived_InstanceBaseMethod', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseMethod called");
    });
    it('Derived_OverloadedInstanceBaseMethod', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseMethod(1);

        var actual = TNSGetOutput();
        expect(actual).toBe("derived overloaded instance baseMethod: called");
    });
    it('Derived_InstanceBaseCategoryProtocolMethod1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod1 called");
    });
    it('Derived_InstanceBaseCategoryProtocolMethod2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod2 called");
    });
    it('Derived_InstanceBaseCategoryMethod', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryMethod called");
    });
    it('Derived_InstanceDerivedProtocolMethod1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedProtocolMethod1 called");
    });
    it('Derived_InstanceDerivedProtocolMethod2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedProtocolMethod2 called");
    });
    it('Derived_InstanceDerivedMethod', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedMethod called");
    });
    it('Derived_InstanceDerivedCategoryProtocolMethod1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedCategoryProtocolMethod1 called");
    });
    it('Derived_InstanceDerivedCategoryProtocolMethod2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedCategoryProtocolMethod2 called");
    });
    it('Derived_InstanceDerivedCategoryMethod', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedCategoryMethod called");
    });

    // Constructors

    it('Base_InitBaseProtocolMethod1', function () {
        TNSBaseInterface.alloc().initBaseProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod1 called");
    });
    it('Base_InitBaseProtocolMethod2', function () {
        TNSBaseInterface.alloc().initBaseProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod2 called");
    });
    it('Base_InitBaseMethod', function () {
        TNSBaseInterface.alloc().initBaseMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseMethod called");
    });
    it('Base_InitBaseCategoryProtocolMethod1', function () {
        TNSBaseInterface.alloc().initBaseCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod1 called");
    });
    it('Base_InitBaseCategoryProtocolMethod2', function () {
        TNSBaseInterface.alloc().initBaseCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod2 called");
    });
    it('Base_InitBaseCategoryMethod', function () {
        TNSBaseInterface.alloc().initBaseCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryMethod called");
    });


    it('Derived_InitBaseProtocolMethod1', function () {
        TNSDerivedInterface.alloc().initBaseProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod1 called");
    });
    it('Derived_InitBaseProtocolMethod2', function () {
        TNSDerivedInterface.alloc().initBaseProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod2 called");
    });
    it('Derived_InitBaseMethod', function () {
        TNSDerivedInterface.alloc().initBaseMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseMethod called");
    });
    it('Derived_InitBaseCategoryProtocolMethod1', function () {
        TNSDerivedInterface.alloc().initBaseCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod1 called");
    });
    it('Derived_InitBaseCategoryProtocolMethod2', function () {
        TNSDerivedInterface.alloc().initBaseCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod2 called");
    });
    it('Derived_InitBaseCategoryMethod', function () {
        TNSDerivedInterface.alloc().initBaseCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryMethod called");
    });
    it('Derived_InitDerivedProtocolMethod1', function () {
        TNSDerivedInterface.alloc().initDerivedProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedProtocolMethod1 called");
    });
    it('Derived_InitDerivedProtocolMethod2', function () {
        TNSDerivedInterface.alloc().initDerivedProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedProtocolMethod2 called");
    });
    it('Derived_InitDerivedMethod', function () {
        TNSDerivedInterface.alloc().initDerivedMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedMethod called");
    });
    it('Derived_InitDerivedCategoryProtocolMethod1', function () {
        TNSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedCategoryProtocolMethod1 called");
    });
    it('Derived_InitDerivedCategoryProtocolMethod2', function () {
        TNSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedCategoryProtocolMethod2 called");
    });
    it('Derived_InitDerivedCategoryMethod', function () {
        TNSDerivedInterface.alloc().initDerivedCategoryMethod();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedCategoryMethod called");
    });

    // Optional Static

    it('Base_StaticBaseProtocolMethod1Optional', function () {
        TNSBaseInterface.baseProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod1Optional called");
    });
    it('Base_StaticInitBaseProtocolMethod1Optional', function () {
        TNSBaseInterface.alloc().initBaseProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod1Optional called");
    });

    it('Base_StaticBaseProtocolMethod2Optional', function () {
        TNSBaseInterface.baseProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod2Optional called");
    });
    it('Base_StaticInitBaseProtocolMethod2Optional', function () {
        TNSBaseInterface.alloc().initBaseProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod2Optional called");
    });

    it('Base_StaticBaseCategoryProtocolMethod1Optional', function () {
        TNSBaseInterface.baseCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod1Optional called");
    });
    it('Base_StaticInitBaseCategoryProtocolMethod1Optional', function () {
        TNSBaseInterface.alloc().initBaseCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod1Optional called");
    });

    it('Base_StaticBaseCategoryProtocolMethod2Optional', function () {
        TNSBaseInterface.baseCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod2Optional called");
    });
    it('Base_StaticInitBaseCategoryProtocolMethod2Optional', function () {
        TNSBaseInterface.alloc().initBaseCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod2Optional called");
    });


    it('Derived_StaticBaseProtocolMethod1Optional', function () {
        TNSDerivedInterface.baseProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod1Optional called");
    });
    it('Derived_StaticInitBaseProtocolMethod1Optional', function () {
        TNSDerivedInterface.alloc().initBaseProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod1Optional called");
    });

    it('Derived_StaticBaseProtocolMethod2Optional', function () {
        TNSDerivedInterface.baseProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseProtocolMethod2Optional called");
    });
    it('Derived_StaticInitBaseProtocolMethod2Optional', function () {
        TNSDerivedInterface.alloc().initBaseProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseProtocolMethod2Optional called");
    });

    it('Derived_StaticBaseCategoryProtocolMethod1Optional', function () {
        TNSDerivedInterface.baseCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod1Optional called");
    });
    it('Derived_StaticInitBaseCategoryProtocolMethod1Optional', function () {
        TNSDerivedInterface.alloc().initBaseCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod1Optional called");
    });

    it('Derived_StaticBaseCategoryProtocolMethod2Optional', function () {
        TNSDerivedInterface.baseCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static baseCategoryProtocolMethod2Optional called");
    });
    it('Derived_StaticInitBaseCategoryProtocolMethod2Optional', function () {
        TNSDerivedInterface.alloc().initBaseCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initBaseCategoryProtocolMethod2Optional called");
    });

    it('Derived_StaticDerivedProtocolMethod1Optional', function () {
        TNSDerivedInterface.derivedProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedProtocolMethod1Optional called");
    });
    it('Derived_StaticInitDerivedProtocolMethod1Optional', function () {
        TNSDerivedInterface.alloc().initDerivedProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedProtocolMethod1Optional called");
    });

    it('Derived_StaticDerivedProtocolMethod2Optional', function () {
        TNSDerivedInterface.derivedProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedProtocolMethod2Optional called");
    });
    it('Derived_StaticInitDerivedProtocolMethod2Optional', function () {
        TNSDerivedInterface.alloc().initDerivedProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedProtocolMethod2Optional called");
    });

    it('Derived_StaticDerivedCategoryProtocolMethod1Optional', function () {
        TNSDerivedInterface.derivedCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedCategoryProtocolMethod1Optional called");
    });
    it('Derived_StaticInitDerivedCategoryProtocolMethod1Optional', function () {
        TNSDerivedInterface.alloc().initDerivedCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedCategoryProtocolMethod1Optional called");
    });

    it('Derived_StaticDerivedCategoryProtocolMethod2Optional', function () {
        TNSDerivedInterface.derivedCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("static derivedCategoryProtocolMethod2Optional called");
    });
    it('Derived_StaticInitDerivedCategoryProtocolMethod2Optional', function () {
        TNSDerivedInterface.alloc().initDerivedCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("constructor initDerivedCategoryProtocolMethod2Optional called");
    });

    // Optional Instance

    it('Base_InstanceBaseProtocolMethod1Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod1Optional called");
    });
    it('Base_InstanceBaseProtocolMethod2Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod2Optional called");
    });
    it('Base_InstanceBaseCategoryProtocolMethod1Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod1Optional called");
    });
    it('Base_InstanceBaseCategoryProtocolMethod2Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod2Optional called");
    });


    it('Derived_InstanceBaseProtocolMethod1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod1Optional called");
    });
    it('Derived_InstanceBaseProtocolMethod2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseProtocolMethod2Optional called");
    });
    it('Derived_InstanceBaseCategoryProtocolMethod1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod1Optional called");
    });
    it('Derived_InstanceBaseCategoryProtocolMethod2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance baseCategoryProtocolMethod2Optional called");
    });
    it('Derived_InstanceDerivedProtocolMethod1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedProtocolMethod1Optional called");
    });
    it('Derived_InstanceDerivedProtocolMethod2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedProtocolMethod2Optional called");
    });
    it('Derived_InstanceDerivedCategoryProtocolMethod1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolMethod1Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedCategoryProtocolMethod1Optional called");
    });
    it('Derived_InstanceDerivedCategoryProtocolMethod2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolMethod2Optional();

        var actual = TNSGetOutput();
        expect(actual).toBe("instance derivedCategoryProtocolMethod2Optional called");
    });

    // Properties
    it('Base_BaseProtocolProperty1', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolProperty1 = 1;
        UNUSED(instance.baseProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty1: calledinstance baseProtocolProperty1 called');
    });
    it('Base_BaseProtocolProperty1', function () {
        TNSBaseInterface.baseProtocolProperty1 = 1;
        UNUSED(TNSBaseInterface.baseProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty1: calledstatic baseProtocolProperty1 called');
    });
    it('Base_BaseProtocolProperty1Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolProperty1Optional = 1;
        UNUSED(instance.baseProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty1Optional: calledinstance baseProtocolProperty1Optional called');
    });
    it('Base_BaseProtocolProperty1Optional', function () {
        TNSBaseInterface.baseProtocolProperty1Optional = 1;
        UNUSED(TNSBaseInterface.baseProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty1Optional: calledstatic baseProtocolProperty1Optional called');
    });
    it('Base_BaseProtocolProperty2', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolProperty2 = 1;
        UNUSED(instance.baseProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2: calledinstance baseProtocolProperty2 called');
    });
    it('Base_BaseProtocolProperty2', function () {
        TNSBaseInterface.baseProtocolProperty2 = 1;
        UNUSED(TNSBaseInterface.baseProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty2: calledstatic baseProtocolProperty2 called');
    });
    it('Base_BaseProtocolProperty2Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolProperty2Optional = 1;
        UNUSED(instance.baseProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2Optional: calledinstance baseProtocolProperty2Optional called');
    });
    it('Base_BaseProtocolProperty2Optional', function () {
        TNSBaseInterface.baseProtocolProperty2Optional = 1;
        UNUSED(TNSBaseInterface.baseProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty2Optional: calledstatic baseProtocolProperty2Optional called');
    });
    it('Base_BaseProperty', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProperty = 1;
        UNUSED(instance.baseProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProperty: calledinstance baseProperty called');
    });
    it('Base_BaseProperty', function () {
        TNSBaseInterface.baseProperty = 1;
        UNUSED(TNSBaseInterface.baseProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProperty: calledstatic baseProperty called');
    });
    it('Base_BaseCategoryProtocolProperty1', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty1 = 1;
        UNUSED(instance.baseCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1: calledinstance baseCategoryProtocolProperty1 called');
    });
    it('Base_BaseCategoryProtocolProperty1', function () {
        TNSBaseInterface.baseCategoryProtocolProperty1 = 1;
        UNUSED(TNSBaseInterface.baseCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty1: calledstatic baseCategoryProtocolProperty1 called');
    });
    it('Base_BaseCategoryProtocolProperty1Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty1Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1Optional: calledinstance baseCategoryProtocolProperty1Optional called');
    });
    it('Base_BaseCategoryProtocolProperty1Optional', function () {
        TNSBaseInterface.baseCategoryProtocolProperty1Optional = 1;
        UNUSED(TNSBaseInterface.baseCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty1Optional: calledstatic baseCategoryProtocolProperty1Optional called');
    });
    it('Base_BaseCategoryProtocolProperty2', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty2 = 1;
        UNUSED(instance.baseCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2: calledinstance baseCategoryProtocolProperty2 called');
    });
    it('Base_BaseCategoryProtocolProperty2', function () {
        TNSBaseInterface.baseCategoryProtocolProperty2 = 1;
        UNUSED(TNSBaseInterface.baseCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty2: calledstatic baseCategoryProtocolProperty2 called');
    });
    it('Base_BaseCategoryProtocolProperty2Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty2Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2Optional: calledinstance baseCategoryProtocolProperty2Optional called');
    });
    it('Base_BaseCategoryProtocolProperty2Optional', function () {
        TNSBaseInterface.baseCategoryProtocolProperty2Optional = 1;
        UNUSED(TNSBaseInterface.baseCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty2Optional: calledstatic baseCategoryProtocolProperty2Optional called');
    });
    it('Base_BaseCategoryProperty', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProperty = 1;
        UNUSED(instance.baseCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProperty: calledinstance baseCategoryProperty called');
    });
    it('Base_BaseCategoryProperty', function () {
        TNSBaseInterface.baseCategoryProperty = 1;
        UNUSED(TNSBaseInterface.baseCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProperty: calledstatic baseCategoryProperty called');
    });


    it('Derived_BaseProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty1 = 1;
        UNUSED(instance.baseProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty1: calledinstance baseProtocolProperty1 called');
    });
    it('Derived_BaseProtocolProperty1', function () {
        TNSDerivedInterface.baseProtocolProperty1 = 1;
        UNUSED(TNSDerivedInterface.baseProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty1: calledstatic baseProtocolProperty1 called');
    });
    it('Derived_BaseProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty1Optional = 1;
        UNUSED(instance.baseProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty1Optional: calledinstance baseProtocolProperty1Optional called');
    });
    it('Derived_BaseProtocolProperty1Optional', function () {
        TNSDerivedInterface.baseProtocolProperty1Optional = 1;
        UNUSED(TNSDerivedInterface.baseProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty1Optional: calledstatic baseProtocolProperty1Optional called');
    });
    it('Derived_BaseProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty2 = 1;
        UNUSED(instance.baseProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2: calledinstance baseProtocolProperty2 called');
    });
    it('Derived_BaseProtocolProperty2', function () {
        TNSDerivedInterface.baseProtocolProperty2 = 1;
        UNUSED(TNSDerivedInterface.baseProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty2: calledstatic baseProtocolProperty2 called');
    });
    it('Derived_BaseProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty2Optional = 1;
        UNUSED(instance.baseProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2Optional: calledinstance baseProtocolProperty2Optional called');
    });
    it('Derived_BaseProtocolProperty2Optional', function () {
        TNSDerivedInterface.baseProtocolProperty2Optional = 1;
        UNUSED(TNSDerivedInterface.baseProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProtocolProperty2Optional: calledstatic baseProtocolProperty2Optional called');
    });
    it('Derived_BaseProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProperty = 1;
        UNUSED(instance.baseProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProperty: calledinstance baseProperty called');
    });
    it('Derived_BaseProperty', function () {
        TNSDerivedInterface.baseProperty = 1;
        UNUSED(TNSDerivedInterface.baseProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseProperty: calledstatic baseProperty called');
    });
    it('Derived_BaseCategoryProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty1 = 1;
        UNUSED(instance.baseCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1: calledinstance baseCategoryProtocolProperty1 called');
    });
    it('Derived_BaseCategoryProtocolProperty1', function () {
        TNSDerivedInterface.baseCategoryProtocolProperty1 = 1;
        UNUSED(TNSDerivedInterface.baseCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty1: calledstatic baseCategoryProtocolProperty1 called');
    });
    it('Derived_BaseCategoryProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty1Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1Optional: calledinstance baseCategoryProtocolProperty1Optional called');
    });
    it('Derived_BaseCategoryProtocolProperty1Optional', function () {
        TNSDerivedInterface.baseCategoryProtocolProperty1Optional = 1;
        UNUSED(TNSDerivedInterface.baseCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty1Optional: calledstatic baseCategoryProtocolProperty1Optional called');
    });
    it('Derived_BaseCategoryProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty2 = 1;
        UNUSED(instance.baseCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2: calledinstance baseCategoryProtocolProperty2 called');
    });
    it('Derived_BaseCategoryProtocolProperty2', function () {
        TNSDerivedInterface.baseCategoryProtocolProperty2 = 1;
        UNUSED(TNSDerivedInterface.baseCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty2: calledstatic baseCategoryProtocolProperty2 called');
    });
    it('Derived_BaseCategoryProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty2Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2Optional: calledinstance baseCategoryProtocolProperty2Optional called');
    });
    it('Derived_BaseCategoryProtocolProperty2Optional', function () {
        TNSDerivedInterface.baseCategoryProtocolProperty2Optional = 1;
        UNUSED(TNSDerivedInterface.baseCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProtocolProperty2Optional: calledstatic baseCategoryProtocolProperty2Optional called');
    });
    it('Derived_BaseCategoryProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProperty = 1;
        UNUSED(instance.baseCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProperty: calledinstance baseCategoryProperty called');
    });
    it('Derived_BaseCategoryProperty', function () {
        TNSDerivedInterface.baseCategoryProperty = 1;
        UNUSED(TNSDerivedInterface.baseCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setBaseCategoryProperty: calledstatic baseCategoryProperty called');
    });
    it('Derived_DerivedProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty1 = 1;
        UNUSED(instance.derivedProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty1: calledinstance derivedProtocolProperty1 called');
    });
    it('Derived_DerivedProtocolProperty1', function () {
        TNSDerivedInterface.derivedProtocolProperty1 = 1;
        UNUSED(TNSDerivedInterface.derivedProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedProtocolProperty1: calledstatic derivedProtocolProperty1 called');
    });
    it('Derived_DerivedProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty1Optional = 1;
        UNUSED(instance.derivedProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty1Optional: calledinstance derivedProtocolProperty1Optional called');
    });
    it('Derived_DerivedProtocolProperty1Optional', function () {
        TNSDerivedInterface.derivedProtocolProperty1Optional = 1;
        UNUSED(TNSDerivedInterface.derivedProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedProtocolProperty1Optional: calledstatic derivedProtocolProperty1Optional called');
    });
    it('Derived_DerivedProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty2 = 1;
        UNUSED(instance.derivedProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty2: calledinstance derivedProtocolProperty2 called');
    });
    it('Derived_DerivedProtocolProperty2', function () {
        TNSDerivedInterface.derivedProtocolProperty2 = 1;
        UNUSED(TNSDerivedInterface.derivedProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedProtocolProperty2: calledstatic derivedProtocolProperty2 called');
    });
    it('Derived_DerivedProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty2Optional = 1;
        UNUSED(instance.derivedProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty2Optional: calledinstance derivedProtocolProperty2Optional called');
    });
    it('Derived_DerivedProtocolProperty2Optional', function () {
        TNSDerivedInterface.derivedProtocolProperty2Optional = 1;
        UNUSED(TNSDerivedInterface.derivedProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedProtocolProperty2Optional: calledstatic derivedProtocolProperty2Optional called');
    });
    it('Derived_DerivedProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProperty = 1;
        UNUSED(instance.derivedProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProperty: calledinstance derivedProperty called');
    });
    it('Derived_DerivedPropertyReadOnly', function () {
        "use strict";
        var instance = TNSDerivedInterface.alloc().init();
        expect(() => instance.derivedPropertyReadOnly = 1).toThrowError(/Attempted to assign to readonly property/);
        UNUSED(instance.derivedPropertyReadOnly);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance derivedPropertyReadOnly called');
    });
    it('Derived_DerivedProperty', function () {
        TNSDerivedInterface.derivedProperty = 1;
        UNUSED(TNSDerivedInterface.derivedProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedProperty: calledstatic derivedProperty called');
    });
    it('Derived_DerivedCategoryProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty1 = 1;
        UNUSED(instance.derivedCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty1: calledinstance derivedCategoryProtocolProperty1 called');
    });
    it('Derived_DerivedCategoryProtocolProperty1', function () {
        TNSDerivedInterface.derivedCategoryProtocolProperty1 = 1;
        UNUSED(TNSDerivedInterface.derivedCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedCategoryProtocolProperty1: calledstatic derivedCategoryProtocolProperty1 called');
    });
    it('Derived_DerivedCategoryProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty1Optional = 1;
        UNUSED(instance.derivedCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty1Optional: calledinstance derivedCategoryProtocolProperty1Optional called');
    });
    it('Derived_DerivedCategoryProtocolProperty1Optional', function () {
        TNSDerivedInterface.derivedCategoryProtocolProperty1Optional = 1;
        UNUSED(TNSDerivedInterface.derivedCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedCategoryProtocolProperty1Optional: calledstatic derivedCategoryProtocolProperty1Optional called');
    });
    it('Derived_DerivedCategoryProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty2 = 1;
        UNUSED(instance.derivedCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty2: calledinstance derivedCategoryProtocolProperty2 called');
    });
    it('Derived_DerivedCategoryProtocolProperty2', function () {
        TNSDerivedInterface.derivedCategoryProtocolProperty2 = 1;
        UNUSED(TNSDerivedInterface.derivedCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedCategoryProtocolProperty2: calledstatic derivedCategoryProtocolProperty2 called');
    });
    it('Derived_DerivedCategoryProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty2Optional = 1;
        UNUSED(instance.derivedCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty2Optional: calledinstance derivedCategoryProtocolProperty2Optional called');
    });
    it('Derived_DerivedCategoryProtocolProperty2Optional', function () {
        TNSDerivedInterface.derivedCategoryProtocolProperty2Optional = 1;
        UNUSED(TNSDerivedInterface.derivedCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedCategoryProtocolProperty2Optional: calledstatic derivedCategoryProtocolProperty2Optional called');
    });
    it('Derived_DerivedCategoryProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProperty = 1;
        UNUSED(instance.derivedCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProperty: calledinstance derivedCategoryProperty called');
    });
    it('Derived_DerivedPropertyReadOnlyMadeWritable', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedPropertyReadOnlyMadeWritable = 1;
        UNUSED(instance.derivedPropertyReadOnlyMadeWritable);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedPropertyReadOnlyMadeWritable: calledinstance derivedPropertyReadOnlyMadeWritable called');
    });
    it('Derived_DerivedCategoryProperty', function () {
        TNSDerivedInterface.derivedCategoryProperty = 1;
        UNUSED(TNSDerivedInterface.derivedCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('static setDerivedCategoryProperty: calledstatic derivedCategoryProperty called');
    });

    if (isSimulator) {
        // Skip on simulator because libffi breaks exception unwinding on iOS Simulator
        // see https://github.com/libffi/libffi/issues/418
        console.warn("warning: Skipping ObjC exceptions tests on Simulator device!");
    } else {
        it('Throw_ObjC_exceptions_to_JavaScript', function () {
            try {
                NSArray.alloc().init().objectAtIndex(3);
                expect(false).toBeTruthy("Should never be reached because objectAtIndex(3) should throw an Objective-C exception.");
            } catch(e) {
                expect(e.stack).toContain("app/MethodCallsTests.js")
                expect(e.nativeException).toBeDefined();
                expect(e.nativeException instanceof NSException).toBe(true);
                expect(e.nativeException.toString()).toBe(e.nativeException.reason);
                expect(e.nativeException.reason).toContain("index 3 beyond bounds");
                expect(e.nativeException.name).toBe("NSRangeException");
           
                const checkNativeCallStack = !__uikitformac; // TODO: fix callstack unwinding under libffi calls on macOS
                if (checkNativeCallStack) {
                    expect(e.nativeException.callStackSymbols.count).toBeGreaterThan(5);

                    var nativeCallstack = "";
                    for (var i=0; i < e.nativeException.callStackSymbols.count; i++) {
                        nativeCallstack += e.nativeException.callStackSymbols[i] + '\n';
                    }

                    expect(nativeCallstack).toContain("CoreFoundation");
                    expect(nativeCallstack).toContain("TestRunner");
                    expect(nativeCallstack).toContain("objc_exception_throw");
                    expect(nativeCallstack).toContain("UIApplicationMain");
                }
            }
        });
    }

     it('Override: More than one methods with same jsname', function () {

        var i = TNSBaseInterface.extend({
          baseMethod: function (x) {
            if (typeof x === "undefined") {
                this.zeroArgs = true;
            } else {
                this.x = x;
            }
          }
        }).alloc().init();

        i.callBaseMethod(false);

        expect(i.zeroArgs).toBe(true);

        i.callBaseMethod(true);

        expect(i.x).toBe(2);
    });

     it("Prototype.put", function () {
        var i = TNSBaseInterface.extend({}).alloc().init();
        TNSBaseInterface.prototype.baseMethod = function(x) {
            this.x = x;
        }
        i.callBaseMethod(false);
        expect(i.x).toBe(undefined);
        i.callBaseMethod(true);
        expect(i.x).toBe(2);
     });
});
