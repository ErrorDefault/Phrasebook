import SwiftUI

struct PhraseList: View {
    @EnvironmentObject var modelData: ModelData
    @StateObject var synthWrapper: AVSpeechSynthesizerWrapper = AVSpeechSynthesizerWrapper()
    @State private var showFavoritesOnly = false
    
    var phrases: [Phrase]
    
    var filteredPhrases: [Phrase] {
        phrases.filter { phrase in
            (!showFavoritesOnly || phrase.isFavorite)
        }
    }
    
    var body: some View {
        List {
            Toggle(isOn: $showFavoritesOnly) {
                Text("Favorites only")
                    .font(.title2)
            }
            ForEach(filteredPhrases) {
                phrase in PhraseRow(phrase: phrase)
                    .environmentObject(synthWrapper)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct PhraseList_Previews: PreviewProvider {
    static var modelData: ModelData = ModelData()
    
    static var previews: some View {
        PhraseList(
            phrases: modelData.phrases.filter { phrase in
                phrase.category.rawValue == "Common"
            }
        )
            .environmentObject(modelData)
    }
}
