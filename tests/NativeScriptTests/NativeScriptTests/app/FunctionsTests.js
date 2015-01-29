describe(module.id, function() {
    afterEach(function () {
        TNSClearOutput();
    });

    // TODO
    it("CFBag", function() {
        var a = new interop.Reference(interop.types.int32, 1);
        var b = new interop.Reference(interop.types.int32, 2);

        var bagvals = interop.alloc(2 * interop.sizeof(interop.Pointer));
        var bagvalsRef = new interop.Reference(interop.Pointer, bagvals);
        bagvalsRef[0] = a;
        bagvalsRef[1] = b;

        var bag = CFBagCreate(kCFAllocatorDefault, bagvals, 2, null);
        expect(CFBagGetCount(bag)).toBe(2);
        expect(CFBagGetCountOfValue(bag, a)).toBe(1);
        expect(CFBagContainsValue(bag, a)).toBe(true);
        CFRelease(bag);
    });
});
