import Foundation

struct Item: Codable, Identifiable {
    let id: Int
    var name: String
    var description: String?
}

struct ItemCreate: Codable {
    var name: String
    var description: String?
}
