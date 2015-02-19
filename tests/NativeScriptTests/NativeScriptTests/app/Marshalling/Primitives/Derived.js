describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    it("DerivedMethodWithChar1", function () {
        var result = TNSPrimitives.extend({
            methodWithChar: function (x) {
                expect(TNSPrimitives.prototype.methodWithChar.apply(this, arguments)).toBe(127);
                return x;
            }
        }).alloc().init().methodWithChar(127);
        expect(result).toBe(127);

        var actual = TNSGetOutput();
        expect(actual).toBe("127");
    });
    it("DerivedMethodWithChar2", function () {
        var result = TNSPrimitives.extend({
            methodWithChar: function (x) {
                expect(TNSPrimitives.prototype.methodWithChar.apply(this, arguments)).toBe(-128);
                return x;
            }
        }).alloc().init().methodWithChar(-128);
        expect(result).toBe(-128);

        var actual = TNSGetOutput();
        expect(actual).toBe("-128");
    });

    it("DerivedMethodWithShort1", function () {
        var result = TNSPrimitives.extend({
            methodWithShort: function (x) {
                expect(TNSPrimitives.prototype.methodWithShort.apply(this, arguments)).toBe(32767);
                return x;
            }
        }).alloc().init().methodWithShort(32767);
        expect(result).toBe(32767);

        var actual = TNSGetOutput();
        expect(actual).toBe("32767");
    });
    it("DerivedMethodWithShort2", function () {
        var result = TNSPrimitives.extend({
            methodWithShort: function (x) {
                expect(TNSPrimitives.prototype.methodWithShort.apply(this, arguments)).toBe(-32768);
                return x;
            }
        }).alloc().init().methodWithShort(-32768);
        expect(result).toBe(-32768);

        var actual = TNSGetOutput();
        expect(actual).toBe("-32768");
    });

    it("DerivedMethodWithInt1", function () {
        var result = TNSPrimitives.extend({
            methodWithInt: function (x) {
                expect(TNSPrimitives.prototype.methodWithInt.apply(this, arguments)).toBe(2147483647);
                return x;
            }
        }).alloc().init().methodWithInt(2147483647);
        expect(result).toBe(2147483647);

        var actual = TNSGetOutput();
        expect(actual).toBe("2147483647");
    });
    it("DerivedMethodWithInt2", function () {
        var result = TNSPrimitives.extend({
            methodWithInt: function (x) {
                expect(TNSPrimitives.prototype.methodWithInt.apply(this, arguments)).toBe(-2147483648);
                return x;
            }
        }).alloc().init().methodWithInt(-2147483648);
        expect(result).toBe(-2147483648);

        var actual = TNSGetOutput();
        expect(actual).toBe("-2147483648");
    });

    it("DerivedMethodWithLong1", function () {
        var result = TNSPrimitives.extend({
            methodWithLong: function (x) {
                expect(TNSPrimitives.prototype.methodWithLong.apply(this, arguments)).toBe(2147483647);
                return x;
            }
        }).alloc().init().methodWithLong(2147483647);
        expect(result).toBe(2147483647);

        var actual = TNSGetOutput();
        expect(actual).toBe("2147483647");
    });
    it("DerivedMethodWithLong2", function () {
        var result = TNSPrimitives.extend({
            methodWithLong: function (x) {
                expect(TNSPrimitives.prototype.methodWithLong.apply(this, arguments)).toBe(-2147483648);
                return x;
            }
        }).alloc().init().methodWithLong(-2147483648);
        expect(result).toBe(-2147483648);

        var actual = TNSGetOutput();
        expect(actual).toBe("-2147483648");
    });

    //TODO
    // it("DerivedMethodWithLongLong1", function() {
    //     var result = TNSPrimitives.extend({}).alloc().init().methodWithLongLong('9223372036854775807');
    //     expect(result).toBe(ring() === '9223372036854775807');
    //     result = functionWithLongLong(result);
    //     expect(result).toBe(ring() === '9223372036854775807');

    //     var actual = TNSGetOutput();
    //     expect(actual).toBe("92233720368547758079223372036854775807");
    // });
    // it("DerivedMethodWithLongLong2", function() {
    //     var result = TNSPrimitives.extend({}).alloc().init().methodWithLongLong('-9223372036854775808');
    //     expect(result).toBe(ring() === '-9223372036854775808');
    //     result = functionWithLongLong(result);
    //     expect(result).toBe(ring() === '-9223372036854775808');

    //     var actual = TNSGetOutput();
    //     expect(actual).toBe("-9223372036854775808-9223372036854775808");
    // });

    it("DerivedMethodWithUChar", function () {
        var result = TNSPrimitives.extend({
            methodWithUChar: function (x) {
                expect(TNSPrimitives.prototype.methodWithUChar.apply(this, arguments)).toBe(255);
                return x;
            }
        }).alloc().init().methodWithUChar(255);
        expect(result).toBe(255);

        var actual = TNSGetOutput();
        expect(actual).toBe("255");
    });
    it("DerivedMethodWithUShort", function () {
        var result = TNSPrimitives.extend({
            methodWithUShort: function (x) {
                expect(TNSPrimitives.prototype.methodWithUShort.apply(this, arguments)).toBe(65535);
                return x;
            }
        }).alloc().init().methodWithUShort(65535);
        expect(result).toBe(65535);

        var actual = TNSGetOutput();
        expect(actual).toBe("65535");
    });

    it("DerivedMethodWithUInt", function () {
        var result = TNSPrimitives.extend({
            methodWithUInt: function (x) {
                expect(TNSPrimitives.prototype.methodWithUInt.apply(this, arguments)).toBe(4294967295);
                return x;
            }
        }).alloc().init().methodWithUInt(4294967295);
        expect(result).toBe(4294967295);

        var actual = TNSGetOutput();
        expect(actual).toBe("4294967295");
    });

    it("DerivedMethodWithULong", function () {
        var result = TNSPrimitives.extend({
            methodWithULong: function (x) {
                expect(TNSPrimitives.prototype.methodWithULong.apply(this, arguments)).toBe(4294967295);
                return x;
            }
        }).alloc().init().methodWithULong(4294967295);
        expect(result).toBe(4294967295);

        var actual = TNSGetOutput();
        expect(actual).toBe("4294967295");
    });

    // TODO
    // it("DerivedMethodWithULongLong", function() {
    //     var result = TNSPrimitives.extend({}).alloc().init().methodWithULongLong('18446744073709551615');
    //     expect(result).toBe(ring() === '18446744073709551615');
    //     result = functionWithULongLong(result);
    //     expect(result).toBe(ring() === '18446744073709551615');

    //     var actual = TNSGetOutput();
    //     expect(actual).toBe("1844674407370955161518446744073709551615");
    // });

    it("DerivedMethodWithFloat1", function () {
        var result = TNSPrimitives.extend({
            methodWithFloat: function (x) {
                expect(TNSPrimitives.prototype.methodWithFloat.apply(this, arguments)).toBe(3.4028234663852886e+38);
                return x;
            }
        }).alloc().init().methodWithFloat(3.40282347e+38);
        expect(result).toBe(3.40282347e+38);

        var actual = TNSGetOutput();
        expect(actual).toBe("340282346638528859811704183484516925440.000000000000000000000000000000000000000000000");
    });

