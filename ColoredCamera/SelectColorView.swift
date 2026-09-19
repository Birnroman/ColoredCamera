
import SwiftUI

struct SelectColorView: View {
//    private let colors: [Color] = [
//        Color(hex: "FFCE2E"),
//        Color(hex: "7CCC5A"),
//        Color(hex: "4E80FF"),
//        Color(hex: "F257D3"),
//        Color(hex: "EE3F3F")]
    
    private let colors: [String] = [
        "#FFCE2E",
        "#7CCC5A",
        "#4E80FF",
        "#F257D3",
        "#EE3F3F"]
    
    
    @Binding var mainColorHex: String

    
    var body: some View {
        HStack {
            VStack(spacing: 28) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .frame(width: 34)
                        .foregroundStyle(Color(hex: color))
                        .overlay(content: {
                            if color == mainColorHex {
                                Circle()
                                    .stroke(lineWidth: 3)
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
            
            if mainColorHex == "#FFCE2E" {
                Image("yellowColor")
                    .resizable()
                    .scaledToFit()
                
            } else if mainColorHex == "#7CCC5A" {
                Image("greenColor")
                    .resizable()
                    .scaledToFit()

            } else if mainColorHex == "#4E80FF" {
                Image("blueColor")
                    .resizable()
                    .scaledToFit()

            } else if mainColorHex == "#F257D3" {
                Image("pinkColor")
                    .resizable()
                    .scaledToFit()

            } else if mainColorHex == "#EE3F3F" {
                Image("redColor")
                    .resizable()
                    .scaledToFit()


            }
        }
    }
    
    private func tapColor(color: String) {
        self.mainColorHex = color
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
