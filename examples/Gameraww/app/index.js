//import './CanvasViewController';
//import './DetailViewController';
//import './MasterViewController';
import {
  UIResponder,
  UIApplicationDelegate,
  UIApplicationMain
} from '@objc/UIKit';

console.log(UIResponder);

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