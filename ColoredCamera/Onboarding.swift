import SwiftUI

struct Onboarding: View {
    @State private var currentStep = 0
//    @State var currentColor: Color = Color(hex: 0xF257D3)
    @AppStorage("mainColorHex") private var mainColorHex: String = "#F257D3"
    
    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: mainColorHex) },
            set: { newColor in mainColorHex = newColor.toHex() }
        )
    }

    let onFinished: () -> Void
    
    private let steps: [OnboardingStep] = [
        .init(title: "Bad lighting ruins your selfies? We have a solution!", artwork: .beforeAndAfter),
        .init(title: "Flash color selection", artwork: .colorPicker),
        .init(title: "Save photos and videos without limits", artwork: .gallery)
    ]
    
    
    var body: some View {
        let step = steps[currentStep]
        
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xEC197F), Color(hex: 0x9D1DBB), Color(hex: 0x5429C4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                OnboardingProgress(currentStep: currentStep)
                    .padding(.top, 16)
                
                Text("Step \(currentStep + 1)/\(steps.count)")
                    .font(.title3.weight(.medium))
                    .padding(.top, 16)
                
                Text(step.title)
                    .font(.system(size: 38, weight: .medium))
                    .tracking(-1)
                    .lineSpacing(-3)
                    .padding(.top, 30)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer(minLength: 20)
                
                if currentStep == 2 {
                    SelectColorView(mainColorHex: $mainColorHex)
                } else {
                    OnboardingArtwork(kind: step.artwork)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 340)
                }
                
                
                
                Spacer(minLength: 24)
                Button {
                    advance()
                } label: {
                    Text(currentStep == steps.count - 1 ? "Done" : "Continue")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(Color(hex: 0xEC197F), in: RoundedRectangle(cornerRadius: 17))
                        .accessibilityHint(currentStep == steps.count - 1 ? "Opens the subscription screen" : "Shows the next onboarding step")
                }
                
                
                
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
    
    private func advance() {
        guard currentStep < steps.count - 1 else {
            onFinished()
            return
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep += 1
        }
    }
}

private struct OnboardingStep {
    let title: String
    let artwork: OnboardingArtwork.Kind
}

private struct OnboardingProgress: View {
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Color(hex: 0xFFD42A) : .white)
                    .frame(height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding step \(currentStep + 1) of 3")
    }
}

private struct OnboardingArtwork: View {
    enum Kind { case beforeAndAfter, colorPicker, gallery }
    let kind: Kind
    
    var body: some View {
        switch kind {
        case .beforeAndAfter:
            Image("before-after")
                .resizable()
        case .colorPicker:
            Image("picker")
                .resizable()
            
        case .gallery:
            Image("gallery")
                .resizable()
            
        }
    }
    
    
    
    private func color(for index: Int) -> Color {
        let hue = Double(index % 10) / 10
        let brightness = 0.35 + Double(index / 10) * 0.09
        return Color(hue: hue, saturation: 0.78, brightness: brightness)
    }
}



extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension Color {
    // Инициализация из HEX-строки
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }

    // Конвертация Color обратно в HEX
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#F257D3"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    Onboarding(onFinished: {})
}
