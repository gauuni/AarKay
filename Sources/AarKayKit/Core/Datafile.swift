//
//  Datafile.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 31/12/17.
//

import Foundation
import SharedKit

/// A Type that encapsulates the template.
///
/// - name: Returned when using a file as template.
/// - nameStringExt: Returned when using a string as a template
public enum Template {
    case name(String)
    case nameStringExt(String, String, String)

    /// Returns the name of the Template
    public func name() -> String {
        switch self {
        case .name(let name): return name
        case .nameStringExt(let name, _, _): return name
        }
    }
}

/// Represents a Datafile.
public struct Datafile {
    /// The name of the file.
    public private(set) var fileName: String

    /// The directory of the file.
    public private(set) var directory: String

    /// The context to apply to the template.
    public private(set) var context: [String: Any]

    /// Whether to override the existing file with new contents.
    public private(set) var override: Bool

    /// Whether to skip creation of Generatedfile.
    public private(set) var skip: Bool

    /// The template to use for the Datafile.
    public private(set) var template: Template
    
    /// The global context.
    public private(set) var globalContext: [String: Any]

    /// Initializes a Datafile.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - directory: The directory of the file.
    ///   - context: The context to apply to the template.
    ///   - override: Whether to override the existing file with new contents.
    ///   - skip: Whether to skip creation of Generatedfile.
    ///   - template: The template to use for the Datafile.
    public init(
        fileName: String,
        directory: String,
        context: [String: Any],
        override: Bool,
        skip: Bool,
        template: Template,
        globalContext: [String: Any]?
    ) {
        self.fileName = fileName.failIfEmpty()
        self.directory = directory
        self.context = context
        self.override = override
        self.skip = skip
        self.template = template
        self.globalContext = globalContext ?? [:]
    }

    /// Decodes and Encodes the model and sets the context.
    ///
    /// - Parameter type: The type of `Codable`.
    /// - Returns: The decoded model.
    /// - Throws: An `Error` if JSON Decoding or Encoding encouters any error.
    public mutating func dencode<T: Codable>(type: T.Type) throws -> T {
        let model = try decode(type: type)
        try setContext(model)
        return model
    }

    /// Decodes the dictionary to the `Decodable` type.
    ///
    /// - Parameter type: The type of `Decodable`.
    /// - Returns: The decoded model.
    /// - Throws: An `Error` if JSON Decoding encouters any error.
    public func decode<T: Decodable>(type: T.Type) throws -> T {
        let model: T = try Try {
            let decodedData = try JSONSerialization.data(withJSONObject: self.context)
            return try JSONDecoder().decode(type, from: decodedData) as T
        }.catch { error in
            AarKayKitError.invalidContents(
                AarKayKitError.InvalidContentsReason
                    .invalidModel(
                        fileName: fileName,
                        template: template.name(),
                        type: String(describing: T.self),
                        context: context
                    )
            )
        }
        return model
    }

    /// Sets the name of the file.
    ///
    /// - Parameter fileName: The file name.
    public mutating func setFileName(_ fileName: String) {
        self.fileName = fileName.failIfEmpty()
    }

    /// Sets the directory path.
    ///
    /// - Parameter directory: The path of directory.
    public mutating func setDirectory(_ directory: String) {
        self.directory = directory
    }

    /// Appends the directory path.
    ///
    /// - Parameter directory: The path of directory.
    public mutating func appendDirectory(_ directory: String?) {
        if let directory = directory.nilIfEmpty() {
            var dir = self.directory
            if !dir.trimmingCharacters(in: .whitespaces).isEmpty { dir = dir + "/" }
            self.directory = dir + directory
        }
    }

    /// Sets the context.
    ///
    /// - Parameter context: The context.
    public mutating func setContext(_ context: [String: Any]) {
        self.context = context
    }

    /// Adds values to the exiting context.
    ///
    /// - Parameter context: The context.
    public mutating func addContext(_ context: [String: Any]) {
        setContext(self.context + context)
    }

    /// Encodes the model to an object, appends it with another object and sets the context.
    ///
    /// - Parameters:
    ///   - model: The model conforming to `Encodable`.
    ///   - context: The additional context to append.
    /// - Throws: An `Error` if JSON encoding encounters any error.
    public mutating func setContext<T: Encodable>(
        _ model: T,
        with context: [String: Any]? = nil
    ) throws {
        let object = try encode(model)
        if let context = context {
            setContext(object + context)
        } else {
            setContext(object)
        }
    }

    /// Encodes the model to an object, appends it with another object and sets the context.
    ///
    /// - Parameters:
    ///   - model: The model conforming to `Encodable`.
    ///   - context: The additional context to append.
    /// - Throws: An `Error` if JSON encoding encounters any error.
    public mutating func setContext<T: Encodable>(
        _ context: [String: Any],
        with model: T? = nil
    ) throws {
        if let model = model {
            let object = try encode(model)
            setContext(context + object)
        } else {
            setContext(context)
        }
    }

    /// Encodes the model to an object.
    ///
    /// - Parameters: model: The model conforming to `Encodable`.
    /// - Returns: The encoded model.
    /// - Throws: An `Error` if JSON encoding encounters any error.
    public mutating func encode<T: Encodable>(_ model: T) throws -> [String: Any] {
        let object: Any? = try Try {
            let encodedData = try JSONEncoder().encode(model)
            return try JSONSerialization.jsonObject(
                with: encodedData,
                options: .allowFragments
            )
        }.catch { error in
            AarKayKitError.invalidContents(
                AarKayKitError.InvalidContentsReason
                    .invalidModel(
                        fileName: self.fileName,
                        template: self.template.name(),
                        type: String(describing: T.self),
                        context: self.context
                    )
            )
        }
        guard let obj = object as? [String: Any] else {
            throw AarKayKitError.internalError(
                "Failed to decode object from encoded data"
            )
        }
        return obj
    }

    /// Sets whether to override the exisitng file.
    ///
    /// - Parameter override: The override value.
    public mutating func setOverride(_ override: Bool) {
        self.override = override
    }

    /// Sets whether to skip creation of Generatedfile.
    ///
    /// - Parameter skip: The skip value.
    public mutating func setSkip(_ skip: Bool) {
        self.skip = skip
    }

    /// Sets the template.
    ///
    /// - Parameter template: The template.
    public mutating func setTemplate(_ template: Template) {
        self.template = template
    }
}
