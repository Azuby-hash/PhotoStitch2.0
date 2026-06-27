//
//  Intent.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/27/26.
//

import AppIntents

class StitchIntent {
    static let SHARE_NOTI = Notification.Name(UUID().uuidString)
    static let IMAGE_NOTI = Notification.Name(UUID().uuidString)
    static let VIDEO_NOTI = Notification.Name(UUID().uuidString)
    
    static let shared = StitchIntent()
    
    private var intentAction: (() async throws -> Void)?
    private var didAppear = false
    
    func trigger() async throws {
        didAppear = true
        
        guard let intentAction = intentAction else { return }
        self.intentAction = nil
        
        Task {
            try? await intentAction()
        }
    }
    
    func register(_ intentAction: @escaping () async throws -> Void) async throws {
        if didAppear {
            try await intentAction()
            
            return
        }
        
        self.intentAction = intentAction
    }
}
