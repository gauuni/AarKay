//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class TableViewController: ViewController {
    private var model: TableViewControllerModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: TableViewControllerModel.self)
        try super.init(datafile: datafile)
    }
}

public class TableViewControllerModel: ViewControllerModel {
    public var isStatic: Bool!

    private enum CodingKeys: String, CodingKey {
        case isStatic
    }

    override public init(name: String) {
        super.init(name: name)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isStatic = try container.decodeIfPresent(Bool.self, forKey: .isStatic) ?? false
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isStatic, forKey: .isStatic)
        try super.encode(to: encoder)
    }
}
