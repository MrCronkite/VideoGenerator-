//
//  MultipartFormDataBuilder.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 21.06.2026.
//

import UIKit

struct MultipartFormDataBuilder {

    private var body = Data()
    private let boundary: String

    init(boundary: String = "Boundary-\(UUID().uuidString)") {
        self.boundary = boundary
    }

    var contentTypeHeader: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    mutating func addField(name: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    mutating func addFile(name: String, filename: String, mimeType: String, data: Data) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    func build() -> Data {
        var final = body
        final.append("--\(boundary)--\r\n")
        return final
    }
}

