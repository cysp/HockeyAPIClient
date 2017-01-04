//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


open class Client {

    public struct Options {
        public var host: String = "rink.hockeyapp.net"
        public var apiVersion: UInt = 2
        public var token: String

        public init(token: String) {
            self.token = token
        }
    }


    internal let options: Options

    public init(_ options: Options) {
        self.options = options

        let sessionConfiguration = URLSessionConfiguration.default

        session = URLSession(configuration: sessionConfiguration)
    }

    internal let session: URLSession


    internal enum Endpoint {
        case applications
        case applicationVersions(applicationIdentifier: String)
        case applicationVersionSources(applicationIdentifier: String, versionIdentifier: String)
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
            url.appendPathComponent("app_versions", isDirectory: false)
            return url
        case let .applicationVersionSources(applicationIdentifier, versionIdentifier):
            var url = baseURL.appendingPathComponent("apps", isDirectory: true)
            url.appendPathComponent(applicationIdentifier, isDirectory: true)
            url.appendPathComponent("app_versions", isDirectory: true)
            url.appendPathComponent(versionIdentifier, isDirectory: true)
            url.appendPathComponent("app_sources", isDirectory: false)
            return url
        }
    }


    public enum Result<T, E: Error> {
        case ok(T)
        case error(E)
    }

    internal enum RequestError<M: HockeyAPIResponseModel>: Error {
        case unknown
        case networkError(Error)
        case httpError(HTTPURLResponse)
        case modelDataError(M.DataError)
    }
    internal typealias RequestResult<T: HockeyAPIResponseModel> = Result<T, RequestError<T>>

    internal func enqueuedRequest<T: HockeyAPIResponseModel>(url: URL, completion: @escaping ((RequestResult<T>) -> Void)) -> AutoCancellable {
        var req = URLRequest(url: url)
        req.addValue(options.token, forHTTPHeaderField: "X-HockeyAppToken")
        let task: URLSessionDataTask = session.dataTask(with: req, completionHandler: { (data, res, error) in
            if let error = error {
                return completion(.error(.networkError(error)))
            }
            guard let res = res as? HTTPURLResponse else {
                return completion(.error(.unknown))
            }
            switch res.statusCode {
            case 200..<300:
                break
            default:
                return completion(.error(.httpError(res)))
            }

            let model: T
            do {
                model = try HockeyAPIResponseParsing.parse(res: res, data: data)
            } catch let error as T.DataError {
                return completion(.error(.modelDataError(error)))
            } catch {
                return completion(.error(.unknown))
            }
//
//            guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                return completion(.error(.unknown))
//            }
//
//            guard let dict = object as? [String: Any] else {
//                return completion(.error(.unknown))
//            }

            return completion(.ok(model))
        })

        task.resume()
        return URLSessionTaskAutoCancellable(task: task)
    }


    public enum ApplicationsRequestError: Error {
        case unknown
    }
    public func requestApplications(completion: @escaping (Result<[Application], ApplicationsRequestError>) -> Void) -> AutoCancellable {
        return enqueuedRequest(url: url(.applications), completion: { (result: RequestResult<HockeyAPIApplicationsResponseModel>) in
            switch result {
            case .error(_):
                return completion(.error(.unknown))
            case let .ok(response):
                return completion(.ok(response.apps))
            }
        })
    }


    public enum ApplicationVersionsRequestError: Error {
        case unknown
    }
    public func requestApplicationVersions(for application: Application, completion: @escaping (Result<[ApplicationVersion], ApplicationVersionsRequestError>) -> Void) -> AutoCancellable {
        return self.requestApplicationVersions(for: application.publicIdentifier, completion: completion)
    }
    public func requestApplicationVersions(for applicationIdentifier: String, completion: @escaping (Result<[ApplicationVersion], ApplicationVersionsRequestError>) -> Void) -> AutoCancellable {
        return enqueuedRequest(url: url(.applicationVersions(applicationIdentifier: applicationIdentifier)), completion: { (result: RequestResult<HockeyAPIApplicationVersionsResponseModel>) in
            switch result {
            case .error(_):
                return completion(.error(.unknown))
            case let .ok(response):
                return completion(.ok(response.app_versions))
            }
        })
    }


    public enum ApplicationVersionSourcesRequestError: Error {
        case unknown
    }
    public func requestApplicationVersionSources(for applicationAndVersion: (Application, ApplicationVersion), completion: @escaping (Result<[ApplicationSource], ApplicationVersionSourcesRequestError>) -> Void) -> AutoCancellable {
        return requestApplicationVersionSources(for: (applicationAndVersion.0.publicIdentifier, applicationAndVersion.1.version), completion: completion)
    }
    public func requestApplicationVersionSources(for applicationAndVersionIdentifiers: (String, String), completion: @escaping (Result<[ApplicationSource], ApplicationVersionSourcesRequestError>) -> Void) -> AutoCancellable {
        return enqueuedRequest(url: url(.applicationVersionSources(applicationIdentifier: applicationAndVersionIdentifiers.0, versionIdentifier: applicationAndVersionIdentifiers.1)), completion: { (result: RequestResult<HockeyAPIApplicationSourcesResponseModel>) in
            switch result {
            case .error(_):
                return completion(.error(.unknown))
            case let .ok(response):
                return completion(.ok(response.app_sources))
            }
        })
    }
}
