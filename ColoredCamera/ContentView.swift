import SwiftUI
import AVFoundation

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
            
            Button(action: {
                cameraModel.capturePhoto()
            }) {
                Text("Сделать фото")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            cameraModel.configure()
        }
    }
}

class CameraModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "CameraQueue")
    
    func configure() {
        queue.async {
            self.session.beginConfiguration()
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
            
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
            } catch {
                print("Ошибка настройки камеры: \(error)")
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.session.startRunning()
            }
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        self.output.capturePhoto(with: settings, delegate: self)
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
