//
//  URLRequestHelpers.swift
//  RemoveObject3.0
//
//  Created by TapUniverse Dev9 on 8/5/26.
//

import Foundation

enum URLSessionError: Error {
    case invalidURL
    case requestFailed(Int?, String?)
}

extension URLSession {
    static func request(_ string: String, headers: [String: String] = [:], method: URLMethod = .get, contentType: URLContentType = .none) async throws -> URLData {
        guard let url = URL(string: string) else {
            throw URLSessionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response): (Data, URLResponse)
        
        switch contentType {
        case .multipart(let body):
            let multipart = URLSession.multipart(from: body)
            request.setValue("multipart/form-data; boundary=\(multipart.boundary)", forHTTPHeaderField: "Content-Type")
            (data, response) = try await URLSession.shared.upload(for: request, from: multipart.data)
        case .none:
            (data, response) = try await URLSession.shared.data(for: request)
        }
        
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode)
        else { throw URLSessionError.requestFailed((response as? HTTPURLResponse)?.statusCode, String(data: data, encoding: .utf8)) }
        
        return URLData(data: data, statusCode: response.statusCode)
    }
}

extension URLSession {
    private static func multipart(from datas: [String: URLFormData]) -> URLMultiPartBody {
        var data = Data()
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // 1. Thêm các trường văn bản (Text fields)
        for (key, value) in datas {
            if let value = value as? String {
                data.append("--\(boundary)\r\n")
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                data.append("\(value)\r\n")
            } else if let value = value as? URLMedia {
                data.append("--\(boundary)\r\n")
                data.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(UUID().uuidString).\(value.mimetype.ext)\"\r\n")
                data.append("Content-Type: \(value.mimetype.rawValue)\r\n\r\n")
                data.append(value.data)
                data.append("\r\n")
            }
        }
        
        // 3. Kết thúc bằng dấu --boundary--
        data.append("--\(boundary)--\r\n")
        
        return URLMultiPartBody(data: data, boundary: boundary)
    }
}

// Helper để append String vào Data dễ dàng hơn
extension Data {
    fileprivate mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

protocol URLFormData { }

extension String: URLFormData { }
extension Data: URLFormData { }

struct URLMedia: URLFormData {
    let data: Data
    let mimetype: URLMimeType
}

enum URLMimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    
    var ext: String {
        switch self {
        case .jpeg: "jpg"
        case .png: "png"
        }
    }
}

struct URLMultiPartBody {
    let data: Data
    let boundary: String
}

enum URLContentType {
    case multipart([String: URLFormData])
    case none
}

enum URLMethod: String {
    case get = "GET"
    case post = "POST"
}

struct URLData {
    let data: Data
    let statusCode: Int
}
