import SwiftUI
import AVFoundation

struct TTSButton: View {
    @EnvironmentObject var synthWrapper: AVSpeechSynthesizerWrapper
    var string: String
    var language: String
    var phrase: Phrase
    
    var body: some View {
        Button {
            if synthWrapper.state == .inactive {
                let utterance = AVSpeechUtterance(string: string)
                utterance.voice = AVSpeechSynthesisVoice(language: language)
                utterance.volume = 1.0
                synthWrapper.speak(utterance: utterance, phraseId: phrase.id)
            }
        } label: {
            Label("Pronounce", systemImage: "play.circle")
                .foregroundColor(synthWrapper.state == .speaking ? .gray : .accentColor)
                .labelStyle(.iconOnly)
                .scaleEffect(1.2)
        }
        .frame(width: 20, height: 20)
    }
}

struct TTSButton_Previews: PreviewProvider {
    static var previews: some View {
        TTSButton(string: "はい", language: "ja-JP", phrase: ModelData().phrases[0])
            .environmentObject(AVSpeechSynthesizerWrapper())
    }
}
