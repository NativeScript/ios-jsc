describe("StackTrace", function () {
     it("Stack trace is correctly formatted with 'at ....'", function () {
        try {
            throw new Error("Test");
        }
        catch (ex) {
           expect(ex.stack.startsWith("file:///app/StackTraceTests.js:4:28\nat attemptSync(file:///")).toBe(true);
        }
     });
         
     it("Stack trace is formatted using prepareStackTrace", function () {
        Error.prepareStackTrace = function(error, frames) {
            expect(frames.length).toBeGreaterThan(2); // the idea here is to check that the frames are passed to the method
            expect(frames[0]).toBe("file:///app/StackTraceTests.js:19:28");
            return `Overridden stack trace with error: ${error}`;
        };
        
        try {
            throw new Error("Test");
        }
        catch (ex) {
            console.log(ex.stack);
            expect(ex.stack).toBe("Overridden stack trace with error: Error: Test");
        }
     });
         
     it("Stack trace formatting is not broken when prepareStackTrace is not a function", function () {
        Error.prepareStackTrace = "not really a function";
        try {
            throw new Error("Test");
        }
        catch (ex) {
            expect(ex.stack.startsWith("file:///app/StackTraceTests.js")).toBe(true);
        }
     });
});
