//
//  Stitch.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 27/2/26.
//

import UIKit
import AVFoundation
import Accelerate
import Photos

enum StitchError: Error {
    case error(String)
}

struct StitchConfig {
    let indexDownscaleThreshold: Int
    let differentPercentThreshold: Int
    let lengthDifferentPercentThreshold: Int
    let colorDelta: Int
    let mode: StitchConfigMode
    let calConfidence: Bool
    
    init(indexDownscaleThreshold: Int, differentPercentThreshold: Int, lengthDifferentPercentThreshold: Int, colorDelta: Int, mode: StitchConfigMode, calConfidence: Bool) {
        self.indexDownscaleThreshold = indexDownscaleThreshold
        self.differentPercentThreshold = differentPercentThreshold
        self.lengthDifferentPercentThreshold = lengthDifferentPercentThreshold
        self.colorDelta = colorDelta
        self.mode = mode
        self.calConfidence = calConfidence
    }
}

enum StitchConfigMode {
    case image
    case video
}

class Stitch {
    /**
     let result = Stitch().stitch(before: beforeProcess, after: afterProcess, config: Stitch.getConfig(mode: .image))
     if result.maxKIndex > beforeProcess.average.count / 50 && result.confidence > STITCH_CONFIDENCE && result.samePercent < STITCH_SAME_PERCENT
     */
    func stitch(before: StitchProcess, after: StitchProcess, config: StitchConfig) -> StitchResult {
        var maxKIndex = 0
        var maxBefore = -1
        var maxAfter = -1
        var confidence = CGFloat(1)
        var samePercent = 0
        
        let beforeAverage = before.average
        let afterAverage = after.average
        let delta = config.colorDelta
        let isVideo = config.mode == .video
        
        func getIndexes(lookup: [Int: [Int]], color: Int) -> [Int] {
            var indexes = [Int]()
            
            for delta in -delta...delta {
                indexes = indexes + (lookup[color + delta] ?? [])
            }
            
            return indexes
        }
        
        if isVideo {
            var indexes = [Int: [(before: Int, after: Int)]]()
            
            for (color, afterIndexes) in after.colorIndexes {
                let beforeIndexes = getIndexes(lookup: before.colorIndexes, color: color)
                
                guard beforeIndexes.count < beforeAverage.count * (delta + 1) / config.indexDownscaleThreshold && beforeIndexes.count > 0 else {
                    continue
                }
                
                for afterIndex in afterIndexes {
                    for beforeIndex in beforeIndexes {
                        let distance = afterIndex - beforeIndex
                        indexes[distance, default: []].append((beforeIndex, afterIndex))
                    }
                }
            }
            
            var infoIndexes: [Int: (kIndex: Int, differents: Double)] = [:]
            
            indexesLoop: for (beforeIndex, afterIndex) in (indexes.values.max(by: { $0.count < $1.count }) ?? []) {
                var kIndex = 0
                var differents = 0.0
                var didCheck = false
                
                while beforeIndex + kIndex < beforeAverage.count - 1,
                      afterIndex + kIndex < afterAverage.count - 1,
                      abs(Int(beforeAverage[beforeIndex + kIndex]) - Int(afterAverage[afterIndex + kIndex])) <= delta {
                    if kIndex > 0 {
                        differents += abs(Int(beforeAverage[beforeIndex + kIndex]) - Int(beforeAverage[beforeIndex + kIndex - 1])) > 0 ? 1 : 0
                    }
                    
                    if let (checkedKIndex, checkedDifferents) = infoIndexes[beforeIndex + kIndex] {
                        kIndex += checkedKIndex
                        differents += checkedDifferents
                        didCheck = true
                    }
                    
                    if isVideo && kIndex > maxKIndex && kIndex > beforeAverage.count / 10 && differents / Double(kIndex) > Double(config.differentPercentThreshold) / 100 {
                        maxKIndex = kIndex
                        maxBefore = beforeIndex
                        maxAfter = afterIndex
                        
                        infoIndexes[beforeIndex] = (kIndex, differents)
                        
                        break indexesLoop
                    }
                    
                    if didCheck {
                        break
                    }
                    
                    kIndex += 1
                }
                
                if kIndex > maxKIndex && differents / Double(kIndex) > Double(config.differentPercentThreshold) / 100 {
                    maxKIndex = kIndex
                    maxBefore = beforeIndex
                    maxAfter = afterIndex
                }
                
                infoIndexes[beforeIndex] = (kIndex, differents)
            }
        } else {
            DispatchQueue.concurrentPerform(iterations: afterAverage.count) { afterIndex in
                let color = Int(afterAverage[afterIndex])
                let indexes = getIndexes(lookup: before.colorIndexes, color: color)
                
                guard indexes.count < beforeAverage.count * (delta + 1) / config.indexDownscaleThreshold else {
                    return
                }
                
                var lmaxKIndex = -1
                var lmaxBefore = 0
                var lmaxAfter = 0
                
                DispatchQueue.concurrentPerform(iterations: indexes.count) { index in
                    let beforeIndex = indexes[index]
                    
                    guard afterIndex > beforeIndex + max(1, delta) else {
                        return
                    }
                    
                    var kIndex = 0
                    var differents = 0.0
                    
                    while beforeIndex + kIndex < beforeAverage.count - 1,
                          afterIndex + kIndex < afterAverage.count - 1,
                          abs(Int(beforeAverage[beforeIndex + kIndex]) - Int(afterAverage[afterIndex + kIndex])) <= delta {
                        if kIndex > 0 {
                            differents += abs(Int(beforeAverage[beforeIndex + kIndex]) - Int(beforeAverage[beforeIndex + kIndex - 1])) > 0 ? 1 : 0
                        }
                        
                        kIndex += 1
                    }
                    
                    if kIndex > lmaxKIndex && differents / Double(kIndex) > Double(config.differentPercentThreshold) / 100 {
                        lmaxKIndex = kIndex
                        lmaxBefore = beforeIndex
                        lmaxAfter = afterIndex
                    }
                }
                
                if lmaxKIndex > maxKIndex {
                    maxKIndex = lmaxKIndex
                    maxBefore = lmaxBefore
                    maxAfter = lmaxAfter
                }
            }
        }
        
        if config.calConfidence && maxKIndex > 0 {
            var kLeft = 0
            var kRight = 0
            var kSame = 0
            for kIndex in 0..<maxKIndex {
                if abs(Int(before.leftAverage[maxBefore + kIndex]) - Int(after.leftAverage[maxAfter + kIndex])) <= delta {
                    kLeft += 1
                }
                
                if abs(Int(before.rightAverage[maxBefore + kIndex]) - Int(after.rightAverage[maxAfter + kIndex])) <= delta {
                    kRight += 1
                }
            }
            
            confidence = min(CGFloat(kLeft) / CGFloat(maxKIndex), CGFloat(kRight) / CGFloat(maxKIndex))
            
            let sampleCount = min(100, min(beforeAverage.count, afterAverage.count))
            let step = min(beforeAverage.count, afterAverage.count) / sampleCount
            
            for kIndex in 0..<sampleCount {
                if abs(Int(before.average[kIndex * step]) - Int(after.average[kIndex * step])) <= delta {
                    kSame += 1
                }
            }
            
            samePercent = kSame * 100 / sampleCount
            
            print(confidence, maxBefore, maxAfter, maxKIndex, samePercent)
        }
        
        return StitchResult(maxKIndex: maxKIndex, maxBefore: maxBefore, maxAfter: maxAfter, confidence: confidence, samePercent: samePercent)
    }
    
