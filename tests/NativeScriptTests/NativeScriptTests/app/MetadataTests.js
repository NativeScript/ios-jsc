describe("Metadata", function () {
    it("automatically resolves collisions where method in categories are implemented with properties by suffixing the property with Property and preserving the getter as is.", function () {

        // NOTE: MKTileOverlay implements MKOverlay's canReplaceMapContent() with property.
        var template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
        var overlay = MKTileOverlay.alloc().initWithURLTemplate(template);

        expect(overlay.canReplaceMapContentProperty).toBe(false);
        overlay.canReplaceMapContentProperty = true;
        expect(overlay.canReplaceMapContent()).toBe(true);
        overlay.canReplaceMapContentProperty = false;
        expect(overlay.canReplaceMapContent()).toBe(false);

    });
});
