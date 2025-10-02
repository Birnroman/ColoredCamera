import SwiftUI
import AVFoundation
import Foundation
import CoreImage
import UIKit

// Models
struct Preset: Identifiable, Equatable {
  let id = UUID()
  let name: String
}

enum CameraMode: String, CaseIterable, Identifiable {
  case photo = "Photo"
  case video = "Video"
  var id: String { self.rawValue }
}

struct Filter: Identifiable, Equatable {
  let id = UUID()
  let name: String
  let type: String
}

class FilterManager {
  static let shared = FilterManager()
  let ciContext = CIContext()
  
  func applyFilter(_ filterType: String, to ciImage: CIImage) -> CIImage {
    var outputImage = ciImage
    switch filterType {
    case "Brightness + Contrast":
      if let colorFilter = CIFilter(name: "CIColorControls") {
        colorFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorFilter.setValue(0.5, forKey: kCIInputBrightnessKey)
        colorFilter.setValue(1.5, forKey: kCIInputContrastKey)
        outputImage = colorFilter.outputImage ?? ciImage
      }
      
    case "Noise reduction + Sharpen":
      if let noise = CIFilter(name: "CINoiseReduction"),
         let sharp = CIFilter(name: "CISharpenLuminance") {
        noise.setValue(ciImage, forKey: kCIInputImageKey)
        noise.setValue(0.15, forKey: "inputNoiseLevel")
        sharp.setValue(noise.outputImage, forKey: kCIInputImageKey)
        sharp.setValue(1, forKey: kCIInputSharpnessKey)
        outputImage = sharp.outputImage ?? ciImage
      }
      
    case "Night Boost":
      if let color = CIFilter(name: "CIColorControls"),
         let tint = CIFilter(name: "CITemperatureAndTint") {
        color.setValue(ciImage, forKey: kCIInputImageKey)
        color.setValue(1.5, forKey: kCIInputSaturationKey)
        tint.setValue(color.outputImage, forKey: kCIInputImageKey)
        tint.setValue(CIVector(x: 6000 + CGFloat(500), y: 0), forKey: "inputNeutral")
        outputImage = tint.outputImage ?? ciImage
      }
      
    case "Low-Light Composite":
      if let exposure = CIFilter(name: "CIExposureAdjust"),
         let highlight = CIFilter(name: "CIHighlightShadowAdjust"),
         let noise = CIFilter(name: "CINoiseReduction"),
         let color = CIFilter(name: "CIColorControls") {
        exposure.setValue(ciImage, forKey: kCIInputImageKey)
        exposure.setValue(1.0, forKey: kCIInputEVKey)
        highlight.setValue(exposure.outputImage, forKey: kCIInputImageKey)
        highlight.setValue(1.0, forKey: "inputShadowAmount")
        noise.setValue(highlight.outputImage, forKey: kCIInputImageKey)
        noise.setValue(0.03, forKey: "inputNoiseLevel")
        color.setValue(noise.outputImage, forKey: kCIInputImageKey)
        color.setValue(1.2, forKey: kCIInputContrastKey)
        outputImage = color.outputImage ?? ciImage
      }
    default:
      break
    }
    return outputImage
  }
  
  func convertToCGImage(_ ciImage: CIImage) -> CGImage? {
    return ciContext.createCGImage(ciImage, from: ciImage.extent)
  }
}

// ViewModel
class MainViewModel: ObservableObject {
  
  @Published var currentColor: Color = .appPrimaryPurple
  @Published var tryProIsActive: Bool = true
  @Published var presets: [Preset] = [
    Preset(name: "Default"),
    Preset(name: "Night club"),
    Preset(name: "Landscape"),
    Preset(name: "Filter name"),
  ]
  @Published var currentPreset: Preset = Preset(name: "Default")
  @Published var cameraModes: [CameraMode] = CameraMode.allCases
  @Published var currentCameraMode: CameraMode = .photo
  @Published var timerIsActive: Bool = false
  @Published var timerDurationOptions: [Int] = [3, 5, 10]
  @Published var timerDuration: Int = 0
  @Published var isTimerOn: Bool = false
  
  
  var timerIsVisible: Bool {
    currentCameraMode == .photo && tryProIsActive
  }
  
  
  var presetsAreVisible: Bool {
    tryProIsActive
  }
  
