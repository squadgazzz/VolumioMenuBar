import SwiftUI

struct HoverButtonStyle: ButtonStyle {
    var padding: EdgeInsets = EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary.opacity(isHovered ? 0.08 : 0))
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
    }
}
