//
//  AarKayError.swift
//  AarKayKit
//
//  Created by RahulKatariya on 08/01/19.
//

import Foundation

enum AarKayError: Error {
    case missingFileName(String, String)
    case modelDecodingFailure(String)
    case templateNotFound(String)
    case multipleTemplatesFound(String)
    case invalidTemplate(String)
}

extension AarKayError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingFileName(let plugin, let template):
            return "Couldn't resolve filename in \(plugin).\(template)"
        case .modelDecodingFailure(let name):
            return "Couldn't decode \(name)"
        case .templateNotFound(let name):
            return "\(name) could not be found"
        case .multipleTemplatesFound(let name):
            return "More than one template with name - \(name) exists"
        case .invalidTemplate(let name):
            return "\(name) components count should not be more than 3"
        }
    }
}