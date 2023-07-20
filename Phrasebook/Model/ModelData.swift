import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var phrases: [Phrase] = loadDefault("phraseData.json")
    @Published final var options: [String : [String : [String : String]]] = loadDefault("optionsData.json")
    @Published var groups: [String : [Int]] = [:]
    @Published var groupOrder : [String] = []
    
    var categories: [String: [Phrase]] {
        Dictionary(
            grouping: phrases,
            by: { $0.category.rawValue }
        )
    }
    
    static var categoryOrder: [String] = ["Common", "Greetings", "Transportation", "Places", "Directions",
                                          "Restaurant", "Food", "Emergency", "Numbers", "Time and Date",
                                          "Work", "Colors", "Countries"]
    
    static func compareCategories(categoryA: String, categoryB: String) -> Bool {
        let categoryAIndex = categoryOrder.firstIndex(of: categoryA)
        let categoryBIndex = categoryOrder.firstIndex(of: categoryB)
        if !(categoryAIndex == nil || categoryBIndex == nil) {
            return categoryAIndex! < categoryBIndex!
        }
        return categoryA < categoryB
    }
    
    func compareGroups(groupA: String, groupB: String) -> Bool {
        let groupAIndex = groupOrder.firstIndex(of: groupA)
        let groupBIndex = groupOrder.firstIndex(of: groupB)
        if !(groupAIndex == nil || groupBIndex == nil) {
            return groupAIndex! < groupBIndex!
        }
        return groupA < groupB
    }
    
    private static func preferencesFileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("phrasePreferences.data")
    }
    
    private static func getPhrasePreferences(phrases: [Phrase]) -> [PhrasePreference] {
        return phrases.map { (phrase) -> PhrasePreference in
            PhrasePreference(id: phrase.id, isFavorite: phrase.isFavorite)
        }
    }
    
    private static func groupsFileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("phraseGroups.data")
    }
    
    private static func groupOrderFileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("phraseGroupOrder.data")
    }
    
    private func loadPreferences() async throws {
        let task = Task<[PhrasePreference], Error> {
            let fileURL = try Self.preferencesFileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let userPhrasePreferences = try JSONDecoder().decode([PhrasePreference].self, from: data)
            return userPhrasePreferences
        }
        let phrasePreferences = try await task.value
        DispatchQueue.main.async {
            for phrasePreference in phrasePreferences {
                let phraseIndex = self.phrases.firstIndex(where: {$0.id == phrasePreference.id})
                if (phraseIndex != nil) {
                    self.phrases[phraseIndex!].isFavorite = phrasePreference.isFavorite
                }
            }
        }
    }
    
    private func loadGroups() async throws {
        let task = Task<[String : [Int]], Error> {
            let fileURL = try Self.groupsFileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return [:]
            }
            let userGroups = try JSONDecoder().decode([String : [Int]].self, from: data)
            return userGroups
        }
        let groups = try await task.value
        DispatchQueue.main.async {
            self.groups = groups
        }
    }
    
    private func loadGroupOrder() async throws {
        let task = Task<[String], Error> {
            let fileURL = try Self.groupOrderFileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let userGroups = try JSONDecoder().decode([String].self, from: data)
            return userGroups
        }
        let groupOrder = try await task.value
        DispatchQueue.main.async {
            self.groupOrder = groupOrder
        }
    }
    
    func load() async throws {
        try await loadPreferences()
        try await loadGroups()
        try await loadGroupOrder()
    }
    
    private func savePreferences() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(Self.getPhrasePreferences(phrases: self.phrases))
            let outfile = try Self.preferencesFileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    private func saveGroups() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(self.groups)
            let outfile = try Self.groupsFileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    private func saveGroupOrder() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(self.groupOrder)
            let outfile = try Self.groupOrderFileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    func save() async throws {
        try await savePreferences()
        try await saveGroups()
        try await saveGroupOrder()
    }
    
    enum GroupError: Error {
        case groupAlreadyExists
    }
    
    func addGroup(groupName: String) throws {
        if self.groups.keys.contains(groupName) {
            throw GroupError.groupAlreadyExists
        } else {
            self.groups[groupName] = []
            self.groupOrder.append(groupName)
        }
    }
    
    func deleteGroup(groupName: String) {
        self.groups.removeValue(forKey: groupName)
        self.groupOrder.removeAll(where: {$0 == groupName})
    }
}

func loadDefault<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

