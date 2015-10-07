function getURLSession() {
    return NSURLSession.sessionWithConfigurationDelegateDelegateQueue(NSURLSessionConfiguration.defaultSessionConfiguration(), null, NSOperationQueue.mainQueue());
}

function fetch(path) {
    var url = NSURL.URLWithString(path);
    return new Promise((resolve, reject) => {
        var session = getURLSession();
        var dataTask = session.dataTaskWithURLCompletionHandler(url, function (data, response, error) {
            if (error) {
                reject(error);
            } else {
                resolve(data);
            }
        });
        dataTask.resume();
        session.finishTasksAndInvalidate();
    });
}

exports.getURLSession = getURLSession;
exports.fetch = fetch;
