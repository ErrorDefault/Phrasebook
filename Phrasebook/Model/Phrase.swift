import Foundation

struct Phrase: Codable, Hashable, Identifiable {
    let id: Int
    let english: String
    var isFavorite: Bool
    let japanese: String
    let romaji: String
    let optionType: String
    let notes: String
    let isSubcategory: Bool
    
    let category: Category
    enum Category: String, CaseIterable, Codable {
        case common = "Common"
        case greetings = "Greetings"
        case transportation = "Transportation"
        case directions = "Directions"
        case places = "Places"
        case restaurant = "Restaurant"
        case food = "Food"
        case numbers = "Numbers"
        case timeAndDate = "Time and Date"
        case emergency = "Emergency"
        case work = "Work"
        case color = "Colors"
        case countries = "Countries"
    }
}
