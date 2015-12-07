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

    function getRelativeToBundlePath(absolutePath) {
        return absolutePath.substr(applicationPath.length).replace(/^\//, '');
    }

    function getModuleCacheKey(moduleMetadata) {
        return moduleMetadata.bundlePath;
    }

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

        var moduleMetadata = {
            name: nsstr(moduleIdentifier).lastPathComponent,
        };

        var absoluteFilePath = nsstr(absolutePath).stringByAppendingPathExtension("js");
        if (/\.json$/.test(absolutePath)) {
            moduleMetadata.type = 'json';
        } else {
            if (!fileManager.fileExistsAtPathIsDirectory(absoluteFilePath, isDirectory) &&
                fileManager.fileExistsAtPathIsDirectory(absolutePath, isDirectory)) {
                if (!isDirectory.value) {
                    throw new ModuleError(`Expected '${getRelativeToBundlePath(absolutePath)}' to be a directory.`);
                }

                var mainFileName = 'index.js';

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
                absolutePath = absoluteFilePath;
            }

            moduleMetadata.type = 'js';
        }
        absolutePath = nsstr(absolutePath).stringByStandardizingPath;
        var bundlePath = getRelativeToBundlePath(absolutePath);

        if (!fileManager.fileExistsAtPathIsDirectory(absolutePath, isDirectory)) {
            throw new ModuleError(`Failed to find module '${moduleIdentifier}' relative to 'file:///${previousPath}'. Computed path: '${bundlePath}'.`);
        }

        if (isDirectory.value) {
            throw new ModuleError(`Expected '${bundlePath}' to be a file`);
        }

        //console.debug('FIND_MODULE:', moduleIdentifier, absolutePath);

        moduleMetadata.path = absolutePath;
        moduleMetadata.bundlePath = bundlePath;

        pathCache.set(requestedPath, moduleMetadata);
        return moduleMetadata;
    }

    function __executeModule(moduleMetadata, module) {
        var modulePath = moduleMetadata.bundlePath;
        var moduleSource = NSString.stringWithContentsOfFileEncodingError(moduleMetadata.path, NSUTF8StringEncoding, null);

        var hadError = true;

        if (moduleMetadata.type === 'js') {
            module.require = function __require(moduleIdentifier) {
                return __loadModule(moduleIdentifier, modulePath).exports;
            };
            var dirName = nsstr(moduleMetadata.path).stringByDeletingLastPathComponent.toString();

            try {
                var moduleFunction = createModuleFunction(moduleSource, "file:///" + moduleMetadata.bundlePath);
                moduleFunction(module.require, module, module.exports, dirName, moduleMetadata.path);
                hadError = false;
            } finally {
                if (hadError) {
                    modulesCache.delete(getModuleCacheKey(moduleMetadata));
                }
            }
        } else if (moduleMetadata.type === 'json') {
            try {
                module.exports = JSON.parse(moduleSource);
                hadError = false;
            } catch (e) {
                e.message = `File: 'file:///${moduleMetadata.bundlePath}'. ${e.message}`;
                throw e;
            } finally {
                if (hadError) {
                    modulesCache.delete(getModuleCacheKey(moduleMetadata));
                }
            }
        } else {
            throw new ModuleError(`Unknown module type '${moduleMetadata.type}'`);
        }
    }

    function __loadModule(moduleIdentifier, previousPath) {
        if (/\.js$/.test(moduleIdentifier)) {
            moduleIdentifier = moduleIdentifier.replace(/\.js$/, '');
        }

        var moduleMetadata = __findModule(moduleIdentifier, previousPath);

        var key = getModuleCacheKey(moduleMetadata);
        if (modulesCache.has(key)) {
            return modulesCache.get(key);
        }

        var module = {
            exports: {},
            id: moduleMetadata.bundlePath,
            filename: moduleMetadata.path,
        };

        modulesCache.set(key, module);

        __executeModule(moduleMetadata, module);

        return module;
    }

    global.require = (moduleIdentifier) => __loadModule(moduleIdentifier, defaultPreviousPath).exports;

    return __loadModule;
});
