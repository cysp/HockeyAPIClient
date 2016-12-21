//: Playground - noun: a place where people can play

import PlaygroundSupport
import HockeyAPIClient


PlaygroundPage.current.needsIndefiniteExecution = true


let o = Client.Options(token: "d31d487e5e2a4194ad6c1fb0ba497996")
let c = Client(o)


//var t = c.requestApplications { result in
//
//    switch result {
//    case let .ok(applications):
//        applications
//    case let .error(error):
//        error
//    }
//
//    PlaygroundPage.current.finishExecution()
//}
//t.cancelOnDeinit = false


//var t = c.requestApplicationVersions(for: "cfcd455e7565a68f2785eaa36948e0e4", completion: { result in
//    switch result {
//    case let .ok(applications):
//        applications
//    case let .error(error):
//        error
//    }
//
//    PlaygroundPage.current.finishExecution()
//})
//t.cancelOnDeinit = false


var t = c.requestApplicationVersionSources(for: ("cfcd455e7565a68f2785eaa36948e0e4", "310"), completion: { result in
    switch result {
    case let .ok(applications):
        applications
    case let .error(error):
        error
    }

    PlaygroundPage.current.finishExecution()
})
t.cancelOnDeinit = false
