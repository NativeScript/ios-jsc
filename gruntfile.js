var fs = require('fs');
var os = require('os');
var util = require('util');
var path = require('path');
var shell = require('shelljs/global');

module.exports = function (grunt) {
    var srcDir = ".";

    // build outputs
    var outDistDir = srcDir + "/dist";
    var outPackageDir = outDistDir + "/package";
    var outPackageFrameworkDir = outPackageDir + "/framework";

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

    grunt.initConfig({
        srcDir: srcDir,
        outDistDir: outDistDir,
        outPackageDir: outPackageDir,
        outPackageFrameworkDir: outPackageFrameworkDir,

        pkg: grunt.file.readJSON(srcDir + "/package.json"),
        clean: {
            outDist: [outDistDir]
        },
        mkdir: {
            outPackage: {
                options: { create: [outPackageDir] }
            },
            outPackageFramework : {
                options: { create: [outPackageFrameworkDir] }
            },
        },
        exec: {
            npmPackPackage: {
                cmd: "npm pack ./package",
                cwd: outDistDir
            },
            copyInspector: {
                cmd: "cp -a '<%= srcDir %>/build/inspector/NativeScript Inspector.app' '<%= outPackageDir %>/WebInspectorUI/NativeScript Inspector.app'"
            }
        },
        copy: {
            packageComponents: {
                files: [
                    { expand: true, cwd: "<%= outDistDir %>", src: ["NativeScript", "NativeScript/**"], dest: "<%= outPackageFrameworkDir %>" },
                    { expand: true, cwd: "<%= outDistDir %>", src: ["NativeScript.framework", "NativeScript.framework/**"], dest: "<%= outPackageFrameworkDir %>" },
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
            NativeScript: {
                command: './build/scripts/build.sh',
                options: {
                    execOptions: {
                        maxBuffer: Infinity
                    }
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
        "package"
    ]);

    grunt.registerTask("package", [
        "clean:outDist",
        "shell:NativeScript",
        "mkdir:outPackageFramework",
        "copy:packageComponents",
        "exec:copyInspector",
        "shell:getGitSHA",
        "copy:packageJson",
        "exec:npmPackPackage"
    ]);
};
