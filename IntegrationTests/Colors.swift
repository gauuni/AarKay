//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Colors: NSObject, Templatable {
    public var datafile: Datafile
    private var model: ColorsModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: ColorsModel.self)
    }
}

public class ColorsModel: Codable {
    public var colors: [ColorModel]

    private enum CodingKeys: String, CodingKey {
        case colors
    }

    public init(colors: [ColorModel]) {
        self.colors = colors
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.colors = try container.decode([ColorModel].self, forKey: .colors)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(colors, forKey: .colors)
    }
}
