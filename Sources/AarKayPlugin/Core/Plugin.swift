//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Plugin: NSObject, Templatable {
    public var datafile: Datafile
    private var model: PluginModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: PluginModel.self)
    }
}

public class PluginModel: Codable {
    public var name: String
    public var properties: [ArgModel]!
    public var computedProperties: [ArgModel]?

    public var allProperties: [ArgModel]? {
        /// <aarkay allProperties>
        let props = properties ?? []
        let cProps = computedProperties ?? []
        let allProperties = props + cProps
        return allProperties.isEmpty ? nil : allProperties
        /// </aarkay>
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case properties
        case computedProperties
        case allProperties
    }

    public init(name: String) {
        self.name = name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.properties = try container.decodeIfPresent([ArgModel].self, forKey: .properties) ?? []
        self.computedProperties = try container.decodeIfPresent([ArgModel].self, forKey: .computedProperties)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(properties, forKey: .properties)
        try container.encodeIfPresent(computedProperties, forKey: .computedProperties)
        try container.encodeIfPresent(allProperties, forKey: .allProperties)
    }
}

// MARK: - AarKayEnd
extension Plugin {
    public func datafiles() throws -> [Datafile] {
        model.name = model.name + "Plugin"
        datafile.setFileName(model.name)
        try datafile.setContext(model)
        return [datafile]
    }
}
