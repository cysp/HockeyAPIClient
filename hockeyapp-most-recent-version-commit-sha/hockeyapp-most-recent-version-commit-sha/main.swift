//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation
import HockeyAPIClient


func requestMostRecentExtantCommitSha(client: Client, applicationId: String, versions: [ApplicationVersion], completion: @escaping ((String?) -> Void)) {
    func dothething_(client: Client, applicationId: String, versions: [ApplicationVersion], completion: @escaping ((String?) -> Void)) {
        var versions = versions
        guard let version = versions.popLast() else {
            return completion(nil)
        }

        var t = client.requestApplicationVersionSources(for: (applicationId, version.version)) { result in
            switch result {
            case .error(_):
                return dothething_(client: client, applicationId: applicationId, versions: versions, completion: completion)
            case let .ok(sources):
                guard let commitSHA = sources.first?.commitSHA else {
                    return dothething_(client: client, applicationId: applicationId, versions: versions, completion: completion)
                }
                return completion(commitSHA)
            }
        }
        t.cancelOnDeinit = false
    }
    return dothething_(client: client, applicationId: applicationId, versions: versions, completion: completion)
}


let p = ProcessInfo()

guard let apiToken = p.environment["HOCKEYAPP_API_TOKEN"] else {
    exit(1)
}

guard let appId = p.environment["HOCKEYAPP_APP_ID"] else {
    exit(1)
}


let c = Client(Client.Options(token: apiToken))

var t = c.requestApplicationVersions(for: appId) { result in
    switch result {
    case .error(_):
        exit(1)
    case let .ok(versions):
        requestMostRecentExtantCommitSha(client: c, applicationId: appId, versions: versions, completion: { (sha) in
            guard let sha = sha else {
                exit(1)
            }

            print("\(sha)")
        })
    }
}
t.cancelOnDeinit = false


dispatchMain()
