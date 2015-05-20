describe(module.id, function() {
    afterEach(function () {
        TNSClearOutput();
    });

    it("InterfaceDiff", function() {
        if (SYSTEM_VERSION_LESS_THAN("7.1")) {
            expect(global.MPContentItem).toBeUndefined();
        } else {
            var object = new MPContentItem();
            expect(object).not.toBeUndefined();
        }
    });

    it("ConstantDiff", function() {
        if (SYSTEM_VERSION_LESS_THAN("7.1")) {
            expect(global.MKLaunchOptionsCameraKey).toBeUndefined();
        } else {
            expect(global.MKLaunchOptionsCameraKey).not.toBeUndefined();
        }
    });

    it("PropertyDiff", function() {
        var object = SKView.alloc().init();
        if (SYSTEM_VERSION_LESS_THAN("8.0")) {
            expect(object.allowsTransparency).toBeUndefined();
        } else {
            expect(object.allowsTransparency).not.toBeUndefined();
        }
    });

    it("FunctionDiff", function() {
        if (SYSTEM_VERSION_LESS_THAN("7.1")) {
            expect(global.SKTerminateForInvalidReceipt).toBeUndefined();
        } else {
            expect(global.SKTerminateForInvalidReceipt).not.toBeUndefined();
        }
    });
         
    it("FunctionDiff", function() {
        if (SYSTEM_VERSION_LESS_THAN("8.0")) {
            expect(global.SCNAction).toBeUndefined();
        } else {
            expect(global.SCNAction).not.toBeUndefined();
        }
    });
});
