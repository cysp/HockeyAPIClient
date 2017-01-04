//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation


internal protocol HockeyAPIResponseModel {
    associatedtype DataError: Error, Equatable

    init(res: HTTPURLResponse, dict: [String: Any]?) throws;
}

internal struct HockeyAPIResponseParsing {
    internal enum Error<T: Swift.Error & Equatable>: Swift.Error, Equatable {
        case unknown
//        case missingData
        case modelDecodingError(T)
    }

    static func parse<Model: HockeyAPIResponseModel>(res: HTTPURLResponse, data: Data?) throws -> Model {
        typealias Error = HockeyAPIResponseParsing.Error<Model.DataError>

        let dict: [String: Any]?
        if let data = data {
            let object = try? JSONSerialization.jsonObject(with: data, options: [])
            dict = object as? [String: Any]
        } else {
            dict = nil
        }

        let model: Model
        do {
            model = try Model(res: res, dict: dict)
        } catch let error as Model.DataError {
            throw Error.modelDecodingError(error)
        } catch let error as Error {
            let _ = error
//            throw error
            throw Error.unknown
        } catch {
            throw Error.unknown
        }
        
        return model
    }
    
}

internal func ==<T>(lhs: HockeyAPIResponseParsing.Error<T>, rhs: HockeyAPIResponseParsing.Error<T>) -> Bool {
    switch (lhs, rhs) {
    case (.unknown, .unknown):
        return true
//    case (.missingData, .missingData):
//        return true
    case (.modelDecodingError(let lhs), .modelDecodingError(let rhs)):
        return lhs == rhs
    default:
        return false
    }
}


internal struct HockeyAPIApplicationsResponseModel: HockeyAPIResponseModel {
    internal enum DataError: Swift.Error {
        case unknown
    }

    internal let apps: [Application]

    init(res: HTTPURLResponse, dict: [String : Any]?) throws {
        guard let dict = dict else {
            throw DataError.unknown
        }
        guard let applicationDicts = dict["apps"] as? [[String: Any]] else {
            throw DataError.unknown
        }
        self.apps = applicationDicts.flatMap { try? Application(dict: $0) }
    }
}


internal struct HockeyAPIApplicationVersionsResponseModel: HockeyAPIResponseModel {
    internal enum DataError: Swift.Error {
        case unknown
    }

    internal let app_versions: [ApplicationVersion]

    init(res: HTTPURLResponse, dict: [String : Any]?) throws {
        guard let dict = dict else {
            throw DataError.unknown
        }
        guard let applicationVersionDicts = dict["app_versions"] as? [[String: Any]] else {
            throw DataError.unknown
        }
        self.app_versions = applicationVersionDicts.flatMap { try? ApplicationVersion(dict: $0) }
    }
}


internal struct HockeyAPIApplicationSourcesResponseModel: HockeyAPIResponseModel {
    internal enum DataError: Swift.Error {
        case unknown
    }

    internal let app_sources: [ApplicationSource]

    init(res: HTTPURLResponse, dict: [String : Any]?) throws {
        guard let dict = dict else {
            throw DataError.unknown
        }
        guard let applicationSourceDicts = dict["app_sources"] as? [[String: Any]] else {
            throw DataError.unknown
        }
        self.app_sources = applicationSourceDicts.flatMap { try? ApplicationSource(dict: $0) }
    }
}
