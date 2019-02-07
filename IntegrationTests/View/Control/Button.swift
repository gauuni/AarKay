//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import AarKayPlugin
import Foundation

public class Button: View {
    private var model: ButtonModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: ButtonModel.self)
        try super.init(datafile: datafile)
    }
}

public class ButtonModel: ViewModel {}