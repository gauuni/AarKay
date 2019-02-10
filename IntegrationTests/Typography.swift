//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Typography: NSObject, Templatable {
    public var datafile: Datafile
    private var model: TypographyModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: TypographyModel.self)
    }
}

public class TypographyModel: Codable {
    public var fontStyles: [ArgModel]
    public var fontSizes: [ArgModel]

    private enum CodingKeys: String, CodingKey {
        case fontStyles
        case fontSizes
    }

    public init(fontStyles: [ArgModel], fontSizes: [ArgModel]) {
        self.fontStyles = fontStyles
        self.fontSizes = fontSizes
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fontStyles = try container.decode([ArgModel].self, forKey: .fontStyles)
        self.fontSizes = try container.decode([ArgModel].self, forKey: .fontSizes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fontStyles, forKey: .fontStyles)
        try container.encode(fontSizes, forKey: .fontSizes)
    }
}
