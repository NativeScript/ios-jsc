describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("StaticMethodWithChar1", function () {
        var result = TNSPrimitives.methodWithChar(127);
        expect(result).toBe(127);

        var actual = TNSGetOutput();
        expect(actual).toBe("127");
    });
    it("StaticMethodWithChar2", function () {
        var result = TNSPrimitives.methodWithChar(-128);
        expect(result).toBe(-128);

        var actual = TNSGetOutput();
        expect(actual).toBe("-128");
    });

    it("StaticMethodWithShort1", function () {
        var result = TNSPrimitives.methodWithShort(32767);
        expect(result).toBe(32767);

        var actual = TNSGetOutput();
        expect(actual).toBe("32767");
    });
    it("StaticMethodWithShort2", function () {
        var result = TNSPrimitives.methodWithShort(-32768);
        expect(result).toBe(-32768);

        var actual = TNSGetOutput();
        expect(actual).toBe("-32768");
    });

    it("StaticMethodWithInt1", function () {
        var result = TNSPrimitives.methodWithInt(2147483647);
        expect(result).toBe(2147483647);

        var actual = TNSGetOutput();
        expect(actual).toBe("2147483647");
    });
    it("StaticMethodWithInt2", function () {
        var result = TNSPrimitives.methodWithInt(-2147483648);
        expect(result).toBe(-2147483648);

        var actual = TNSGetOutput();
        expect(actual).toBe("-2147483648");
    });

    it("StaticMethodWithLong1", function () {
        var result = TNSPrimitives.methodWithLong(2147483647);
        expect(result).toBe(2147483647);

        var actual = TNSGetOutput();
        expect(actual).toBe("2147483647");
    });
    it("StaticMethodWithLong2", function () {
        var result = TNSPrimitives.methodWithLong(-2147483648);
        expect(result).toBe(-2147483648);

        var actual = TNSGetOutput();
        expect(actual).toBe("-2147483648");
    });

    //TODO
    // it("StaticMethodWithLongLong1", function() {
    //     var result = TNSPrimitives.methodWithLongLong('9223372036854775807');
    //     expect(result).toBe(ring() === '9223372036854775807');
    //     result = functionWithLongLong(result);
    //     expect(result).toBe(ring() === '9223372036854775807');

    //     var actual = TNSGetOutput();
    //     expect(actual).toBe("92233720368547758079223372036854775807");
    // });
    // it("StaticMethodWithLongLong2", function() {
    //     var result = TNSPrimitives.methodWithLongLong('-9223372036854775808');
    //     expect(result).toBe(ring() === '-9223372036854775808');
    //     result = functionWithLongLong(result);
    //     expect(result).toBe(ring() === '-9223372036854775808');

    //     var actual = TNSGetOutput();
    //     expect(actual).toBe("-9223372036854775808-9223372036854775808");
    // });

    it("StaticMethodWithUChar", function () {
        var result = TNSPrimitives.methodWithUChar(255);
        expect(result).toBe(255);

        var actual = TNSGetOutput();
        expect(actual).toBe("255");
    });
    it("StaticMethodWithUShort", function () {
        var result = TNSPrimitives.methodWithUShort(65535);
        expect(result).toBe(65535);

        var actual = TNSGetOutput();
        expect(actual).toBe("65535");
    });

    it("StaticMethodWithUInt", function () {
        var result = TNSPrimitives.methodWithUInt(4294967295);
        expect(result).toBe(4294967295);

        var actual = TNSGetOutput();
        expect(actual).toBe("4294967295");
    });

    it("StaticMethodWithULong", function () {
        var result = TNSPrimitives.methodWithULong(4294967295);
        expect(result).toBe(4294967295);

        var actual = TNSGetOutput();
        expect(actual).toBe("4294967295");
    });

    // TODO
    // it("StaticMethodWithULongLong", function() {
    //     var result = TNSPrimitives.methodWithULongLong('18446744073709551615');
    //     expect(result).toBe(ring() === '18446744073709551615');
    //     result = functionWithULongLong(result);
    //     expect(result).toBe(ring() === '18446744073709551615');

    //     var actual = TNSGetOutput();
    //     expect(actual).toBe("1844674407370955161518446744073709551615");
    // });

    it("StaticMethodWithFloat1", function () {
        var result = TNSPrimitives.methodWithFloat(3.40282347e+38);
        expect(result).toBe(3.4028234663852886e+38);

        var actual = TNSGetOutput();
        expect(actual).toBe("340282346638528859811704183484516925440.000000000000000000000000000000000000000000000");
    });

// TODO: This test passes only on iPhone 5s
//    it("StaticMethodWithFloat2", function () {
//        var result = TNSPrimitives.methodWithFloat(1.17549435e-38);
//        expect(result).toBe(1.1754943508222875e-38);
//
//        var actual = TNSGetOutput();
//        expect(actual).toBe("0.000000000000000000000000000000000000011754944");
//    });

    it("StaticMethodWithDouble1", function () {
        var result = TNSPrimitives.methodWithDouble(1.7976931348623157e+308);
        expect(result).toBe(1.7976931348623157e+308);

        var actual = TNSGetOutput();
        expect(actual).toBe("179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
    });
    it("StaticMethodWithDouble2", function () {
        var result = TNSPrimitives.methodWithDouble(2.2250738585072014e-308);
        expect(result).toBe(2.2250738585072014e-308);

        var actual = TNSGetOutput();
        expect(actual).toBe("0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222507385850720138");
    });

    it("StaticMethodWithSelector", function () {
        var result = TNSPrimitives.methodWithSelector('init');
        expect(result).toBe('init');

        var actual = TNSGetOutput();
        expect(actual).toBe("init");
    });

    it("StaticMethodWithClass", function () {
        var result = TNSPrimitives.methodWithClass(NSObject);
        expect(result).toBe(NSObject);

        var actual = TNSGetOutput();
        expect(actual).toBe("NSObject");
    });

    it("StaticMethodWithProtocol", function () {
        var result = TNSPrimitives.methodWithProtocol(TNSBaseProtocol1);
        expect(result).toBe(TNSBaseProtocol1);

        var actual = TNSGetOutput();
        expect(actual).toBe("TNSBaseProtocol1");
    });

    it("StaticMethodWithNull", function () {
        var result = TNSPrimitives.methodWithNull(null);
        expect(result).toBe(null);

        var actual = TNSGetOutput();
        expect(actual).toBe("(null)");
    });

    it("StaticMethodWithBool", function () {
        var result = TNSPrimitives.methodWithBool(true);
        expect(result).toBe(true);

        var actual = TNSGetOutput();
        expect(actual).toBe("1");
    });

    it("StaticMethodWithBool2", function () {
        var result = TNSPrimitives.methodWithBool2(true);
        expect(result).toBe(true);

        var actual = TNSGetOutput();
        expect(actual).toBe("1");
    });

    it("StaticMethodWithBool3", function () {
        var result = TNSPrimitives.methodWithBool3(true);
        expect(result).toBe(true);

        var actual = TNSGetOutput();
        expect(actual).toBe("1");
    });

    it("StaticMethodWithUnichar", function () {
        var result = TNSPrimitives.methodWithUnichar('i');
        expect(result).toBe('i');

        var actual = TNSGetOutput();
        expect(actual).toBe("i");

        expect(function() {
            TNSPrimitives.methodWithUnichar('iPhone');
        }).toThrowError();
    });
});
