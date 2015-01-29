// This node app runs tests and logs the results in a file.
// Parameters:
//  - Path to APK to deploy and run.
//  - Path for the junit.xml output.

// We need to pass also the device...

/*
NOTE:
It allows multiple devices to run tests simultaneously:

var proc = require('child_process');

var p1 = proc.exec('node ./Build/Tasks/run-tests.js ./Tests/NativeScriptTests/build/NativeScriptTests.app ./junit-d1.xml 2316c45a992b2109248f6807ac3813c5e224f6ce 12345');
p1.stdout.pipe(process.stdout, { end: false });
p1.stderr.pipe(process.stderr, { end: false });

var p2 = proc.exec('node ./Build/Tasks/run-tests.js ./Tests/NativeScriptTests/build/NativeScriptTests.app ./junit-d2.xml d39c73c77164f186ed3b283e9a65d1631c6b209c 12346');
p2.stdout.pipe(process.stdout, { end: false });
p2.stderr.pipe(process.stderr, { end: false });
*/

if (process.argv.length < 4) {
	console.error("Expects two arguments - path to apk and path to output junit.xml!");
	process.exit(1);
}

var apk = process.argv[2];
var jUnitLocation = process.argv[3];

var uuid = undefined;
if (process.argv.length >= 5) {
    uuid = process.argv[4];
}

var port = undefined;
if (process.argv.length >= 6) {
    port = process.argv[5];
}

var proc = require('child_process');
var fs = require('fs');

var launched = 'Application Start!';
var term = 'TKUnit: ';
var end = '</testsuites>';

var deployTimeout = 180000; // 3 minutes to deploy and launch.
var testsTimeout = 120000; // 2 minutes to run all tests.

// NOTE: If the "lldb" process is currently running the ios-deploy will fail to connect...

var cmd = 'ios-deploy --verbose --bundle ' + apk + ' --debug --arg \'-logjunit\'';

if (uuid) {
    cmd = cmd + ' --id ' + uuid;
}

if (port) {
    cmd = cmd + ' --port ' + port;
}

var results = fs.createWriteStream(jUnitLocation);

function timeoutFunction(msg) {
    if (uuid) {
        msg += " " + uuid;
    }
    console.error(msg);
    results.end();
    testrun.kill();
    process.exit(1);
};

var timeout = setTimeout(function() { timeoutFunction("ERROR: Deploy timeout!"); }, deployTimeout);
var completedSuccessfully = false;

console.log("Executing ios-deploy: " + cmd);
var testrun = proc.exec(cmd, { maxBuffer: 1024 * 1024 * 10 }, function(error, stdout, stderr) {
    // If the process exits prematurely kill the timer anyway...
    clearTimeout(timeout);
    if (!completedSuccessfully && error) {
        console.error("ERROR: Test run failed!");
        results.end();
        process.exit(1);
    }
}); // 10MB output buffers...
testrun.stderr.pipe(process.stderr, { end: false });

var leftover = "";

testrun.stdout.on('data', function(chunks) {
 
    chunks = leftover + chunks;
    chunks = chunks.replace(/\(lldb\)\s/g, '');
    var lines = chunks.split('\n');
    for(var i = 0; i < lines.length - 1; i++) {
        var line = lines[i];

        if (line.indexOf(launched) >= 0) {
            clearTimeout(timeout);
            timeout = setTimeout(function() { timeoutFunction("ERROR: Tests run timeout!"); }, testsTimeout);
            console.log("Application deployed and launched! Deploy timeout reset. Start test run timeout.");
        }

        // if line.indexOf('App Start') reset the timeout function
        var index = line.indexOf(term);
        if (index <= 0) {
            process.stdout.write(line + '\n');
        } else {
            var data = line.substr(index + term.length);
            
            results.write(data);

            if (data.search(end) >= 0) {
                completedSuccessfully = true;
                results.end();
                testrun.kill();
                clearTimeout(timeout);
            }
        }
    }

    leftover = lines[lines.length - 1];
});

