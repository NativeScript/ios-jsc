describe("Promise scheduling", function () {
   it("should be executed", function(done) {
       Promise.resolve().then(done); 
   });
});