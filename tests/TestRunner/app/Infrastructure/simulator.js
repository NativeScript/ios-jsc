function isSimulator() {
    if (NSProcessInfo.processInfo.isOperatingSystemAtLeastVersion({majorVersion: 9, minorVersion: 0, patchVersion: 0})) {
        return NSProcessInfo.processInfo.environment.objectForKey("SIMULATOR_DEVICE_NAME") !== null;
    } else {
        return UIDevice.currentDevice.name.toLowerCase().indexOf("simulator") > -1;
    }
}

global.isSimulator = isSimulator();
