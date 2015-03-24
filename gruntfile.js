module.exports = function (grunt) {

    var fs = require('fs');
    var os = require('os');
    var util = require('util');
    var path = require('path');
    var shell = require('shelljs/global');
    var traceur = require('traceur');

    var srcDir = ".";
    var metadataGeneratorRepository = srcDir + "/src/metadata-generator";

    // build outputs
    var outDistDir = srcDir + "/dist";
    var outJscDir = outDistDir + "/jsc";
    var outJscLibDir = outJscDir + "/lib";
    var outJscHeadersDir = outJscDir + "/include";
    var outNativeScriptDir = outDistDir + "/NativeScript.framework";
    var outNativeScriptIntermediateDir = outNativeScriptDir + "/intermediate";
    var outTNSDebuggingDir = outDistDir + "/TNSDebugging.framework";
    var outTNSDebuggingIntermediateDir = outTNSDebuggingDir + "/intermediate";
    var outPackageDir = outDistDir + "/package";
    var outPackageFrameworkDir = outPackageDir + "/framework";
    var outPackageFrameworkMetadataDir = outPackageFrameworkDir + "/Metadata";
    var outMetadataGeneratorDir = outDistDir + "/metadataGenerator";
    var outMetadataMergerDir = outDistDir + "/metadataMerger";
    var outMetadataDir = outDistDir + "/metadata";
    var outSDKMetadataDir = outMetadataDir + "/iPhoneSDK";
    var outTestsMetadataDir = outMetadataDir + "/tests";
    var outWebInspectorUIDir = outDistDir + "/WebInspectorUI";
    var outWebInspectorUISafariDir = outWebInspectorUIDir + "/Safari";
    var outWebInspectorUISafariIntermediateDir = outWebInspectorUISafariDir + "/intermediates";
    var outWebInspectorUIChromeDir = outWebInspectorUIDir + "/Chrome";
    var outBuildLog = outDistDir + "/build_log.txt";

    var updatePackageVersion = function (content, srcPath) {
        var packageVersion = process.env.PACKAGE_VERSION;
        if (!packageVersion)
            return content;

        return content.replace(/"(version"\s*:\s*"\d+\.\d+\.\d+)"/, "\"$1-" + packageVersion + "\"");
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
        metadataGeneratorRepository: metadataGeneratorRepository,
        outDistDir: outDistDir,
        outNativeScriptDir: outNativeScriptDir,
        outNativeScriptIntermediateDir: outNativeScriptIntermediateDir,
        outTNSDebuggingDir: outTNSDebuggingDir,
        outTNSDebuggingIntermediateDir: outTNSDebuggingIntermediateDir,
        outPackageDir: outPackageDir,
        outPackageFrameworkDir: outPackageFrameworkDir,
        outPackageFrameworkMetadataDir: outPackageFrameworkMetadataDir,
        outMetadataGeneratorDir: outMetadataGeneratorDir,
        outMetadataMergerDir: outMetadataMergerDir,
        outMetadataDir: outMetadataDir,
        outSDKMetadataDir: outSDKMetadataDir,
        outTestsMetadataDir: outTestsMetadataDir,
        outWebInspectorUIDir: outWebInspectorUIDir,
        outWebInspectorUISafariDir: outWebInspectorUISafariDir,
        outWebInspectorUISafariIntermediateDir: outWebInspectorUISafariIntermediateDir,
        outWebInspectorUIChromeDir: outWebInspectorUIChromeDir,
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
            outNativeScript: [outNativeScriptDir],
            outNativeScriptIntermediate: [outNativeScriptIntermediateDir],
            outTNSDebugging: [outTNSDebuggingDir],
            outTNSDebuggingIntermediate: [outTNSDebuggingIntermediateDir],
            outPackage: [outPackageDir],
            outPackageFramework: [outPackageFrameworkDir],
            outPackageFrameworkMetadata: [outPackageFrameworkMetadataDir],
            outMetadataGenerator: [outMetadataGeneratorDir],
            outMetadataMerger: [outMetadataMergerDir],
            outSDKMetadata: [outSDKMetadataDir],
            outTestsMetadata: [outTestsMetadataDir],
            outWebInspectorUI: [outWebInspectorUIDir],
            outWebInspectorUISafari: [outWebInspectorUISafariDir],
            outWebInspectorUISafariIntermediate: [outWebInspectorUISafariIntermediateDir],
            outWebInspectorUIChrome: [outWebInspectorUIChromeDir]
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
            outNativeScript: {
                options: { create: [outNativeScriptDir] }
            },
            outTNSDebugging: {
                options: { create: [outTNSDebuggingDir] }
            },
            outPackage: {
                options: { create: [outPackageDir] }
            },
            outPackageFramework : {
                options: { create: [outPackageFrameworkDir] }
            },
            outPackageFrameworkMetadata : {
                options: { create: [outPackageFrameworkMetadataDir] }
            },
            outMetadataGenerator: {
                options: { create: [outMetadataGeneratorDir] }
            },
            outMetadataMerger : {
                options: { create: [outMetadataMergerDir] }
            },
            outSDKMetadata: {
                options: { create: [outSDKMetadataDir] }
            },
            outTestsMetadata: {
                options: { create: [outTestsMetadataDir] }
            },
            outWebInspectorUISafari: {
                options: { create: [outWebInspectorUISafariDir] }
            },
            outWebInspectorUISafariIntermediate: {
                options: { create: [outWebInspectorUISafariIntermediateDir] }
            },
            outWebInspectorUIChrome: {
                options: { create: [outWebInspectorUIChromeDir] }
            }
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

            libNativeScript_i386_x86_64: {
                cmd: "xcodebuild -configuration Release -sdk iphonesimulator -scheme NativeScript -workspace <%= srcDir %>/src/NativeScript/NativeScript.xcworkspace SYMROOT=../../<%= outNativeScriptIntermediateDir %> ARCHS=\"i386 x86_64\" VALID_ARCHS=\"i386 x86_64\" clean build > <%= outBuildLog %>"
            },
            libNativeScript_armv7_arm64: {
                cmd: "xcodebuild -configuration Release -sdk iphoneos -scheme NativeScript -workspace <%= srcDir %>/src/NativeScript/NativeScript.xcworkspace SYMROOT=../../<%= outNativeScriptIntermediateDir %> ARCHS=\"armv7 arm64\" VALID_ARCHS=\"armv7 arm64\" clean build CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO > <%= outBuildLog %>"
            },
            libNativeScript_universal: {
                cmd: "lipo -create -output <%= outNativeScriptDir %>/NativeScript <%= outNativeScriptIntermediateDir %>/Release-iphoneos/libNativeScript.a <%= outNativeScriptIntermediateDir %>/Release-iphonesimulator/libNativeScript.a "
            },

            libTNSDebugging_i386_x86_64: {
                cmd: "xcodebuild -configuration Release -sdk iphonesimulator -workspace <%= srcDir %>/src/debugging/TNSDebugging/TNSDebugging.xcworkspace -scheme TNSDebugging SYMROOT=../../../<%= outTNSDebuggingIntermediateDir %> ARCHS=\"i386 x86_64\" VALID_ARCHS=\"i386 x86_64\" clean build > <%= outBuildLog %>"
            },
            libTNSDebugging_armv7_arm64: {
                cmd: "xcodebuild -configuration Release -sdk iphoneos -scheme TNSDebugging -workspace <%= srcDir %>/src/debugging/TNSDebugging/TNSDebugging.xcworkspace SYMROOT=../../../<%= outTNSDebuggingIntermediateDir %> ARCHS=\"armv7 arm64\" VALID_ARCHS=\"armv7 arm64\" clean build CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO > <%= outBuildLog %>"
            },
            libTNSDebugging_universal: {
                cmd: "lipo -create -output <%= outTNSDebuggingDir %>/TNSDebugging <%= outTNSDebuggingIntermediateDir %>/Release-iphoneos/libTNSDebugging.a <%= outTNSDebuggingIntermediateDir %>/Release-iphonesimulator/libTNSDebugging.a "
            },

            webInspectorUISafari: {
                cmd: "xcodebuild -configuration Release -sdk macosx -project <%= srcDir %>/src/debugging/WebInspectorUI-600.1.4/WebInspectorUI.xcodeproj SYMROOT=../../../<%= outWebInspectorUISafariIntermediateDir %> clean build > <%= outBuildLog %>"
            },
            webInspectorUIChrome: {
                cmd: "<%= srcDir %>/build/scripts/WIBuildForChrome.sh"
            },
            npmPackPackage: {
                cmd: "npm pack ./package",
                cwd: outDistDir
            },
            tnsAppBuildStats: {
                cmd: 'echo "TNS_IPA_SIZE:" $(du -k TNSApp.ipa | awk \'{print $1}\')KB && ' +
                    'echo "TNS_IPA_SIZE_KB\\n"$(du -k TNSApp.ipa | awk \'{print $1}\') > ../../../build-stats.csv',
                cwd: path.join(srcDir, 'examples/TNSApp/build')
            },

            npmInstallMetadataGenerator: {
                cmd: 'npm install',
                cwd: 'src/metadata-generator'
            }
        },
        copy: {
            libNativeScript_headers: {
                files: [
                    { expand: true, cwd: "<%= outNativeScriptIntermediateDir %>/Release-iphoneos/include/NativeScript", src: "**", dest: "<%= outNativeScriptDir %>/Headers/" }
                ]
            },

            libTNSDebugging_headers: {
                files: [
                    { expand: true, cwd: "<%= outTNSDebuggingIntermediateDir %>/Release-iphoneos/include/TNSDebugging", src: "**", dest: "<%= outTNSDebuggingDir %>/Headers/" }
                ]
            },

            webInspectorUISafari: {
                files: [
                    { expand: true, cwd: "<%= outWebInspectorUISafariIntermediateDir %>/Release/WebInspectorUI.framework/Resources", src: "**", dest: "<%= outWebInspectorUISafariDir %>" }
                ]
            },

            packageComponents: {
                files: [
                    { expand: true, cwd: "<%= outDistDir %>", src: ["NativeScript.framework", "NativeScript.framework/**"], dest: "<%= outPackageFrameworkDir %>" },
                    { expand: true, cwd: "<%= outDistDir %>", src: ["TNSDebugging.framework", "TNSDebugging.framework/**"], dest: "<%= outPackageFrameworkDir %>" },
                    { expand: true, cwd: "<%= outDistDir %>", src: ["WebInspectorUI/Safari", "WebInspectorUI/Safari/**"], dest: "<%= outPackageDir %>" },
                    { expand: true, cwd: "<%= outSDKMetadataDir %>/yaml", src: "**", dest: "<%= outPackageFrameworkMetadataDir %>" },
                    { expand: true, cwd: "<%= outMetadataGeneratorDir %>", src: "**", dest: "<%= outPackageFrameworkMetadataDir %>" },
                    { expand: true, cwd: "<%= outMetadataMergerDir %>", src: "**", dest: "<%= outPackageFrameworkMetadataDir %>" },
                    { expand: true, cwd: "<%= srcDir %>/build/project-template", src: "**", dest: "<%= outPackageFrameworkDir %>" },
                    { expand: true, src: "<%= srcDir %>/package.json", dest: outPackageDir, options: { process: updatePackageVersion } }
                ],
                options: {
                    mode: true
                }
            }
        },

        shell: {
            buildXcodeProject: {
                command: function (project, target, outputPath) {
                    if (grunt.file.exists(outputPath)) {
                        grunt.file.delete(outputPath);
                    }

                    outputPath = path.join('../../', outputPath);

                    return util.format('xcodebuild -project %s -target %s -configuration Release -sdk iphoneos ARCHS=armv7 VALID_ARCHS=armv7 CONFIGURATION_BUILD_DIR="%s" clean build | xcpretty', project, target, outputPath);
                }
            },

            generateYamlMetadata: {
                command: function (umbrellaHeader, outputPath, clangArgs) {
                    umbrellaHeader = path.resolve(umbrellaHeader);
                    outputPath = path.resolve(outputPath);
                    return util.format('MetadataGenerator -s "%s" -u "%s" -o "%s" -cflags="%s"', IPHONEOS_SDK_PATH, umbrellaHeader, outputPath, clangArgs);
                },
                options: {
                    execOptions: {
                        cwd: outMetadataGeneratorDir,
                        env: {
                            'DYLD_LIBRARY_PATH': path.join(XCODE_PATH, 'Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib')
                        }
                    }
                }
            },

            generateBinMetadata: {
                command: function (inputPath, outputPath) {
                    inputPath = path.resolve(inputPath);
                    outputPath = path.resolve(outputPath);
                    return util.format('./MetaMerge %s %s', inputPath, outputPath) +
                        util.format('&& echo "TNS_METADATA_SIZE:" $(du -k %s | awk \'{print $1}\')KB', outputPath);
                },
                options: {
                    execOptions: {
                        cwd: outMetadataMergerDir,
                    }
                }
            },

            archiveApp: {
                command: function (project, target, outputPath) {
                    if (grunt.file.exists(outputPath)) {
                        grunt.file.delete(outputPath);
                    }

                    if (path.extname(project) === '.xcworkspace') {
                        project = '-workspace ' + project;
                    } else {
                        project = '-project ' + project;
                    }

                    var archivePath = path.join(path.dirname(outputPath), path.basename(outputPath, path.extname(outputPath)) + '.xcarchive');

                    return util.format('export LC_CTYPE=en_US.UTF-8 && ' +
                        'xcodebuild %s -scheme %s archive -archivePath %s <%= getKeychainCommand() %> | xcpretty && ' +
                        'xcodebuild -exportArchive -exportFormat ipa -archivePath %s -exportPath %s', project, target, archivePath, archivePath, outputPath);
                }
            },

            runTests: {
                command: function(app, jUnitLocation, device_udid) {
                    var cmd = util.format('node build/tasks/run-tests.js %s %s %s', app, jUnitLocation, device_udid);
                    console.log("RunTests CMD: " + cmd);
                    return cmd;
                }
            }
        },

        grunt: {
            metadataGenerator: {
                gruntfile: metadataGeneratorRepository + "/gruntfile.js",
                task: util.format("packageGenerator:%s", path.resolve(outMetadataGeneratorDir))
            },
            metadataMerger: {
                gruntfile: metadataGeneratorRepository + "/gruntfile.js",
                task: util.format("packageMerger:%s", path.resolve(outMetadataMergerDir))
            }
        }
    });

    grunt.loadNpmTasks("grunt-contrib-clean");
    grunt.loadNpmTasks("grunt-contrib-copy");
    grunt.loadNpmTasks("grunt-mkdir");
    grunt.loadNpmTasks("grunt-exec");
    grunt.loadNpmTasks("grunt-shell");
    grunt.loadNpmTasks("grunt-grunt");

    grunt.registerTask("default", [
        "build"
    ]);

    grunt.registerTask("build", [
        "package",
        "shell:archiveApp:examples/TNSApp/TNSApp.xcodeproj:TNSApp:examples/TNSApp/build/TNSApp.ipa",
        "exec:tnsAppBuildStats"
    ]);

    grunt.registerTask("package", [
        "jsc",
        "metadataTools",
        "NativeScript",
        "TNSDebugging",
        "dist-metadata",
        "WebInspectorUI",
        "clean:outPackage",
        "mkdir:outPackageFramework",
        "mkdir:outPackageFrameworkMetadata",
        "copy:packageComponents",
        "exec:npmPackPackage"
    ]);

    grunt.registerTask("metadataTools", [
        "metadataGenerator",
        "metadataMerger"
    ]);

    grunt.registerTask("metadataGenerator", [
        "clean:outMetadataGenerator",
        "mkdir:outMetadataGenerator",
        "exec:npmInstallMetadataGenerator",
        "grunt:metadataGenerator"
    ]);

    grunt.registerTask("metadataMerger", [
        "clean:outMetadataMerger",
        "mkdir:outMetadataMerger",
        "exec:npmInstallMetadataGenerator",
        "grunt:metadataMerger"
    ]);

    grunt.registerTask("NativeScript", [
        "clean:outNativeScript",
        "mkdir:outNativeScript",
        "exec:libNativeScript_i386_x86_64",
        "exec:libNativeScript_armv7_arm64",
        "exec:libNativeScript_universal",
        "copy:libNativeScript_headers",
        "clean:outNativeScriptIntermediate"
    ]);

    grunt.registerTask("jsc", function(){
        var buildJsc = true;
        try
        {
            if (fs.lstatSync(outJscDir).isDirectory() &&  fs.lstatSync(outJscHeadersDir).isDirectory() && 
                fs.lstatSync(outJscHeadersDir + "/JavaScriptCore").isDirectory() && fs.lstatSync(outJscHeadersDir + "/wtf").isDirectory() &&
                fs.lstatSync(outJscLibDir).isDirectory() && fs.lstatSync(outJscLibDir + "/libJavaScriptCore.a").isFile()) {
                // JavaScriptCore is already built and there is no need to build it again
                buildJsc = false;
            }
        }
        catch(e) {}
        if (buildJsc) {
            console.log("Build JavaScriptCore");
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

    grunt.registerTask("TNSDebugging", [
        "clean:outTNSDebugging",
        "mkdir:outTNSDebugging",
        "exec:libTNSDebugging_i386_x86_64",
        "exec:libTNSDebugging_armv7_arm64",
        "exec:libTNSDebugging_universal",
        "copy:libTNSDebugging_headers",
        "clean:outTNSDebuggingIntermediate"
    ]);

    grunt.registerTask('test', [
        "jsc",
        "metadataTools",
        'test-metadata',
        'shell:buildXcodeProject:tests/NativeScriptTests/NativeScriptTests.xcodeproj:NativeScriptTests:tests/NativeScriptTests/build/',
        util.format('shell:runTests:./tests/NativeScriptTests/build/NativeScriptTests.app:./junit-result.xml:%s', DEVICE_UDID)
    ]);

    grunt.registerTask("metadata", function(umbrellaHeader, outputPath, clangArgs) {
        clangArgs = clangArgs || "";
        var yamlPath = path.resolve(path.join(outputPath, "yaml"));
        var binPath = path.resolve(path.join(outputPath, "bin"));
        grunt.task.run(util.format('shell:generateYamlMetadata:%s:%s:%s', umbrellaHeader, yamlPath, clangArgs));
        grunt.task.run(util.format('shell:generateBinMetadata:%s:%s', path.join(yamlPath, "Metadata-armv7"), path.join(binPath, "'metadata-armv7.bin'")));
        grunt.task.run(util.format('shell:generateBinMetadata:%s:%s', path.join(yamlPath, "Metadata-arm64"), path.join(binPath, "'metadata-arm64.bin'")));
    });

    grunt.registerTask("dist-metadata", [
        "clean:outSDKMetadata",
        "mkdir:outSDKMetadata",
        util.format("metadata:%s:%s:%s", srcDir + "/build/ios-sdk-umbrella-headers/ios8.2.h", outSDKMetadataDir, "")
    ]);

    grunt.registerTask("test-metadata", [
        "clean:outTestsMetadata",
        "mkdir:outTestsMetadata",
        util.format("metadata:%s:%s:%s", srcDir + "/tests/NativeScriptTests/NativeScriptTests/TNSTestCases.h", outTestsMetadataDir, "")
    ]);

    grunt.registerTask("WebInspectorUI", [
        "WebInspectorUISafari",
        "WebInspectorUIChrome"
    ]);

    grunt.registerTask("WebInspectorUISafari", [
        "clean:outWebInspectorUISafari",
        "mkdir:outWebInspectorUISafari",
        "exec:webInspectorUISafari",
        "copy:webInspectorUISafari",
        "clean:outWebInspectorUISafariIntermediate"
    ]);

    // First WebInspectorUISafari must be built
    grunt.registerTask("WebInspectorUIChrome", [
        "clean:outWebInspectorUIChrome",
        "mkdir:outWebInspectorUIChrome",
        "exec:webInspectorUIChrome"
    ]);

    grunt.registerTask('build-gameraww-ipa', [
        "jsc",
        "metadataTools",
        "dist-metadata",
        "shell:archiveApp:examples/Gameraww/Gameraww.xcodeproj:Gameraww:examples/Gameraww/build/Gameraww.ipa"
    ]);

    grunt.registerTask('build-tnsapp-ipa', [
        "jsc",
        "metadataTools",
        'dist-metadata',
        'shell:archiveApp:examples/TNSApp/TNSApp.xcodeproj:TNSApp:examples/TNSApp/build/TNSApp.ipa'
    ]);
};
