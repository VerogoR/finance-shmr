import Foundation

final class CategoriesService {
    private let categoriesMock: [Category] = [
        Category(id: "c1i", name: "Зарплата", emoji: "💰", isIncome: true),
        Category(id: "c2o", name: "Продукты", emoji: "🛒", isIncome: false),
        Category(id: "c3o", name: "Подарки", emoji: "🎁", isIncome: false)
    ]
    
    func categories() async throws -> [Category] {
        return categoriesMock
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        return categoriesMock.filter { $0.direction == direction }
    }
}

