//
//  CastledNetworkMonitor.swift
//  Castled
//
//  Created by antony on 27/09/2023.
//

import Combine
import Network

class CastledNetworkMonitor {
    static let shared = CastledNetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "CastledNetworkMonitor")
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
//            print(path.status == .satisfied ? "Connected" : "Disconnected")
            if path.status == .satisfied {
                Castled.sharedInstance?.executeBGTasks()
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
