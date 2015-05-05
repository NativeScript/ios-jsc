describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("ParameterlessConstructor", function () {
        var instance1 = new TNSCInterface();
        var instance2 = new (TNSCInterface.extend({}))();

        var actual = TNSGetOutput();
        expect(actual).toBe("init calledinit called");
    });

    it("WithPrimitive", function () {
        var instance1 = new TNSCInterface(7);
        var instance2 = new (TNSCInterface.extend({}))(7);

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithPrimitive:7 calledinitWithPrimitive:7 called");
    });

    it("WithInterface", function () {
        var interface = new TNSCInterface11();
        var instance1 = new TNSCInterface(interface);
        var instance2 = new (TNSCInterface.extend({}))(interface);

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithInterface: calledinitWithInterface: called");
    });

    it("WithStructure", function () {
        var struct = {
            x: 1,
            y: 2,
        };
        var instance1 = new TNSCInterface(struct);
        var instance2 = new (TNSCInterface.extend({}))(struct);

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithStructure:1.2 calledinitWithStructure:1.2 called");
    });

    it("WithProtocol", function () {
        var Protocol = TNSCProtocol1.implements({});
        var protocol = new Protocol();
        var instance1 = new TNSCInterface(protocol);
        var instance2 = new (TNSCInterface.extend({}))(protocol);

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithProtocol: calledinitWithProtocol: called");
    });

    it("WithString", function () {
        var instance1 = new TNSCInterface('str');
        var instance2 = new (TNSCInterface.extend({}))('str');

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithString:str calledinitWithString:str called");
    });

    it("Complex", function () {
        var Protocol = TNSCProtocol1.implements({});
        var protocol = new Protocol();
        var struct = TNSCStructure.create();
        var interface = new TNSCInterface11();
        var instance1 = new TNSCInterface(3, interface, struct, protocol, 'str', 4);
        var instance2 = new (TNSCInterface.extend({}))(3, interface, struct, protocol, 'str', 4);

        var actual = TNSGetOutput();
        expect(actual).toBe("initWithPrimitive:instance:structure:protocol:string:number: calledinitWithPrimitive:instance:structure:protocol:string:number: called");
    });
});
