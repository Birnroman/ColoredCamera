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
    
    @AppStorage("mainColorHex") private var mainColorHex: String = "#F257D3"
    
    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: mainColorHex) },
            set: { newColor in mainColorHex = newColor.toHex() }
        )
    }
    
    @AppStorage("reviewRequestIsPresented") var reviewRequestIsPresented: Bool = false
    
    @AppStorage("isNewUser") var isNewUser: Bool = true
    
    @Environment(\.requestReview) var requestReview
    @State var showPaywall: Bool = false
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        ZStack {
            
            //            Color(currentColor)
            Color(hex: mainColorHex)
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
                    .scaleEffect(
                        cameraModel.isScaledDown ? 0.5 : 1.0
                    )
                    .animation(.easeInOut, value: cameraModel.isScaledDown)
                
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
                .opacity(cameraModel.isRecording ? 0 : 1.0)
                
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
                        ColorPicker("", selection: colorBinding).offset(x: -45)
                    }
            }
            .padding()
            .onAppear {
                cameraModel.configure()
                if isNewUser && !userVM.isSubscriptionActive {
                    showPaywall = true
                } else {
                    showPaywall = false
                }
                
                cameraModel.setMaxBrightness()
            }
            .onReceive(userVM.$isSubscriptionActive) { isActive in
                if isNewUser && !isActive {
                    showPaywall = true
                } else {
                    showPaywall = false
                    if isActive {
                        isNewUser = false // Обновляем флаг при активной подписке
                    }
                }
            }
            .onDisappear {
                cameraModel.session.stopRunning() // ← ДОБАВЬ ЭТО!
                
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
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
                    .environmentObject(userVM)
                
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
    @Published var isSessionReady = false
    @Published var isScaledDown = false
    
    private var photoOutput = AVCapturePhotoOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private var timer: Timer?
    private var originalBrightness: CGFloat = 0
    
    
    override init() {
        super.init()
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopTimer()
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    // MARK: - Notifications
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if self?.isRecording == true {
                self?.stopRecording()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.session.stopRunning()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if self?.isSessionReady == true && !self!.session.isRunning {
                // ИСПРАВИТЬ: Запускать в фоновом потоке
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.session.startRunning()
                }
            }
        }
    }
    
    // MARK: - Configuration
    func configure() {
        checkPermissions { [weak self] in
            self?.setupSession()
        }
    }
    
    private func checkPermissions(completion: @escaping () -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch cameraStatus {
        case .authorized:
            if micStatus == .authorized {
                completion()
            } else if micStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .audio) { _ in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } else {
                completion() // Продолжаем без микрофона
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    AVCaptureDevice.requestAccess(for: .audio) { _ in
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
        default:
            print("Camera access denied")
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        
        // Устанавливаем preset
        session.sessionPreset = .high
        
        // Удаляем существующие входы и выходы
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        
        do {
            // Настройка камеры
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .front) else {
                print("No front camera available")
                session.commitConfiguration()
                return
            }
            
            videoInput = try AVCaptureDeviceInput(device: camera)
            guard let videoInput = videoInput,
                  session.canAddInput(videoInput) else {
                print("Cannot add video input")
                session.commitConfiguration()
                return
            }
            session.addInput(videoInput)
            
            // Настройка микрофона
            if let audioDevice = AVCaptureDevice.default(for: .audio) {
                audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if let audioInput = audioInput,
                   session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                }
            }
            
            // Настройка photo output
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            // Настройка movie output
            if session.canAddOutput(movieOutput) {
                session.addOutput(movieOutput)
            }
            
        } catch {
            print("Setup error: \(error)")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        
        // ИСПРАВЛЕНИЕ: Обновляем состояние в главном потоке
        DispatchQueue.main.async {
            self.isSessionReady = true
        }
        
        // ИСПРАВЛЕНИЕ: Запускаем сессию в фоновом потоке
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    // MARK: - Photo Capture
    func capturePhoto() {
        guard isSessionReady && session.isRunning else {
            print("Session not ready")
            return
        }
        
        
        // Проверяем соединение
        guard let connection = photoOutput.connection(with: .video),
              connection.isEnabled && connection.isActive else {
            print("No active video connection")
            return
        }
        DispatchQueue.main.async {
            self.isScaledDown = true
        }
        setMaxBrightness()
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = false
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isScaledDown = false
            self.restoreOriginalBrightness() // ← ДОБАВИЛИ
            
        }
    }
    
    // MARK: - Video Recording
    func startRecording() {
        guard isSessionReady && session.isRunning && !movieOutput.isRecording else {
            print("Cannot start recording")
            return
        }
        isScaledDown = true
        setMaxBrightness() // ← ДОБАВИЛИ
        
        
        // Проверяем соединение
        guard let connection = movieOutput.connection(with: .video),
              connection.isEnabled && connection.isActive else {
            print("No active video connection for recording")
            restoreOriginalBrightness() // Восстанавливаем если ошибка
            
            return
        }
        
        let tempDir = NSTemporaryDirectory()
        let fileName = "video_\(Date().timeIntervalSince1970).mov"
        let filePath = tempDir + fileName
        let fileURL = URL(fileURLWithPath: filePath)
        
        movieOutput.startRecording(to: fileURL, recordingDelegate: self)
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.recordingTime = 0
            self.startTimer()
        }
    }
    
    func stopRecording() {
        guard movieOutput.isRecording else {
            resetRecordingState()
            return
        }
        movieOutput.stopRecording()
        
        isScaledDown = false
        restoreOriginalBrightness() // ← ДОБАВИЛИ
        
    }
    
    func setMaxBrightness() {
        DispatchQueue.main.async {
            self.originalBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1.0
        }
    }
    func restoreOriginalBrightness() {
        DispatchQueue.main.async {
            UIScreen.main.brightness = self.originalBrightness
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.movieOutput.isRecording {
                self.recordingTime += 1
            } else {
                self.resetRecordingState()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetRecordingState() {
        DispatchQueue.main.async {
            self.stopTimer()
            self.isRecording = false
            self.recordingTime = 0
            self.restoreOriginalBrightness() // ← ДОБАВИЛИ (на всякий случай)
            
        }
    }
}

// MARK: - Photo Delegate
extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Cannot convert photo to image")
            return
        }
        
        savePhotoToLibrary(image: image)
    }
    
    private func savePhotoToLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                print("Photo saved successfully")
            } else {
                print("Photo library access denied")
            }
        }
    }
}

// MARK: - Video Delegate
extension CameraModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Recording started")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        defer {
            resetRecordingState()
        }
        
        if let error = error {
            print("Recording error: \(error)")
            return
        }
        
        saveVideoToLibrary(url: outputFileURL)
    }
    
    private func saveVideoToLibrary(url: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { success, error in
                    if success {
                        print("Video saved successfully")
                    } else {
                        print("Video save error: \(error?.localizedDescription ?? "Unknown")")
                    }
                    
                    // Удаляем временный файл
                    try? FileManager.default.removeItem(at: url)
                }
            } else {
                print("Photo library access denied")
                try? FileManager.default.removeItem(at: url)
            }
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
