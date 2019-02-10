//
//  CodableExtensions.swift
//  AarKayKit
//
//  Created by RahulKatariya on 10/02/19.
//

import Foundation
import SharedKit

public class JSONCoder {
    /// Decodes the dictionary to the `Decodable` type.
    ///
    /// - Parameter type: The type of `Decodable`.
    /// - Returns: The decoded model.
    /// - Throws: An `Error` if JSON Decoding encouters any error.
    public static func decode<T: Decodable>(type: T.Type, context: Any) throws -> T {
        let decodedData = try JSONSerialization.data(withJSONObject: context)
        return try JSONDecoder().decode(type, from: decodedData) as T
    }

    /// Encodes the model to an object.
    ///
    /// - Parameters: model: The model conforming to `Encodable`.
    /// - Returns: The encoded model.
    /// - Throws: An `Error` if JSON encoding encounters any error.
    public static func encode<T: Encodable>(_ model: T) throws -> Any {
        let encodedData = try JSONEncoder().encode(model)
        return try JSONSerialization.jsonObject(
            with: encodedData,
            options: .allowFragments
        )
    }

}
