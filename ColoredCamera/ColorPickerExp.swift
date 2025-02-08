import AVFoundation
import Photos
import PhotosUI
import SwiftUI
import RevenueCat
import RevenueCatUI

struct ColorPickerExp: View {
  
  @State var currentColor: Color = Color(UIColor(cgColor: #colorLiteral(red: 0.831372549, green: 0.2, blue: 0.8588235294, alpha: 1)))
  @State var isCPPresented: Bool = false
  @StateObject private var cameraModel = CameraModel()
  
  @State var isVideo: Bool = false
  @State var isShowingAlert: Bool = false
  
  @AppStorage("reviewRequestIsPresented") var reviewRequestIsPresented: Bool = false
  @Environment(\.requestReview) var requestReview
  
  
  var body: some View {
    ZStack {
      
      Color(currentColor)
        .ignoresSafeArea()
      VStack {
        
        Spacer()
        
        CameraPreview(session: cameraModel.session)
          .frame(width: 180, height: 260)
          .cornerRadius(20)
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .stroke(Color.white, lineWidth: 2)
          )
          .overlay(
            Group {
              if cameraModel.isRecording {
                RecordingTimer(elapsedTime: cameraModel.recordingTime)
                  .padding(8)
              }
            },
            alignment: .topLeading
          )
          .padding()
        HStack(spacing: 0) {
          
          Button {
            
            isVideo = false
            
          } label: {
            Text("Photo").font(.headline)
              .foregroundStyle(isVideo ? .white : .black)
              .frame(height: 34)
              .padding(.horizontal)
              .background(isVideo ? .clear : .white)
              .cornerRadius(17)
          }
          
          Button {
            
            isVideo = true
            
          } label: {
            Text("Video").font(.headline)
              .foregroundStyle(isVideo ? .black : .white)
              .frame(height: 34)
              .padding(.horizontal)
              .background(isVideo ? .white : .clear)
              .cornerRadius(17)
          }
        }
        .background(.black.opacity(0.4))
        .cornerRadius(17)
        Spacer()
        HStack(spacing: 80) {
          Button {

            if isVideo {
              if cameraModel.isRecording {
                cameraModel.stopRecording()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  isShowingAlert = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                  isShowingAlert = false
                }
                
                
              } else {
                cameraModel.startRecording()
              }
            } else {
              cameraModel.capturePhoto()
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isShowingAlert = true
              }
              DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isShowingAlert = false
              }
              if !reviewRequestIsPresented {
                requestReview()
                reviewRequestIsPresented = true
              }
            }
            
          } label: {
            ZStack(alignment: .center) {
              
              
              Circle().foregroundStyle(.black.opacity(0.4)).frame(width: 76)
              
              Circle().foregroundStyle(.white).frame(width: 60)
              
              if isVideo {
                if cameraModel.isRecording {
                  RoundedRectangle(cornerRadius: 8).foregroundStyle(.red).frame(width: 36, height: 36)
                }
              }
              
            }
          }
          
        }.frame(maxWidth: .infinity)
          .overlay {
            ColorPicker("", selection: $currentColor).offset(x: -45)
          }
      }
      .padding()
      .onAppear {
        cameraModel.configure()

        
      }
      .overlay {
        if isShowingAlert {
          VStack {
            HStack {
              Spacer()
              Image(systemName: "xmark").font(.subheadline).foregroundStyle(.white)
                .onTapGesture {
                  isShowingAlert = false
                }
            }
            VStack(alignment: .leading, spacing: 10) {
              Image(systemName: "photo.badge.checkmark.fill")
                .font(.largeTitle)
              Text("Saved to the Gallery")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            }              .foregroundStyle(.white)
            
            
          }
          .padding(16)
          .background(.black.opacity(0.9))
          .cornerRadius(12)
          .padding(.horizontal, 40)
          .transition(.opacity)
          .animation(.easeInOut, value: isShowingAlert)
        }
      }

      
    }
  }
}



