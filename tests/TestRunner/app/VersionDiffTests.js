describe(module.id, function() {
    afterEach(function () {
        TNSClearOutput();
    });

    function SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version) {
        var systemVersion = NSString.stringWithString(UIDevice.currentDevice.systemVersion);
        return systemVersion.compareOptions(version, NSStringCompareOptions.NSNumericSearch) !== NSComparisonResult.NSOrderedAscending;
    };

    function check(value, major, minor) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(`${major}.${minor}`)) {
            expect(value).toBeDefined(`must be available after version ${major}.${minor}`);
        } else {
            expect(value).toBeUndefined(`must be unavailable before version ${major}.${minor}`);
        }
    }

    function forEachVersion(action) {
        for (var major = 9; major <= 15; major++) {
            for (var minor = 0; minor <= 5; minor++) {
                action(major, minor);
            }
        }
    }

    it("Version interfaces", function() {
        forEachVersion((major, minor) => {
            var value = global[`TNSInterface${major}_${minor}Plus`];
            check(value, major, minor);
        });
    });

    it("Version function", function() {
        forEachVersion((major, minor) => {
            var value = global[`TNSFunction${major}_${minor}Plus`];
            check(value, major, minor);
        });
    });

    it("Version constant", function() {
        forEachVersion((major, minor) => {
            var value = global[`TNSConstant${major}_${minor}Plus`];
            check(value, major, minor);
        });
    });

    it("Version enum", function() {
        forEachVersion((major, minor) => {
            var value = global[`TNSEnum${major}_${minor}Plus`];
            check(value, major, minor);
        });
    });

    it("Version static method", function() {
        forEachVersion((major, minor) => {
            var value = global[`TNSInterfaceMembers${major}_${minor}`].staticMethod;
            check(value, major, minor);
        });
    });

    it("Version instance method", function() {
        forEachVersion((major, minor) => {
            var value = global[`TNSInterfaceMembers${major}_${minor}`].prototype.instanceMethod;
            check(value, major, minor);
        });
    });

    it("Version property", function() {
        forEachVersion((major, minor) => {
            var value = Object.getOwnPropertyDescriptor(global[`TNSInterfaceMembers${major}_${minor}`].prototype, 'property');
            check(value, major, minor);
        });
    });

    it("Version category static methods", function() {
        expect(TNSInterfaceAlwaysAvailable.unavailableStaticMethod).toBeUndefined("Parent Category is unavailable, so should the method.");
        expect(TNSInterfaceAlwaysAvailable.explicitlyAvailableStaticMethod1_0).toBeDefined("Parent Category is unavailable, but method has overridden it.");

        expect(TNSInterfaceAlwaysAvailable.availableStaticMethod1_0).toBeDefined("Parent Category is available, so should the method.");
        expect(TNSInterfaceAlwaysAvailable.explicitlyUnavailableStaticMethod).toBeUndefined("Parent Category is available, but method has overridden it.");
    });

    it("Version category methods", function() {
        const var = new TNSInterfaceAlwaysAvailable();

        expect(var.unavailableMethod).toBeUndefined("Parent Category is unavailable, so should the method.");
        expect(var.explicitlyAvailableMethod1_0).toBeDefined("Parent Category is unavailable, but method has overridden it.");

        expect(var.availableMethod1_0).toBeDefined("Parent Category is available, so should the method.");
        expect(var.explicitlyUnavailableMethod).toBeUndefined("Parent Category is available, but method has overridden it.");
    });
});
