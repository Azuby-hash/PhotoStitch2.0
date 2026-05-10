//
//  OptionalHelper.swift
//  RemoveObject3.0
//
//  Created by TapUniverse Dev9 on 8/5/26.
//

import SwiftUI

enum OptionalError: Error {
    case error(String)
}

extension Optional {
    func unwrap() throws -> Wrapped {
        guard let self else {
            throw OptionalError.error("Cant unwrap")
        }
        
        return self
    }
}

prefix operator ~

prefix func ~ <T>(value: Any) throws -> T {
    guard let value = value as? T else {
        throw OptionalError.error("Cant cast")
    }
    
    return value
}
