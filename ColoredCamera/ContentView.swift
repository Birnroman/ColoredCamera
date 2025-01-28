import SwiftUI
import AVFoundation
import PhotosUI


struct CameraView: View {
    @StateObject private var cameraModel = CameraModel()
    
    var body: some View {
        VStack {
            CameraPreview(session: cameraModel.session)
                .frame(width: 300, height: 400)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
                .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    cameraModel.capturePhoto()
                }) {
                    Text("Сделать фото")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 160, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    if cameraModel.isRecording {
                        cameraModel.stopRecording()
                    } else {
                        cameraModel.startRecording()
                    }
                }) {
                    Text(cameraModel.isRecording ? "Остановить" : "Видео")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 160, height: 50)
                        .background(cameraModel.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            cameraModel.configure()
        }
    }
}

class CameraModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let queue = DispatchQueue(label: "CameraQueue")
    
    func configure() {
        queue.async {
            self.session.beginConfiguration()
            
            // Настройка камеры
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
            guard let audio = AVCaptureDevice.default(for: .audio) else { return }
            
            do {
                // Добавляем видео вход
                let videoInput = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }
                
                // Добавляем аудио вход
                let audioInput = try AVCaptureDeviceInput(device: audio)
                if self.session.canAddInput(audioInput) {
                    self.session.addInput(audioInput)
                }
                
                // Добавляем фото выход
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                // Добавляем видео выход
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
        }
    }
    
    func stopRecording() {
        guard movieOutput.isRecording else { return }
        movieOutput.stopRecording()
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
        
        // Сохраняем видео в галерею
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
