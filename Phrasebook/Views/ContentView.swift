import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .list
    
    enum Tab {
        case list
        case search
        case favorites
        case groups
    }
    
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: ()->Void
    
    var body: some View {
        TabView(selection: $selection) {
            CategoryList()
                .tabItem {
                    Label("Categories", systemImage: "list.bullet")
                }
                .tag(Tab.list)
            SearchList()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
            FavoriteList()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(Tab.favorites)
            GroupList()
                .tabItem {
                    Label("My Groups", systemImage: "folder")
                }
                .tag(Tab.groups)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                saveAction()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(saveAction: {})
            .environmentObject(ModelData())
    }
}
