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
            expect(value).toBeDefined();
        } else {
            expect(value).toBeUndefined();
        }
    }

    function forEachVersion(action) {
        for (var major = 7; major <= 10; major++) {
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
});
