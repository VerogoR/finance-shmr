import Foundation

final class CategoriesService {
    
    func categories() async throws -> [Category] {
        let client = NetworkClient(token: Secret.token)
        do {
            let categories: [Category] = try await client.request(
                path: "categories",
                method: "GET"
            )
            return categories
        } catch {
            print("Ошибка: \(error.localizedDescription)")
            throw error
        }
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        let client = NetworkClient(token: Secret.token)
        do {
            let categories: [Category] = try await client.request(
                path: "categories/type/\(direction == .income ? "true" : "false")",
                method: "GET"
            )
            return categories
        } catch {
            print("Ошибка: \(error.localizedDescription)")
            throw error
        }
    }
}

