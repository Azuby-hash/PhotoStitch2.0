//
//  ShareViewController.swift
//  PhotoStitchShare
//
//  Created by Azuby on 6/27/26.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import AppIntents

fileprivate(set) var VIEW_CONTROLLER = UIViewController()

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VIEW_CONTROLLER = self
        
        isModalInPresentation = true
    }
}

class ShareHosting: UIHostingController<Home> {
    required init?(coder aDecoder: NSCoder) {
        super.init(rootView: Home())
    }
}

struct Home: View {
    @State private var homeUpdater = HomeUpdater()
    
    @State var items: [StitchItem] = []
    
    var body: some View {
        ZStack {
            ZStack {
                if !items.isEmpty {
                    Edit(editUpdater: EditUpdater(items: items, axis: .vertical, shareVer: true))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color._background.ignoresSafeArea())
        }
        .background(Color._background)
        .environment(homeUpdater)
        .onAppear {
            Task {
                do {
                    while !(VIEW_CONTROLLER is ShareViewController) {
                        try await Task.sleep(for: .seconds(0.1))
                    }
                    
                    try await process()
                } catch {
                    print(error)
                    
                    VIEW_CONTROLLER.extensionContext?.completeRequest(returningItems: [])
                }
            }
        }
    }
    
    private func process() async throws {
        let extensionContext = try VIEW_CONTROLLER.extensionContext.unwrap()
        let extensionItems = try (extensionContext.inputItems as? [NSExtensionItem]).unwrap()

        let imageType = UTType.image.identifier

        let providers = extensionItems
            .compactMap(\.attachments)
            .flatMap { $0 }
            .filter { $0.hasItemConformingToTypeIdentifier(imageType) }
        
        let maxCount = 8

        if providers.count > maxCount {
            throw MainError.error("You can share up to \(maxCount) images at once.")
        }

        let images = await withTaskGroup(of: (Data?, CGSize?, Int).self) { group in
            for (index, provider) in providers.enumerated() {
                group.addTask {
                    await withCheckedContinuation { continuation in
                        provider.loadDataRepresentation(forTypeIdentifier: imageType) { data, _ in
                            let size = data.flatMap(imageSize(from:))
                            continuation.resume(returning: (data, size, index))
                        }
                    }
                }
            }

            var results: [(Int, Data, CGSize)] = []
            for await result in group {
                if let data = result.0, let size = result.1 {
                    results.append((result.2, data, size))
                }
            }

            return results.sorted(by: { $0.0 < $1.0 }).map { ($0.1, $0.2) }
        }
        
        VIEW_CONTROLLER.startLoading("Loading 0 / \(images.count) Items...")
        
        var items = [StitchItem]()
        
        for image in images {
            autoreleasepool {
                items.append(StitchItem(asset: nil, size: image.1, image: image.0, clean: image.0, process: StitchProcess()))
            }
            
            VIEW_CONTROLLER.startLoading("Loading \(items.count) / \(images.count) Items...")
        }
        
        guard !items.isEmpty else {
            throw MainError.error("No Items")
        }
        
        await withCheckedContinuation { continuation in VIEW_CONTROLLER.stopLoading { continuation.resume() } }
        
        self.items = items
    }
    
    private func imageSize(from data: Data) -> CGSize? {
        guard let thumb = UIImage.thumbnail(from: data, fillSquareOf: THUMB_SIZE) else {
            return nil
        }
        
        return thumb.size
    }
}

@Observable class HomeUpdater: NSObject {
    var showEdit = true {
        didSet {
            if !showEdit {
                VIEW_CONTROLLER.extensionContext?.completeRequest(returningItems: [])
            }
        }
    }
    
    var removeOriginals = RemoveOriginals.never
}

class OpenCVWrapper {
    static func inpaint(image: UIImage, mask: UIImage, radius: Float) -> UIImage {
        return image
    }
}