    func stitch(from av: AVAsset, of asset: PHAsset, progress: @escaping (CGFloat) -> Void) async throws -> StitchItem {
        let date = Date()
        
        // 1. Chuẩn bị Reader và Output
        guard let track = try await av.loadTracks(withMediaType: .video).first else {
            throw StitchError.error("No track video")
        }
        
        var transform = try await track.load(.preferredTransform)
        transform = CGAffineTransform.identity.rotated(by: -transform.decomposed().rotation)
        
        let reader = try AVAssetReader(asset: av)
        
        // Định dạng đầu ra là BGRA để dễ xử lý ảnh sau này
        let settings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(output)
        
        // 2. Bắt đầu đọc
        reader.startReading()
        
        let duration = try await av.load(.duration)
        let config = Stitch.getConfig(mode: .video)
        let interval: Double = 3 / 60 // Khoảng cách 0.05s
        var lastExtractedTime: Double = -interval // Để lấy được frame đầu tiên tại 0s
        
        var currProcess: StitchProcess?
        var stitchInfosList: [[StitchInfo]] = []
        var currStitchAverage = [UInt8]()
        
        while let sampleBuffer = output.copyNextSampleBuffer() {
            // Lấy thời gian thực của frame hiện tại
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let currentTime = CMTimeGetSeconds(presentationTime)
            let beginStitchAverage = currStitchAverage
            
            // 3. Kiểm tra xem đã đến lúc lấy frame chưa
            autoreleasepool {
                guard currentTime >= lastExtractedTime + interval,
                      let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                else { return }
                
                var afterCI = CIImage(cvImageBuffer: pixelBuffer)
                    
                afterCI = afterCI
                    .transformed(by: .init(translationX: -afterCI.extent.width / 2, y: -afterCI.extent.height / 2))
                    .transformed(by: transform)
                    .transformed(by: .init(translationX: afterCI.extent.width / 2, y: afterCI.extent.height / 2))
                let afterProcess = StitchProcess().setup(image: afterCI, config: config)
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                
                if let beforeProcess = currProcess, let currStitch = stitchInfosList.last?.last {
                    let result = stitch(before: beforeProcess, after: afterProcess, config: config)
                    let aPosition = result.maxAfter + result.maxKIndex / 2
                    
                    if result.maxKIndex > Int(afterCI.extent.height) / 100 {
                        let newCrop: CGRect
                        
                        if result.maxAfter > result.maxBefore {
                            newCrop = CGRect(x: 0, y: 0, width: afterCI.extent.width, height: CGFloat(aPosition))
                        } else {
                            newCrop = CGRect(x: 0, y: CGFloat(aPosition), width: afterCI.extent.width, height: afterCI.extent.height - CGFloat(aPosition))
                        }

                        let transalte = CGFloat(result.maxAfter - result.maxBefore)
                        let currRect = currStitch.getCurr().applying(.init(translationX: 0, y: transalte))
                        let newInfo: StitchInfo
                        
                        if newCrop.minY < currRect.minY || newCrop.maxY > currRect.maxY {
                            guard let afterData = CICONTEXT.jpegRepresentation(of: afterCI, colorSpace: colorSpace, options: [:]) else {
                                return
                            }
                            
                            newInfo = StitchInfo(data: afterData, crop: newCrop, rect: currRect, translate: transalte)
                            
                            let bonusHeight = Int(abs(newInfo.getCurr().height - currRect.height))
                            
                            if result.maxAfter > result.maxBefore {
                                if afterProcess.average.count - aPosition < 0 {
                                    return
                                }
                                
                                currStitchAverage = afterProcess.average.dropLast(afterProcess.average.count - aPosition) + currStitchAverage.dropFirst(aPosition - bonusHeight)
                            } else {
                                if afterProcess.average.count - aPosition - bonusHeight < 0 {
                                    return
                                }
                                
                                currStitchAverage = currStitchAverage.dropLast(afterProcess.average.count - aPosition - bonusHeight) + afterProcess.average.dropFirst(aPosition)
                            }
                        } else {
                            newInfo = StitchInfo(data: nil, crop: nil, rect: currRect, translate: transalte)
                        }
                        
                        if Int(newInfo.getCurr().maxY) - afterProcess.average.count < 0 {
                            currStitchAverage = beginStitchAverage
                            return
                        }
                        
                        stitchInfosList[stitchInfosList.count - 1].append(newInfo)

                        let cropStitchAverage: [UInt8] = currStitchAverage.dropFirst(Int(abs(newInfo.getCurr().minY))).dropLast(Int(newInfo.getCurr().maxY) - afterProcess.average.count)
                        currProcess = StitchProcess(average: cropStitchAverage, colorIndexes: [:]).applyColorIndexes(config: config)
                    } else if result.maxKIndex < Int(afterCI.extent.height) / 500 {
                        guard let afterData = CICONTEXT.jpegRepresentation(of: afterCI, colorSpace: colorSpace, options: [:]) else {
                            return
                        }
                        
                        stitchInfosList.append([StitchInfo(data: afterData, crop: afterCI.extent, rect: afterCI.extent, translate: .zero)])
                        currStitchAverage = afterProcess.average
                        currProcess = afterProcess
                    }
                } else {
                    guard let afterData = CICONTEXT.jpegRepresentation(of: afterCI, colorSpace: colorSpace, options: [:]) else {
                        return
                    }
                    
                    stitchInfosList.append([StitchInfo(data: afterData, crop: afterCI.extent, rect: afterCI.extent, translate: .zero)])
                    currStitchAverage = afterProcess.average
                    currProcess = afterProcess
                }
                
                lastExtractedTime = currentTime
            }
            
            await Task.yield()
            await MainActor.run {
                progress(sampleBuffer.outputPresentationTimeStamp.seconds / (duration.seconds * 1.2))
            }
            
            if reader.status == .completed || reader.status == .failed {
                break
            }
        }
        
        defer {
            print(stitchInfosList.count, date.timeIntervalSinceNow)
        }
        
        if let stitchInfos = stitchInfosList.max(by: { $0[$0.count - 1].getCurr().height < $1[$1.count - 1].getCurr().height }) {
            var fullStitchCI: CIImage?
            
            for (index, stitchInfo) in stitchInfos.enumerated() {
                if let stitchCI = fullStitchCI {
                    if let data = stitchInfo.data, let crop = stitchInfo.crop, let ciImage = CIImage(data: data) {
                        fullStitchCI = ciImage.cropped(to: crop).composited(over: stitchCI.transformed(by: .init(translationX: 0, y: stitchInfo.translate)))
                    } else {
                        fullStitchCI = stitchCI.transformed(by: .init(translationX: 0, y: stitchInfo.translate))
                    }
                } else if let data = stitchInfo.data {
                    fullStitchCI = CIImage(data: data)
                }
                
                await MainActor.run {
                    progress((duration.seconds + duration.seconds * 0.2 * CGFloat(index) / CGFloat(stitchInfos.count)) / (duration.seconds * 1.2))
                }
            }
            
            if let fullStitchCI = fullStitchCI, let stitchCG = CICONTEXT.createCGImage(fullStitchCI, from: fullStitchCI.extent), let currProcess = currProcess {
                return try StitchItem(image: UIImage(cgImage: stitchCG), asset: asset, process: currProcess)
            }
        }
        
        throw StitchError.error("No stitch found")
    }
    
