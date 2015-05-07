UIViewController.extend({
    loadView: function() {
        this.view = new UIView(CGRectMake(0, 0, 320, 200));
    },
    viewDidLoad: function() {
        UIViewController.prototype.viewDidLoad.apply(this, arguments);
        this.preferredContentSize = CGSizeMake(0, 200);

        var label = new UILabel(CGRectMake(0, 0, 250, 60));
        label.text = "Hello, World!";
        label.textColor = UIColor.whiteColor();

        this.view.addSubview(label);
    }
}, {
    name: "TNSTodayExtension"
});
