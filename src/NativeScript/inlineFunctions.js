Object.assign(global, {
    CGPointMake(x, y) {
        return new CGPoint({ x, y });
    },
    CGRectMake(x, y, width, height) {
        return new CGRect({ origin: { x, y }, size: { width, height } });
    },
    CGSizeMake(width, height) {
        return new CGSize({ width, height });
    },
    UIEdgeInsetsMake(top, left, bottom, right) {
        return new UIEdgeInsets({ top, left, bottom, right });
    },
    NSMakeRange(location, length) {
        return new NSRange({ location, length });
    },

    // Decorators support    
    __decorate(decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    },
    __param(paramIndex, decorator) {
        return function (target, key) { decorator(target, key, paramIndex); }
    },

    // Decorators
    ObjCClass() {
        var protocols = Array.from(arguments);

        return function (target) {
            if (protocols.length > 0) {
                target.ObjCProtocols = (target.ObjCProtocols && target.ObjCProtocols instanceof Array ? target.ObjCProtocols.concat(protocols) : protocols);
            }    
        }
    },
    ObjCMethod() {
        var name = arguments[0];
        var hasName = (name !== undefined && typeof name === "string");
        var returnType = (hasName ? arguments[1] : arguments[0]);

        return function (target, propertyKey, descriptor) {
            if (!target.constructor.ObjCExposedMethods) {
                target.constructor.ObjCExposedMethods = {};
            }
            if (!target.constructor.ObjCExposedMethods[propertyKey]) {
                target.constructor.ObjCExposedMethods[propertyKey] = {};
            }
            target.constructor.ObjCExposedMethods[propertyKey].returns = returnType || interop.types.void;

            if (hasName && name !== propertyKey) {
                target.constructor.ObjCExposedMethods[name] = target.constructor.ObjCExposedMethods[propertyKey];
                delete target.constructor.ObjCExposedMethods[propertyKey];

                target[name] = function () { 
                    return this[propertyKey].apply(this, arguments);
                }
            }
        }
    },
    ObjC() {
        var args = Array.from(arguments);        

        return function (target, propertyKey, descriptor) {
            if (propertyKey === undefined) {
                return ObjCClass.apply(this, args)(target);
            }

            ObjCMethod.apply(this, args)(target, propertyKey, descriptor);
        };
    },
    ObjCParam(type) {
        return function (target, propertyKey, parameterIndex) {
            if (!target.constructor.ObjCExposedMethods) {
                target.constructor.ObjCExposedMethods = {};
            }
            if (!target.constructor.ObjCExposedMethods[propertyKey]) {
                target.constructor.ObjCExposedMethods[propertyKey] = {};
            }
            var exposedMethod = target.constructor.ObjCExposedMethods[propertyKey];
            if (!exposedMethod.params) {
                exposedMethod.params = [];
            }
            exposedMethod.params[parameterIndex] = type || interop.types.void;
        };
    },
});

Object.defineProperty(global, "__tsEnum", {
    writable: false,
    enumerable: false,
    configurable: false,
    value: function(obj) {
        var result = {};
        for (var key of Object.keys(obj)) {
            result[key] = obj[key];
            result[obj[key]] = key;
        }
        return result;
    }
});
