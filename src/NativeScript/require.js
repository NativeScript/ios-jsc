/*
 * THIS JAVASCRIPT FILE IS EMBEDED BY THE BUILD PROCESS.
 *
 * You can ignore this file and continue debugging.
 * To correct errors, edit the source file at: https://github.com/NativeScript/ios-runtime/blob/master/src/NativeScript/require.js
*/

(function (applicationPath, createModuleFunction) {
    'use strict';

    // TODO: Use class syntax
    function ModuleError() {
        var tmp = Error.apply(this, arguments);
        this.message = tmp.message;
        Object.defineProperty(this, 'stack', { get: () => tmp.stack });
    }
    ModuleError.prototype = Object.create(Error.prototype);
    ModuleError.prototype.constructor = ModuleError;
    global.ModuleError = ModuleError;

    var fileManager = NSFileManager.defaultManager();
    var nsstr = NSString.stringWithString.bind(NSString);

    applicationPath = nsstr(applicationPath).stringByStandardizingPath;

    var USER_MODULES_ROOT = nsstr('app');
    var CORE_MODULES_ROOT = nsstr('app/tns_modules');

    var isDirectory = new interop.Reference(interop.types.bool, false);
    var defaultPreviousPath = NSString.pathWithComponents([USER_MODULES_ROOT, 'index.js']).toString();

    var pathCache = new Map();
    var modulesCache = new Map();

    function __findModule(moduleIdentifier, previousPath) {
        var isBootstrap = !previousPath;
        if (isBootstrap) {
            previousPath = defaultPreviousPath;
        }
        var absolutePath;
        if (/^\.{1,2}\//.test(moduleIdentifier)) { // moduleIdentifier starts with ./ or ../
            var moduleDir = nsstr(previousPath).stringByDeletingLastPathComponent;
            absolutePath = NSString.pathWithComponents([applicationPath, moduleDir, moduleIdentifier]);
        } else if (/^\//.test(moduleIdentifier)) { // moduleIdentifier starts with /
            absolutePath = NSString.pathWithComponents([moduleIdentifier]);
        } else if (/^~\//.test(moduleIdentifier)) {
            absolutePath = NSString.pathWithComponents([applicationPath, USER_MODULES_ROOT, moduleIdentifier.substr(2)]);
        } else {
            absolutePath = NSString.pathWithComponents([applicationPath, CORE_MODULES_ROOT, moduleIdentifier]);
        }
        absolutePath = nsstr(absolutePath).stringByStandardizingPath;

        var requestedPath = absolutePath;
        if (pathCache.has(requestedPath)) {
            return pathCache.get(requestedPath);
        }

        if (fileManager.fileExistsAtPathIsDirectory(absolutePath, isDirectory)) {
            if (!isDirectory.value) {
                throw new ModuleError(`Expected '${absolutePath}' to be a directory`);
            }

            var mainFileName;
            if (isBootstrap && fileManager.fileExistsAtPathIsDirectory(NSString.pathWithComponents([applicationPath, USER_MODULES_ROOT, 'bootstrap.js']), null)) {
                mainFileName = 'bootstrap.js';
            } else {
                mainFileName = 'index.js';
            }

            var packageJsonPath = nsstr(absolutePath).stringByAppendingPathComponent("package.json");
            var packageJson = NSString.stringWithContentsOfFileEncodingError(packageJsonPath, NSUTF8StringEncoding, null);
            if (packageJson) {
                //console.debug("PACKAGE_FOUND: " + packageJsonPath);

                try {
                    var packageJsonMain = JSON.parse(packageJson).main;
                    if (packageJsonMain && !/\.js$/.test(packageJsonMain)) {
                        packageJsonMain += '.js';
                    }
                    mainFileName = packageJsonMain || mainFileName;
                } catch (e) {
                    throw new ModuleError(`Error parsing package.json in '${absolutePath}' - ${e}`);
                }
            }

            absolutePath = nsstr(absolutePath).stringByAppendingPathComponent(mainFileName);
        } else {
            absolutePath = nsstr(absolutePath).stringByAppendingPathExtension("js");
        }
        absolutePath = nsstr(absolutePath).stringByStandardizingPath;

        if (fileManager.fileExistsAtPathIsDirectory(absolutePath, isDirectory)) {
            if (isDirectory.value) {
                throw new ModuleError(`Expected '${absolutePath}' to be a file`);
            }

            //console.debug('FIND_MODULE:', moduleIdentifier, absolutePath);

            var moduleMetadata = {
                name: nsstr(moduleIdentifier).lastPathComponent,
                path: absolutePath,
                bundlePath: absolutePath.substr(applicationPath.length)
            };

            pathCache.set(requestedPath, moduleMetadata);
            return moduleMetadata;
        } else {
            throw new ModuleError(`Failed to find module '${moduleIdentifier}' relative to '${previousPath}'. Computed path: ${absolutePath}`);
        }
    }

    function __executeModule(moduleMetadata, module) {
        var modulePath = moduleMetadata.bundlePath;
        module.require = function require(moduleIdentifier) {
            return __loadModule(moduleIdentifier, modulePath).exports;
        };
        var moduleSource = NSString.stringWithContentsOfFileEncodingError(moduleMetadata.path, NSUTF8StringEncoding, null);
        var moduleFunction = createModuleFunction(moduleSource, "file://" + moduleMetadata.bundlePath);
        var fileName = moduleMetadata.path;
        var dirName = nsstr(moduleMetadata.path).stringByDeletingLastPathComponent.toString();
        module.filename = fileName;

        var hadError = true;
        try {
            moduleFunction(module.require, module, module.exports, dirName, fileName);
            hadError = false;
        } finally {
            if (hadError) {
               modulesCache.delete(moduleMetadata.bundlePath);
            }
        }
    }

    function __loadModule(moduleIdentifier, previousPath) {
        if (/\.js$/.test(moduleIdentifier)) {
            moduleIdentifier = moduleIdentifier.replace(/\.js$/, '');
        }

        var moduleMetadata = __findModule(moduleIdentifier, previousPath);

        var key = moduleMetadata.bundlePath;
        if (modulesCache.has(key)) {
            return modulesCache.get(key);
        }

        var module = {
            exports: {},
            id: moduleMetadata.bundlePath
        };

        modulesCache.set(key, module);

        __executeModule(moduleMetadata, module);

        return module;
    }

    global.require = (moduleIdentifier) => __loadModule(moduleIdentifier, defaultPreviousPath).exports;

    return __loadModule;
});
