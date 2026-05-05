//
//  FileManagerExtension.swift
//  BlurVideo
//
//  Created by TapUniverse Dev9 on 25/07/2023.
//

import UIKit

fileprivate let folderID = "ffc4f1f8-ab79-4d48-b232-9c6f0279471b"

fileprivate var localFolder: URL = {
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
        .appendingPathComponent(folderID)
    else { return URL(fileURLWithPath: ".") }
    
    if !FileManager.default.fileExists(atPath: path.path) {
        try? FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
    }

    return path
}()

fileprivate var icloudFolder: URL = {
    guard let path = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
        .appendingPathComponent(folderID)
    else { return URL(fileURLWithPath: ".") }
    
    if !FileManager.default.fileExists(atPath: path.path) {
        try? FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
    }

    return path
}()


extension FileManager {
    static func eraseDocumentAndData() {
        if let items = try? FileManager.default.contentsOfDirectory(atPath: localFolder.path) {
            // Remove each item
            for item in items {
                let itemPath = localFolder.appendingPathComponent(item).path
                try? FileManager.default.removeItem(atPath: itemPath)
            }
        }
        
        if let items = try? FileManager.default.contentsOfDirectory(atPath: icloudFolder.path) {
            // Remove each item
            for item in items {
                let itemPath = icloudFolder.appendingPathComponent(item).path
                try? FileManager.default.removeItem(atPath: itemPath)
            }
        }
    }
    
    static func remove(forKey key: String) {
        if FileManager.default.fileExists(atPath: localFolder.appendingPathComponent(key).path) {
            try? FileManager.default.removeItem(atPath: localFolder.appendingPathComponent(key).path)
        }
    }
    
    static func object(forKey key: String) -> Any? {
        guard let data = try? Data(contentsOf: localFolder.appendingPathComponent(key)) else { return nil }

        let decode = JSONDecoder()
        
        for t in [CGFloat.zero, Double.zero, String(""), [String("")]] as [Decodable] {
            let t = type(of: t)
            
            if let value = try? decode.decode(t.self, from: data) {
                return value
            }
        }
        
        return data
    }
    
    static func set(_ value: Any?, forKey key: String) {
        let filePath = localFolder.appendingPathComponent(key)

        if FileManager.default.fileExists(atPath: filePath.path) {
            try? FileManager.default.removeItem(at: filePath)
        }

        func encodeAndWrite<T: Encodable>(_ value: T) {
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(value) {
                try? encodedData.write(to: filePath)
            }
        }

        switch value {
        case let data as Data:
            try? data.write(to: filePath)
        case let encodableValue as Encodable:
            encodeAndWrite(encodableValue)
        default:
            break
        }
    }
    
    static func exist(at key: String) -> Bool {
        let filePath = localFolder.appendingPathComponent(key)
        
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    static func copy(from url: URL, forKey key: String) {
        let filePath = localFolder.appendingPathComponent(key)

        do {
            try FileManager.default.copyItem(at: url, to: filePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func move(from url: URL, forKey key: String) {
        let filePath = localFolder.appendingPathComponent(key)
        
        do {
            try FileManager.default.moveItem(at: url, to: filePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func copy(fromKey sourceKey: String, forKey destiKey: String) {
        let sourceFilePath = localFolder.appendingPathComponent(sourceKey)
        let destiFilePath = localFolder.appendingPathComponent(destiKey)
        
        do {
            try FileManager.default.copyItem(at: sourceFilePath, to: destiFilePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func move(fromKey sourceKey: String, forKey destiKey: String) {
        let sourceFilePath = localFolder.appendingPathComponent(sourceKey)
        let destiFilePath = localFolder.appendingPathComponent(destiKey)
        
        do {
            try FileManager.default.moveItem(at: sourceFilePath, to: destiFilePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func url(name: String?) -> URL {
        guard let name = name else {
            return localFolder
        }
        
        return localFolder.appendingPathComponent(name)
    }
}

extension FileManager {
    static func removeIcloud(forKey key: String) {
        if FileManager.default.fileExists(atPath: icloudFolder.appendingPathComponent(key).path) {
            try? FileManager.default.removeItem(atPath: icloudFolder.appendingPathComponent(key).path)
        }
    }
    
    static func objectIcloud(forKey key: String) -> Any? {
        guard let data = try? Data(contentsOf: icloudFolder.appendingPathComponent(key)) else { return nil }

        let decode = JSONDecoder()
        
        for t in [CGFloat.zero, Double.zero, String(""), [String("")]] as [Decodable] {
            let t = type(of: t)
            
            if let value = try? decode.decode(t.self, from: data) {
                return value
            }
        }
        
        return data
    }
    
    static func setIcloud(_ value: Any?, forKey key: String) {
        let filePath = icloudFolder.appendingPathComponent(key)

        func encodeAndWrite<T: Encodable>(_ value: T) {
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(value) {
                try? encodedData.write(to: filePath)
            }
        }

        switch value {
        case let data as Data:
            try? data.write(to: filePath)
        case let encodableValue as Encodable:
            encodeAndWrite(encodableValue)
        default:
            break
        }
    }
    
    static func existIcloud(at key: String) -> Bool {
        let filePath = icloudFolder.appendingPathComponent(key)
        
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    static func copyIcloud(from url: URL, forKey key: String) {
        let filePath = icloudFolder.appendingPathComponent(key)
        
        do {
            try FileManager.default.copyItem(at: url, to: filePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func moveIcloud(from url: URL, forKey key: String) {
        let filePath = icloudFolder.appendingPathComponent(key)
        
        do {
            try FileManager.default.moveItem(at: url, to: filePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func copyIcloud(fromKey sourceKey: String, forKey destiKey: String) {
        let sourceFilePath = icloudFolder.appendingPathComponent(sourceKey)
        let destiFilePath = icloudFolder.appendingPathComponent(destiKey)
        
        do {
            try FileManager.default.copyItem(at: sourceFilePath, to: destiFilePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func moveIcloud(fromKey sourceKey: String, forKey destiKey: String) {
        let sourceFilePath = icloudFolder.appendingPathComponent(sourceKey)
        let destiFilePath = icloudFolder.appendingPathComponent(destiKey)
        
        do {
            try FileManager.default.moveItem(at: sourceFilePath, to: destiFilePath)
        } catch {
            print("From my \(error)")
        }
    }
    
    static func urlIcloud(name: String?) -> URL {
        guard let name = name else {
            return icloudFolder
        }
        
        return icloudFolder.appendingPathComponent(name)
    }
}
