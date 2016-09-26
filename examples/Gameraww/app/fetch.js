module.exports = function fetch(path) {
  var url = NSURL.URLWithString(path);
  return new Promise((resolve, reject) => {
    var dataTask =
        NSURLSession.sharedSession.dataTaskWithURLCompletionHandler(
            url, function(data, response, error) {
              if (error) {
                reject(error);
              } else {
                resolve(data);
              }
            });
    dataTask.resume();
  });
}
