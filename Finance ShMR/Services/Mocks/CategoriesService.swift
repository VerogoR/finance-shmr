//
//  CategoriesService.swift
//  Finance ShMR
//
//  Created by Egor Herdziy on 12.06.25.
//

import Foundation

final class CategoriesService {
    private let categoriesMock: [Category] = [
        Category(id: "c1i", name: "Зарплата", emoji: "💰", direction: .income),
        Category(id: "c2o", name: "Продукты", emoji: "🛒", direction: .outcome),
        Category(id: "c3o", name: "Подарки", emoji: "🎁", direction: .outcome)
    ]
    
    func categories() async throws -> [Category] {
        return categoriesMock
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        return categoriesMock.filter { $0.direction == direction }
    }
}

