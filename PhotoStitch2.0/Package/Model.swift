//
//  Model.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 26/1/26.
//

import UIKit
import Photos

enum ModelError: Error {
    case error(String)
}

enum ModelTab: CaseIterable {
    case photos
    case video
    case website
}

typealias Axis = NSLayoutConstraint.Axis

class Model: ItemDelegate {
    static let shared = Model()
    
    let photoLibrary = AssetLibrary(albumType: .image)
    let videoLibrary = AssetLibrary(albumType: .video)
    
    private var items: [Item]?
    private var mode: ModelTab = .photos
    private var stitched: Bool = false
    private var axis: Axis = .vertical
    
    func request(completion: @escaping () -> Void) {
        photoLibrary.request { [self] _ in
            videoLibrary.request { _ in
                completion()
            }
        }
    }
    
    func getAutoStitch() -> Bool {
        return stitched
    }
    
    func getItems() -> [Item]? {
        return items
    }
    
    func getMode() -> ModelTab {
        return mode
    }
    
    func getAxis() -> Axis {
        return axis
    }
    
    func setAutoStitch(_ stitched: Bool) throws {
        if stitched {
            try autoStitch()
        }
        
        self.stitched = stitched
    }
    
    func selectItems(_ items: [Item]?) {
        self.items = items?.map({
            $0.delegate = self
            return $0.copy()
        })
    }
    
    func addItem(_ item: Item, to index: Int) {
        items = items?.filter({ $0 != item })
        items?.insert(item, at: index)
    }
    
    func removeItem(_ item: Item) {
        items = items?.filter({ $0 != item })
    }
    
    func setItems(_ items: [Item]) {
        self.items = items
    }
    
    func setMode(_ mode: ModelTab) {
        self.mode = mode
    }
    
    func setAxis(_ axis: Axis) {
        self.axis = axis
    }
}

protocol ItemDelegate: AnyObject {
    func setAutoStitch(_ stitched: Bool) throws
}

class Item: Equatable, Hashable {
    let id: String
    
    fileprivate weak var delegate: ItemDelegate?
    
    private let data: Data?
    private let size: CGSize
    private var process: ItemProcess
    
    init(id: String = UUID().uuidString, data: Data?, size: CGSize, process: ItemProcess) {
        self.id = id
        self.data = data
        self.size = size
        self.process = process
    }
    
    func copy() -> Item {
        return Item(data: data, size: size, process: process)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func getImage() throws -> UIImage {
        guard let data = data,
              let image = UIImage(data: data)
        else { throw ModelError.error("Can't get image") }
        
        return image
    }
    
    func getThumbnail() throws -> UIImage {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 100,
            kCGImageSourceShouldCacheImmediately: true
        ]
        
        guard let data = data,
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        else { throw ModelError.error("Can't get thumbnail") }
        
        return UIImage(cgImage: thumbnail)
    }
    
    func hasData() -> Bool {
        return data != nil
    }
    
    func getSize() -> CGSize {
        return size
    }
    
    func getProcess() -> ItemProcess {
        return process
    }
    
    func setProcess(_ process: ItemProcess) {
        self.process = process
        
        try? delegate?.setAutoStitch(false)
    }
    
    func setRect(_ rect: CGRect) {
        self.process = self.process.setRect(rect)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ItemProcess: Equatable {
    private(set) var rect: CGRect // 0011
    private(set) var average: [UInt8] = []
    private(set) var colorIndexes: [Int: [Int]] = [:]
    private(set) var didSetup: Bool = false
    
    init(rect: CGRect = RECT0011) {
        self.rect = rect
    }
    
    func setRect(_ rect: CGRect) -> ItemProcess {
        var process = self
        process.rect = rect
        
        return process
    }
    
    func setup(image: CIImage) -> ItemProcess {
        let row = image
            .cropped(to: image.extent.insetBy(dx: SCROLL_REMOVE, dy: 0))
            .applyingFilter("CIRowAverage", parameters: ["inputExtent": CIVector(cgRect: image.extent.insetBy(dx: SCROLL_REMOVE, dy: 0))])
        let width = (Int(row.extent.width) / 4 + 1) * 4
        
        var average = [UInt8].init(repeating: 0, count: width)
        var colorIndexes = [Int: [Int]]()
        
        CICONTEXT.render(row, toBitmap: &average, rowBytes: average.count, bounds: row.extent, format: .L8, colorSpace: nil)
        
        average.removeLast(width - Int(row.extent.width))
        
        for index in 0..<average.count {
            let color = Int(average[index])
            var indexes = colorIndexes[color] ?? []
            indexes.append(index)
            colorIndexes[color] = indexes
        }
        
        var process = self
        process.average = average
        process.colorIndexes = colorIndexes
        process.didSetup = true
        
        return process
    }
}
