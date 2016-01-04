import './CanvasViewController';
import './DetailViewController';
import './MasterViewController';

var TNSAppDelegate = UIResponder.extend({
    get window() {
        return this._window;
    },
    set window(aWindow) {
        this._window = aWindow;
    }
}, {
    protocols: [UIApplicationDelegate]
});

UIApplicationMain(0, null, null, TNSAppDelegate.name);