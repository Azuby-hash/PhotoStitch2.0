//
//  Config.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/25/26.
//

import UIKit
import SwiftUI

let IOS26 = {
    if #available(iOS 26, *) {
        return true
    }
    
    return false
} ()

let RECT0011 = CGRect(x: 0, y: 0, width: 1, height: 1)
let ANIM_DURATION = CGFloat(0.25)
let MAX_ZOOM = CGFloat(100)
let PROCESS_SIZE = CGFloat(512)

var AUTO_SELECTION: Bool {
    get { UserDefaults.standard.object(forKey: "b3fb2293-a55d-4553-93dd-8f26129c44b2") as? Bool ?? true }
    set { UserDefaults.standard.set(newValue, forKey: "b3fb2293-a55d-4553-93dd-8f26129c44b2") }
}

var AUTO_STITCH: Bool {
    get { UserDefaults.standard.object(forKey: "c344d5a0-967a-4f6b-b331-0c6bc2929766") as? Bool ?? true }
    set { UserDefaults.standard.set(newValue, forKey: "c344d5a0-967a-4f6b-b331-0c6bc2929766") }
}

var REMOVE_ORIGINALS: RemoveOriginals {
    get { RemoveOriginals(rawValue: UserDefaults.standard.object(forKey: "b19bd7ef-8191-4b55-9b64-916db4b80a3e") as? Int ?? -1) ?? .ask }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: "b19bd7ef-8191-4b55-9b64-916db4b80a3e") }
}

var PHOTO_FILTER: PhotosFilter {
    get { PhotosFilter(rawValue: UserDefaults.standard.object(forKey: "d3451715-a5ff-4d37-ad71-bc0a8b17de73") as? Int ?? -1) ?? .both }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: "d3451715-a5ff-4d37-ad71-bc0a8b17de73") }
}

enum RemoveOriginals: Int, CaseIterable {
    case never
    case ask
    case always
    
    var title: String {
        switch(self) {
        case .never: return "Never"
        case .ask: return "Ask"
        case .always: return "Always"
        }
    }
    
    var color: Color {
        switch(self) {
        case .never: return ._primary
        case .ask: return .yellow
        case .always: return ._red
        }
    }
}

enum PhotosFilter: Int, CaseIterable {
    case photos
    case videos
    case both
    
    var title: String {
        switch(self) {
        case .photos: return "Photos"
        case .videos: return "Videos"
        case .both: return "Photos & Videos"
        }
    }
    
    var icon: String {
        switch(self) {
        case .photos: return "photo.on.rectangle.angled"
        case .videos: return "video.fill"
        case .both: return "photo.stack"
        }
    }
}
