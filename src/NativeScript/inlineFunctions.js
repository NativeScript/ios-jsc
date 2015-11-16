Object.assign(global, {
    CGPointMake(x, y) {
        return new CGPoint({ x, y });
    },
    CGRectMake(x, y, width, height) {
        return new CGRect({ origin: { x, y }, size: { width, height } });
    },
    CGSizeMake(width, height) {
        return new CGSize({ width, height });
    },
    UIEdgeInsetsMake(top, left, bottom, right) {
        return new UIEdgeInsets({ top, left, bottom, right });
    },
    NSMakeRange(location, length) {
        return new NSRange({ location, length });
    },
});

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