#Preview {
  ColorPickerExp()
    .environmentObject(UserViewModel())
}
struct RecordingTimer: View {
  let elapsedTime: TimeInterval
  
  var formattedTime: String {
    let minutes = Int(elapsedTime) / 60
    let seconds = Int(elapsedTime) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
  
  var body: some View {
    Text(formattedTime)
      .font(.system(.title3, design: .monospaced))
      .foregroundColor(.white)
      .padding(6)
      .background(Color.black.opacity(0.6))
      .cornerRadius(6)
  }
}

class CameraModel: NSObject, ObservableObject {
  @Published var session = AVCaptureSession()
  @Published var isRecording = false
  @Published var recordingTime: TimeInterval = 0
  
  private let photoOutput = AVCapturePhotoOutput()
  private let movieOutput = AVCaptureMovieFileOutput()
  private let queue = DispatchQueue(label: "CameraQueue")
  private var timer: Timer?
  
  func configure() {
    queue.async {
      self.session.beginConfiguration()
      
      guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
      guard let audio = AVCaptureDevice.default(for: .audio) else { return }
      
      do {
        let videoInput = try AVCaptureDeviceInput(device: camera)
        if self.session.canAddInput(videoInput) {
          self.session.addInput(videoInput)
        }
        
        let audioInput = try AVCaptureDeviceInput(device: audio)
        if self.session.canAddInput(audioInput) {
          self.session.addInput(audioInput)
        }
        
        if self.session.canAddOutput(self.photoOutput) {
          self.session.addOutput(self.photoOutput)
        }
        
        if self.session.canAddOutput(self.movieOutput) {
          self.session.addOutput(self.movieOutput)
        }
        
      } catch {
        print("Ошибка настройки камеры: \(error)")
      }
      
      self.session.commitConfiguration()
      
      DispatchQueue.main.async {
        self.session.startRunning()
      }
    }
  }
  
  func capturePhoto() {
    let settings = AVCapturePhotoSettings()
    self.photoOutput.capturePhoto(with: settings, delegate: self)
  }
  
  func startRecording() {
    guard !movieOutput.isRecording else { return }
    
    guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let videoName = "video_\(Date().timeIntervalSince1970).mov"
    let videoPath = documentsPath.appendingPathComponent(videoName)
    
    movieOutput.startRecording(to: videoPath, recordingDelegate: self)
    
    DispatchQueue.main.async {
      self.isRecording = true
      self.recordingTime = 0
      
      // Запускаем таймер
      self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
        self?.recordingTime += 1
      }
    }
  }
  
  func stopRecording() {
    guard movieOutput.isRecording else { return }
    movieOutput.stopRecording()
    
    // Останавливаем таймер
    timer?.invalidate()
    timer = nil
  }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error = error {
      print("Ошибка при фотографировании: \(error)")
      return
    }
    guard let data = photo.fileDataRepresentation(),
          let image = UIImage(data: data) else { return }
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    print("Фото успешно сохранено!")
  }
}

extension CameraModel: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    print("Началась запись видео")
  }
  
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    if let error = error {
      print("Ошибка при записи видео: \(error)")
      return
    }
    
    PHPhotoLibrary.requestAuthorization { status in
      guard status == .authorized else { return }
      
      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
      }) { success, error in
        if success {
          print("Видео успешно сохранено в галерею")
          try? FileManager.default.removeItem(at: outputFileURL)
        } else if let error = error {
          print("Ошибка сохранения видео: \(error)")
        }
      }
    }
    
    DispatchQueue.main.async {
      self.isRecording = false
      self.recordingTime = 0
    }
  }
}

struct CameraPreview: UIViewRepresentable {
  let session: AVCaptureSession
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: .zero)
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
      DispatchQueue.main.async {
        previewLayer.frame = uiView.bounds
      }
    }
  }
}
