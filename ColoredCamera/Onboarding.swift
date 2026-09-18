import SwiftUI

struct Onboarding: View {
  @State private var currentStep = 0
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

        OnboardingArtwork(kind: step.artwork)
          .frame(maxWidth: .infinity)
          .frame(maxHeight: 340)

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

private extension Color {
  init(hex: UInt) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}

#Preview {
  Onboarding(onFinished: {})
}
