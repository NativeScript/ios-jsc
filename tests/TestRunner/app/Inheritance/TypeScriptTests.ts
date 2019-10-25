// TODO: Use TypeScript definitions when they get ready

declare function afterEach(param);
declare function describe(name, func);
declare function expect(param);
declare function it(name, func);
declare function TNSClearOutput();
declare function TNSLog(message);
declare function TNSGetOutput();
declare var TNSTestNativeCallbacks;
declare function UNUSED(param);

declare var module;
declare function NSStringFromClass(klass);
declare function NSClassFromString(klassName);

declare function ObjCClass(param);
declare function ObjCMethod(name?, param?);
declare function ObjCParam(param);

declare var interop;

declare var global;

declare var NSString: any;


declare class NSObject {
    public static alloc();

    public static class();

    public static superclass();

    public init();

    public class();

    public superclass;

    public static ObjCProtocols;

    public static ObjCExposedMethods;
}

declare class TNSBaseInterface extends NSObject {
    public static baseMethod():void;

    public initBaseMethod();

    public baseMethod():void;

    public baseProperty:number;
}

declare class TNSDerivedInterface extends TNSBaseInterface {
    public static derivedMethod():void;

    public initDerivedMethod();

    public derivedMethod():void;

    public derivedProperty:number;
}

class TSObject extends TNSDerivedInterface {
    initBaseMethod() {
        var self = super.initBaseMethod();
        TNSLog('js initBaseMethod called');
        return self;
    }

    initDerivedMethod() {
        var self = super.initDerivedMethod();
        TNSLog('js initDerivedMethod called');
        return self;
    }

    baseMethod() {
        TNSLog('js baseMethod called');
        super.baseMethod();
    }

    derivedMethod() {
        TNSLog('js derivedMethod called');
        super.derivedMethod();
    }

    get baseProperty() {
        TNSLog('js getBaseProperty called');
        return Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProperty').get.call(this);
    }

    set baseProperty(x:any) {
        TNSLog('js setBaseProperty called');
        Object.getOwnPropertyDescriptor(TNSBaseInterface.prototype, 'baseProperty').set.apply(this, arguments);
    }

    get derivedProperty() {
        TNSLog('js getDerivedProperty called');
        return Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProperty').get.call(this);
    }

    set derivedProperty(x:any) {
        TNSLog('js setDerivedProperty called');
        Object.getOwnPropertyDescriptor(TNSDerivedInterface.prototype, 'derivedProperty').set.apply(this, arguments);
    }

    public static property = 1;

    public method() {
        return (<any>(<any>this).constructor).property;
    }

    public voidSelector() {
        TNSLog('voidSelector called');
    }

    public 'variadicSelector:x:'(a, b) {
        TNSLog('variadicSelector:' + a + ' x:' + b + ' called');
        return a;
    }

    public static returnsConstructorMethod() {
        return TSObject;
    }

    public static ObjCExposedMethods = {
        'voidSelector': { returns: interop.types.void },
        'variadicSelector:x:': { returns: NSObject, params: [ NSString, interop.types.int32 ] }
    };
}

declare var TNSBaseProtocol2;

class TSObject1 extends NSObject {
    baseProtocolMethod1() {
        TNSLog('baseProtocolMethod1 called');
    }

    baseProtocolMethod2() {
        TNSLog('baseProtocolMethod2 called');
    }

    get baseProtocolProperty1() {
        TNSLog('baseProtocolProperty1 called');
        return 0;
    }

    set baseProtocolProperty1(x:any) {
        TNSLog('setBaseProtocolProperty1: called');
    }

    get baseProtocolProperty1Optional() {
        TNSLog('baseProtocolProperty1Optional called');
        return 0;
    }

    set baseProtocolProperty1Optional(x:any) {
        TNSLog('setBaseProtocolProperty1Optional: called');
    }

    public static ObjCProtocols = [TNSBaseProtocol2];
}

class TSDecoratedObject extends TNSDerivedInterface {
    @ObjCMethod()
    public voidSelector() {
        TNSLog('voidSelector called');
    }

    @ObjCMethod('variadicSelector:x:', NSObject)
    public variadicSelectorX(@ObjCParam(NSString) a, @ObjCParam(interop.types.int32) b) {
        TNSLog('variadicSelector:' + a + ' x:' + b + ' called');
        return a;
    }

    static staticFunc(x) {
        TNSLog('staticFunc:' + x + ' called');
    }
}

@ObjCClass(TNSBaseProtocol2)
class TSDecoratedObject1 extends NSObject {
    baseProtocolMethod1() {
        TNSLog('baseProtocolMethod1 called');
    }

    baseProtocolMethod2() {
        TNSLog('baseProtocolMethod2 called');
    }

    get baseProtocolProperty1() {
        TNSLog('baseProtocolProperty1 called');
        return 0;
    }

    set baseProtocolProperty1(x:any) {
        TNSLog('setBaseProtocolProperty1: called');
    }

    get baseProtocolProperty1Optional() {
        TNSLog('baseProtocolProperty1Optional called');
        return 0;
    }

    set baseProtocolProperty1Optional(x:any) {
        TNSLog('setBaseProtocolProperty1Optional: called');
    }
}

