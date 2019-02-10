//
//  AarKayProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 22/10/18.
//

import Foundation
import Result

struct AarKayProvider: AarKayService {
    var datafileService: DatafileService
    var generatedfileService: GeneratedfileService

    func templateProvider(
        plugin: String,
        globalTemplates: [URL]?,
        fileManager: FileManager
    ) throws -> TemplateService {
        if let templateService = try templateService(
            plugin: plugin,
            fileManager: fileManager
        ) {
            return templateService
        } else {
            guard let globalTemplates = globalTemplates else {
                throw AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .templatesNil(name: plugin)
                )
            }
            guard let templates = try Templates(
                fileManager: fileManager,
                templates: globalTemplates
            ) else {
                throw AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .templatesNil(name: plugin)
                )
            }
            return StencilProvider(templates: templates)
        }
    }
}

// MARK: - Private Helpers

extension AarKayProvider {
    private func templateService(
        plugin: String,
        fileManager: FileManager
    ) throws -> TemplateService? {
        guard let plugable = plugableClass(plugin: plugin) else {
            return nil
        }

        guard let templates = try Templates(
            fileManager: fileManager,
            templates: plugable.templates().map { URL(fileURLWithPath: $0) }
        ) else {
            throw AarKayKitError.invalidTemplate(
                AarKayKitError.InvalidTemplateReason
                    .templatesNil(name: plugin)
            )
        }

        return try plugable.templateService().init(
            templates: templates
        )
    }

    private func plugableClass(
        plugin: String
    ) -> Plugable.Type? {
        if let plugable = NSClassFromString("\(plugin).\(plugin)Plugin") as? Plugable.Type {
            return plugable
        } else {
            return nil
        }
    }
}
