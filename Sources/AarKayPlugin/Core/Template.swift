//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Template: NSObject, Templatable {
    public var datafile: Datafile
    private var model: TemplateModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: TemplateModel.self)
    }
}

public class TemplateModel: Codable {
    public var isTemplate: Bool!
    public var name: String
    public var module: String!
    public var base: String?
    public var dir: String?
    public var templates: [TemplateStringModel]?
    public var subs: [TemplateModel]?
    public var inputSerializer: String?
    public var customDecoder: Bool!
    public var properties: [ArgModel]!
    public var baseProperties: [ArgModel]!
    public var computedProperties: [ArgModel]?

    public var allProperties: [ArgModel]? {
        /// <aarkay allProperties>
        let props = properties ?? []
        let cProps = computedProperties ?? []
        let allProperties = props + cProps
        return allProperties.isEmpty ? nil : allProperties
        /// </aarkay>
    }

    public var requiredProperties: [ArgModel]? {
        /// <aarkay requiredProperties>
        return properties.filter { !$0.isOptionalOrWrapped }
        /// </aarkay>
    }

    public var requiredBaseProperties: [ArgModel]? {
        /// <aarkay requiredBaseProperties>
        return baseProperties.filter { !$0.isOptionalOrWrapped }
        /// </aarkay>
    }

    public var requiredAllProperties: [ArgModel]? {
        /// <aarkay requiredAllProperties>
        return (baseProperties + properties).filter { !$0.isOptionalOrWrapped }
        /// </aarkay>
    }

    private enum CodingKeys: String, CodingKey {
        case isTemplate
        case name
        case module
        case base
        case dir
        case templates
        case subs
        case inputSerializer
        case customDecoder
        case properties
        case baseProperties
        case computedProperties
        case allProperties
        case requiredProperties
        case requiredBaseProperties
        case requiredAllProperties
    }

    public init(name: String) {
        self.name = name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isTemplate = try container.decodeIfPresent(Bool.self, forKey: .isTemplate) ?? true
        self.name = try container.decode(String.self, forKey: .name)
        self.module = try container.decodeIfPresent(String.self, forKey: .module) ?? self.name
        self.base = try container.decodeIfPresent(String.self, forKey: .base)
        self.dir = try container.decodeIfPresent(String.self, forKey: .dir)
        self.templates = try container.decodeIfPresent([TemplateStringModel].self, forKey: .templates)
        self.subs = try container.decodeIfPresent([TemplateModel].self, forKey: .subs)
        self.inputSerializer = try container.decodeIfPresent(String.self, forKey: .inputSerializer)
        self.customDecoder = try container.decodeIfPresent(Bool.self, forKey: .customDecoder) ?? false
        self.properties = try container.decodeIfPresent([ArgModel].self, forKey: .properties) ?? []
        self.baseProperties = try container.decodeIfPresent([ArgModel].self, forKey: .baseProperties) ?? []
        self.computedProperties = try container.decodeIfPresent([ArgModel].self, forKey: .computedProperties)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isTemplate, forKey: .isTemplate)
        try container.encode(name, forKey: .name)
        try container.encode(module, forKey: .module)
        try container.encodeIfPresent(base, forKey: .base)
        try container.encodeIfPresent(dir, forKey: .dir)
        try container.encodeIfPresent(templates, forKey: .templates)
        try container.encodeIfPresent(subs, forKey: .subs)
        try container.encodeIfPresent(inputSerializer, forKey: .inputSerializer)
        try container.encode(customDecoder, forKey: .customDecoder)
        try container.encode(properties, forKey: .properties)
        try container.encode(baseProperties, forKey: .baseProperties)
        try container.encodeIfPresent(computedProperties, forKey: .computedProperties)
        try container.encodeIfPresent(allProperties, forKey: .allProperties)
        try container.encodeIfPresent(requiredProperties, forKey: .requiredProperties)
        try container.encodeIfPresent(requiredBaseProperties, forKey: .requiredBaseProperties)
        try container.encodeIfPresent(requiredAllProperties, forKey: .requiredAllProperties)
    }
}

// MARK: - AarKayEnd

extension Template {
    public func datafiles() throws -> [Datafile] {
        var all = [Datafile]()
        var templateDatafile = datafile
        templateDatafile.setDirectory("AarKay/AarKayTemplates")
        templatefiles(
            datafile: templateDatafile,
            model: model,
            all: &all
        )
        try modelFiles(
            datafile: datafile,
            model: model,
            all: &all
        )
        return all
    }

    func templatefiles(
        datafile: Datafile,
        model: TemplateModel,
        all: inout [Datafile]
    ) {
        var df = datafile
        df.appendDirectory(model.dir)
        model.templates?.forEach {
            let fileName = model.name + ($0.suffix ?? "")
            let templateString = $0.string.replacingOccurrences(
                of: "{{self.name}}", with: model.name
            )
            var subDf = df
            let ext: String = $0.ext.nilIfEmpty() != nil ? "\($0.ext!).stencil" : "stencil"
            subDf.setTemplate(.nameStringExt(df.template.name(), templateString, ext))
            subDf.setFileName(fileName)
            all.append(subDf)
        }

        guard let subs = model.subs else { return }

        subs.forEach {
            let sub = $0
            sub.dir = model.name
            if sub.templates == nil && model.templates != nil {
                sub.templates = model.templates!.map { t in
                    if let substring = t.subString {
                        let template = t
                        template.string = substring
                        return template
                    } else {
                        return t
                    }
                }
            }
            templatefiles(
                datafile: datafile,
                model: sub,
                all: &all
            )
        }
    }

    func modelFiles(
        datafile: Datafile,
        model: TemplateModel,
        all: inout [Datafile]
    ) throws {
        var dFile = datafile
        dFile.setFileName(model.name)
        all.append(dFile)

        guard let subs = model.subs else { return }
        try subs.forEach { sub in
            sub.base = (model.properties.isEmpty) ? model.base : model.name
            sub.baseProperties = model.baseProperties + model.properties
            var subFile = datafile
            subFile.appendDirectory(model.name)
            try subFile.setContext(sub)
            try modelFiles(datafile: subFile, model: sub, all: &all)
        }
    }
}
