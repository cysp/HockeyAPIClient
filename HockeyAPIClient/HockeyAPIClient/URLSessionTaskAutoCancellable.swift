//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


public class URLSessionTaskAutoCancellable: AutoCancellable {

    internal let task: URLSessionTask
    public var cancelOnDeinit: Bool

    init(task: URLSessionTask) {
        self.task = task
        cancelOnDeinit = true
    }

    deinit {
        guard cancelOnDeinit else {
            return
        }
        cancel()
    }


    public func cancel() {
        task.cancel()
    }

}
