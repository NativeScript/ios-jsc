describe(module.id, function () {
    afterEach(function () {
        TNSClearOutput();
    });

    // TODO
    it("CFBag", function () {
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
    });
         
    it("String.prototype.normalize", function(){
       //Since we overwrite the original normalize implementation, we test it against the behavior described on https://developer.mozilla.org
       //Source: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/normalize
       // Initial string
       
       // U+1E9B: LATIN SMALL LETTER LONG S WITH DOT ABOVE
       // U+0323: COMBINING DOT BELOW
       var str = '\u1E9B\u0323';
       
       
       // Canonically-composed form (NFC)
       
       // U+1E9B: LATIN SMALL LETTER LONG S WITH DOT ABOVE
       // U+0323: COMBINING DOT BELOW
       expect(str.normalize('NFC')).toBe('\u1E9B\u0323');
       expect(str.normalize()).toBe('\u1E9B\u0323');
       
       
       // Canonically-decomposed form (NFD)
       
       // U+017F: LATIN SMALL LETTER LONG S
       // U+0323: COMBINING DOT BELOW
       // U+0307: COMBINING DOT ABOVE
       expect(str.normalize('NFD')).toBe('\u017F\u0323\u0307'); //
       
       
       // Compatibly-composed (NFKC)
       
       // U+1E69: LATIN SMALL LETTER S WITH DOT BELOW AND DOT ABOVE
       expect(str.normalize('NFKC')).toBe('\u1E69'); // '\u1E69'
       
       
       // Compatibly-decomposed (NFKD)
       
       // U+0073: LATIN SMALL LETTER S
       // U+0323: COMBINING DOT BELOW
       // U+0307: COMBINING DOT ABOVE
       expect(str.normalize('NFKD')).toBe('\u0073\u0323\u0307');
   });
});
