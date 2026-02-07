import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ItemViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "tray",
                        description: Text("Tap + to add your first item.")
                    )
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            VStack(alignment: .leading) {
                                Text(item.name).font(.headline)
                                if let desc = item.description {
                                    Text(desc).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            Task {
                                for index in offsets {
                                    await viewModel.removeItem(viewModel.items[index])
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("DevFest26")
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadItems()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
