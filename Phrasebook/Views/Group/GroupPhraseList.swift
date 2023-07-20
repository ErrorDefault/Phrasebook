import SwiftUI

private struct NoPhrasesText: View {
    var body: some View {
        Group {
            Text("Looks like this group is empty. Tap the")
            + Text(" + ")
                .foregroundColor(.blue)
            + Text("to add phrases to this group.")
        }
        .font(.title2)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
}

struct GroupPhraseList: View {
    @EnvironmentObject var modelData: ModelData
    @StateObject var synthWrapper: AVSpeechSynthesizerWrapper = AVSpeechSynthesizerWrapper()
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    
    var groupName: String
    
    var body: some View {
        VStack {
            if !modelData.groups.keys.contains(groupName) || modelData.groups[groupName]!.isEmpty {
                NoPhrasesText()
            } else {
                List {
                    ForEach(modelData.groups[groupName]!, id: \.self) { phraseId in
                        if editMode?.wrappedValue.isEditing == true {
                            Text(modelData.phrases.first(where: {$0.id == phraseId})!.english)
                                .font(.title2)
                        } else {
                            PhraseRow(phrase: modelData.phrases.first(where: {$0.id == phraseId})!)
                                .environmentObject(synthWrapper)
                        }
                    }
                    .onDelete {
                        modelData.groups[groupName]!.remove(atOffsets: $0)
                        if modelData.groups[groupName]!.isEmpty {
                            editMode?.wrappedValue = .inactive
                        }
                    }
                    .onMove {
                        modelData.groups[groupName]!.move(fromOffsets: $0, toOffset: $1)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .toolbar{
            if modelData.groups.keys.contains(groupName) && !modelData.groups[groupName]!.isEmpty {
                EditButton()
            }
            Button {
                showEditSheet = true
            } label: {
                Label("Change Phrases", systemImage: "plus")
            }
            .disabled(
                editMode?.wrappedValue.isEditing == true
            )
            Button {
                showDeleteAlert = true
            } label: {
                Label("Delete Group", systemImage: "trash")
            }
        }
        .alert(
            "Delete this group?",
            isPresented: $showDeleteAlert,
            actions: {
                Button("Delete", role: .destructive) {
                    modelData.deleteGroup(groupName: groupName)
                    dismiss()
                }.keyboardShortcut(.defaultAction)
                Button("Cancel", role: .cancel) {
                    
                }.keyboardShortcut(.cancelAction)
            },
            message: {
                Text("This action cannot be undone.")
            }
        )
        .sheet(isPresented: $showEditSheet) {
            EditGroupPhraseList(
                isPresented: $showEditSheet,
                groupName: groupName,
                multiSelection: modelData.groups[groupName]!
            )
            .presentationDetents([.large])
        }
        .navigationTitle(groupName)
    }
}

struct GroupPhraseList_Previews: PreviewProvider {
    static var previews: some View {
        GroupPhraseList(groupName: "Restaurant")
            .environmentObject(ModelData())
    }
}
