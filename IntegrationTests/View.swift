//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class View: NSObject, Templatable {
    public var datafile: Datafile
    private var model: ViewModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: ViewModel.self)
    }
}

public class ViewModel: Codable {
    public var name: String
    public var prefix: String!
    public var presenter: Bool!
    public var component: [ArgModel]?
    public var useNib: Bool!

    private enum CodingKeys: String, CodingKey {
        case name
        case prefix
        case presenter
        case component
        case useNib
    }

    public init(name: String) {
        self.name = name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.prefix = try container.decodeIfPresent(String.self, forKey: .prefix) ?? "UI"
        self.presenter = try container.decodeIfPresent(Bool.self, forKey: .presenter) ?? false
        self.component = try container.decodeIfPresent([ArgModel].self, forKey: .component)
        self.useNib = try container.decodeIfPresent(Bool.self, forKey: .useNib) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(prefix, forKey: .prefix)
        try container.encode(presenter, forKey: .presenter)
        try container.encodeIfPresent(component, forKey: .component)
        try container.encode(useNib, forKey: .useNib)
    }
}
