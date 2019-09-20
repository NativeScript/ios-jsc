describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("NativeArrayWithArray", function () {
        var object = NSArray.arrayWithArray([0, 1, '2']);
        expect(object.objectAtIndex(0)).toBe(0);
        expect(object.objectAtIndex(1)).toBe(1);
        expect(object.objectAtIndex(2)).toBe('2');
        expect(object.count).toBe(3);
        expect(object.hash).toBe(3);
    });

    it("MethodCalledInDealloc", function () {
        expect(function () {
            (function () {
                var JSApi = TNSApi.extend({});
                new JSApi();
            }());

            // TODO
            // [self collectGarbage];
        }).not.toThrow();
    });

    it("CustomGetterAndSetter", function () {
        var object = new TNSApi();
        expect(object.property).toBe(0);
        object.property = 3;
        expect(object.property).toBe(3);

        TNSTestNativeCallbacks.apiCustomGetterAndSetter(object);
    });

    it("OverrideWithCustomGetterAndSetter", function () {
        var JSApi = TNSApi.extend({
            get property() {
                return -Object.getOwnPropertyDescriptor(TNSApi.prototype, 'property').get.call(this);
            },
            set property(x) {
                Object.getOwnPropertyDescriptor(TNSApi.prototype, 'property').set.call(this, x * 2);
            },
        });
        var object = new JSApi();
        expect(object.property).toBe(0);
        object.property = 3;
        expect(object.property).toBe(-6);

        TNSTestNativeCallbacks.apiOverrideWithCustomGetterAndSetter(object);
    });

    // TODO
    // it("BigIntMethods", function() {
    //      var bigInt = functionWithLongLong('9223372036854775807');
    //      assert(bigInt.value === '9223372036854775807');
    //      assert(isNaN(bigInt.valueOf()));
    //      assert(('' + bigInt) === 'NaN');
    //      assert(bigInt.toString() === '9223372036854775807');
    //      assert(isNaN(1 + bigInt));
    // });

    // TODO
    // it("BigIntEdgeCases", function() {
    //      assert(functionWithLongLong(9007199254740992) === 9007199254740992);
    //      assert(functionWithLongLong('9007199254740993').toString() === '9007199254740993');

    //      assert(functionWithLongLong(-9007199254740992) === -9007199254740992);
    //      assert(functionWithLongLong('-9007199254740993').toString() === '-9007199254740993');
    // });

    // TODO: check object
