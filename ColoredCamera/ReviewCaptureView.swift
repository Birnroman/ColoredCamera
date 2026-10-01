import AVKit
import SwiftUI

struct ReviewCaptureView: View {
    let media: CameraModel.CapturedMedia
    let onSave: () -> Void
    let onDiscard: () -> Void
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                preview
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .overlay {
                Rectangle()
                    .fill(
                        Gradient(colors: [
                            .black.opacity(0),
                            .black.opacity(0),
                            .black.opacity(0),
                            .black
                        ])
                    )
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onDiscard) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding()
            .padding(.top, 24)
        }
        
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: onSave) {
                Text("Save to gallery")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .foregroundStyle(.white)
                    .background(
                        Color(hex: 0xEC197F),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.black)
        }
        
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
    
    @ViewBuilder
    private var preview: some View {
        switch media.kind {
        case .photo(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        case .video(let url):
            VideoPlayer(player: AVPlayer(url: url))
                .scaledToFill()
        }
    }
}
