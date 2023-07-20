import SwiftUI

private struct NoFavoritesText: View {
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack {
            FavoriteButton(isSet: $isFavorite)
            Text("Add favorites by tapping this icon next to a phrase!")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct FavoriteList: View {
    @EnvironmentObject var modelData: ModelData
    
    var favoritePhrases: [Phrase] {
        modelData.phrases.filter { phrase in
            phrase.isFavorite
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoritePhrases.isEmpty {
                    ZStack {
                        List{}
                            .scrollDisabled(true)
                        NoFavoritesText()
                    }
                } else {
                    CategorizedPhraseList(phrases: favoritePhrases)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

struct FavoriteList_Previews: PreviewProvider {
    static var modelData: ModelData = ModelData()
    
    static var previews: some View {
        FavoriteList()
            .environmentObject(ModelData())
    }
}
