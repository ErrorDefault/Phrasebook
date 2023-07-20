import Foundation

class NewGroupViewModel: ObservableObject {
    let characterLimit: Int = 20
    
    @Published var newGroupName: String = "" {
        didSet {
            if newGroupName.count > characterLimit {
                if oldValue.count == characterLimit {
                    newGroupName = oldValue
                } else {
                    newGroupName = String(newGroupName.prefix(characterLimit))
                }
            }
        }
    }
    
    @Published var showAlert: Bool = false
    
    enum Error {
        case emptyField
        case groupAlreadyExists
    }
    
    @Published var error: Error = .emptyField
    
    func setError(errorType: Error) {
        error = errorType
    }
    
    var errorMessage: String {
        switch error {
        case .emptyField:
            return "Please fill in all the fields."
        case .groupAlreadyExists:
            return "This group name already exists."
        }
    }
    
    func getTrimmedNewGroupName() -> String {
        return newGroupName.trimmingCharacters(in: .whitespaces)
    }
    
    var canSave: Bool {
        guard !newGroupName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        return true
    }
}