    func getPtr<V: Equatable>(from array: inout [V]) -> UnsafeMutablePointer<V>? {
        return array.withUnsafeMutableBufferPointer { ptr in
            return ptr.baseAddress
        }
    }
    
    private func getPtr<V: Equatable>(from array: [V]) -> UnsafePointer<V>? {
        return array.withUnsafeBufferPointer { ptr in
            return ptr.baseAddress
        }
    }
    
    static func getConfig(mode: StitchConfigMode) -> StitchConfig {
        if mode == .image {
            return StitchConfig(indexDownscaleThreshold: 50, differentPercentThreshold: 10, lengthDifferentPercentThreshold: 50, colorDelta: 1, mode: mode, calConfidence: true)
        } else {
            return StitchConfig(indexDownscaleThreshold: 50, differentPercentThreshold: 10, lengthDifferentPercentThreshold: 50, colorDelta: 1, mode: mode, calConfidence: false)
        }
    }
}

class StitchInfo {
    let data: Data?
    let crop: CGRect?
    let rect: CGRect
    let translate: CGFloat
    
    init(data: Data?, crop: CGRect?, rect: CGRect, translate: CGFloat) {
        self.data = data
        self.crop = crop
        self.rect = rect
        self.translate = translate
    }
    
    func getCurr() -> CGRect {
        return rect.merge(with: crop ?? rect)
    }
}

