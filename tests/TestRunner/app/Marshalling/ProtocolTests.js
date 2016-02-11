describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("Base methods", function () {
        expect(TNSBaseProtocol1).toBeDefined();

        expect(TNSBaseProtocol1.baseProtocolMethod1).toBeDefined();
        expect(TNSBaseProtocol1.baseProtocolMethod1Optional).toBeDefined();
        expect(TNSBaseProtocol1.prototype.baseProtocolMethod1).toBeDefined();
        expect(TNSBaseProtocol1.prototype.baseProtocolMethod1Optional).toBeDefined();
        expect(Object.getOwnPropertyDescriptor(TNSBaseProtocol1.prototype, 'baseProtocolProperty1')).toBeDefined();
        expect(Object.getOwnPropertyDescriptor(TNSBaseProtocol1.prototype, 'baseProtocolProperty1Optional')).toBeDefined();
    });

    it("Derived methods", function () {
        expect(TNSBaseProtocol2).toBeDefined();

        expect(TNSBaseProtocol2.baseProtocolMethod1).toBeDefined();
        expect(TNSBaseProtocol2.baseProtocolMethod1Optional).toBeDefined();
        expect(TNSBaseProtocol2.prototype.baseProtocolMethod1).toBeDefined();
        expect(TNSBaseProtocol2.prototype.baseProtocolMethod1Optional).toBeDefined();
        expect(Object.getOwnPropertyDescriptor(TNSBaseProtocol2.prototype, 'baseProtocolProperty1')).toBeDefined();
        expect(Object.getOwnPropertyDescriptor(TNSBaseProtocol2.prototype, 'baseProtocolProperty1Optional')).toBeDefined();

        expect(TNSBaseProtocol2.baseProtocolMethod2).toBeDefined();
        expect(TNSBaseProtocol2.baseProtocolMethod2Optional).toBeDefined();
        expect(TNSBaseProtocol2.prototype.baseProtocolMethod2).toBeDefined();
        expect(TNSBaseProtocol2.prototype.baseProtocolMethod2Optional).toBeDefined();
        expect(Object.getOwnPropertyDescriptor(TNSBaseProtocol2.prototype, 'baseProtocolProperty2')).toBeDefined();
        expect(Object.getOwnPropertyDescriptor(TNSBaseProtocol2.prototype, 'baseProtocolProperty2Optional')).toBeDefined();
    });

    it("Calling protocol methods", function () {
        var instance = TNSDerivedInterface.alloc().init();

        expect(TNSBaseProtocol2.baseProtocolMethod1.call(TNSDerivedInterface));
        expect(TNSBaseProtocol2.prototype.baseProtocolMethod1.call(instance));

        var descriptor = Object.getOwnPropertyDescriptor(TNSBaseProtocol1.prototype, 'baseProtocolProperty1');
        descriptor.set.call(instance, 1);
        descriptor.get.call(instance);

        expect(TNSGetOutput()).toBe(
            'static baseProtocolMethod1 called' +
            'instance baseProtocolMethod1 called' +
            'instance setBaseProtocolProperty1: called' +
            'instance baseProtocolProperty1 called');
    });
});
