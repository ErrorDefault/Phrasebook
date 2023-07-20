import SwiftUI
import AVFoundation

extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}

struct OptionableEnglishText: View {
    @EnvironmentObject var synthWrapper: AVSpeechSynthesizerWrapper
    var phrase: Phrase
    var selection: String?
    @Binding var isSelected: Bool
    @Binding var showOptions: Bool
    
    var body: some View {
        let startIndex = phrase.english.range(of: "...")?.lowerBound
        let endIndex = phrase.english.range(of: "...")?.upperBound
        Group {
            Text(phrase.english[..<startIndex!].trimmingCharacters(in: .whitespaces))
                .foregroundColor(phrase.isSubcategory ? .red : nil)
            Text(selection == nil ? "..." : selection!)
                .foregroundColor(synthWrapper.state == .speaking && synthWrapper.currentPhraseId == phrase.id ? .gray : .accentColor)
                .onTapGesture {
                    isSelected = true
                    if !(synthWrapper.state == .speaking && synthWrapper.currentPhraseId == phrase.id) {
                        showOptions = true
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
            Text(phrase.english[endIndex!...].trimmingCharacters(in: .whitespaces))
                .foregroundColor(phrase.isSubcategory ? .red : nil)
        }
        .font(.title2)
    }
}

struct JapaneseText: View {
    @EnvironmentObject var synthWrapper: AVSpeechSynthesizerWrapper
    var phrase: Phrase
    var japanese: String
    
    var body: some View {
        let lower = synthWrapper.currentCharacterRange.lowerBound
        let upper = synthWrapper.currentCharacterRange.upperBound
        if(synthWrapper.currentPhraseId == phrase.id && lower != upper) {
            let trans = japanese
            let subStart = trans.index(trans.startIndex, offsetBy: lower)
            let subEnd = trans.index(subStart,  offsetBy: upper-lower)
            let before = String(trans[..<subStart])
            let after = String(trans[subEnd...])
            let current = String(trans[subStart..<subEnd])
            Group {
                Text(before) +
                Text(current)
                    .fontWeight(.bold) +
                Text(after)
            }
            .font(.title2)
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(japanese)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SelectionSheet: View {
    @Binding var selection: String?
    var options: [String]
    @Binding var showOptions: Bool
    
    var body: some View {
        VStack {
            List(selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .font(.title2)
                }
            }
            Button("Done") {
                showOptions = false
            }
            .padding(.top)
        }
    }
}

struct PhraseRow: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var synthWrapper: AVSpeechSynthesizerWrapper
    var phrase: Phrase
    @State private var isSelected: Bool = false
    @State private var selection: String? = nil
    @State private var showOptions: Bool = false
    
    var options: [String] {
        if let options = modelData.options[phrase.optionType] {
            return options.keys.sorted { itemA, itemB in
                itemA.isNumber && itemB.isNumber ? Int(itemA)! < Int(itemB)! : itemA < itemB
            }
        } else {
            return []
        }
    }
    
    var phraseIndex: Int {
        modelData.phrases.firstIndex(where: {$0.id == phrase.id})!
    }
    
    var body: some View {
        let japanese = phrase.optionType.isEmpty || selection == nil ? phrase.japanese : phrase.japanese.replacingOccurrences(
                of: "...",
                with: modelData.options[phrase.optionType]![selection!]!["japanese"]!
            )

        let romaji = phrase.optionType.isEmpty || selection == nil ? phrase.romaji : phrase.romaji.replacingOccurrences(
                 of: "...",
                 with: modelData.options[phrase.optionType]![selection!]!["romaji"]!
             )
        
        VStack {
            HStack {
                if(options.isEmpty) {
                    Text(phrase.english)
                        .font(.title2)
                        .foregroundColor(phrase.isSubcategory ? .red : nil)
                } else {
                    OptionableEnglishText(
                        phrase: phrase,
                        selection: selection,
                        isSelected: $isSelected,
                        showOptions: $showOptions
                    )
                }
                Spacer()
                FavoriteButton(isSet: $modelData.phrases[phraseIndex].isFavorite)
            }
            if isSelected {
                HStack {
                    VStack {
                        JapaneseText(phrase: phrase, japanese: japanese)
                        Text(romaji)
                            .font(.title3)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    TTSButton(string: japanese, language: "ja-JP", phrase: phrase)
                }
                .padding(.top, 1)
                if !phrase.notes.isEmpty {
                    HStack {
                        Text("ⓘ \(phrase.notes)")
                            .foregroundColor(.gray)
                            .font(.callout)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isSelected.toggle()
        }
        .sheet(isPresented: $showOptions) {
            SelectionSheet(selection: $selection, options: options, showOptions: $showOptions)
                .presentationDetents([.medium])
        }
    }
}

struct PhraseRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static var previews: some View {
        PhraseRow(phrase: modelData.phrases[0])
            .environmentObject(modelData)
            .environmentObject(AVSpeechSynthesizerWrapper())
    }
}
