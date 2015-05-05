function getURLSession() {
    return NSURLSession.sessionWithConfigurationDelegateDelegateQueue(NSURLSessionConfiguration.defaultSessionConfiguration(), null, NSOperationQueue.mainQueue());
}

function imageViewLoadFromURL(imageView, path, completionHandler) {
    var url = NSURL.URLWithString(path);
    var session = getURLSession();
    var dataTask = session.dataTaskWithURLCompletionHandler(url, function(data, response, error) {
        if (error) {
            console.error(error.localizedDescription);
        } else {
            var image = UIImage.imageWithData(data);
            if (image) {
                imageView.image = image;
			}
        }

        if (completionHandler) {
            completionHandler(error);
        }
    });
    dataTask.resume();
    session.finishTasksAndInvalidate();
}

exports.getURLSession = getURLSession;
exports.imageViewLoadFromURL = imageViewLoadFromURL;
