//
//  JSONHelpers.swift
//  RemoveObject
//
//  Created by Azuby on 30/11/24.
//

import UIKit

class JSONHelpers {
    private init() { }
    
    static func getJSON<T: Decodable>(from bundlePath: String, type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: bundlePath, withExtension: nil),
              let text = try? String(contentsOf: url),
              let data = text.data(using: .utf8),
              let obj = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        
        return obj
    }

    static func getJSON<T: Decodable>(_ key: String, from bundlePath: String, type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: bundlePath, withExtension: nil),
              let text = try? String(contentsOf: url),
              let data = text.data(using: .utf8),
              let obj = try? JSONDecoder().decode([String: T].self, from: data)
        else { return nil }
        
        return obj[key]
    }
}
