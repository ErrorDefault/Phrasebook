import SwiftUI

struct SelectablePhraseRow: View {
    @Binding var multiSelection: [Int]
    var phrase: Phrase
    
    private var isSelected: Bool {
        multiSelection.contains(phrase.id)
    }
    
    var body: some View {
        HStack {
            Text(phrase.english)
                .opacity(isSelected ? 1 : 0.5)
                .font(.title2)
            Spacer()
            Label("Selected", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                .scaleEffect(isSelected ? 1.25 : 1)
                .labelStyle(.iconOnly)
                .foregroundColor(isSelected ? .accentColor : .gray)
                .font(.title3)
        }
        
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                if isSelected {
                    multiSelection.remove(at: multiSelection.firstIndex(where: {$0 == phrase.id})!)
                } else {
                    multiSelection.append(phrase.id)
                }
            }
        }
    }
}

struct SelectablePhraseList: View {
    @EnvironmentObject var modelData: ModelData
    @Binding var multiSelection: [Int]
    var filteredPhrases: [Phrase]
    var filteredCategories: [String: [Phrase]]
    
    var body: some View {
        List() {
            ForEach(filteredCategories.keys.sorted{ categoryA, categoryB in
                ModelData.compareCategories(categoryA: categoryA, categoryB: categoryB)
            }, id: \.self) { category in
                Section {
                    ForEach(modelData.categories[category]!) { phrase in
                        if filteredPhrases.contains(phrase) {
                            SelectablePhraseRow(multiSelection: $multiSelection, phrase: phrase)
                        }
                    }
                } header: { Text(category) }
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct EditGroupPhraseList: View {
    @EnvironmentObject var modelData: ModelData
    @Binding var isPresented: Bool
    
    var groupName: String
    
    @State var multiSelection: [Int]
    
    @State private var search: String = ""
    
    var filteredPhrases: [Phrase] {
        let trimmedSearch = search.trimmingCharacters(in: .whitespaces)
        
        return modelData.phrases.filter {
            phrase in
            trimmedSearch.count == 0 ||
            phrase.english.localizedCaseInsensitiveContains(trimmedSearch) ||
            phrase.japanese.localizedCaseInsensitiveContains(trimmedSearch) ||
            phrase.category.rawValue.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }
    
    var filteredCategories: [String: [Phrase]] {
        Dictionary(
            grouping: filteredPhrases,
            by: { $0.category.rawValue }
        )
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(groupName)
                    .font(.title)
                    .bold()
                Spacer()
                Button("Done") {
                    isPresented = false
                    modelData.groups[groupName] = Array(multiSelection)
                }
            }
            .padding()
            SearchBar(placeholder: "Search phrases", text: $search)
                .padding([.leading, .bottom, .trailing])
            SelectablePhraseList(
                multiSelection: $multiSelection,
                filteredPhrases: filteredPhrases,
                filteredCategories: filteredCategories
            )
        }
        .padding(.top)
    }
}

struct EditGroupPhraseList_Previews: PreviewProvider {
    static var modelData: ModelData = ModelData()
    
    static var previews: some View {
        EditGroupPhraseList(
            isPresented: .constant(true),
            groupName: "Restaurant",
            multiSelection:
                    modelData.phrases.map { (phrase) -> Int in
                    phrase.id
                }
        )
        .environmentObject(modelData)
    }
}
