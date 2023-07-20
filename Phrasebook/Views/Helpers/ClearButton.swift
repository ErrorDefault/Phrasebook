import SwiftUI

struct ClearButton: View {
    @Binding var text: String
    
    var body: some View {
        Button {
            text = ""
        } label: {
            Label("Clear", systemImage: "xmark.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundColor(.gray)
        }
        .frame(width: 20, height: 20)
    }
}

struct ClearButton_Previews: PreviewProvider {
    static var previews: some View {
        ClearButton(text: .constant(""))
    }
}
