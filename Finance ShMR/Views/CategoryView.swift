import SwiftUI

final class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []

    private let service = CategoriesService()
    
    @MainActor
    func fetchCategories(for direction: Direction) async {
        categories = try! await service.categories(for: direction) // две секции: доходы / расходы
    }
    
}

struct CategoryView: View {
    @State private var searchText = ""  // Текст поиска
    @State private var direction: Direction = .outcome
    @State private var showDirectionPicker: Bool = false
    
    @StateObject private var categoryViewModel = CategoryViewModel()
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categoryViewModel.categories
        } else {
            return categoryViewModel.categories.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !categoryViewModel.categories.isEmpty {
                    List {
                        Section("Статьи") {
                            ForEach(filteredCategories) { category in
                                CategoryTab(category: category)
                            }
                        }
                    }
                } else {
                    ProgressView("Загрузка...")
                        .task {
                            await categoryViewModel.fetchCategories(for: direction)
                        }
                }
            }
            .navigationTitle("Мои статьи")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDirectionPicker = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(Color.indigo)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .confirmationDialog("Выберите категорию статей", isPresented: $showDirectionPicker, titleVisibility: .visible) {
                ForEach(Direction.allCases, id: \.self) { newDirection in
                    Button {
                        direction = newDirection
                    } label: {
                        Text(newDirection.rawValue)
                            .foregroundStyle(Color.indigo)
                    }
                }
            }
            .onChange(of: direction) {
                Task {
                    await categoryViewModel.fetchCategories(for: direction)
                }
            }

        }
    }
}

struct CategoryTab: View {
    let category: Category
    init(category: Category) {
        self.category = category
    }
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 35, height: 35)
                    .foregroundStyle(Color.accentColor)
                    .opacity(0.2)
                Text("\(category.emoji)")
            }
            Spacer()
                .frame(width: 15)
            VStack(alignment: .leading) {
                Text(category.name)
            }
            Spacer()
        }
    }
}

#Preview {
    CategoryView()
}
