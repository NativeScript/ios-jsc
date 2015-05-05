module.exports = function (grunt) {

    var fs = require('fs');
    var os = require('os');
    var util = require('util');
    var path = require('path');
    var shell = require('shelljs/global');

    var srcDir = ".";

    // build outputs
    var outDistDir = srcDir + "/dist";
    var outJscDir = outDistDir + "/jsc";
    var outJscLibDir = outJscDir + "/lib";
    var outJscHeadersDir = outJscDir + "/include";
    var outPackageDir = outDistDir + "/package";
    var outPackageFrameworkDir = outPackageDir + "/framework";
    var outBuildLog = outDistDir + "/build_log.txt";

    var commitSHA = (process.env.GIT_COMMIT) ? process.env.GIT_COMMIT : "";

    var assignGitSHA = function(err, stdout, stderr, cb) {
        if (!commitSHA) {
            commitSHA = stdout.replace("\n", "");
        }
        cb();
    };

    var getPackageVersion = function(baseVersion) {
        var buildVersion = process.env.PACKAGE_VERSION;
        if (!buildVersion) {
            return baseVersion;
        }
        return baseVersion + "-" + buildVersion;
    };

    var updatePackageVersion = function (content, srcPath) {
        var contentAsObject = JSON.parse(content);

        contentAsObject.version = getPackageVersion(contentAsObject.version);
        if (commitSHA) {
            contentAsObject.repository.url += "/commit/" + commitSHA;
        }

        return JSON.stringify(contentAsObject, null, "\t")
    };

    // /Applications/Xcode.app
    var XCODE_PATH = path.dirname(path.dirname(exec('xcode-select -print-path').output.trim()));
    grunt.log.subhead('XCODE_PATH: ' + XCODE_PATH);

    // 7.1
    var IPHONEOS_VERSION = exec('xcodebuild -showsdks | grep iphoneos | sort -r | tail -1 | awk \'{print $2}\'').output.trim();
    grunt.log.subhead('IPHONEOS_VERSION: ' + IPHONEOS_VERSION);

    // /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.1.sdk
    var IPHONEOS_SDK_PATH = path.join(XCODE_PATH, util.format('Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS%s.sdk', IPHONEOS_VERSION));
    grunt.log.subhead('IPHONEOS_SDK_PATH: ' + IPHONEOS_SDK_PATH);

    // 2316c45a992b2109248f6807ac3813c5e224f6ce
    var DEVICE_UDID = grunt.option('device_udid') || exec('system_profiler SPUSBDataType | sed -n -e "/iPad/,/Serial/p" -e "/iPhone/,/Serial/p" | grep "Serial Number:" | head -1 | awk -F ": " \'{print $2}\'').output.trim();
    grunt.log.subhead('DEVICE_UDID: ' + DEVICE_UDID);

    grunt.initConfig({
        srcDir: srcDir,
        outJscDir: outJscDir,
        outJscLibDir: outJscLibDir,
        outJscHeadersDir: outJscHeadersDir,
        outDistDir: outDistDir,
        outPackageDir: outPackageDir,
        outPackageFrameworkDir: outPackageFrameworkDir,
        outBuildLog: outBuildLog,

        getKeychainCommand: function () {
            if (process.env.KEYCHAIN) {
                return "\"OTHER_CODE_SIGN_FLAGS=--keychain " + process.env.KEYCHAIN + "\"";
            }
            return "";
        },

        pkg: grunt.file.readJSON(srcDir + "/package.json"),
        clean: {
            outDist: [outDistDir],
            outJsc: [outJscDir],
            outJscIntermediates: [outJscDir + "/JavaScriptCore.build", outJscDir + "/Production-iphonesimulator", outJscDir + "/WTF.build", outJscDir + "/Production-iphoneos"],
            outPackage: [outPackageDir],
            outPackageFramework: [outPackageFrameworkDir],
        },
        mkdir: {
            outDist: {
                options: { create: [outDistDir] }
            },
            outJsc: {
                options: { create: [outJscDir] }
            },
            outJscLib: {
                options: { create: [outJscLibDir] }
            },
            outJscHeaders: {
                options: { create: [outJscHeadersDir] }
            },
            outPackage: {
                options: { create: [outPackageDir] }
            },
            outPackageFramework : {
                options: { create: [outPackageFrameworkDir] }
            },
        },
        exec: {
            libJavaScriptCore_i386_x86_64: {
                cmd: "xcodebuild -project ./src/jsc/JavaScriptCore/JavaScriptCore.xcodeproj -target \"JavaScriptCore iOS\" -sdk iphonesimulator -configuration Production SYMROOT=../../../<%= outJscDir %> ARCHS=\"i386 x86_64\" clean build | xcpretty"
            },
            libJavaScriptCore_armv7_arm64: {
                cmd: "xcodebuild -project ./src/jsc/JavaScriptCore/JavaScriptCore.xcodeproj -target \"JavaScriptCore iOS\" -sdk iphoneos -configuration Production SYMROOT=../../../<%= outJscDir %> ARCHS=\"armv7 arm64\" clean build | xcpretty"
            },
            libJavaScriptCore_universal: {
                cmd: "lipo -create -output <%= outJscDir %>/lib/libJavaScriptCore.a <%= outJscDir %>/Production-iphonesimulator/libJavaScriptCore.a <%= outJscDir %>/Production-iphoneos/libJavaScriptCore.a"
            },
            libJavaScriptCore_copyHeaders: {
                cmd: "<%= srcDir %>/build/scripts/JSCCopyHeaders.sh"
            },

            npmPackPackage: {
                cmd: "npm pack ./package",
                cwd: outDistDir
            },
            buildStats: {
                cmd: 'echo "TNS_IPA_SIZE:" $(du -k Gameraww.ipa | awk \'{print $1}\')KB && ' +
                    'echo "TNS_IPA_SIZE_KB\\n"$(du -k Gameraww.ipa | awk \'{print $1}\') > ../../../../build-stats.csv',
                cwd: path.join(srcDir, 'cmake-build/examples/Gameraww/Release-iphoneos')
            }
        },
        copy: {
            packageComponents: {
                files: [
                    { expand: true, cwd: "<%= outDistDir %>", src: ["NativeScript", "NativeScript/**"], dest: "<%= outPackageFrameworkDir %>" },
                    { expand: true, cwd: "<%= srcDir %>/src/debugging", src: "TNSDebugging.h", dest: "<%= outPackageFrameworkDir %>/__PROJECT_NAME__" },
                    { expand: true, cwd: "<%= srcDir %>/src/debugging/WebInspectorUI", src: "**", dest: "<%= outPackageDir %>/WebInspectorUI/Safari" },
                    { expand: true, cwd: "<%= outDistDir %>/metadataGenerator", src: "**", dest: "<%= outPackageFrameworkDir %>/metadataGenerator" },
                    { expand: true, cwd: "<%= srcDir %>/build/project-template", src: "**", dest: "<%= outPackageFrameworkDir %>" }
                ],
                options: {
                    mode: true
                }
            },
            packageJson: { expand: true, src: "<%= srcDir %>/package.json", dest: outPackageDir, options: { process: updatePackageVersion } }
        },

        shell: {
            createIpa: {
                command: function (appFolder) {
                    var folder = path.dirname(appFolder);
                    var name = path.basename(appFolder, '.app');
                    return util.format('cd %s && rm -rf Payload && mkdir Payload && cp -r %s.app Payload/ && zip -r %s.ipa Payload', folder, name, name);
                }
            },

            buildApp: {
                command: function (target, config) {
                    config = config || 'Release';
                    return util.format('cmake --build . --config %s --target %s', config, target);
                },
                options: {
                    execOptions: {
                        cwd: 'cmake-build',
                        maxBuffer: Infinity
                    }
                }
            },

            NativeScript: {
                command: './build/build.sh',
                options: {
                    execOptions: {
                        maxBuffer: Infinity
                    }
                }
            },

            runTests: {
                command: function(app, jUnitLocation, device_udid) {
                    var cmd = util.format('node build/tasks/run-tests.js %s %s %s', app, jUnitLocation, device_udid);
                    return cmd;
                }
            },

            getGitSHA: {
                command: "git rev-parse HEAD",
                options: {
                    callback: assignGitSHA
                }
            },
        }
    });

    grunt.loadNpmTasks("grunt-contrib-clean");
    grunt.loadNpmTasks("grunt-contrib-copy");
    grunt.loadNpmTasks("grunt-mkdir");
    grunt.loadNpmTasks("grunt-exec");
    grunt.loadNpmTasks("grunt-shell");

    grunt.registerTask("default", [
        "build"
    ]);

    grunt.registerTask("build", [
        "package",
        "tests-ipa",
        "gameraww-ipa",
        "exec:buildStats"
    ]);

    grunt.registerTask("package", [
        "jsc",
        "shell:NativeScript",
        "clean:outPackage",
        "mkdir:outPackageFramework",
        "copy:packageComponents",
        "shell:getGitSHA",
        "copy:packageJson",
        "exec:npmPackPackage"
    ]);

    grunt.registerTask("jsc", function(){
        var buildJsc = true;
        try
        {
            if (fs.lstatSync(outJscDir).isDirectory() &&  fs.lstatSync(outJscHeadersDir).isDirectory() &&
                fs.lstatSync(outJscHeadersDir + "/JavaScriptCore").isDirectory() && fs.lstatSync(outJscHeadersDir + "/wtf").isDirectory() &&
                fs.lstatSync(outJscLibDir).isDirectory() && fs.lstatSync(outJscLibDir + "/libJavaScriptCore.a").isFile()) {
                buildJsc = false;
            }
        }
        catch(e) {}
        if (buildJsc) {
            console.log("Building JavaScriptCore");
            grunt.task.run("jscClean");
        }
    });

    grunt.registerTask("jscClean", [
        "clean:outJsc",
        "mkdir:outJsc",
        "mkdir:outJscLib",
        "mkdir:outJscHeaders",
        "exec:libJavaScriptCore_i386_x86_64",
        "exec:libJavaScriptCore_armv7_arm64",
        "exec:libJavaScriptCore_universal",
        "exec:libJavaScriptCore_copyHeaders",
        "clean:outJscIntermediates"
    ]);

    grunt.registerTask('gameraww-ipa', [
        'shell:buildApp:Gameraww:Release',
        'shell:createIpa:cmake-build/examples/Gameraww/Release-iphoneos/Gameraww.app'
    ]);

    grunt.registerTask('tests-ipa', [
        'shell:buildApp:TestRunner:Debug',
        'shell:createIpa:cmake-build/tests/TestRunner/Debug-iphoneos/TestRunner.app'
    ]);

    grunt.registerTask('run-tests', [
        util.format('shell:runTests:./cmake-build/tests/TestRunner/Debug-iphoneos/TestRunner.ipa:./junit-result.xml:%s', DEVICE_UDID)
    ]);

    grunt.registerTask('test', [
        'tests-ipa',
        'run-tests'
    ]);
};
