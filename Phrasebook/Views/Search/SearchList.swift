import SwiftUI

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct SearchList: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.colorScheme) var colorScheme
    
    @State private var search: String = ""
    
    @State private var searchBarSize = CGSize()
    
    var filteredPhrases: [Phrase] {
        let trimmedSearch = search.trimmingCharacters(in: .whitespaces)
        
        return modelData.phrases.filter { phrase in
            phrase.english.localizedCaseInsensitiveContains(trimmedSearch) ||
            phrase.japanese.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                CategorizedPhraseList(phrases: filteredPhrases)
                    .padding(.top, searchBarSize.height)
                    .scrollDisabled(filteredPhrases.isEmpty)
                VStack {
                    SearchBar(placeholder: "Search phrases", text: $search)
                        .padding()
                        .background(colorScheme == .light ? Color.white : Color.black)
                        .readSize { size in
                            searchBarSize = size
                        }
                    Spacer()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
        
}

struct SearchList_Previews: PreviewProvider {
    static var previews: some View {
        SearchList()
            .environmentObject(ModelData())
    }
}
