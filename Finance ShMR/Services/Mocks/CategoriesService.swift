import Foundation

final class CategoriesServiceMock {
    private let categoriesMock: [Category] = [
        Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true),
        Category(id: 2, name: "Продукты", emoji: "🛒", isIncome: false),
        Category(id: 3, name: "Подарки", emoji: "🎁", isIncome: false)
    ]
    
    func categories() async throws -> [Category] {
        return categoriesMock
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        return categoriesMock.filter { $0.direction == direction }
    }
}

