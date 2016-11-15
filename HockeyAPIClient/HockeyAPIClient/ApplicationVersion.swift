//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


public struct ApplicationVersion {

    public let version: String
    public let configURL: URL

    public let status: Application.Status

    public enum DecodeError: Error {
        case unknown
    }
    init(dict: [String: Any]) throws {
        guard let version = dict["version"] as? String else {
            throw DecodeError.unknown
        }
        guard let configURLString = dict["config_url"] as? String else {
            throw DecodeError.unknown
        }
        guard let configURL = URL(string: configURLString) else {
            throw DecodeError.unknown
        }
        guard let statusInt = dict["status"] as? Int else {
            throw DecodeError.unknown
        }
        guard let status = Application.Status(rawValue: statusInt) else {
            throw DecodeError.unknown
        }

        self.version = version
        self.configURL = configURL
        self.status = status
    }

//    "version": "208",
//    "mandatory": false,
//    "config_url": "https://rink.hockeyapp.net/manage/apps/1266/app_versions/208",
//    "download_url":"https://rink.hockeyapp.net/apps/0873e2b98ad046a92c170a243a8515f6/app_versions/208
//    "timestamp": 1326195742,
//    "appsize": 157547,
//    "device_family": null,
//    "notes": "<p>Fixed bug when users could not sign in.</p>\n",
//    "status": 2,
//    "shortversion": "1.1",
//    "minimum_os_version": null,
//    "title": "HockeyApp"

}
