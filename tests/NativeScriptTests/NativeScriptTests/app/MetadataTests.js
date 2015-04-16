describe("Metadata", function () {
    it("where method in category is implemented with property, the property access and modification should work and the method should be 'hided'.", function () {

        // NOTE: MKTileOverlay implements MKOverlay's canReplaceMapContent() with property.
        var template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
        var overlay = MKTileOverlay.alloc().initWithURLTemplate(template);

        expect(overlay.canReplaceMapContent).toBe(false);
        overlay.canReplaceMapContent = true;
        expect(overlay.canReplaceMapContent).toBe(true);
        overlay.canReplaceMapContent = false;
        expect(overlay.canReplaceMapContent).toBe(false);

    });
});
