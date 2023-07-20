import SwiftUI

struct CategorizedPhraseList: View {
    @EnvironmentObject var modelData: ModelData
    @StateObject var synthWrapper: AVSpeechSynthesizerWrapper = AVSpeechSynthesizerWrapper()
    
    @State private var search: String = ""
    
    var phrases: [Phrase]
    
    var categories: [String: [Phrase]] {
        Dictionary(
            grouping: phrases,
            by: { $0.category.rawValue }
        )
    }
    
    var body: some View {
        List {
            ForEach(categories.keys.sorted { categoryA, categoryB in
                ModelData.compareCategories(categoryA: categoryA, categoryB: categoryB)
            }, id: \.self) { category in
                Section {
                    ForEach(categories[category]!) { phrase in
                        PhraseRow(phrase: phrase)
                            .environmentObject(synthWrapper)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                } header: { Text(category) }
            }
        }
    }
}

struct CategorizedPhraseList_Previews: PreviewProvider {
    static var modelData: ModelData = ModelData()
    
    static var previews: some View {
        CategorizedPhraseList(phrases: modelData.phrases)
            .environmentObject(ModelData())
    }
}
