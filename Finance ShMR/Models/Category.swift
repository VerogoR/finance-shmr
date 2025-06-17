import Foundation

struct Category: Identifiable {
    let id: String
    let name: String
    let emoji: Character
    let isIncome: Bool
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
}

