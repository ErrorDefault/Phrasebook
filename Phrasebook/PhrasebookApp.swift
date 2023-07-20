import SwiftUI

@main
struct PhrasebookApp: App {
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView() {
                Task {
                    do {
                        try await modelData.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .task {
                do {
                    try await modelData.load()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
            .environmentObject(modelData)
        }
    }
}
