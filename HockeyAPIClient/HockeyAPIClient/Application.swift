//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


public struct Application {

    public let title: String
    public let bundleIdentifier: String
    public let publicIdentifier: String

//    public let deviceFamily: DeviceFamily
//    public let minimumOSVersion: Version

    public enum ReleaseType: Int {
        case alpha = 2
        case beta = 0
        case store = 1
        case enterprise = 3
    }
    public let releaseType: ReleaseType

    public enum Status: Int {
        case notDownloadable = 1
        case downloadable = 2
    }
    public let status: Status

    public enum Platform: String {
        case iOS = "iOS"
        case android = "Android"
        case macOS = "Mac OS"
        case windowsPhone = "Windows Phone"
        case custom = "Custom"
    }
    public let platform: Platform


    public enum DecodeError: Error {
        case unknown
    }

    init(dict: [String: Any]) throws {
        guard let title = dict["title"] as? String else {
            throw DecodeError.unknown
        }
        guard let bundleIdentifier = dict["bundle_identifier"] as? String else {
            throw DecodeError.unknown
        }
        guard let publicIdentifier = dict["public_identifier"] as? String else {
            throw DecodeError.unknown
        }
        guard let releaseTypeInt = dict["release_type"] as? Int else {
            throw DecodeError.unknown
        }
        guard let releaseType = ReleaseType(rawValue: releaseTypeInt) else {
            throw DecodeError.unknown
        }
        guard let statusInt = dict["status"] as? Int else {
            throw DecodeError.unknown
        }
        guard let status = Status(rawValue: statusInt) else {
            throw DecodeError.unknown
        }
        guard let platformString = dict["platform"] as? String else {
            throw DecodeError.unknown
        }
        guard let platform = Platform(rawValue: platformString) else {
            throw DecodeError.unknown
        }

        self.title = title
        self.bundleIdentifier = bundleIdentifier
        self.publicIdentifier = publicIdentifier
        self.releaseType = releaseType
        self.status = status
        self.platform = platform
    }

}