  var cameraControlsAreVisible: Bool {
    tryProIsActive
  }
  
  var cameraForVideo: Bool {
    currentCameraMode == .video && tryProIsActive
  }
  
  var startButtonIsVisible: Bool {
    !timerIsActive
  }
  
  var pickerIsVisible: Bool {
    !timerIsActive
  }
  
  init() {
    self.currentPreset = presets.first ?? Preset(name: "Default")
  }
  
  func selectPreset(preset: Preset) {
    self.currentPreset = preset
  }
  
  func selectCameraMode(type: CameraMode) {
    self.currentCameraMode = type
    if type == .video {
      self.timerIsActive = false
    }
  }
  
  func selectDuraion(duration: Int) {
    self.timerDuration = duration
  }
  
  
  func timerActivate() {
    
  }
  
  func resetTimer() {
    if isTimerOn {
      isTimerOn = false
      timerDuration = 0
    }
  }
  
  
  
}

class CameraViewModel: ObservableObject {
  // настройка AVCaptureSession
  
  // Применение фильтров в реальном времени
  // Захват фото/видео
  // Управление таймером
}

// Views
struct MainView: View {
  
  @EnvironmentObject var viewModel: MainViewModel
  @State var showPicker = false
  
  var body: some View {
    ZStack {
      viewModel.currentColor.ignoresSafeArea()
      
      VStack(spacing: 24) {
        // try pro
        TryPRO()
        
        // preview frame
        RoundedRectangle(cornerRadius: 24)
          .frame(maxWidth: 240, maxHeight: 378)
        
        // presets
        if viewModel.presetsAreVisible {
          Presets(presets: viewModel.presets, currentPreset: viewModel.currentPreset) { selectedPreset in
            self.viewModel.selectPreset(preset: selectedPreset)
          }
          
        }
        
        Spacer()
        
        // photo/video
        if viewModel.cameraControlsAreVisible {
          CameraType(cameraModes: viewModel.cameraModes, currentCameraMode: viewModel.currentCameraMode) { selectedCameraType in
            self.viewModel.selectCameraMode(type: selectedCameraType)
          }
        }
        
        
        // timer + startButton + picker
        HStack {
          if viewModel.timerIsVisible {
            TimerView()
          } else {
            Color.clear.frame(width: 58, height: 58)
          }
          Spacer()
          if viewModel.startButtonIsVisible {
            StartButton()
          } else {
            Color.clear.frame(width: 92, height: 92)
          }
          Spacer()
          if viewModel.pickerIsVisible {
            ZStack {
              
              Button {
                
              } label: {
                Picker()
                
              }
              
              ColorPicker("", selection: $viewModel.currentColor)
                .labelsHidden()
                .scaleEffect(1.5)
            }
            
          } else {
            Color.clear.frame(width: 58, height: 58)
          }
        }
        .overlay {
          if viewModel.timerIsActive {
            TimerBar() { duration in
              self.viewModel.selectDuraion(duration: duration)
            }
          }
        }
      }
      .padding(.horizontal)
      .background(
        Color.clear
          .contentShape(Rectangle())
          .simultaneousGesture(
            TapGesture().onEnded({ _ in
              if viewModel.timerIsActive {
                viewModel.timerIsActive.toggle()
              }
              
            })
          )
      )
    }
  }
}

struct TryPRO: View {
  
  //  @Binding var tryProIsActive: Bool
  @EnvironmentObject var viewModel: MainViewModel
  
  var body: some View {
    
    Toggle(isOn: $viewModel.tryProIsActive) {
      Text("Try PRO Mode")
        .font(.headline)
        .foregroundStyle(.white)
    }
    .tint(.white.opacity(0.4))
    .fixedSize(horizontal: true, vertical: false)
    .onChange(of: viewModel.tryProIsActive) { _, newValue in
      if newValue == false {
        viewModel.timerIsActive = false
      }
    }
    
  }
}

struct Presets: View {
  
  var presets: [Preset]
  var currentPreset: Preset
  var onPresetSelected: (Preset) -> Void
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 32) {
        ForEach(presets) { preset in
          Text(preset.name)
            .fontWeight(preset == currentPreset ? .semibold : .regular)
            .foregroundStyle(.white)
            .opacity(preset == currentPreset ? 1 : 0.7)
            .onTapGesture {
              onPresetSelected(preset)
            }
        }
      }
    }
  }
}

