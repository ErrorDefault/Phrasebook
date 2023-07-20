import SwiftUI

struct CategoryList: View {
    @EnvironmentObject var modelData: ModelData
    
    var categories : [String] {
        modelData.categories.keys.sorted { categoryA, categoryB in
            ModelData.compareCategories(categoryA: categoryA, categoryB: categoryB)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    NavigationLink {
                        CategoryPhraseList(categoryName: category)
                    } label: {
                        CategoryRow(name: category)
                    }
                }
            }
            .navigationTitle("Categories")
        }
    }
}

struct CategoryList_Previews: PreviewProvider {
    static var previews: some View {
        CategoryList()
            .environmentObject(ModelData())
    }
}
