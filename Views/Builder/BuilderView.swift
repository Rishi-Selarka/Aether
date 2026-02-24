import SwiftUI

struct BuilderView: View {
    let tierID: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Color(red: 234 / 255, green: 239 / 255, blue: 239 / 255)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Back")
                }
            }
    }
}