struct CameraType: View {
  
  var cameraModes: [CameraMode]
  var currentCameraMode: CameraMode
  var onCameraModeSelected: (CameraMode) -> Void
  
  var body: some View {
    HStack {
      ForEach(cameraModes) { cameraMode in
        Text(cameraMode.rawValue)
          .font(.headline)
          .foregroundStyle(currentCameraMode == cameraMode ? .black : .white)
          .padding(.horizontal)
          .frame(maxHeight: .infinity)
          .background(currentCameraMode == cameraMode ? .white : .clear)
          .cornerRadius(17)
          .onTapGesture {
            onCameraModeSelected(cameraMode)
          }
      }
    }
    .frame(height: 34)
    .background(.black.opacity(0.45)).cornerRadius(17)
  }
}

struct TimerView: View {
  
  @EnvironmentObject var viewModel: MainViewModel
  
  var body: some View {
    
    Button {
      viewModel.timerIsActive.toggle()
      
    } label: {
      Image(systemName: "timer")
        .font(.title)
        .foregroundStyle(.white)
        .frame(width: 58, height: 58)
        .background(
          Circle().fill(.black.opacity(0.27))
            .stroke(!viewModel.timerIsActive && viewModel.isTimerOn ? .white : .clear, style: .init(lineWidth: 3))
        )
        .cornerRadius(29)
        .overlay {
          if !viewModel.timerIsActive && viewModel.isTimerOn  {
            Text("\(viewModel.timerDuration)")
              .font(.headline)
              .foregroundStyle(.black)
              .frame(width: 24, height: 24)
              .background(.white)
              .cornerRadius(12)
              .offset(x: 24, y: -20)
          }
        }
    }
  }
}

struct TimerBar: View {
  
  @EnvironmentObject var viewModel: MainViewModel
  var onDurationSelected: (Int) -> Void
  @State var isAnimated: Bool = false
  
  var body: some View {
    HStack {
      Image(systemName: "timer")
        .font(.title)
        .foregroundStyle(.white)
        .frame(width: 58, height: 58)
        .background(.black.opacity(0.1))
        .cornerRadius(29)
        .onTapGesture {
          viewModel.timerIsActive = false
        }
      Text(viewModel.isTimerOn ? "Off" : "Timer: off")
        .fontWeight(viewModel.isTimerOn ? .regular : .bold)
        .onTapGesture {
          viewModel.resetTimer()
        }
      Spacer()
      HStack(spacing: 24) {
        ForEach(viewModel.timerDurationOptions, id: \.self) { number in
          Button {
            onDurationSelected(number)
            viewModel.isTimerOn = true
          } label: {
            Text("\(number) s")
              .fontWeight(number == viewModel.timerDuration && viewModel.isTimerOn ? .bold : .regular)
          }
        }
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: 58)
    .padding(.trailing)
    .background(.black.opacity(0.4))
    .cornerRadius(27)
    .foregroundStyle(.white)
  }
}

struct StartButton: View {
  
  @EnvironmentObject var viewModel: MainViewModel
  
  var body: some View {
    Button {
      
    } label: {
      ZStack {
        Circle()
          .frame(width: 92, height: 92)
          .foregroundStyle(.black.opacity(0.27))
        
        if viewModel.cameraForVideo {
          RoundedRectangle(cornerRadius: 31)
            .frame(width: 62, height: 62)
            .foregroundStyle(.red)
            .background(
              Circle().foregroundStyle(.white)
                .frame(width: 76, height: 76)
            )
        } else {
          Circle().foregroundStyle(.white)
            .frame(width: 76, height: 76)
        }
      }
    }
  }
}

struct Picker: View {
  var body: some View {
    Button {
      
    } label: {
      Image("picker")
        .frame(width: 58, height: 58)
        .background(.black.opacity(0.27))
        .cornerRadius(29)
    }
  }
}

struct CameraView {
  
}

extension Color {
  static let appPrimaryPurple = Color(red: 0.831, green: 0.2, blue: 0.859)
}

#Preview {
  MainView()
    .environmentObject(MainViewModel())
}
