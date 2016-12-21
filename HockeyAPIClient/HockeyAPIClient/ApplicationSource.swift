//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


public struct ApplicationSource {

    public let commitSHA: String?

    public enum DecodeError: Error {
        case unknown
    }
    init(dict: [String: Any]) throws {
        guard let commitSHA = dict["commit_sha"] as? String else {
            throw DecodeError.unknown
        }

        self.commitSHA = commitSHA
    }

}
