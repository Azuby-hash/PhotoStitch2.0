//
//  CloudKit.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 7/3/26.
//

import CloudKit

actor CloudKitManager {
    static let shared = CloudKitManager()
    
    private let database = CKContainer(identifier: "iCloud.com.azubylabs.cloudkit").publicCloudDatabase
    
    func load(id: String, key: String) async throws -> Any {
        let recordID = CKRecord.ID(recordName: id)
        let result = try await database.record(for: recordID)
        return try await result[key].unwrap()
    }
}
