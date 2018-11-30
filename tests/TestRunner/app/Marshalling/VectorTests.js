describe(module.id, function () {
    if (interop.sizeof(interop.types.id) == 4) {
        console.warn("warning: Skipping all vector tests on 32-bit architecture!");
        return;
    }

    it("simd_float2", function(){
        var f = getFloat2();
        expect(f[0].toFixed(4)).toBe(1.2345.toFixed(4));
        expect(f[1].toFixed(4)).toBe(2.3456.toFixed(4));
        var fi = incrementFloat2(f);
        expect(fi[0].toFixed(4)).toBe(2.2345.toFixed(4));
        expect(fi[1].toFixed(4)).toBe(3.3456.toFixed(4));
    });

    it("simd_float3", function(){
        var f = getFloat3();
        expect(f[0].toFixed(4)).toBe(1.2345.toFixed(4));
        expect(f[1].toFixed(4)).toBe(2.3456.toFixed(4));
        expect(f[2].toFixed(4)).toBe(3.4567.toFixed(4));
        var fi = incrementFloat3(f);
        expect(fi[0].toFixed(4)).toBe(2.2345.toFixed(4));
        expect(fi[1].toFixed(4)).toBe(3.3456.toFixed(4));
        expect(fi[2].toFixed(4)).toBe(4.4567.toFixed(4));
    });

    it("simd_float4", function(){
        var f = getFloat4();
        expect(f[0].toFixed(4)).toBe(1.2345.toFixed(4));
        expect(f[1].toFixed(4)).toBe(2.3456.toFixed(4));
        expect(f[2].toFixed(4)).toBe(3.4567.toFixed(4));
        expect(f[3].toFixed(4)).toBe(4.5678.toFixed(4));
        var fi = incrementFloat4(f);
        expect(fi[0].toFixed(4)).toBe(2.2345.toFixed(4));
        expect(fi[1].toFixed(4)).toBe(3.3456.toFixed(4));
        expect(fi[2].toFixed(4)).toBe(4.4567.toFixed(4));
        expect(fi[3].toFixed(4)).toBe(5.5678.toFixed(4));
    });

    it("simd_double2", function(){
        var d = getDouble2();
        expect(d[0].toFixed(4)).toBe(1.2345.toFixed(4));
        expect(d[1].toFixed(4)).toBe(2.3456.toFixed(4));
        var di = incrementDouble2(d);
        expect(di[0].toFixed(4)).toBe(2.2345.toFixed(4));
        expect(di[1].toFixed(4)).toBe(3.3456.toFixed(4));
    });

    it("simd_double3", function(){
        var d = getDouble3();
        expect(d[0].toFixed(4)).toBe(1.2345.toFixed(4));
        expect(d[1].toFixed(4)).toBe(2.3456.toFixed(4));
        expect(d[2].toFixed(4)).toBe(3.4567.toFixed(4));
        var di = incrementDouble3(d);
        expect(di[0].toFixed(4)).toBe(2.2345.toFixed(4));
        expect(di[1].toFixed(4)).toBe(3.3456.toFixed(4));
        expect(di[2].toFixed(4)).toBe(4.4567.toFixed(4));
    });

    it("simd_double4", function(){
        var d = getDouble4();
        expect(d[0].toFixed(4)).toBe(1.2345.toFixed(4));
        expect(d[1].toFixed(4)).toBe(2.3456.toFixed(4));
        expect(d[2].toFixed(4)).toBe(3.4567.toFixed(4));
        expect(d[3].toFixed(4)).toBe(4.5678.toFixed(4));
        var di = incrementDouble4(d);
        expect(di[0].toFixed(4)).toBe(2.2345.toFixed(4));
        expect(di[1].toFixed(4)).toBe(3.3456.toFixed(4));
        expect(di[2].toFixed(4)).toBe(4.4567.toFixed(4));
        expect(di[3].toFixed(4)).toBe(5.5678.toFixed(4));

    });

    it("SCNVector3ToFloat3", function() {
        var v = _SCNVector3ToFloat3({x: 1.23, y: 2.3456, z:3.4567});
        expect(v[0].toFixed(4)).toBe((1.23).toFixed(4));
        expect(v[1].toFixed(4)).toBe((2.3456).toFixed(4));
        expect(v[2].toFixed(4)).toBe((3.4567).toFixed(4));
    });

    it("SCNVector4ToFloat4", function() {
        var v = _SCNVector4ToFloat4({x: 1.23, y: 2.3456, z:3.4567, w: 4.5678});
        expect(v[0].toFixed(4)).toBe((1.23).toFixed(4));
        expect(v[1].toFixed(4)).toBe((2.3456).toFixed(4));
        expect(v[2].toFixed(4)).toBe((3.4567).toFixed(4));
        expect(v[3].toFixed(4)).toBe((4.5678).toFixed(4));
    });

    it("SCNVector3FromFloat3", function() {
        var v = _SCNVector3FromFloat3(getFloat3());
        expect(v.x.toFixed(4)).toBe((1.2345).toFixed(4));
        expect(v.y.toFixed(4)).toBe((2.3456).toFixed(4));
        expect(v.z.toFixed(4)).toBe((3.4567).toFixed(4));
    });

    it("SCNVector4FromFloat4", function() {
        var v = _SCNVector4FromFloat4(getFloat4());
        expect(v.x.toFixed(4)).toBe((1.2345).toFixed(4));
        expect(v.y.toFixed(4)).toBe((2.3456).toFixed(4));
        expect(v.z.toFixed(4)).toBe((3.4567).toFixed(4));
        expect(v.w.toFixed(4)).toBe((4.5678).toFixed(4));
    });
});
