//
//  URLExtensions.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 26/06/18.
//

import Foundation
import SharedKit

extension FileManager {
    public func subDirectories(at url: URL) throws -> [URL] {
        let results = try directoryEnumerator(at: url)
            .map { $0 as! URL }
            .filter { try isDirectory(url: $0) }
        return results
    }

    public func subDirectories(at urls: [URL]) throws -> [URL] {
        return try urls.reduce(initial: urls) { try subDirectories(at: $0) }
    }

    public func subFiles(at url: URL) throws -> [URL] {
        let results = try directoryEnumerator(at: url)
            .map { $0 as! URL }
            .filter { !(try isDirectory(url: $0)) }
        return results
    }

    public func subFiles(at urls: [URL]) throws -> [URL] {
        return try urls.reduce { try subFiles(at: $0) }
    }

    private func isDirectory(url: URL) throws -> Bool {
        #if os(Linux)
        var isDir: ObjCBool = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDir) {
            return isDir.boolValue
        } else {
            throw AarKayKitError.internalError(
                "File doesn't exist at \(url.absoluteString)"
            )
        }
        #else
        return try Try {
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            guard let isDir = resourceValues.isDirectory else {
                throw AarKayKitError.internalError(
                    "Failed to fetch isDirectory for \(url.absoluteString)"
                )
            }
            return isDir
        }.catch { error in
            AarKayKitError.internalError(
                "Failed to fetch resourceValues for \(url.absoluteString)",
                with: error
            )
        }
        #endif
    }
}

// MARK: - Private Helpers

extension FileManager {
    fileprivate func directoryEnumerator(at url: URL) throws -> DirectoryEnumerator {
        guard let enumerator = self.enumerator(
            at: url, includingPropertiesForKeys: [.isDirectoryKey]
        ) else {
            throw AarKayKitError.internalError(
                "Failed to create directory enumerator at \(url.absoluteString)"
            )
        }
        return enumerator
    }
}

extension Array {
    fileprivate func reduce(
        initial: [Element]? = nil,
        block: (Element) throws -> [Element]
    ) rethrows -> [Element] {
        return try reduce(
            initial ?? [Element]()
        ) { (initial: [Element], next: Element) -> [Element] in
            let items = try block(next)
            return initial + items
        }
    }
}
