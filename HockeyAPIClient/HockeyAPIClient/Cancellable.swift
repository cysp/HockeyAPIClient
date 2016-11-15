//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


public protocol Cancellable {
    func cancel()
}


public protocol AutoCancellable: Cancellable {
    var cancelOnDeinit: Bool { get set }
}
