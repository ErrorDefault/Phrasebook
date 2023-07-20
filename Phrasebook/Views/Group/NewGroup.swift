import SwiftUI


struct NewGroup: View {
    @EnvironmentObject var modelData: ModelData
    @Binding var isPresented: Bool
    @StateObject var viewModel = NewGroupViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Group name", text: $viewModel.newGroupName)
                
                Button(action: {
                    if viewModel.canSave {
                        do {
                            try modelData.addGroup(groupName: viewModel.getTrimmedNewGroupName())
                            isPresented = false
                        } catch ModelData.GroupError.groupAlreadyExists {
                            viewModel.showAlert = true
                            viewModel.setError(errorType: NewGroupViewModel.Error.groupAlreadyExists)
                        } catch {
                            
                        }
                    } else {
                        viewModel.showAlert = true
                        viewModel.setError(errorType: NewGroupViewModel.Error.emptyField)
                    }
                }) {
                    Text("Save")
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage))
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NewGroup_Previews: PreviewProvider {
    static var previews: some View {
        NewGroup(isPresented: .constant(true))
            .environmentObject(ModelData())
    }
}
