// TODO: Use TypeScript definitions when they get ready
var __extends = this.__extends || function (d, b) {
        for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
        function __() {
            this.constructor = d;
        }

        __.prototype = b.prototype;
        d.prototype = new __();
    };

var TSObject = (function (_super) {
    __extends(TSObject, _super);
    function TSObject() {
        _super.apply(this, arguments);
    }

    TSObject.prototype.initBaseMethod = function () {
        var self = _super.prototype.initBaseMethod.call(this);
        TNSLog('js initBaseMethod called');
        return self;
    };

    TSObject.prototype.initDerivedMethod = function () {
        var self = _super.prototype.initDerivedMethod.call(this);
        TNSLog('js initDerivedMethod called');
        return self;
    };

    TSObject.prototype.baseMethod = function () {
        TNSLog('js baseMethod called');
        _super.prototype.baseMethod.call(this);
    };

    TSObject.prototype.derivedMethod = function () {
        TNSLog('js derivedMethod called');
        _super.prototype.derivedMethod.call(this);
    };

    Object.defineProperty(TSObject.prototype, "baseProperty", {
        get: function () {
            TNSLog('js getBaseProperty called');
            return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProperty').get.call(this);
        },
        set: function (x) {
            TNSLog('js setBaseProperty called');
            Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProperty').set.apply(this, arguments);
        },
        enumerable: true,
        configurable: true
    });


    Object.defineProperty(TSObject.prototype, "derivedProperty", {
        get: function () {
            TNSLog('js getDerivedProperty called');
            return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProperty').get.call(this);
        },
        set: function (x) {
            TNSLog('js setDerivedProperty called');
            Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProperty').set.apply(this, arguments);
        },
        enumerable: true,
        configurable: true
    });


    TSObject.prototype.method = function () {
        return this.constructor.property;
    };

    TSObject.prototype.voidSelector = function () {
        TNSLog('voidSelector called');
    };

    TSObject.prototype['variadicSelector:x:'] = function (a, b) {
        TNSLog('variadicSelector:' + a + ' x:' + b + ' called');
        return a;
    };
    TSObject.property = 1;

    TSObject.ObjCExposedMethods = {
        'voidSelector': {returns: interop.types.void},
        'variadicSelector:x:': {returns: NSObject, params: [NSString, interop.types.int32]}
    };
    return TSObject;
})(TNSDerivedInterface);

var TSObject1 = (function (_super) {
    __extends(TSObject1, _super);
    function TSObject1() {
        _super.apply(this, arguments);
    }

    TSObject1.prototype.baseProtocolMethod1 = function () {
        TNSLog('baseProtocolMethod1 called');
    };

    TSObject1.prototype.baseProtocolMethod2 = function () {
        TNSLog('baseProtocolMethod2 called');
    };

    Object.defineProperty(TSObject1.prototype, "baseProtocolProperty1", {
        get: function () {
            TNSLog('baseProtocolProperty1 called');
            return 0;
        },
        set: function (x) {
            TNSLog('setBaseProtocolProperty1: called');
        },
        enumerable: true,
        configurable: true
    });


    Object.defineProperty(TSObject1.prototype, "baseProtocolProperty1Optional", {
        get: function () {
            TNSLog('baseProtocolProperty1Optional called');
            return 0;
        },
        set: function (x) {
            TNSLog('setBaseProtocolProperty1Optional: called');
        },
        enumerable: true,
        configurable: true
    });


    TSObject1.ObjCProtocols = [TNSBaseProtocol2];
    return TSObject1;
})(NSObject);

var A = (function () {
    function A() {
    }

    return A;
})();

var B = (function (_super) {
    __extends(B, _super);
    function B() {
        _super.apply(this, arguments);
    }

    return B;
})(A);

var UnusedConstructor = (function (_super) {
    __extends(UnusedConstructor, _super);
    function UnusedConstructor() {
        _super.apply(this, arguments);
        this.x = 3;
    }

    return UnusedConstructor;
})(NSObject);

describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it('SimpleInheritance', function () {
        var object = TSObject.alloc().init();
        expect(object.constructor).toBe(TSObject);

        expect(object instanceof TSObject).toBe(true);
        expect(object instanceof TNSDerivedInterface).toBe(true);
        expect(object instanceof NSObject).toBe(true);

        expect(object.class()).toBe(TSObject);
        expect(object.superclass).toBe(TNSDerivedInterface);

        expect(TSObject.class()).toBe(TSObject);
        expect(TSObject.superclass()).toBe(TNSDerivedInterface);

        expect(NSStringFromClass(TSObject)).toBe('TSObject');
    });

    it('StaticMethods', function () {
        TSObject.baseMethod();
        TSObject.derivedMethod();
        expect(TNSGetOutput()).toBe('static baseMethod called' + 'static derivedMethod called');
    });

    it('InstanceMethods', function () {
        var object = TSObject.alloc().init();

        object.baseMethod();
        object.derivedMethod();

        expect(TNSGetOutput()).toBe('js baseMethod called' + 'instance baseMethod called' + 'js derivedMethod called' + 'instance derivedMethod called');
    });

    it('ConstructorCalls', function () {
        expect(TSObject.alloc().initBaseMethod() instanceof TSObject).toBe(true);
        expect(TSObject.alloc().initDerivedMethod() instanceof TSObject).toBe(true);

        expect(TNSGetOutput()).toBe('constructor initBaseMethod called' + 'js initBaseMethod called' + 'constructor initDerivedMethod called' + 'js initDerivedMethod called');
    });

    it('PropertyCalls', function () {
        var object = TSObject.alloc().init();

        object.baseProperty = 0;
        UNUSED(object.baseProperty);

        object.derivedProperty = 0;
        UNUSED(object.derivedProperty);

        expect(TNSGetOutput()).toBe('js setBaseProperty called' + 'instance setBaseProperty: called' + 'js getBaseProperty called' + 'instance baseProperty called' + 'js setDerivedProperty called' + 'instance setDerivedProperty: called' + 'js getDerivedProperty called' + 'instance derivedProperty called');
    });

    it('ExposedMethods', function () {
        var object = TSObject.alloc().init();

        TNSTestNativeCallbacks.inheritanceVoidSelector(object);
        expect(TNSTestNativeCallbacks.inheritanceVariadicSelector(object)).toBe('native');

        expect(TNSGetOutput()).toBe('voidSelector called' + 'variadicSelector:native x:9 called');
    });

    it('AddedNewProperty', function () {
        var object = TSObject.alloc().init();

        expect(object.method()).toBe(1);
    });

    it('ImplementMethod', function () {
        var object = TSObject1.alloc().init();

        TNSTestNativeCallbacks.protocolImplementationProtocolInheritance(object);

        expect(TNSGetOutput()).toBe('baseProtocolMethod1 called' + 'baseProtocolMethod2 called');
    });

    it('ImplementProperties', function () {
        var object = TSObject1.alloc().init();

        TNSTestNativeCallbacks.protocolImplementationProperties(object);

        expect(TNSGetOutput()).toBe('setBaseProtocolProperty1: called' + 'baseProtocolProperty1 called' + 'setBaseProtocolProperty1Optional: called' + 'baseProtocolProperty1Optional called');
    });

    it('PlainExtends', function () {
        expect(new B() instanceof A).toBe(true);
    });
});
