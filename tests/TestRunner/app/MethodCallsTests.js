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
    it('Base_BaseProtocolProperty1Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolProperty1Optional = 1;
        UNUSED(instance.baseProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty1Optional: calledinstance baseProtocolProperty1Optional called');
    });
    it('Base_BaseProtocolProperty2', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolProperty2 = 1;
        UNUSED(instance.baseProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2: calledinstance baseProtocolProperty2 called');
    });
    it('Base_BaseProtocolProperty2Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProtocolProperty2Optional = 1;
        UNUSED(instance.baseProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2Optional: calledinstance baseProtocolProperty2Optional called');
    });
    it('Base_BaseProperty', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseProperty = 1;
        UNUSED(instance.baseProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProperty: calledinstance baseProperty called');
    });
    it('Base_BaseCategoryProtocolProperty1', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty1 = 1;
        UNUSED(instance.baseCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1: calledinstance baseCategoryProtocolProperty1 called');
    });
    it('Base_BaseCategoryProtocolProperty1Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty1Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1Optional: calledinstance baseCategoryProtocolProperty1Optional called');
    });
    it('Base_BaseCategoryProtocolProperty2', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty2 = 1;
        UNUSED(instance.baseCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2: calledinstance baseCategoryProtocolProperty2 called');
    });
    it('Base_BaseCategoryProtocolProperty2Optional', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProtocolProperty2Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2Optional: calledinstance baseCategoryProtocolProperty2Optional called');
    });
    it('Base_BaseCategoryProperty', function () {
        var instance = TNSBaseInterface.alloc().init();
        instance.baseCategoryProperty = 1;
        UNUSED(instance.baseCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProperty: calledinstance baseCategoryProperty called');
    });


    it('Derived_BaseProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty1 = 1;
        UNUSED(instance.baseProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty1: calledinstance baseProtocolProperty1 called');
    });
    it('Derived_BaseProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty1Optional = 1;
        UNUSED(instance.baseProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty1Optional: calledinstance baseProtocolProperty1Optional called');
    });
    it('Derived_BaseProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty2 = 1;
        UNUSED(instance.baseProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2: calledinstance baseProtocolProperty2 called');
    });
    it('Derived_BaseProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProtocolProperty2Optional = 1;
        UNUSED(instance.baseProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProtocolProperty2Optional: calledinstance baseProtocolProperty2Optional called');
    });
    it('Derived_BaseProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseProperty = 1;
        UNUSED(instance.baseProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseProperty: calledinstance baseProperty called');
    });
    it('Derived_BaseCategoryProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty1 = 1;
        UNUSED(instance.baseCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1: calledinstance baseCategoryProtocolProperty1 called');
    });
    it('Derived_BaseCategoryProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty1Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty1Optional: calledinstance baseCategoryProtocolProperty1Optional called');
    });
    it('Derived_BaseCategoryProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty2 = 1;
        UNUSED(instance.baseCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2: calledinstance baseCategoryProtocolProperty2 called');
    });
    it('Derived_BaseCategoryProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProtocolProperty2Optional = 1;
        UNUSED(instance.baseCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProtocolProperty2Optional: calledinstance baseCategoryProtocolProperty2Optional called');
    });
    it('Derived_BaseCategoryProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.baseCategoryProperty = 1;
        UNUSED(instance.baseCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setBaseCategoryProperty: calledinstance baseCategoryProperty called');
    });
    it('Derived_DerivedProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty1 = 1;
        UNUSED(instance.derivedProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty1: calledinstance derivedProtocolProperty1 called');
    });
    it('Derived_DerivedProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty1Optional = 1;
        UNUSED(instance.derivedProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty1Optional: calledinstance derivedProtocolProperty1Optional called');
    });
    it('Derived_DerivedProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty2 = 1;
        UNUSED(instance.derivedProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty2: calledinstance derivedProtocolProperty2 called');
    });
    it('Derived_DerivedProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProtocolProperty2Optional = 1;
        UNUSED(instance.derivedProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProtocolProperty2Optional: calledinstance derivedProtocolProperty2Optional called');
    });
    it('Derived_DerivedProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedProperty = 1;
        UNUSED(instance.derivedProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedProperty: calledinstance derivedProperty called');
    });
    it('Derived_DerivedCategoryProtocolProperty1', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty1 = 1;
        UNUSED(instance.derivedCategoryProtocolProperty1);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty1: calledinstance derivedCategoryProtocolProperty1 called');
    });
    it('Derived_DerivedCategoryProtocolProperty1Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty1Optional = 1;
        UNUSED(instance.derivedCategoryProtocolProperty1Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty1Optional: calledinstance derivedCategoryProtocolProperty1Optional called');
    });
    it('Derived_DerivedCategoryProtocolProperty2', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty2 = 1;
        UNUSED(instance.derivedCategoryProtocolProperty2);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty2: calledinstance derivedCategoryProtocolProperty2 called');
    });
    it('Derived_DerivedCategoryProtocolProperty2Optional', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProtocolProperty2Optional = 1;
        UNUSED(instance.derivedCategoryProtocolProperty2Optional);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProtocolProperty2Optional: calledinstance derivedCategoryProtocolProperty2Optional called');
    });
    it('Derived_DerivedCategoryProperty', function () {
        var instance = TNSDerivedInterface.alloc().init();
        instance.derivedCategoryProperty = 1;
        UNUSED(instance.derivedCategoryProperty);

        var actual = TNSGetOutput();
        expect(actual).toBe('instance setDerivedCategoryProperty: calledinstance derivedCategoryProperty called');
    });
    it('methods can be recursively called', function() {
        var result = TNSTestNativeCallbacks.callRecursively(function() {
            return TNSTestNativeCallbacks.callRecursively(function() {
                 return "InnerRecursiveResult";
            });
        });
        expect(result).toBe("InnerRecursiveResult");
    });
});
