import Foundation
import AVFoundation

final class AVSpeechSynthesizerWrapper: NSObject, ObservableObject {
    @Published var state: State = .inactive
    @Published var currentPhraseId: Int? = nil
    @Published var currentCharacterRange: NSRange = NSRange()
    
    enum State: String {
        case inactive, speaking
    }
    
    override init() {
        super.init()
        synth.delegate = self
    }
    
    func speak(utterance: AVSpeechUtterance, phraseId: Int) {
        if(state == .inactive){
            synth.speak(utterance)
            currentPhraseId = phraseId
        }
    }
    
    private let synth: AVSpeechSynthesizer = .init()
}

extension AVSpeechSynthesizerWrapper: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.state = .speaking
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.state = .inactive
        self.currentPhraseId = nil
        currentCharacterRange = NSRange()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        currentCharacterRange = characterRange
    }
}
