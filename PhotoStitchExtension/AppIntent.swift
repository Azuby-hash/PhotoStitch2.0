//
//  AppIntent.swift
//  PhotoStitch
//
//  Created by TapUniverse Dev9 on 25/6/26.
//

import AppIntents

class StitchIntent {
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

struct StitchPhotosIntent: AppIntent {
    static var title: LocalizedStringResource { "Photos" }
    static var openAppWhenRun: Bool { true }
    
    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .foreground(.deferred) }

    func perform() async throws -> some IntentResult {
        try await StitchIntent.shared.register {
            NotificationCenter.default.post(name: StitchIntent.IMAGE_NOTI, object: nil)
        }
        
        return .result()
    }
}

struct StitchVideosIntent: AppIntent {
    static var title: LocalizedStringResource { "Video" }
    static var openAppWhenRun: Bool { true }
    
    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .foreground(.deferred) }

    func perform() async throws -> some IntentResult {
        try await StitchIntent.shared.register {
            NotificationCenter.default.post(name: StitchIntent.VIDEO_NOTI, object: nil)
        }
        
        return .result()
    }
}
