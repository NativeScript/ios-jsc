function CGPointMake(x, y) {
    return new CGPoint({ x: x, y: y });
}

function CGRectMake(x, y, width, height) {
    return new CGRect({ origin: { x: x, y: y }, size: { width: width, height: height } });
}

function CGSizeMake(width, height) {
    return new CGSize({ width: width, height: height });
}

function UIEdgeInsetsMake(top, left, bottom, right) {
    return new UIEdgeInsets({ top: top, left: left, bottom: bottom, right: right });
}

function NSMakeRange(loc, len) {
    return new NSRange({ location: loc, length: len });
}

Object.defineProperty(global, "__tsEnum", {
    writable: false,
    enumerable: false,
    configurable: false,
    value: function(obj) {
        var result = {};
        for (var key of Object.keys(obj)) {
            result[key] = obj[key];
            result[obj[key]] = key;
        }
        return result;
    }
});