struct StitchResult {
    let maxKIndex: Int
    let maxBefore: Int
    let maxAfter: Int
    let confidence: CGFloat
    let samePercent: Int
    
    init(maxKIndex: Int, maxBefore: Int, maxAfter: Int, confidence: CGFloat, samePercent: Int) {
        self.maxKIndex = maxKIndex
        self.maxBefore = maxBefore
        self.maxAfter = maxAfter
        self.confidence = confidence
        self.samePercent = samePercent
    }
}

struct StitchProcess: Equatable {
    private(set) var rect: CGRect // 0011
    private(set) var average: [UInt8] = []
    private(set) var leftAverage: [UInt8] = []
    private(set) var rightAverage: [UInt8] = []
    private(set) var colorIndexes: [Int: [Int]] = [:]
    
    init(rect: CGRect = RECT0011) {
        self.rect = rect
    }
    
    fileprivate init(average: [UInt8], colorIndexes: [Int: [Int]]) {
        self.rect = RECT0011
        self.average = average
        self.colorIndexes = colorIndexes
    }
    
    mutating func setRect(_ rect: CGRect) {
        self.rect = rect
    }
    
    func setup(image: CIImage, config: StitchConfig) -> StitchProcess {
        let rect = image.extent.insetBy(dx: SCROLL_REMOVE, dy: 0)
        let row = image
            .cropped(to: rect)
            .applyingFilter("CIRowAverage", parameters: ["inputExtent": CIVector(cgRect: image.extent.insetBy(dx: SCROLL_REMOVE, dy: 0))])
        let width = (Int(row.extent.width) / 4 + 1) * 4
        
        var process = self
        
        var average = [UInt8].init(repeating: 0, count: width)
        CICONTEXT.render(row, toBitmap: &average, rowBytes: average.count, bounds: row.extent, format: .L8, colorSpace: nil)
        average.removeLast(width - Int(row.extent.width))
        process.average = average

        if config.calConfidence {
            let leftRow = image
                .cropped(to: CGRect(origin: rect.origin, size: rect.size * CGSize(width: 0.5, height: 1)))
                .applyingFilter("CIRowAverage", parameters: ["inputExtent": CIVector(cgRect: image.extent.insetBy(dx: SCROLL_REMOVE, dy: 0))])
            
            var leftAverage = [UInt8].init(repeating: 0, count: width)
            CICONTEXT.render(leftRow, toBitmap: &leftAverage, rowBytes: leftAverage.count, bounds: leftRow.extent, format: .L8, colorSpace: nil)
            leftAverage.removeLast(width - Int(leftRow.extent.width))
            process.leftAverage = leftAverage
            
            let rightRow = image
                .cropped(to: CGRect(origin: rect.origin + rect.size * CGSize(width: 0.5, height: 0), size: rect.size * CGSize(width: 0.5, height: 1)))
                .applyingFilter("CIRowAverage", parameters: ["inputExtent": CIVector(cgRect: image.extent.insetBy(dx: SCROLL_REMOVE, dy: 0))])
            
            var rightAverage = [UInt8].init(repeating: 0, count: width)
            CICONTEXT.render(rightRow, toBitmap: &rightAverage, rowBytes: rightAverage.count, bounds: rightRow.extent, format: .L8, colorSpace: nil)
            rightAverage.removeLast(width - Int(rightRow.extent.width))
            process.rightAverage = rightAverage
        }
        
        process = process.applyColorIndexes(config: config)
        
        return process
    }
    
