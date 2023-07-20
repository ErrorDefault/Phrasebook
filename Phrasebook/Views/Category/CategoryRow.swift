import SwiftUI

struct CategoryRow: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(.title)
            .frame(height: 50)
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(name: "Greetings")
    }
}
