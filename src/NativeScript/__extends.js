// __extends is a TypeScript helper function generated when targeting older ES versions.
// We inject our own function that branches logic whether base class is native or not.
// This one gets called for classes that don't inherit from native ones.
(function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
});
