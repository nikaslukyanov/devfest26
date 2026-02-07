import Foundation

@MainActor
class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadItems() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await APIService.shared.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addItem(name: String, description: String?) async {
        let payload = ItemCreate(name: name, description: description)
        do {
            let newItem = try await APIService.shared.createItem(payload)
            items.append(newItem)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeItem(_ item: Item) async {
        do {
            try await APIService.shared.deleteItem(id: item.id)
            items.removeAll { $0.id == item.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
