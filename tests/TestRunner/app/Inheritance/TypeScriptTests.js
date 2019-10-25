// TODO: Use TypeScript definitions when they get ready
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var TSObject = /** @class */ (function (_super) {
    __extends(TSObject, _super);
    function TSObject() {
        return _super !== null && _super.apply(this, arguments) || this;
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
    TSObject.returnsConstructorMethod = function () {
        return TSObject;
    };
    TSObject.property = 1;
    TSObject.ObjCExposedMethods = {
        'voidSelector': { returns: interop.types.void },
        'variadicSelector:x:': { returns: NSObject, params: [NSString, interop.types.int32] }
    };
    return TSObject;
}(TNSDerivedInterface));
var TSObject1 = /** @class */ (function (_super) {
    __extends(TSObject1, _super);
    function TSObject1() {
        return _super !== null && _super.apply(this, arguments) || this;
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
}(NSObject));
var TSDecoratedObject = /** @class */ (function (_super) {
    __extends(TSDecoratedObject, _super);
    function TSDecoratedObject() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    TSDecoratedObject.prototype.voidSelector = function () {
        TNSLog('voidSelector called');
    };
    TSDecoratedObject.prototype.variadicSelectorX = function (a, b) {
        TNSLog('variadicSelector:' + a + ' x:' + b + ' called');
        return a;
    };
    TSDecoratedObject.staticFunc = function (x) {
        TNSLog('staticFunc:' + x + ' called');
    };
    __decorate([
        ObjCMethod(),
        __metadata("design:type", Function),
        __metadata("design:paramtypes", []),
        __metadata("design:returntype", void 0)
    ], TSDecoratedObject.prototype, "voidSelector", null);
    __decorate([
        ObjCMethod('variadicSelector:x:', NSObject),
        __param(0, ObjCParam(NSString)), __param(1, ObjCParam(interop.types.int32)),
        __metadata("design:type", Function),
        __metadata("design:paramtypes", [Object, Object]),
        __metadata("design:returntype", void 0)
    ], TSDecoratedObject.prototype, "variadicSelectorX", null);
    return TSDecoratedObject;
}(TNSDerivedInterface));
var TSDecoratedObject1 = /** @class */ (function (_super) {
    __extends(TSDecoratedObject1, _super);
    function TSDecoratedObject1() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    TSDecoratedObject1.prototype.baseProtocolMethod1 = function () {
        TNSLog('baseProtocolMethod1 called');
    };
    TSDecoratedObject1.prototype.baseProtocolMethod2 = function () {
        TNSLog('baseProtocolMethod2 called');
    };
    Object.defineProperty(TSDecoratedObject1.prototype, "baseProtocolProperty1", {
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
    Object.defineProperty(TSDecoratedObject1.prototype, "baseProtocolProperty1Optional", {
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
    TSDecoratedObject1 = __decorate([
        ObjCClass(TNSBaseProtocol2)
    ], TSDecoratedObject1);
    return TSDecoratedObject1;
}(NSObject));
var UnusedConstructor = /** @class */ (function (_super) {
    __extends(UnusedConstructor, _super);
    function UnusedConstructor() {
        var _this = _super !== null && _super.apply(this, arguments) || this;
        _this.x = 3;
        return _this;
    }
    return UnusedConstructor;
}(NSObject));
describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });
    it('should replace the TypeScript-generated constructor function', function () {
        expect(interop.handleof(TSObject)).toEqual(jasmine.any(interop.Pointer));
        expect(NSClassFromString(TSObject.name)).toBe(TSObject);
        expect(TSObject.returnsConstructorMethod()).toBe(TSObject);
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
        expect(TNSGetOutput()).toBe('static baseMethod called' +
            'static derivedMethod called');
    });
    it('InstanceMethods', function () {
        var object = TSObject.alloc().init();
        object.baseMethod();
        object.derivedMethod();
        expect(TNSGetOutput()).toBe('js baseMethod called' +
            'instance baseMethod called' +
            'js derivedMethod called' +
            'instance derivedMethod called');
    });
    it('ConstructorCalls', function () {
        expect(TSObject.alloc().initBaseMethod() instanceof TSObject).toBe(true);
        expect(TSObject.alloc().initDerivedMethod() instanceof TSObject).toBe(true);
        expect(TNSGetOutput()).toBe('constructor initBaseMethod called' +
            'js initBaseMethod called' +
            'constructor initDerivedMethod called' +
            'js initDerivedMethod called');
    });
    it('PropertyCalls', function () {
        var object = TSObject.alloc().init();
        object.baseProperty = 0;
        UNUSED(object.baseProperty);
        object.derivedProperty = 0;
        UNUSED(object.derivedProperty);
        expect(TNSGetOutput()).toBe('js setBaseProperty called' +
            'instance setBaseProperty: called' +
            'js getBaseProperty called' +
            'instance baseProperty called' +
            'js setDerivedProperty called' +
            'instance setDerivedProperty: called' +
            'js getDerivedProperty called' +
            'instance derivedProperty called');
    });
    it('ExposedMethods', function () {
        var object = TSObject.alloc().init();
        TNSTestNativeCallbacks.inheritanceVoidSelector(object);
        expect(TNSTestNativeCallbacks.inheritanceVariadicSelector(object)).toBe('native');
        expect(TNSGetOutput()).toBe('voidSelector called' +
            'variadicSelector:native x:9 called');
    });
    it("MethodOverrides: errors", function () {
        expect(function () {
            var TSObjectErr1 = /** @class */ (function (_super) {
                __extends(TSObjectErr1, _super);
                function TSObjectErr1() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                Object.defineProperty(TSObjectErr1.prototype, "isEqual", {
                    get: function () { return false; },
                    enumerable: true,
                    configurable: true
                });
                return TSObjectErr1;
            }(NSObject));
            return TSObjectErr1.alloc();
        }).toThrowError(/Cannot override native method "isEqual" with a property, define it as a JS function instead./);
        expect(function () {
            var TSObjectErr2 = /** @class */ (function (_super) {
                __extends(TSObjectErr2, _super);
                function TSObjectErr2() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                return TSObjectErr2;
            }(TNSDerivedInterface));
            TSObjectErr2.prototype.isEqual = true;
            return TSObjectErr2.alloc();
        }).toThrowError(/true cannot override native method "isEqual"./);
    });
    it('ExposeWithWrongParams', function () {
        expect(function () {
            var ExposeWithWrongParams = /** @class */ (function (_super) {
                __extends(ExposeWithWrongParams, _super);
                function ExposeWithWrongParams() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                ExposeWithWrongParams.prototype.wrongRet = function () { };
                ExposeWithWrongParams.ObjCExposedMethods = {
                    'wrongRet': { returns: "a string", params: [interop.types.selector] }
                };
                return ExposeWithWrongParams;
            }(NSObject));
            return ExposeWithWrongParams.alloc();
        }).toThrowError("\"a string\" Method wrongRet has an invalid return type encoding");
        expect(function () {
            var ExposeWithWrongParams2 = /** @class */ (function (_super) {
                __extends(ExposeWithWrongParams2, _super);
                function ExposeWithWrongParams2() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                ExposeWithWrongParams2.prototype.wrongArg = function () { };
                ExposeWithWrongParams2.ObjCExposedMethods = {
                    'wrongArg': { returns: interop.types.selector, params: [3] }
                };
                return ExposeWithWrongParams2;
            }(NSObject));
            return ExposeWithWrongParams2.alloc();
        }).toThrowError("3 Method wrongArg has an invalid type encoding for argument 1");
        expect(function () {
            var ExposeWithWrongParams3 = /** @class */ (function (_super) {
                __extends(ExposeWithWrongParams3, _super);
                function ExposeWithWrongParams3() {
                    return _super !== null && _super.apply(this, arguments) || this;
                }
                ExposeWithWrongParams3.prototype.wrongArg = function () { };
                ExposeWithWrongParams3.ObjCExposedMethods = {
                    'wrongArg': { returns: interop.types.void, params: { notArray: true } }
                };
                return ExposeWithWrongParams3;
            }(NSObject));
            return ExposeWithWrongParams3.alloc();
        }).toThrowError("Object The 'params' property of method wrongArg is not an array");
    });
    it('AddedNewProperty', function () {
        var object = TSObject.alloc().init();
        expect(object.method()).toBe(1);
    });
    it('ImplementMethod', function () {
        var object = TSObject1.alloc().init();
        TNSTestNativeCallbacks.protocolImplementationProtocolInheritance(object);
        expect(TNSGetOutput()).toBe('baseProtocolMethod1 called' +
            'baseProtocolMethod2 called');
    });
    it('ImplementProperties', function () {
        var object = TSObject1.alloc().init();
        TNSTestNativeCallbacks.protocolImplementationProperties(object);
        expect(TNSGetOutput()).toBe('setBaseProtocolProperty1: called' +
            'baseProtocolProperty1 called' +
            'setBaseProtocolProperty1Optional: called' +
            'baseProtocolProperty1Optional called');
    });
    it('PlainExtends', function () {
        var A = /** @class */ (function () {
            function A() {
            }
            return A;
        }());
        var B = /** @class */ (function (_super) {
            __extends(B, _super);
            function B() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return B;
        }(A));
        expect(new B() instanceof A).toBe(true);
    });
    it('Scope', function () {
        global["Derived"] = 3;
        var Derived = /** @class */ (function (_super) {
            __extends(Derived, _super);
            function Derived() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return Derived;
        }(NSObject));
        ;
        expect(global["Derived"]).toBe(3);
        delete global["Derived"];
    });
    it('TypeScriptDecoratedShim', function () {
        expect(global.__decorate).toBeDefined();
        expect(global.__param).toBeDefined();
    });
    it('TypeScriptDecoratedProtocolImplementation', function () {
        var object = TSDecoratedObject1.alloc().init();
        TNSTestNativeCallbacks.protocolImplementationProtocolInheritance(object);
        expect(TNSGetOutput()).toBe('baseProtocolMethod1 called' +
            'baseProtocolMethod2 called');
    });
    it('TypeScriptDecoratedExposedMethods', function () {
        var object = TSDecoratedObject.alloc().init();
        TNSTestNativeCallbacks.inheritanceVoidSelector(object);
        expect(TNSTestNativeCallbacks.inheritanceVariadicSelector(object)).toBe('native');
        expect(TNSGetOutput()).toBe('voidSelector called' +
            'variadicSelector:native x:9 called');
    });
    it('TypeScriptDecoratedExposedMethodsCalledFromJs', function () {
        var object = TSDecoratedObject.alloc().init();
        object.voidSelector();
        expect(object.variadicSelectorX('js', 5)).toBe('js');
        TSDecoratedObject.staticFunc(9);
        expect(TNSGetOutput()).toBe('voidSelector called' +
            'variadicSelector:js x:5 called' +
            'staticFunc:9 called');
    });
});
