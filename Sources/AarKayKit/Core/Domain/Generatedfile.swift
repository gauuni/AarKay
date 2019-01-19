//
//  Generatedfile.swift
//  AarKayKit
//
//  Created by RahulKatariya on 24/08/18.
//

import Foundation

public struct Generatedfile {
    public let name: String
    public let ext: String?
    public let directory: String?
    public let override: Bool
    public let skip: Bool
    public let contents: String

    public var nameWithExt: String {
        if let ext = self.ext {
            return name + "." + ext
        } else {
            return name
        }
    }

    init(
        name: String,
        ext: String?,
        directory: String?,
        override: Bool,
        skip: Bool,
        contents: String
    ) {
        self.name = name.failIfEmpty()
        self.ext = ext.nilIfEmpty()
        self.directory = directory.nilIfEmpty()
        self.override = override
        self.skip = skip
        self.contents = contents
    }

    public func merge(_ string: String) -> String {
        return string.rk.merge(templateString: contents)
    }
}
