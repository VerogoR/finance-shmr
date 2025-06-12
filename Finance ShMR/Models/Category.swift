//
//  Category.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 11.06.25.
//

import Foundation

struct Category: Identifiable { // CAN DO CHANGES LIKE NAME OR EMOJI ???
    let id = UUID()
    let name: String
    let emoji: Character
    let direction: Direction
    var isIncome: Bool {
        direction == .income
    }
}


// PARSE OR CODABLE JSON ???

/*extension Category {
    init?(from jsonObject: Any){
        guard
            let jsonDict = jsonObject as? [String: Any],
            let name = jsonDict["name"] as? String,
            let emojiString = jsonDict["emoji"] as? String,
            let emoji = emojiString.first,
            let isIncome = jsonDict["isIncome"] as? Bool
        else {
            return nil
        }
        self.name = name
        self.emoji = emoji
        self.direction = isIncome ? .income : .outcome
    }
    
    var jsonObject: Any {
        return [
            "name": name,
            "emoji": String(emoji),
            "isIncome": isIncome
        ]
    }
}*/

