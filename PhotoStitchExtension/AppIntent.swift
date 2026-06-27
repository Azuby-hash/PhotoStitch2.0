//
//  AppIntent.swift
//  PhotoStitch
//
//  Created by TapUniverse Dev9 on 25/6/26.
//

import AppIntents

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
