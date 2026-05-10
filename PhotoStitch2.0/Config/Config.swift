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

let LOW_REMOVE: CGFloat = 141
let HIGH_REMOVE: CGFloat = 156
let SCROLL_REMOVE: CGFloat = 27

let STITCH_CONFIDENCE: CGFloat = 0.9
let STITCH_SAME_PERCENT: Int = 90

let CICONTEXT = CIContext()

var SHOW_ONBOARDING: Bool {
    get { UserDefaults.standard.object(forKey: "4aac33cf6c6a8064") as? Bool ?? true }
    set { UserDefaults.standard.set(newValue, forKey: "4aac33cf6c6a8064") }
}

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
    get { PhotosFilter(rawValue: UserDefaults.standard.object(forKey: "d3451715-a5ff-4d37-ad71-bc0a8b17de73") as? Int ?? -1) ?? .all }
    set { UserDefaults.standard.set(newValue.rawValue, forKey: "d3451715-a5ff-4d37-ad71-bc0a8b17de73") }
}

var ALBUM_SELECT: String? {
    get { UserDefaults.standard.object(forKey: "1e5684e492d5598b") as? String }
    set { UserDefaults.standard.set(newValue, forKey: "1e5684e492d5598b") }
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
    case images
    case videos
    case all
    
    var title: String {
        switch(self) {
        case .images: return "Images"
        case .videos: return "Videos"
        case .all: return "All Photos"
        }
    }
    
    var icon: String {
        switch(self) {
        case .images: return "photo.on.rectangle.angled"
        case .videos: return "video.fill"
        case .all: return "photo.stack"
        }
    }
}

enum MainError: Error {
    case error(String)
}

extension UIImage {
    func jpegData() throws -> Data {
        return try jpegData(compressionQuality: 0.8).unwrap()
    }
    
    func processClean() throws -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let mask = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(x: size.width - SCROLL_REMOVE, y: 0, width: SCROLL_REMOVE, height: size.height))
        }
        
        let output = OpenCVWrapper.inpaint(image: self, mask: mask, radius: 0.0)
        
        return try output.jpegData()
    }
}
