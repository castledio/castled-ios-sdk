//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

@objc class CastledStore: NSObject {
    static let castledStoreQueue = DispatchQueue(label: "CastledbHandler")

    static func getAllFailedRequests() -> [CastledNetworkRequest] {
        print("before calling getAllFailedRequests from CastledStore")
        let result = CastledRetryCoreDataOperations.shared.getAllFailedRequests()
        print("after calling getAllFailedRequests from CastledStore \(result.count)")
        return result
    }

    static func deleteCastledNetworkRequests(_ items: [CastledNetworkRequest]) {
        CastledRetryCoreDataOperations.shared.deleteCastledNetworkRequests(items)
    }

    static func enqueCastledNetworkRequest(_ request: CastledNetworkRequest) {
        CastledRetryCoreDataOperations.shared.enqueCastledNetworkRequest(request)
    }
}

extension CastledStore {
    // Function to write to a file (appending)
    static func writeToFile(data: Data, filename: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent(filename).path

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: filePath))
            fileHandle.write(data)
            fileHandle.closeFile()

        } catch {}
    }

    // Function to read from a file
    static func readFromFile(filename: String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent(filename).path

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                return data
            }
            return nil
        } catch {
            return nil
        }
    }

    static func removeFile(filename: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent(filename).path

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }

        } catch {}
    }
}
