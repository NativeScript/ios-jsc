describe("Runtime exposes", function () {
  it("__time a low overhead, high resolution, time in ms.", function() {
    var dateTimeStart = Date.now();
    var timeStart = __time();
    var acc = 0;
    var s = CACurrentMediaTime();
     
    while (Date.now() - dateTimeStart < 5)
    {
    }
     
    var dateTimeEnd = Date.now();
    var timeEnd = __time();
    var dateDelta = dateTimeEnd - dateTimeStart;
    var timeDelta = timeEnd - timeStart;
    expect(Math.abs(dateDelta - timeDelta)).toBeLessThan(dateDelta * 0.25);
  });
});
