//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class ColorModel: Codable {
    public var name: String
    public var red: Float
    public var green: Float
    public var blue: Float
    public var alpha: Float!

    private enum CodingKeys: String, CodingKey {
        case name
        case red
        case green
        case blue
        case alpha
    }

    public init(name: String, red: Float, green: Float, blue: Float) {
        self.name = name
        self.red = red
        self.green = green
        self.blue = blue
    }

    public required init(from decoder: Decoder) throws {
        /// <aarkay decoder>
        /// your code goes here.
        /// </aarkay>
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }
}
