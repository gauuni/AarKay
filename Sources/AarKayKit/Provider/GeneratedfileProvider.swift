//
//  GeneratedfileProvider.swift
//  AarKayKit
//
//  Created by RahulKatariya on 19/01/19.
//

import Foundation
import Result
import SharedKit

struct GeneratedfileProvider: GeneratedfileService {
    var templatesService: TemplateService

    func generatedfiles(
        datafiles: [Result<Datafile, AnyError>],
        globalContext: [String: Any]?
    ) -> [Result<Generatedfile, AnyError>] {
        return datafiles.map { result -> Result<[Generatedfile], AnyError> in
            switch result {
            case .success(let value):
                return Result {
                    try generatedfiles(
                        datafile: value,
                        globalContext: globalContext
                    )
                }
            case .failure(let error):
                return .failure(error)
            }
        }.reduce(
            [Result<Generatedfile, AnyError>]()
        ) { (initial, next) -> [Result<Generatedfile, AnyError>] in
            var results = initial
            switch next {
            case .failure(let error):
                results.append(.failure(error))
            case .success(let files):
                results = results + files.map { .success($0) }
            }
            return results
        }
    }
}

// MARK: - Private Helpers

extension GeneratedfileProvider {
    private func generatedfiles(
        datafile: Datafile,
        globalContext: [String: Any]?
    ) throws -> [Generatedfile] {
        switch datafile.template {
        case .name(let name):
            return try generatedfiles(
                datafile: datafile,
                template: name,
                context: datafile.globalContext + datafile.context
            )
        case .nameStringExt(_, let string, let ext):
            let file = generatedfile(
                datafile: datafile,
                stringContents: string,
                pathExtension: ext
            )
            return [file]
        }
    }

    private func generatedfiles(
        datafile: Datafile,
        template: String,
        context: [String: Any]? = nil
    ) throws -> [Generatedfile] {
        let templateUrls = try templatesService.templatefiles
            .getTemplatefile(for: template)
        return try templateUrls.map { templateFile in
            try Try {
                let rendered = try self.templatesService.renderTemplate(
                    name: templateFile.template, context: context
                )
                return self.generatedfile(
                    datafile: datafile,
                    stringContents: rendered,
                    pathExtension: templateFile.ext
                )
            }.catch { _ in
                AarKayKitError.invalidTemplate(
                    AarKayKitError.InvalidTemplateReason
                        .notFound(name: template)
                )
            }
        }
    }

    private func generatedfile(
        datafile: Datafile,
        stringContents: String,
        pathExtension: String?
    ) -> Generatedfile {
        return Generatedfile(
            name: datafile.fileName,
            ext: pathExtension,
            directory: datafile.directory,
            override: datafile.override,
            skip: datafile.skip,
            contents: stringContents
        )
    }
}
