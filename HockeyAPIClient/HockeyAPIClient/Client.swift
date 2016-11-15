//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


public enum Result<T, E: Error> {
    case ok(T)
    case error(E)
}

open class Client {

    public struct Options {
        public var host: String = "rink.hockeyapp.net"
        public var apiVersion: UInt = 2
        public var token: String
    }


    internal let options: Options

    init(_ options: Options) {
        self.options = options

        let sessionConfiguration = URLSessionConfiguration.default

        session = URLSession(configuration: sessionConfiguration)
    }

    internal let session: URLSession


    internal enum Endpoint {
        case applications
        case applicationVersions(applicationIdentifier: String)
    }
    internal func url(_ endpoint: Endpoint) -> URL {
        var c = URLComponents()
        c.scheme = "https"
        c.host = options.host
        c.path = "/api/\(options.apiVersion)/"

        let baseURL = c.url!

        switch endpoint {
        case .applications:
            return baseURL.appendingPathComponent("apps", isDirectory: false)
        case let .applicationVersions(applicationIdentifier):
            var url = baseURL.appendingPathComponent("apps", isDirectory: true)
            url.appendPathComponent(applicationIdentifier, isDirectory: true)
            return url.appendingPathComponent("app_versions", isDirectory: false)
        }
    }


    internal enum RequestError: Error {
        case unknown
    }
    internal func enqueuedRequest(url: URL, completion: @escaping ((Result<[String: Any], RequestError>) -> Void)) -> URLSessionTaskAutoCancellable {
        let task: URLSessionDataTask = session.dataTask(with: url, completionHandler: { (data, res, error) in
            if error != nil {
                return completion(.error(.unknown))
            }
            guard let res = res as? HTTPURLResponse else {
                return completion(.error(.unknown))
            }
            switch res.statusCode {
            case 200..<300:
                break
            default:
                return completion(.error(.unknown))
            }
            guard let data = data else {
                return completion(.error(.unknown))
            }

            guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
                return completion(.error(.unknown))
            }

            guard let dict = object as? [String: Any] else {
                return completion(.error(.unknown))
            }

            return completion(.ok(dict))
        })

        task.resume()
        return URLSessionTaskAutoCancellable(task: task)
    }


    public enum ApplicationsRequestError: Error {
        case unknown
    }
    public func requestApplications(completion: @escaping (Result<[Application], ApplicationsRequestError>) -> Void) -> AutoCancellable {
        return enqueuedRequest(url: url(.applications), completion: { result in
            switch result {
            case .error(_):
                return completion(.error(.unknown))
            case let .ok(dict):
                guard let applicationDicts = dict["apps"] as? [[String: Any]] else {
                    return completion(.error(.unknown))
                }
                let applications = applicationDicts.flatMap { try? Application(dict: $0) }
                return completion(.ok(applications))
            }
        })
    }


    public enum ApplicationVersionsRequestError: Error {
        case unknown
    }
    public func requestApplicationVersions(application: Application, completion: @escaping (Result<[ApplicationVersion], ApplicationVersionsRequestError>) -> Void) -> AutoCancellable {
        return self.requestApplicationVersions(applicationIdentifier: application.publicIdentifier, completion: completion)
    }
    public func requestApplicationVersions(applicationIdentifier: String, completion: @escaping (Result<[ApplicationVersion], ApplicationVersionsRequestError>) -> Void) -> AutoCancellable {
        return enqueuedRequest(url: url(.applications), completion: { result in
            switch result {
            case .error(_):
                return completion(.error(.unknown))
            case let .ok(dict):
                guard let applicationVersionDicts = dict["app_versions"] as? [[String: Any]] else {
                    return completion(.error(.unknown))
                }
                let applicationVersions = applicationVersionDicts.flatMap { try? ApplicationVersion(dict: $0) }
                return completion(.ok(applicationVersions))
            }
        })
    }

}
