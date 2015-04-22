(function __extends(Derived, Base) {
    for (var key in Base) {
        if (Base.hasOwnProperty(key)) {
            Derived[key] = Base[key];
        }
    }

    function __() {
        this.constructor = Derived;
    }

    __.prototype = Base.prototype;
    Derived.prototype = new __();
});