    func applyColorIndexes(config: StitchConfig) -> StitchProcess {
        var colorIndexes = [Int: [Int]]()
        
        for index in 0..<average.count {
            colorIndexes[Int(average[index]), default: []].append(index)
        }
        
        for (color, indexes) in colorIndexes {
            if indexes.count < average.count * (config.colorDelta + 1) / config.indexDownscaleThreshold && indexes.count > 0 {
                continue
            }
            
            colorIndexes.removeValue(forKey: color)
        }
        
        var process = self
        process.colorIndexes = colorIndexes
        
        return process
    }
}

@Observable class StitchItem: Identifiable {
    var id = UUID().uuidString
    let size: CGSize
    let asset: PHAsset
    var image: Data
    var clean: Data
    var process = StitchProcess()
    
    init(image: UIImage, asset: PHAsset) throws {
        guard let ciImage = CIImage(image: image) else {
            throw MainError.error("Cant convert to ciimage")
        }
        
        self.asset = asset
        self.size = image.size
        self.image = try image.jpegData()
        self.clean = try image.processClean()
        self.process = process.setup(image: ciImage, config: Stitch.getConfig(mode: .image))
    }
    
    init(id: String = UUID().uuidString, asset: PHAsset, size: CGSize, image: Data, clean: Data, process: StitchProcess) {
        self.id = id
        self.asset = asset
        self.size = size
        self.image = image
        self.clean = clean
        self.process = process
    }
    
    fileprivate init(image: UIImage, asset: PHAsset, process: StitchProcess) throws {
        self.size = image.size
        self.asset = asset
        self.image = try image.jpegData()
        self.clean = try image.processClean()
        self.process = process
    }
    
    func copy(id: String = UUID().uuidString) -> StitchItem {
        return StitchItem(id: id, asset: asset, size: size, image: image, clean: clean, process: process)
    }
}
