//
//  AarKayService.swift
//  AarKayKit
//
//  Created by RahulKatariya on 20/10/18.
//

import Foundation
import Result

/// A Type encapsulating all the services required by AarKayKit to perform operations.
protocol AarKayService {
    /// The DatafileService.
    var datafileService: DatafileService { get }

    /// The Generatedfile Service.
    var generatedfileService: GeneratedfileService { get }

    /// Creates a TemplateService object which is responsible for rendering the contents to a template.
    ///
    /// - Parameters:
    ///   - plugin: The name of the Plugin.
    ///   - globalTemplates: The global templates locations.
    ///   - fileManager: The file manager.
    /// - Returns: A TemplateService instance to render templates.
    /// - Throws: An `Error` if TemplateService creation encouters any error.
    func templateProvider(
        plugin: String,
        globalTemplates: [URL]?,
        fileManager: FileManager
    ) throws -> TemplateService
}

/// A Type that encapsulates all operations related to Datafile.
protocol DatafileService {
    /// Creates the Templatable Type at runtime from the plugin and template name.
    ///
    /// - Parameters:
    ///   - plugin: The plugin name.
    ///   - template: The template name.
    /// - Returns: The Templatable Type.
    func templateClass(
        plugin: String,
        template: String
    ) -> Templatable.Type?

    /// Creates the Datafiles result object from the datafile raw values on disk.
    ///
    /// - Parameters:
    ///   - plugin: The plugin name.
    ///   - name: The name of the file.
    ///   - template: The template to use.
    ///   - contents: The contents for the Datafile.
    ///   - serializer: The serializer used to decode the contents.
    /// - Returns: Result of Datafiles
    /// - Throws: An `Error` if serializing encouters any error.
    func serialize(
        plugin: String,
        name: String,
        directory: String,
        template: String,
        contents: String,
        using serializer: InputSerializable,
        globalContext: [String: Any]?
    ) throws -> [Result<Datafile, AnyError>]

    /// Process and modify Datafile object by applying to the given template and create new datafiles.
    ///
    /// - Parameters:
    ///   - datafile: The Datafile object.
    ///   - templateClass: The template class.
    /// - Returns: The new datafiles returned from template.
    /// - Throws: An `Error` if Templatable operations encouters any error.
    func templateDatafiles(
        datafile: Datafile,
        templateClass: Templatable.Type
    ) throws -> [Datafile]
}

/// A Type that encapsulates all operations related to Generatedfile.
protocol GeneratedfileService {
    /// Creates the Generatedfile result objects by applying the datafile to a template.
    ///
    /// - Parameters:
    ///   - datafiles: The Datafiles.
    ///   - templateService: The TemplateService.
    ///   - globalContext: The shared context.
    /// - Returns: The Generatedfiles result.
    func generatedfiles(
        datafiles: [Result<Datafile, AnyError>],
        templateService: TemplateService,
        globalContext: [String: Any]?
    ) -> [Result<Generatedfile, AnyError>]
}
