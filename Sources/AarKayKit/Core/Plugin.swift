//
//  Plugin.swift
//  AarKayKit
//
//  Created by Rahul Katariya on 04/12/17.
//

import Foundation
import Result

/// Represents a Plugin.
public struct Plugin {
    /// The name of the plugin.
    let name: String

    /// The global context shared with all Generatedfiles.
    let globalContext: [String: Any]?

    /// The location of global templates.
    let globalTemplates: [URL]?

    /// The FileManager
    let fileManager: FileManager

    /// The AarKayService
    let aarkayService: AarKayService

    /// The TemplateService
    let templateService: TemplateService

    /// Initializes a Plugin object.
    ///
    /// - Parameters:
    ///   - name: The name of the plugin.
    ///   - globalContext: The global context shared with all Generatedfiles.
    ///   - globalTemplates: The location of global templates.
    ///   - fileManager: The FileManager
    /// - Throws: An `Error` if the templates service encouters any error.
    public init(
        name: String,
        globalContext: [String: Any]?,
        globalTemplates: [URL]?,
        fileManager: FileManager = FileManager.default
    ) throws {
        self.name = name
        self.globalContext = globalContext
        self.globalTemplates = globalTemplates
        self.fileManager = fileManager
        self.aarkayService = AarKayProvider(
            datafileService: DatafileProvider(),
            generatedfileService: GeneratedfileProvider()
        )
        self.templateService = try aarkayService.templateProvider(
            plugin: name,
            globalTemplates: globalTemplates,
            fileManager: fileManager
        )
    }
}

extension Plugin {
    /// Creates GeneratedFile results from one Datafile on a disk.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file.
    ///   - directory: The directory.
    ///   - template: The template to use.
    ///   - contents: The contents of the file.
    /// - Returns: The `Generatedfile` results.
    /// - Throws: An `Error` if the program encouters any error.
    public func generate(
        fileName: String,
        directory: String,
        template: String,
        contents: String
    ) throws -> [Result<Generatedfile, AnyError>] {
        if let templateClass = aarkayService.datafileService.templateClass(
            plugin: name,
            template: template
        ) {
            let datafiles = try aarkayService.datafileService.serialize(
                plugin: name,
                name: fileName,
                directory: directory,
                template: template,
                contents: contents,
                using: templateClass.inputSerializer(),
                globalContext: globalContext
            )

            let templateDatafiles = datafiles
                .map { result -> [Result<Datafile, AnyError>] in
                    switch result {
                    case .success(let value):
                        let res = Result {
                            return try aarkayService.datafileService
                                .templateDatafiles(
                                    datafile: value,
                                    templateClass: templateClass
                                )
                        }
                        switch res {
                        case .success(let files):
                            return files.map { .success($0) }
                        case .failure(let error):
                            return [.failure(error)]
                        }
                    case .failure(let error):
                        return [.failure(error)]
                    }
                }.reduce(
                    [Result<Datafile, AnyError>]()
                ) { (initial, next) -> [Result<Datafile, AnyError>] in
                    var results: [Result<Datafile, AnyError>] = initial
                    next.forEach { results.append($0) }
                    return results
                }

            return aarkayService.generatedfileService.generatedfiles(
                datafiles: templateDatafiles,
                templateService: templateService,
                globalContext: globalContext
            )
        } else {
            let datafiles = try aarkayService.datafileService.serialize(
                plugin: name,
                name: fileName,
                directory: directory,
                template: template,
                contents: contents,
                using: YamlInputSerializer(),
                globalContext: globalContext
            )

            return aarkayService.generatedfileService.generatedfiles(
                datafiles: datafiles,
                templateService: templateService,
                globalContext: globalContext
            )
        }
    }
}
