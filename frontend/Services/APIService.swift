import Foundation

class APIService {
    static let shared = APIService()

    // Change this to your machine's local IP when testing on a real device
    private let baseURL = "http://localhost:8000/api"

    private init() {}

    func fetchItems() async throws -> [Item] {
        let url = URL(string: "\(baseURL)/items/")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Item].self, from: data)
    }

    func createItem(_ payload: ItemCreate) async throws -> Item {
        let url = URL(string: "\(baseURL)/items/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Item.self, from: data)
    }

    func deleteItem(id: Int) async throws {
        let url = URL(string: "\(baseURL)/items/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let _ = try await URLSession.shared.data(for: request)
    }
}
