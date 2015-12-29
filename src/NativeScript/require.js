/*
 * THIS JAVASCRIPT FILE IS EMBEDED BY THE BUILD PROCESS.
 *
 * You can ignore this file and continue debugging.
 * To correct errors, edit the source file at: https://github.com/NativeScript/ios-runtime/blob/master/src/NativeScript/require.js
 */

(function (applicationPath, createModuleFunction) {
    'use strict';

    let fileManager = NSFileManager.defaultManager();
    let nsstr = NSString.stringWithString.bind(NSString);

    applicationPath = nsstr(applicationPath).stringByStandardizingPath;

    let USER_MODULES_ROOT = nsstr('app');
    let CORE_MODULES_ROOT = nsstr('app/tns_modules');

    let isDirectory = new interop.Reference(interop.types.bool, false);
    let defaultPreviousPath = NSString.pathWithComponents([USER_MODULES_ROOT, 'index.js']).toString();

    let pathCache = new Map();
    let modulesCache = new Map();

    function getRelativeToBundlePath(absolutePath) {
        return absolutePath.substr(applicationPath.length).replace(/^\//, '');
    }

    function getModuleCacheKey(moduleMetadata) {
        return moduleMetadata.bundlePath;
    }

    function __findModule(moduleIdentifier, previousPath) {
        let isBootstrap = !previousPath;
        if (isBootstrap) {
            previousPath = defaultPreviousPath;
        }
        let absolutePath;
        if (/^\.{1,2}\//.test(moduleIdentifier)) { // moduleIdentifier starts with ./ or ../
            let moduleDir = nsstr(previousPath).stringByDeletingLastPathComponent;
            absolutePath = NSString.pathWithComponents([applicationPath, moduleDir, moduleIdentifier]);
        } else if (/^\//.test(moduleIdentifier)) { // moduleIdentifier starts with /
            absolutePath = NSString.pathWithComponents([moduleIdentifier]);
        } else if (/^~\//.test(moduleIdentifier)) {
            absolutePath = NSString.pathWithComponents([applicationPath, USER_MODULES_ROOT, moduleIdentifier.substr(2)]);
        } else {
            absolutePath = NSString.pathWithComponents([applicationPath, CORE_MODULES_ROOT, moduleIdentifier]);
        }
        absolutePath = nsstr(absolutePath).stringByStandardizingPath;

        let requestedPath = absolutePath;
        if (pathCache.has(requestedPath)) {
            return pathCache.get(requestedPath);
        }

        let moduleMetadata = {
            name: nsstr(moduleIdentifier).lastPathComponent,
        };

        let absoluteFilePath = nsstr(absolutePath).stringByAppendingPathExtension("js");
        if (/\.json$/.test(absolutePath)) {
            moduleMetadata.type = 'json';
        } else {
            if (!fileManager.fileExistsAtPathIsDirectory(absoluteFilePath, isDirectory) &&
                fileManager.fileExistsAtPathIsDirectory(absolutePath, isDirectory)) {
                if (!isDirectory.value) {
                    throw new Error(`Expected '${getRelativeToBundlePath(absolutePath)}' to be a directory.`);
                }

                let mainFileName = 'index.js';

                let packageJsonPath = nsstr(absolutePath).stringByAppendingPathComponent("package.json");
                let packageJson = NSString.stringWithContentsOfFileEncodingError(packageJsonPath, NSUTF8StringEncoding, null);
                if (packageJson) {
                    //console.debug("PACKAGE_FOUND: " + packageJsonPath);

                    let packageJsonMain;
                    try {
                        packageJsonMain = JSON.parse(packageJson).main;
                    } catch (e) {
                        throw new Error(`Error parsing package.json in 'file:///${getRelativeToBundlePath(absolutePath)}/package.json' - ${e}`);
                    }

                    if (packageJsonMain && !/\.js$/.test(packageJsonMain)) {
                        packageJsonMain += '.js';
                    }
                    mainFileName = packageJsonMain || mainFileName;
                }

                absolutePath = nsstr(absolutePath).stringByAppendingPathComponent(mainFileName);
            } else {
                absolutePath = absoluteFilePath;
            }

            moduleMetadata.type = 'js';
        }
        absolutePath = nsstr(absolutePath).stringByStandardizingPath;
        let bundlePath = getRelativeToBundlePath(absolutePath);

        if (!fileManager.fileExistsAtPathIsDirectory(absolutePath, isDirectory)) {
            throw new Error(`Failed to find module '${moduleIdentifier}' relative to 'file:///${previousPath}'. Computed path: '${bundlePath}'.`);
        }

        if (isDirectory.value) {
            throw new Error(`Expected '${bundlePath}' to be a file`);
        }

        //console.debug('FIND_MODULE:', moduleIdentifier, absolutePath);

        moduleMetadata.path = absolutePath;
        moduleMetadata.bundlePath = bundlePath;

        pathCache.set(requestedPath, moduleMetadata);
        return moduleMetadata;
    }

    function __executeModule(moduleMetadata, module) {
        let modulePath = moduleMetadata.bundlePath;
        let moduleSource = NSString.stringWithContentsOfFileEncodingError(moduleMetadata.path, NSUTF8StringEncoding);

        let hadError = true;

        if (moduleMetadata.type === 'js') {
            module.require = function __require(moduleIdentifier) {
                return __loadModule(moduleIdentifier, modulePath).exports;
            };
            let dirName = nsstr(moduleMetadata.path).stringByDeletingLastPathComponent.toString();

            try {
                let moduleFunction = createModuleFunction(moduleSource, "file:///" + moduleMetadata.bundlePath);
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
            throw new Error(`Unknown module type '${moduleMetadata.type}'`);
        }
    }

    function __loadModule(moduleIdentifier, previousPath) {
        if (/\.js$/.test(moduleIdentifier)) {
            moduleIdentifier = moduleIdentifier.replace(/\.js$/, '');
        }

        let moduleMetadata = __findModule(moduleIdentifier, previousPath);

        let key = getModuleCacheKey(moduleMetadata);
        if (modulesCache.has(key)) {
            return modulesCache.get(key);
        }

        let module = {
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