class UnusedConstructor extends NSObject {
    private x = 3;
}

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
        expect(TNSGetOutput()).toBe(
            'static baseMethod called' +
            'static derivedMethod called'
        );
    });

    it('InstanceMethods', function () {
        var object = TSObject.alloc().init();

        object.baseMethod();
        object.derivedMethod();

        expect(TNSGetOutput()).toBe(
            'js baseMethod called' +
            'instance baseMethod called' +
            'js derivedMethod called' +
            'instance derivedMethod called'
        );
    });

    it('ConstructorCalls', function () {
        expect(TSObject.alloc().initBaseMethod() instanceof TSObject).toBe(true);
        expect(TSObject.alloc().initDerivedMethod() instanceof TSObject).toBe(true);

        expect(TNSGetOutput()).toBe(
            'constructor initBaseMethod called' +
            'js initBaseMethod called' +
            'constructor initDerivedMethod called' +
            'js initDerivedMethod called'
        );
    });

    it('PropertyCalls', function () {
        var object = TSObject.alloc().init();

        object.baseProperty = 0;
        UNUSED(object.baseProperty);

        object.derivedProperty = 0;
        UNUSED(object.derivedProperty);

        expect(TNSGetOutput()).toBe(
            'js setBaseProperty called' +
            'instance setBaseProperty: called' +
            'js getBaseProperty called' +
            'instance baseProperty called' +
            'js setDerivedProperty called' +
            'instance setDerivedProperty: called' +
            'js getDerivedProperty called' +
            'instance derivedProperty called'
        );
    });

    it('ExposedMethods', function () {
        var object = TSObject.alloc().init();

        TNSTestNativeCallbacks.inheritanceVoidSelector(object);
        expect(TNSTestNativeCallbacks.inheritanceVariadicSelector(object)).toBe('native');

        expect(TNSGetOutput()).toBe(
            'voidSelector called' +
            'variadicSelector:native x:9 called'
        );
    });

    it("MethodOverrides: errors", function () {
        expect(() => {
            class TSObjectErr1 extends NSObject {
                get isEqual() { return false; }
            }
            return TSObjectErr1.alloc();
        }).toThrowError(/Cannot override native method "isEqual" with a property, define it as a JS function instead./);

        expect(() => {
            class TSObjectErr2 extends TNSDerivedInterface {
            }
            (TSObjectErr2.prototype as any).isEqual = true;
            return TSObjectErr2.alloc();
         }).toThrowError(/true cannot override native method "isEqual"./);
    });

    it('ExposeWithWrongParams', function () {
        expect(() => {
            class ExposeWithWrongParams extends NSObject {
                wrongRet() {}
                public static ObjCExposedMethods = {
                    'wrongRet': { returns: "a string", params: [interop.types.selector] }
                };
            }
            return ExposeWithWrongParams.alloc();
        }).toThrowError("\"a string\" Method wrongRet has an invalid return type encoding");
        expect(() => {
            class ExposeWithWrongParams2 extends NSObject {
                wrongArg() {}
                public static ObjCExposedMethods = {
                    'wrongArg': { returns: interop.types.selector, params: [3] }
                };
            }
            return ExposeWithWrongParams2.alloc();
        }).toThrowError("3 Method wrongArg has an invalid type encoding for argument 1");
        expect(() => {
            class ExposeWithWrongParams3 extends NSObject {
                wrongArg() {}
                public static ObjCExposedMethods = {
                    'wrongArg': { returns: interop.types.void, params: { notArray: true } }
                };
            }
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

        expect(TNSGetOutput()).toBe(
            'baseProtocolMethod1 called' +
            'baseProtocolMethod2 called');
    });

    it('ImplementProperties', function () {
        var object = TSObject1.alloc().init();

        TNSTestNativeCallbacks.protocolImplementationProperties(object);

        expect(TNSGetOutput()).toBe(
            'setBaseProtocolProperty1: called' +
            'baseProtocolProperty1 called' +
            'setBaseProtocolProperty1Optional: called' +
            'baseProtocolProperty1Optional called');
    });

    it('PlainExtends', function () {
        class A {
        }

        class B extends A {
        }

        expect(new B() instanceof A).toBe(true);
    });

    it('Scope', function () {
        global["Derived"] = 3;
        class Derived extends NSObject { };
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

        expect(TNSGetOutput()).toBe(
            'baseProtocolMethod1 called' +
            'baseProtocolMethod2 called');
    });

    it('TypeScriptDecoratedExposedMethods', function () {
        var object = TSDecoratedObject.alloc().init();

        TNSTestNativeCallbacks.inheritanceVoidSelector(object);
        expect(TNSTestNativeCallbacks.inheritanceVariadicSelector(object)).toBe('native');

        expect(TNSGetOutput()).toBe(
            'voidSelector called' +
            'variadicSelector:native x:9 called'
        );
    });

    it('TypeScriptDecoratedExposedMethodsCalledFromJs', function () {
        var object = TSDecoratedObject.alloc().init();

        object.voidSelector();
        expect(object.variadicSelectorX('js', 5)).toBe('js');
        TSDecoratedObject.staticFunc(9);

        expect(TNSGetOutput()).toBe(
            'voidSelector called' +
            'variadicSelector:js x:5 called' +
            'staticFunc:9 called'
        );
    });
});
