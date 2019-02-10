//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

class AarKayPluginPlugin: Plugable {

    public var plugin: Pluginfile
    private var model: AarKayPluginPluginModel

    public required init(plugin: Pluginfile) throws {
        self.plugin = plugin
        self.model = try self.plugin.dencode(type: AarKayPluginPluginModel.self)
    }

    static func templates() -> [String] {
        var templates: [String] = []
        templates.append(#file)
        /// <aarkay templates>
        /// </aarkay>
        return templates
    }
}

public class AarKayPluginPluginModel: Codable {
    public var isPlugin: Bool!

    private enum CodingKeys: String, CodingKey {
        case isPlugin
    }

    public init() {
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isPlugin = try container.decodeIfPresent(Bool.self, forKey: .isPlugin) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isPlugin, forKey: .isPlugin)
    }
}
