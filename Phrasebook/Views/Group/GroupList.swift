import SwiftUI

private struct NoGroupsText: View {
    var body: some View {
        Group {
            Text("Looks like you don't have any groups. Tap the")
            + Text(" + ")
                .foregroundColor(.blue)
            + Text("to create a new group.")
        }
        .font(.title2)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
}

struct GroupList: View {
    @EnvironmentObject var modelData : ModelData
    @State private var newGroupPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if modelData.groups.count > 0 {
                    List {
                        ForEach(modelData.groups.keys.sorted{ groupA, groupB in
                            modelData.compareGroups(groupA: groupA, groupB: groupB)
                        }, id: \.self) { groupName in
                            NavigationLink {
                                GroupPhraseList(
                                    groupName: groupName
                                )
                            } label: {
                                CategoryRow(name: groupName)
                            }
                        }
                        .onMove {
                            modelData.groupOrder.move(fromOffsets: $0, toOffset: $1)
                        }
                        .onDelete {
                            for i in $0.makeIterator() {
                                modelData.deleteGroup(groupName: modelData.groupOrder[i])
                            }
                        }
                    }
                } else {
                    ZStack {
                        List{}
                            .scrollDisabled(true)
                        NoGroupsText()
                    }
                }
            }
            .navigationTitle("My Groups")
            .toolbar {
                Button {
                    newGroupPresented.toggle()
                } label: {
                    Label("Create New Group", systemImage: "plus")
                }
            }
            .sheet(isPresented: $newGroupPresented) {
                NewGroup(isPresented: $newGroupPresented)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

struct GroupList_Previews: PreviewProvider {
    static var previews: some View {
        GroupList()
            .environmentObject(ModelData())
    }
}
