//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//

import AarKayKit
import Foundation

public class Slider: View {
    private var model: SliderModel

    public required init(datafile: Datafile) throws {
        self.datafile = datafile
        self.model = try self.datafile.dencode(type: SliderModel.self)
        try super.init(datafile: datafile)
    }
}

public class SliderModel: ViewModel {}
