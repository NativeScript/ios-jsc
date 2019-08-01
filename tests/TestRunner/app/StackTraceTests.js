describe("StackTrace", function () {
     it("Stack trace is correctly formatted with 'at ....'", function () {
        try {
            throw new Error("Test");
        }
        catch (ex) {
            expect(ex.stack).toMatch(new RegExp("^file:///app/StackTraceTests\\.js:\\d*:\\d*\\nat attemptSync\\(file:///"));
        }
     });

     it("Stack trace is formatted using prepareStackTrace", function () {
        Error.prepareStackTrace = function(error, frames) {
            expect(frames.length).toBeGreaterThan(2); // the idea here is to check that the frames are passed to the method
            expect(frames[0]).toMatch(new RegExp("^file:///app/StackTraceTests\\.js:\\d*:\\d*$"));
            return `Overridden stack trace with error: ${error}`;
        };

        try {
            throw new Error("Test");
        }
        catch (ex) {
            expect(ex.stack).toBe("Overridden stack trace with error: Error: Test");
        }
     });
         
     it("Stack trace frames should have the needed functions", function () {
        var lastErrorFrame;
        Error.prepareStackTrace = function(error, frames) {
            lastErrorFrame = {
                thisValue: frames[0].getThis(),
                typeName: frames[0].getTypeName(),
                functionValue: frames[0].getFunction(),
                functionName: frames[0].getFunctionName(),
                stringValue: frames[0].toString(),
                fileName: frames[0].getFileName(),
                lineNumber: frames[0].getLineNumber(),
                columnNumber: frames[0].getColumnNumber(),
                evalOrigin: frames[0].getEvalOrigin(),
                isToplevel: frames[0].isToplevel(),
                isEval: frames[0].isEval(),
                isNative: frames[0].isNative(),
                isConstructor: frames[0].isConstructor(),
                isAsync: frames[0].isAsync(),
                isPromiseAll: frames[0].isPromiseAll(),
                promiseIndex: frames[0].getPromiseIndex()
            }
            return `Overridden stack trace with error: ${error}`;
        };
        
        var testFunction = function testFunction() {
            throw new Error("Test");
        }
        
        try {
            testFunction();
        }
        catch (ex) {
            expect(ex.stack).toBe("Overridden stack trace with error: Error: Test");
            expect(lastErrorFrame.thisValue).toBe(undefined);
            expect(lastErrorFrame.typeName).toBe(undefined);
            expect(lastErrorFrame.functionValue.toString()).toMatch(new RegExp("^function testFunction\\(\\)"));
            expect(lastErrorFrame.functionName).toBe("testFunction");
            expect(lastErrorFrame.fileName).toBe("file:///app/StackTraceTests.js");
            expect(lastErrorFrame.stringValue).toMatch(new RegExp("^testFunction\\(file:///app/StackTraceTests\\.js:\\d+:\\d+\\)$"));
            expect(lastErrorFrame.lineNumber).toMatch(new RegExp("^\\d+$"));
            expect(lastErrorFrame.columnNumber).toMatch(new RegExp("^\\d+$"));
            expect(lastErrorFrame.evalOrigin).toBe(undefined);
            expect(lastErrorFrame.isToplevel).toBe(undefined);
            expect(lastErrorFrame.isEval).toBe(undefined);
            expect(lastErrorFrame.isNative).toBe(false);
            expect(lastErrorFrame.isConstructor).toBe(undefined);
            expect(lastErrorFrame.isAsync).toBe(undefined);
            expect(lastErrorFrame.isPromiseAll).toBe(undefined);
            expect(lastErrorFrame.promiseIndex).toBe(undefined);
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
