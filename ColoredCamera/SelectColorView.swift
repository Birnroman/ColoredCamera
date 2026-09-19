
import SwiftUI

struct SelectColorView: View {
    private let colors: [Color] = [
        Color(hex: 0xFFCE2E),
        Color(hex: 0x7CCC5A),
        Color(hex: 0x4E80FF),
        Color(hex: 0xF257D3),
        Color(hex: 0xEE3F3F)]
    
    
    private let manImagesNames = [
        "noColor", "yellowColor", "greenColor", "blueColor", "pinkColor", "redColor"
    ]
    
    @Binding var currentColor: Color
    
    var body: some View {
        HStack {
            VStack(spacing: 28) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .frame(width: 34)
                        .foregroundStyle(color)
                        .overlay(content: {
                            if color == currentColor {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 38)
                                    .background(.clear)
                                    
                            }
                        })
                    
                    
                        .onTapGesture {
                            tapColor(color: color)
                        }
                }
            }
            Spacer()
            
            if currentColor == Color(hex: 0xFFCE2E) {
                Image("yellowColor")
                    .resizable()
                    .scaledToFit()
                
            } else if currentColor == Color(hex: 0x7CCC5A) {
                Image("greenColor")
                    .resizable()
                    .scaledToFit()

            } else if currentColor == Color(hex: 0x4E80FF) {
                Image("blueColor")
                    .resizable()
                    .scaledToFit()

            } else if currentColor == Color(hex: 0xF257D3) {
                Image("pinkColor")
                    .resizable()
                    .scaledToFit()

            } else if currentColor == Color(hex: 0xEE3F3F) {
                Image("redColor")
                    .resizable()
                    .scaledToFit()


            }
        }
    }
    
    private func tapColor(color: Color) {
        self.currentColor = color
    }
}

struct ColoredMan {
    let manColor: Color
    let manImage: Image
}

//
//#Preview {
//    SelectColorView(currentColor: <#Binding<Color>#>)
//}
