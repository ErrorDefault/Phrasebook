import SwiftUI

struct CategoryPhraseList: View {
    @EnvironmentObject var modelData: ModelData
    var categoryName: String
    
    var body: some View {
        PhraseList(
            phrases: modelData.phrases.filter { phrase in
                phrase.category.rawValue == categoryName
            }
        )
        .navigationTitle(categoryName)
    }
}

struct CategoryPhraseList_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPhraseList(categoryName: "Greetings")
            .environmentObject(ModelData())
    }
}
