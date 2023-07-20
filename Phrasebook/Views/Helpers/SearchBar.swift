import SwiftUI

struct SearchBar: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Label("Search", systemImage: "magnifyingglass")
                .labelStyle(.iconOnly)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .disableAutocorrection(true)
                .font(.title2)
            if text.count > 0 {
                ClearButton(text: $text)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    @State private var text: String = "Hello world!"
    
    static var previews: some View {
        Group {
            SearchBar(placeholder: "Search phrases", text: .constant(""))
            SearchBar(placeholder: "Search phrases", text: .constant("Hello world!"))
        }
    }
}