// TODO: This test passes only on iPhone 5s
//    it("DerivedMethodWithFloat2", function() {
//        var result = TNSPrimitives.extend({
//            methodWithFloat: function(x) {
//                expect(TNSPrimitives.prototype.methodWithFloat.apply(this, arguments)).toBe(1.1754943508222875e-38);
//                return x;
//            }
//        }).alloc().init().methodWithFloat(1.17549435e-38);
//        expect(result).toBe(1.17549435e-38);
//
//        var actual = TNSGetOutput();
//        expect(actual).toBe("0.000000000000000000000000000000000000011754944");
//    });

    it("DerivedMethodWithDouble1", function () {
        var result = TNSPrimitives.extend({
            methodWithDouble: function (x) {
                expect(TNSPrimitives.prototype.methodWithDouble.apply(this, arguments)).toBe(1.7976931348623157e+308);
                return x;
            }
        }).alloc().init().methodWithDouble(1.7976931348623157e+308);
        expect(result).toBe(1.7976931348623157e+308);

        var actual = TNSGetOutput();
        expect(actual).toBe("179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
    });
    it("DerivedMethodWithDouble2", function () {
        var result = TNSPrimitives.extend({
            methodWithDouble: function (x) {
                expect(TNSPrimitives.prototype.methodWithDouble.apply(this, arguments)).toBe(2.2250738585072014e-308);
                return x;
            }
        }).alloc().init().methodWithDouble(2.2250738585072014e-308);
        expect(result).toBe(2.2250738585072014e-308);

        var actual = TNSGetOutput();
        expect(actual).toBe("0.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222507385850720138");
    });

    it("DerivedMethodWithSelector", function () {
        var result = TNSPrimitives.extend({
            methodWithSelector: function (x) {
                expect(TNSPrimitives.prototype.methodWithSelector.apply(this, arguments)).toBe('init');
                return x;
            }
        }).alloc().init().methodWithSelector('init');
        expect(result).toBe('init');

        var actual = TNSGetOutput();
        expect(actual).toBe("init");
    });

    it("DerivedMethodWithClass", function () {
        var result = TNSPrimitives.extend({
            methodWithClass: function (x) {
                expect(TNSPrimitives.prototype.methodWithClass.apply(this, arguments)).toBe(NSObject);
                return x;
            }
        }).alloc().init().methodWithClass(NSObject);
        expect(result).toBe(NSObject);

        var actual = TNSGetOutput();
        expect(actual).toBe("NSObject");
    });

    it("DerivedMethodWithProtocol", function () {
        var result = TNSPrimitives.extend({
            methodWithProtocol: function (x) {
                expect(TNSPrimitives.prototype.methodWithProtocol.apply(this, arguments)).toBe(TNSBaseProtocol1);
                return x;
            }
        }).alloc().init().methodWithProtocol(TNSBaseProtocol1);
        expect(result).toBe(TNSBaseProtocol1);

        var actual = TNSGetOutput();
        expect(actual).toBe("TNSBaseProtocol1");
    });

    it("DerivedMethodWithNull", function () {
        var result = TNSPrimitives.extend({
            methodWithNull: function (x) {
                expect(TNSPrimitives.prototype.methodWithNull.apply(this, arguments)).toBe(null);
                return x;
            }
        }).alloc().init().methodWithNull(null);
        expect(result).toBe(null);

        var actual = TNSGetOutput();
        expect(actual).toBe("(null)");
    });

    it("DerivedMethodWithBool", function () {
        var result = TNSPrimitives.extend({
            methodWithBool: function (x) {
                expect(TNSPrimitives.prototype.methodWithBool.apply(this, arguments)).toBe(true);
                return x;
            }
        }).alloc().init().methodWithBool(true);
        expect(result).toBe(true);

        var actual = TNSGetOutput();
        expect(actual).toBe("1");
    });

    it("DerivedMethodWithBool2", function () {
        var result = TNSPrimitives.extend({
            methodWithBool2: function (x) {
                expect(TNSPrimitives.prototype.methodWithBool2.apply(this, arguments)).toBe(true);
                return x;
            }
        }).alloc().init().methodWithBool2(true);
        expect(result).toBe(true);

        var actual = TNSGetOutput();
        expect(actual).toBe("1");
    });

    it("DerivedMethodWithBool3", function () {
        var result = TNSPrimitives.extend({
            methodWithBool3: function (x) {
                expect(TNSPrimitives.prototype.methodWithBool3.apply(this, arguments)).toBe(true);
                return x;
            }
        }).alloc().init().methodWithBool3(true);
        expect(result).toBe(true);

        var actual = TNSGetOutput();
        expect(actual).toBe("1");
    });

    it("DerivedMethodWithUnichar", function () {
        var result = TNSPrimitives.extend({
            methodWithUnichar: function (x) {
                expect(TNSPrimitives.prototype.methodWithUnichar.apply(this, arguments)).toBe('i');
                return x;
            }
        }).alloc().init().methodWithUnichar('i');
        expect(result).toBe('i');

        var actual = TNSGetOutput();
        expect(actual).toBe("i");
    });
});
