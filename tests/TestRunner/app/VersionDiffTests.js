describe(module.id, function() {
    afterEach(function () {
        TNSClearOutput();
    });

    function SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version) {
        const systemVersion = __uikitformac ? NSString.stringWithString("13.2") : NSString.stringWithString(UIDevice.currentDevice.systemVersion);
        return systemVersion.compareOptions(version, NSStringCompareOptions.NSNumericSearch) !== NSComparisonResult.NSOrderedAscending;
    };

    function check(value, major, minor, valueDescription) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(`${major}.${minor}`)) {
            expect(value).toBeDefined(`${valueDescription} must be available after version ${major}.${minor}`);
        } else {
            expect(value).toBeUndefined(`${valueDescription} must be unavailable before version ${major}.${minor}`);
        }
    }

    function forEachVersion(action) {
        for (var major = 9; major <= 15; major++) {
            for (var minor = 0; minor <= 5; minor++) {
                action(major, minor);
            }
        }
    }

         
    it("UIDevice.systemVersion to return macOS Version", function() {
        const macOSVersionRegEx = /^10\.1[\d]/;
        if (__uikitformac) {
            // If this version becomes the correct iOS version again, remove the hardcoded "13.2" values from Metadata.mm and SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
            expect(UIDevice.currentDevice.systemVersion).toMatch(macOSVersionRegEx);
        } else {
       // If this version becomes the correct iOS version again, remove the hardcoded "13.2" values from Metadata.mm and SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
            expect(UIDevice.currentDevice.systemVersion).not.toMatch(macOSVersionRegEx);
        }
    });


    it("SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO compares against iOS (not macOS!) version", function() {
        expect(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("10.10") && !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("11.0")).toBe(false, `Invalid iOS version ${UIDevice.currentDevice.systemVersion} which is inside [10.10 and 11.0)`);
    });

    it("Version interfaces", function() {
        forEachVersion((major, minor) => {
            const className = `TNSInterface${major}_${minor}Plus`;
            var value = global[className];
            check(value, major, minor, className);
        });
    });

    it("Version function", function() {
        forEachVersion((major, minor) => {
            const functionName = `TNSFunction${major}_${minor}Plus`;
            var value = global[functionName];
            check(value, major, minor, functionName);
        });
    });

    it("Version constant", function() {
        forEachVersion((major, minor) => {
            const constName = `TNSConstant${major}_${minor}Plus`;
            var value = global[constName];
            check(value, major, minor, constName);
        });
    });

    it("Version enum", function() {
        forEachVersion((major, minor) => {
            const enumName = `TNSEnum${major}_${minor}Plus`;
            var value = global[enumName];
            check(value, major, minor, enumName);
        });
    });

    it("Version static method", function() {
        forEachVersion((major, minor) => {
            const className = `TNSInterfaceMembers${major}_${minor}`;
            var value = global[className].staticMethod;
            check(value, major, minor, `${className}.staticMethod`);
        });
    });

    it("Version instance method", function() {
        forEachVersion((major, minor) => {
            const className = `TNSInterfaceMembers${major}_${minor}`;
            var value = global[className].prototype.instanceMethod;
            check(value, major, minor, `${className}.instanceMethod`);
        });
    });

    it("Version property", function() {
        forEachVersion((major, minor) => {
            const className = `TNSInterfaceMembers${major}_${minor}`;
            var value = Object.getOwnPropertyDescriptor(global[className].prototype, 'property');
            check(value, major, minor, `${className}.property`);
        });
    });
         
    it("TNSInterfaceAlwaysAvailablePrivate has no metadata", function() {
        expect(global.TNSInterfaceAlwaysAvailablePrivate).toBeUndefined();
    });

    it("Base class which is unavailable should be skipped", function() {
        // Test case inspired from MTLArrayType(8.0) : MTLType(11.0) : NSObject
        // TNSInterfaceNeverAvailableDescendant : TNSInterfaceNeverAvailable(API31.7 - skipped) : TNSInterfaceAlwaysAvailable
        expect(Object.getPrototypeOf(TNSInterfaceNeverAvailableDescendant).toString()).toBe(TNSInterfaceAlwaysAvailable.toString(), "TNSInterfaceNeverAvailable base class should be skipped as it is unavailable");
    });

    it("Members of a protocol which is unavailable should be skipped only when not implemented by class", function() {
       expect(Object.getOwnPropertyNames(TNSInterfaceAlwaysAvailable)).toContain("staticPropertyFromProtocolNeverAvailable", "TNSProtocolNeverAvailable static properties that are implemented should be present although the protocol is unavailable");
       expect(Object.getOwnPropertyNames(TNSInterfaceAlwaysAvailable)).not.toContain("staticPropertyFromProtocolNeverAvailableNotImplemented", "TNSProtocolNeverAvailable unimplemented static properties should be skipped");
       expect(TNSInterfaceAlwaysAvailable.staticMethodFromProtocolNeverAvailable).toBeDefined("TNSProtocolNeverAvailable static methods that are implemented should be present although the protocol is unavailable");
       expect(TNSInterfaceAlwaysAvailable.staticMethodFromProtocolNeverAvailableNotImplemented).toBeUndefined("TNSProtocolNeverAvailable unimplemented static methods should be skipped");
       expect(Object.getOwnPropertyNames(TNSInterfaceAlwaysAvailable.prototype)).toContain("propertyFromProtocolNeverAvailable", "TNSProtocolNeverAvailable properties that are implemented should be present although the protocol is unavailable");
       expect(Object.getOwnPropertyNames(TNSInterfaceAlwaysAvailable.prototype)).not.toContain("propertyFromProtocolNeverAvailableNotImplemented", "TNSProtocolNeverAvailable unimplemented properties should be skipped");
       expect(new TNSInterfaceAlwaysAvailable().methodFromProtocolNeverAvailable).toBeDefined("TNSProtocolNeverAvailable methods that are implemented should be present although the protocol is unavailable");
       expect(new TNSInterfaceAlwaysAvailable().methodFromProtocolNeverAvailableNotImplemented).toBeUndefined("TNSProtocolNeverAvailable unimplemented methods should be skipped");
    });

    it("Members of a protocol which is available should be present", function() {
        const obj = new TNSInterfaceAlwaysAvailable();
        let expectedOutput = "";
        expect(Object.getOwnPropertyNames(TNSInterfaceAlwaysAvailable.prototype)).toContain("propertyFromProtocolAlwaysAvailable", "TNSProtocolAlwaysAvailable properties should be present as it is available");
        expect(obj.propertyFromProtocolAlwaysAvailable).toBe(0);
       
        expect(obj.methodFromProtocolAlwaysAvailable).toBeDefined("TNSProtocolAlwaysAvailable methods should be present as it is available");
        obj.methodFromProtocolAlwaysAvailable(); expectedOutput += "methodFromProtocolAlwaysAvailable called";
        expect(TNSGetOutput()).toBe(expectedOutput);
       
        TNSClearOutput();
       
        expectedOutput = "";
        expect(Object.getOwnPropertyNames(TNSInterfaceAlwaysAvailable)).toContain("staticPropertyFromProtocolAlwaysAvailable", "TNSProtocolAlwaysAvailable static properties should be present as it is available");
        TNSInterfaceAlwaysAvailable.staticPropertyFromProtocolAlwaysAvailable; expectedOutput += "staticPropertyFromProtocolAlwaysAvailable called";
       
        expect(TNSInterfaceAlwaysAvailable.staticMethodFromProtocolAlwaysAvailable).toBeDefined("TNSProtocolAlwaysAvailable static methods should be present as it is available");
        TNSInterfaceAlwaysAvailable.staticMethodFromProtocolAlwaysAvailable(); expectedOutput += "staticMethodFromProtocolAlwaysAvailable called";
       
       expect(TNSGetOutput()).toBe(expectedOutput);
    });
});
