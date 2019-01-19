//
//  AarKay+String.swift
//  AarKayKit
//
//  Created by RahulKatariya on 28/08/18.
//

import Foundation
import Yams

extension String: AarKayExtensionsProvider {}

extension AarKay where Base == String {
    func merge(templateString: String) -> String {
        var string = templateString
        let blockRegexPattern = "\\n(.*)<aarkay (.*)>([\\s\\S]*?)\\n(.*)<\\/aarkay>(.*)\\n"
        if let blockGroups = base.capturedGroups(withRegex: blockRegexPattern),
            let templateBlockGroups = string.capturedGroups(withRegex: blockRegexPattern) {
            var blocks = [String: String]()
            blockGroups.forEach { blocks[String(base[$0[1]])] = String(base[$0[2]]) }
            templateBlockGroups.reversed().forEach {
                let text = blocks[String(templateString[$0[1]])] ?? ""
                let replacableRange = $0[2]
                string = string.replacingCharacters(in: replacableRange, with: "")
                text.reversed().forEach {
                    string.insert($0, at: replacableRange.lowerBound)
                }
            }
        }

        let endRegexPattern = "\\n(.*) AarKayEnd"
        if let existingRange = string.range(of: endRegexPattern, options: [.regularExpression]) {
            string = String(string[..<existingRange.lowerBound])
        }
        if let range = base.range(of: endRegexPattern, options: [.regularExpression]) {
            string += String(base[range.lowerBound...])
        }
        return string
    }
}
