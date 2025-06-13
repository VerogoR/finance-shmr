//
//  Category.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 11.06.25.
//

import Foundation

struct Category: Identifiable {
    let id: String
    let name: String
    let emoji: Character
    let direction: Direction
    var isIncome: Bool {
        direction == .income
    }
}

