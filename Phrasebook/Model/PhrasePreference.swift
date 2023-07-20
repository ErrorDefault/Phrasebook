import Foundation

struct PhrasePreference: Codable, Hashable, Identifiable {
    var id: Int
    var isFavorite: Bool
}
