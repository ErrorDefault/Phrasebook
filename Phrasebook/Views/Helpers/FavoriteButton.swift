import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet: Bool
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1))  {
                isSet.toggle()
            }
        } label: {
            Label("Toggle Favorite", systemImage: isSet ? "star.fill" : "star")
                .labelStyle(.iconOnly)
                .foregroundColor(isSet ? .yellow : .gray)
        }
        .frame(width: 20, height: 20)
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FavoriteButton(isSet: .constant(false))
            FavoriteButton(isSet: .constant(true))
        }
    }
}