//    it("CFDictionary", function() {
//        var object = new NSMutableDictionary();
//        object.setObjectForKey('value', 'key');
//        var value = CFDictionaryGetValue(object, 'key');
//    });

    it("instanceOfNativeClass", function () {
        var array = new NSMutableArray();
        expect(array instanceof NSMutableArray).toBe(true);
        expect(array instanceof NSArray).toBe(true);
        expect(array instanceof NSObject).toBe(true);
    });

    it("instanceOfDerivedClass", function () {
        var JSObject = TNSDerivedInterface.extend({});
        var object = JSObject.alloc().init();
        expect(object instanceof JSObject).toBe(true);
        expect(object instanceof TNSDerivedInterface).toBe(true);
        expect(object instanceof NSObject).toBe(true);
    });

    it("instanceOfUITabBarController", function () {
        var object = UITabBarController.alloc().init();
        expect(object instanceof UITabBarController).toBe(true);
        expect(object instanceof UIViewController).toBe(true);
        expect(object instanceof UIResponder).toBe(true);
        expect(object instanceof NSObject).toBe(true);
    });

    it("NSStringFromClassForClassWithoutMetadata", function () {
        var c = UITableViewCell.new();
        // UITableViewCellContentView is internal class thus we don't have metadata for it
        expect(NSStringFromClass(c.subviews[0].class())).toBe('UITableViewCellContentView');
    });

    it("Appearance", function () {
        expect(UILabel.appearance().description.indexOf('<Customizable class: UILabel>')).not.toBe(-1);

        UILabel.appearance().textColor = UIColor.redColor;
        expect(UILabel.appearance().textColor).toBe(UIColor.redColor);
        expect(UILabel.appearance().constructor).toBe(UILabel);
    });

    it("ReadonlyPropertyInProtocolAndOverrideWithSetterInInterface", function () {
        var object = new UIView();
        object.bounds = {
            origin: {
                x: 10,
                y: 20
            },
            size: {
                width: 30,
                height: 40
            }
        };

        TNSTestNativeCallbacks.apiReadonlyPropertyInProtocolAndOverrideWithSetterInInterface(object);
    });

    it("DescriptionOverride", function () {
        var object = NSObject.extend({
            get description() {
                return 'js description';
            }
        }).alloc().init();

        expect(object.description).toBe('js description');
        expect(object.toString()).toBe('js description');

        TNSTestNativeCallbacks.apiDescriptionOverride(object);
    });

    it("ProtocolClassConflict", function () {
        expect(NSProtocolFromString("NSObject")).toBe(NSObjectProtocol);
    });

    it("NSMutableArrayMethods", function () {
        var JSMutableArray = NSMutableArray.extend({
            init: function () {
                var self = NSMutableArray.prototype.init.apply(this, arguments);
                self._array = [];
                return self;
            },
// TODO
//            dealloc: function() {
//                TNSLog(this.count);
//                delete this._array;
//                NSMutableArray.prototype.dealloc.apply(this, arguments);
//            },
            insertObjectAtIndex: function (anObject, index) {
                this._array.splice(index, 0, anObject);
            },
            removeObjectAtIndex: function (index) {
                this._array.splice(index, 1);
            },
            addObject: function (anObject) {
                this._array.push(anObject);
            },
            removeLastObject: function () {
                this._array.pop();
            },
            replaceObjectAtIndexWithObject: function (index, anObject) {
                this._array[index] = anObject;
            },
            objectAtIndex: function (index) {
                return this._array[index];
            },
            get count() {
                return this._array.length;
            },
            get hash() {
                return this.count;
            }
        }, {
            name: 'JSMutableArray'
        });

        (function () {
            var array = new JSMutableArray();
            TNSTestNativeCallbacks.apiNSMutableArrayMethods(array);
        }());
        __collect();

        expect(TNSGetOutput()).toBe('44abcd');
    });

    it("SpecialCaseProperty_When_InstancesRespondToSelector:_IsFalse", function () {
        var field = new UITextField();
        expect(field.secureTextEntry).toBe(false);
        field.secureTextEntry = true;
        expect(field.secureTextEntry).toBe(true);
    });

     it("SpecialCaseProperty_When_CustomSelector_ImplementedInJS", function () {
        var field = new (UITextField.extend({
            get secureTextEntry() {
                TNSLog("getter");
                return this._secureTextEntry;
            },
            set secureTextEntry(val) {
                this._secureTextEntry = val;
                TNSLog("setter:" + val);
            }
        }))();
        var expectedOutput = "";

        expect(field.secureTextEntry).toBeUndefined(); expectedOutput+="getter";

        field.secureTextEntry = true; expectedOutput+="setter:true";

        expect(field.secureTextEntry).toBe(true); expectedOutput+="getter";

        field.secureTextEntry = false; expectedOutput+="setter:false";

        expect(field.secureTextEntry).toBe(false); expectedOutput+="getter";

        expect(TNSGetOutput()).toBe(expectedOutput);
     });

    it("TypedefPointerClass", function () {
        expect(TNSApi.alloc().init().strokeColor).toBeNull();
    });

    if (TNSIsConfigurationDebug) {
        it("GlobalObjectProperties", function () {
            var propertyNames = Object.getOwnPropertyNames(global);
            expect(propertyNames).toContain("NSTimeZoneNameStyle");
            expect(propertyNames).toContain("UITextViewTextDidChangeNotification");
            expect(propertyNames).toContain("UIApplicationStateRestorationBundleVersionKey");
            expect(propertyNames.length).toBeGreaterThan(4000);
        });
    }

    it("NSObjectSuperClass", function () {
        expect(NSObject.superclass()).toBeNull();
        expect(NSObject.alloc().init().superclass).toBeNull();
    });

    it("NSObjectAsId", function () {
        expect(NSObject.respondsToSelector('description')).toBe(true);
    });

    it("FunctionLength", function () {
        expect(functionWithInt.length).toBe(1);
        expect(NSObject.isSubclassOfClass.length).toBe(1);
    });

    it("ArgumentsCount", function () {
        expect(function () {
            NSObject.alloc().init(3);
        }).toThrowError();
    });

    it("NSError", function () {
        expect(function () {
            TNSApi.new().methodError(0);
        }).not.toThrow();

        var isThrown = false;
        try {
            TNSApi.new().methodError(1);
        } catch (e) {
            isThrown = true;
            expect(e instanceof interop.NSErrorWrapper).toBe(true);
            expect(e.stack).toEqual(jasmine.any(String));
        } finally {
            expect(isThrown).toBe(true);
        }

        expect(function () {
            TNSApi.new().methodError(1, null);
        }).not.toThrow();

        expect(function () {
            TNSApi.new().methodError(1, 2, 3);
        }).toThrowError(/arguments count/);

        var errorRef = new interop.Reference();
        TNSApi.new().methodError(1, errorRef);
        expect(errorRef.value instanceof NSError).toBe(true);
    });

    it("NSErrorOverride", function () {
        var JSApi = TNSApi.extend({
            methodError: function (x) {
                TNSLog(x.toString());

                if (x !== 0) {
                    throw new Error("JS error");
                }
            }
        });

        TNSTestNativeCallbacks.apiNSErrorOverride(JSApi.new());
        expect(TNSGetOutput()).toBe("011TNSErrorDomain");

        expect(function () {
            JSApi.new().methodError(1);
        }).toThrowError(/JS error/);
    });

    it("NSErrorExpose", function () {
        var JSApi = TNSApi.extend({
            "method:error2:": function (x) {
                TNSLog(x.toString());

                if (x !== 0) {
                    throw new Error("JS error");
                }
            }
        }, {
            exposedMethods: {
                "method:error2:": {
                    returns: interop.types.bool,
                    params: [interop.types.int32, new interop.types.ReferenceType(NSError)] }
            }
        });

        TNSTestNativeCallbacks.apiNSErrorExpose(JSApi.new());
        expect(TNSGetOutput()).toBe("011TNSErrorDomain");

        expect(function () {
            JSApi.new()["method:error2:"](1);
        }).toThrowError(/JS error/);
    });

    it("globalPropertyOfGlobalObject", function () {
        expect(global.toString()).toBe("[object NativeScriptGlobal]");
    });

    it("globalPropertyOfGlobalObjectIsEqulatToGlobalScopeThis", function () {
        var globalScopeThis = Function("return this")();
        expect(global).toBe(globalScopeThis);
    });

    it("Swizzle", function () {
        var object = TNSSwizzleKlass.alloc().init();

        (function () {
            var nativeProperty = Object.getOwnPropertyDescriptor(TNSSwizzleKlass.prototype, 'aProperty');
            Object.defineProperty(TNSSwizzleKlass.prototype, 'aProperty', {
                get: function () {
                    return 2 * nativeProperty.get.call(this);
                },
                set: function (x) {
                    nativeProperty.set.call(this, 2 * x);
                }
            });

            var nativeStaticMethod = TNSSwizzleKlass.staticMethod;
            TNSSwizzleKlass.staticMethod = function (x) {
                return 2 * nativeStaticMethod.apply(this, arguments);
            };

            var nativeInstanceMethod = TNSSwizzleKlass.prototype.instanceMethod;
            TNSSwizzleKlass.prototype.instanceMethod = function (x) {
                return 2 * nativeInstanceMethod.apply(this, arguments);
            };

            object.aProperty = 4;
            expect(object.aProperty).toBe(16, "property * 4");
            expect(TNSSwizzleKlass.staticMethod(4)).toBe(8, "static method * 2");
            expect(object.instanceMethod(4)).toBe(8, "instance method * 2");

            TNSTestNativeCallbacks.apiSwizzle(TNSSwizzleKlass.alloc().init());
            expect(TNSGetOutput()).toBe('1266');
            TNSClearOutput();
        }());

        (function () {
            var swizzledProperty = Object.getOwnPropertyDescriptor(TNSSwizzleKlass.prototype, 'aProperty');
            Object.defineProperty(TNSSwizzleKlass.prototype, 'aProperty', {
                get: function () {
                    return 3 * swizzledProperty.get.call(this);
                },
                set: function (x) {
                    swizzledProperty.set.call(this, 3 * x);
                }
            });

            var swizzledStaticMethod = TNSSwizzleKlass.staticMethod;
            TNSSwizzleKlass.staticMethod = function (x) {
                return 3 * swizzledStaticMethod.apply(this, arguments);
            };

            var swizzledInstanceMethod = TNSSwizzleKlass.prototype.instanceMethod;
            TNSSwizzleKlass.prototype.instanceMethod = function (x) {
                return 3 * swizzledInstanceMethod.apply(this, arguments);
            };

            object.aProperty = 4;
            // Multiplier is 3*2 (from previous test)
            // for methods is 6 and for properties 36 (set*get)
            expect(object.aProperty).toBe(144);
            expect(TNSSwizzleKlass.staticMethod(4)).toBe(24);
            expect(object.instanceMethod(4)).toBe(24);

            TNSTestNativeCallbacks.apiSwizzle(TNSSwizzleKlass.alloc().init());
            expect(TNSGetOutput()).toBe('1081818');
            TNSClearOutput();
        }());
    });

    if (interop.sizeof(interop.Pointer) == 8) {
        it("TaggedPointers", function () {
            expect(NSDate.dateWithTimeIntervalSinceReferenceDate(0)).toBe(NSDate.dateWithTimeIntervalSinceReferenceDate(0));
            expect(NSDate.dateWithTimeIntervalSinceReferenceDate(0).class()).toBe(NSClassFromString("__NSTaggedDate"));
        });
    }

    function range(start, end, inclusive) {
        var mapper = (_, k) => start + k;
        if (end < start) {
            mapper = (_, k) => start - k;
        }

        return Array.from({ length: Math.abs(start - end) + (inclusive ? 1 : 0) }, mapper);
    }

    it("should be able to iterate over NSArray", function () {
        var expected = range(0, 256);
        var actual = new Array();

        var array = NSArray.arrayWithArray(expected);
        for (var x of array) {
            actual.push(x);
        }

        expect(actual).toEqual(expected);
    });

    it("should be able to iterate over NSEnumerator", function () {
        var expected = range(0, 256);
        var actual = new Array();

        var array = NSArray.arrayWithArray(expected);
        for (var x of array.reverseObjectEnumerator()) {
            actual.push(x);
        }
        expected.reverse();

        expect(actual).toEqual(expected);
    });

    it("should be able to call string.normalize with simple value", function () {
        var str = 'string value';
        expect(str.normalize()).toBe(str);
    });

    describe("__releaseNativeCounterpart", function () {
        it("deallocates js derived instances created with alloc().init()", function () {
            var P = TNSAllocLog.extend({
                dealloc: function () {
                    TNSAllocLog.dealloc.apply(this);
                }
            });

            var p = P.alloc().init();

            __releaseNativeCounterpart(p);

            const output = TNSGetOutput();
            expect(output).toBe("TNSAllocLog initTNSAllocLog dealloc");
        });

        it("deallocates js derived instances created with new", function () {
            var P = TNSAllocLog.extend({
                dealloc: function () {
                    TNSAllocLog.dealloc.apply(this);
                }
            });

            var p = new P();

            __releaseNativeCounterpart(p);

            const output = TNSGetOutput();
            expect(output).toBe("TNSAllocLog initTNSAllocLog dealloc");
        });

        it("deallocates native instances created with alloc().init()", function () {
            var p = TNSAllocLog.alloc().init();

            __releaseNativeCounterpart(p);

            const output = TNSGetOutput();
            expect(output).toBe("TNSAllocLog initTNSAllocLog dealloc");
        });

        it("deallocates native instances created with new", function () {
            var p = new TNSAllocLog();

            __releaseNativeCounterpart(p);

            const output = TNSGetOutput();
            expect(output).toBe("TNSAllocLog initTNSAllocLog dealloc");
        });

        it("sets object to nil", function () {
            var arr = NSArray.arrayWithArray([1,2,3]);
            expect(arr.count).toBe(3);
            __releaseNativeCounterpart(arr);

            expect(arr.toString()).toBe(null);
            expect(typeof arr).toBe(typeof {});

            // Extract from [Working with nil](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithObjects/WorkingwithObjects.html#//apple_ref/doc/uid/TP40011210-CH4-SW22):
            // If you expect a return value from a message sent to nil, the return value will be
            // nil for object return types, 0 for numeric types, and NO for BOOL types. Returned
            // structures have all members initialized to zero.
            expect(arr.count).toBe(0);
        });
        
        it("exceptions", function () {
            expect(() => __releaseNativeCounterpart(1, 2, 3)).toThrowError(/Actual arguments count: "3". Expected: "1". \(evaluating '__releaseNativeCounterpart\(1, 2, 3\)'\)/);
            const getNotANativeWrapperRegex2 = (obj, objParam) => new RegExp(`${obj} is an object which is not a native wrapper. \\(evaluating '__releaseNativeCounterpart\\(${objParam}\\)'\\)`);
            const getNotANativeWrapperRegex = obj => getNotANativeWrapperRegex2(obj, JSON.stringify(obj));
           
            expect(() => __releaseNativeCounterpart(0)).toThrowError(getNotANativeWrapperRegex(0));
            expect(() => __releaseNativeCounterpart("")).toThrowError(getNotANativeWrapperRegex(""));
            expect(() => __releaseNativeCounterpart([])).toThrowError(getNotANativeWrapperRegex2("Array", "\\[\\]"));
            expect(() => __releaseNativeCounterpart({})).toThrowError(getNotANativeWrapperRegex({}));
            expect(() => __releaseNativeCounterpart(null)).toThrowError(getNotANativeWrapperRegex(null));
            expect(() => __releaseNativeCounterpart(undefined)).toThrowError(getNotANativeWrapperRegex(undefined));
        });
    });
    describe("async", function () {
        it("should work", function (done) {
            var str = NSString.alloc();
            str.initWithString.async(str, ["test"])
                .then(value => expect(value.toString()).toEqual("test"))
                .then(done);
        });

        it("argument marshalling phase should be done asyncronously", function (done) {
            var str = NSString.alloc();
            str.initWithString.async(str, [])
                .then(() => { throw new Error ("Promise should be rejected due to incorrect number of arguments."); })
                .catch(err => {
                    expect(err.toString()).toMatch(/Error.* arguments count.*0.*expected.*1/i);
                    done();
                });
        });

        it("should reject the returned promise if an error is raised in the result marshalling phase", function (done) {
            var api = TNSApi.new();
            api.methodError.async(api, [1])
            .catch(error => {
                expect(error).toEqual(jasmine.any(interop.NSErrorWrapper));
                done();
            });
        });

        if (isSimulator) {
            // Skip on simulator because libffi breaks exception unwinding on iOS Simulator
            // see https://github.com/libffi/libffi/issues/418
            console.warn("warning: Skipping async ObjC exceptions tests on Simulator device!");
        } else {
            it("should throw Objective-C exceptions to JavaScript", function (done) {
                const value = 333;
                const arr = NSArray.arrayWithObject(value);
                var promise = arr.objectAtIndex.async(arr, [0])
                .then(res => {
                    expect(res).toBe(value);
                    expect(NSThread.currentThread.isMainThread).toBe(true);
                })
                .then(() => arr.objectAtIndex.async(arr, [2]))
                .catch(error => {
                    expect(NSThread.currentThread.isMainThread).toBe(true);
                    expect(error.toString()).toMatch("index 2 beyond bounds");
                    expect(error.stack).toEqual("objectAtIndex([native code])\nat [native code]");
                    done();
                });
             });
        }
    });

    it("should distinguish between undefined and unavailable variables", function () {
        expect(function() {
            global.TNSUnavailableConstant;
        }).toThrowError(ReferenceError, /TNSUnavailableConstant/);
    });

    it("bridged types", function () {
        expect(TNSObjectGet() instanceof NSObject).toBe(true);
        expect(TNSMutableObjectGet() instanceof NSObject).toBe(true);
    });

    it("returns retained", function () {
        expect(functionReturnsNSRetained().retainCount()).toBe(1);
        expect(functionReturnsCFRetained().retainCount()).toBe(1);
        expect(functionImplicitCreate().retainCount()).toBe(1);

        var obj = functionExplicitCreateNSObject();
        expect(obj.retainCount()).toBe(2);
        CFRelease(obj);

        expect(TNSReturnsRetained.methodReturnsNSRetained().retainCount()).toBe(1);
        expect(TNSReturnsRetained.methodReturnsCFRetained().retainCount()).toBe(1);
        expect(TNSReturnsRetained.newNSObjectMethod().retainCount()).toBe(1);
    });

    it("unmanaged", function () {
        var unmanaged = functionReturnsUnmanaged();
        expect('takeRetainedValue' in unmanaged).toBe(true);
        expect('takeUnretainedValue' in unmanaged).toBe(true);
        expect(functionReturnsUnmanaged().takeRetainedValue().retainCount()).toBe(1);

        var value = functionReturnsUnmanaged().takeUnretainedValue();
        expect(value.retainCount()).toBe(2);
        CFRelease(value);

        unmanaged.takeRetainedValue();
        expect(function() {
            unmanaged.takeUnretainedValue();
        }).toThrow();
    });

    it('methods can be recursively called', function() {
        var result = TNSTestNativeCallbacks.callRecursively(function() {
            return TNSTestNativeCallbacks.callRecursively(function() {
                 return "InnerRecursiveResult";
            });
        });
        expect(result).toBe("InnerRecursiveResult");
    });

    it('methods returning blocks can be recursively called', function() {
        var i = 0;
        var stack = null;
        var log = function(message) {
            if (stack) {
                stack += " > " + message;
            } else {
                stack = message;
            }
        }

        log("start");
        var Derived = TNSTestNativeCallbacks.extend({
            getBlock: function() {
                i++;
                var that = this;
                if (i == 1) {
                    log("get recurse");
                    that.getBlockFromNative()();
                    return function() {
                        log("f1");
                    }
                } else if (i == 2) {
                    log("get recurse");
                    that.getBlockFromNative()();
                    return function() {
                        log("f2");
                    }
                } else {
                    log("get bottom");
                    return function() {
                        log("f3");
                    }
                }
            }
        });

        var inst = Derived.alloc().init();

        log("get");
        var block = inst.getBlock();
        log("exec");
        var blockResult = block();
        log("end");

        var expectedStack = "start > get > get recurse > get recurse > get bottom > f3 > f2 > exec > f1 > end";

        expect(stack).toBe(expectedStack);
    });

    it("should allow calling callbacks from another thread", function () {
        var result = TNSTestNativeCallbacks.callOnThread(function() {
            return 'method called';
        });

        expect(result).toBe('method called');
    });

    it("Unimplemented properties from UIBarItem class should be provided by the inheritors", function () {
        var classConstructors = ["UIBarButtonItem", "UITabBarItem"];
        var props = ["enabled", "image", "imageInsets", "title"];
        if (NSProcessInfo.processInfo.isOperatingSystemAtLeastVersion({majorVersion: 11, minorVersion: 0, patchVersion: 0})) {
            props = props.concat("landscapeImagePhone", "landscapeImagePhoneInsets");
        }

        for (var klass of classConstructors) {
            var instance = new global[klass]();
            for (var prop of props) {
                expect(instance[prop]).toBeDefined(`"${prop}" must be defined in instances of "${klass}"`);
            }
        }
    });

    it("Unimplemented properties from MTLRenderPassAttachmentDescriptor class should be provided by the inheritors", function () {
        var classConstructors = [
            "MTLRenderPassDepthAttachmentDescriptor", "MTLRenderPassStencilAttachmentDescriptor",
            "MTLRenderPassColorAttachmentDescriptor"
        ];
        var props = [
            "depthPlane", "level", "loadAction", "resolveDepthPlane", "resolveLevel", "resolveSlice",
            "resolveTexture", "slice", "storeAction", "texture"
        ];

        if (NSProcessInfo.processInfo.isOperatingSystemAtLeastVersion({majorVersion: 11, minorVersion: 0, patchVersion: 0})) {
            props = props.concat("storeActionOptions");
        }

        for (var klass of classConstructors) {
            var instance = new global[klass]();
            for (var prop of props) {
                expect(instance[prop]).toBeDefined(`"${prop}" must be defined in instances of "${klass}"`);
            }
        }
    });

    // Metal is unavailable on iOS Simulator and devices with processors before A7 (arm64 on iPhone 5s)
    if (!isSimulator && interop.sizeof(interop.types.id) == 8) {
        it("MetalKit private interface members can be accessed", function() {
            const device = MTLCreateSystemDefaultDevice();
            expect(device.toString()).toMatch(/^<\w*?Device: 0x/);
            const queue = device.newCommandQueue();
            expect(queue.toString()).toMatch(/^<\w*?CommandQueue: 0x/);
            const buffer = queue.commandBuffer();
            expect(buffer.toString()).toMatch(/^<\w*?CommandBuffer: 0x/);
            const view = MTKView.alloc().initWithFrameDevice(CGRectMake(0,0,100,100), device);
            expect(view.toString()).toMatch(/^<MTKView: 0x\w*; frame = \(0 0; 100 100\); .*>/);
            const texture = view.currentDrawable.texture;
            expect(texture.toString()).toMatch(/^<\w*?Texture: 0x/);

            buffer.presentDrawable(view.currentDrawable);
            buffer.commit();
        });
    }

    if (TNSIsConfigurationDebug) {
        // skip test in release because it requires downloading from the internet
        it("NSURLSession.sharedSession.downloadTaskWithURLCompletionHandler's ", function(done) {
           const url = NSURL.URLWithString("http://upload.wikimedia.org/wikipedia/commons/7/7f/Williams_River-27527.jpg");
           const downloadPhotoTask = NSURLSession.sharedSession.downloadTaskWithURLCompletionHandler(url, () => {
               expect(downloadPhotoTask.response.toString()).toContain("Williams_River-27527.jpg");
               expect(downloadPhotoTask.response.statusCode).toBe(200);
               // execute `done` on main thread, otherwise ApiIterator will be executed on a worker thread.
               // Generally this shouldn't be an issue but WebKit.framework has classes with static initializers which
               // require to be run the main thread
               NSOperationQueue.mainQueue.addOperationWithBlock(done);
           });
           downloadPhotoTask.resume();
        });

        it("Completion handler doesn't hijack main tests execution in a worker thread", function() {
           expect(NSThread.isMainThread).toBe(true);
        });
    }
    if (TNSIsConfigurationDebug) {
        it("ApiIterator", function () {
            var counter = 0;
            Object.getOwnPropertyNames(global).forEach(function (globalName) {
//                console.debug(`Symbol global.${globalName}`);
                                                       
                // according to SDK headers kCFAllocatorUseContext is of type id, but in fact it is not
                if (globalName == "kCFAllocatorUseContext"
                    || globalName == "JSExport"
                    || globalName == "kSCNetworkInterfaceIPv4"
                    ) {
                    return;
                }

                counter++;

                try {
                    var symbol = global[globalName];
                } catch (e) {
                    if (e instanceof ReferenceError) {
                        return;
                    }

                    throw e;
                }

                if (NSObject.isPrototypeOf(symbol) || symbol === NSObject) {
                    var klass = symbol;
                    expect(klass).toBeDefined(`Class ${globalName} should be defined.`);

//                    console.debug(`Entering class ${klass}`);

                    Object.getOwnPropertyNames(klass).forEach(function (y) {
                        if (klass.respondsToSelector(y)) {
//                            console.debug(`Checking class member ${globalName} . ${y}`);

                            // supportedVideoFormats is a property and it's getter is being called the value is read below.
                            // We skip it because it will throw "Supported video formats should be called on individual configuration class."
                            if (y == "supportedVideoFormats"
                                || (globalName == "MPMusicPlayerController" &&
                                     (y == "applicationQueuePlayer") || (y == "applicationMusicPlayer")) // Blocking calls in Catalyst
                                ) {
                                return;
                            }
                            var method = klass[y];
                            expect(method).toBeDefined(`Static method ${globalName} . ${y} should be defined.`);

                            counter++;
                        }
                    });

                    Object.getOwnPropertyNames(klass.prototype).forEach(function (y) {
                        if (klass.instancesRespondToSelector(y)) {
//                            console.debug(`Checking instance member ${globalName} . ${y}`);
                            
                            var property = Object.getOwnPropertyDescriptor(klass.prototype, y);

                            if (!property) {
                                var method = klass.prototype[y];
                                expect(method).toBeDefined(`Instance method -[${globalName} ${y}] should be defined.`);
                            }

                            counter++;
                        }
                    });
                }

                if (counter % 100 === 0) {
                    __collect();
                }
            });

            expect(counter).toBeGreaterThan(2900);
        });
    }
});
