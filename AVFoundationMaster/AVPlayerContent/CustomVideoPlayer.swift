
import SwiftUI
import AVKit
import Foundation
import Combine

public struct CustomVideoPlayer: View {
    @StateObject private var viewModel: VideoPlayerViewModel

    public init(url: URL) {
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(playerManager: AVPlayerManager(url: url)))
    }

    public var body: some View {
        ZStack {
            VideoPlayer(player: viewModel.playerManager.player)
                .onAppear {
                    viewModel.play()
                }
                .onDisappear {
                    viewModel.pause()
                }

            if viewModel.showErrorOverlay {
                errorOverlay
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("エラー"),
                message: Text(viewModel.errorMessage),
                primaryButton: .default(Text("再試行"), action: viewModel.retry),
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
    }

    private var errorOverlay: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
            Text("再生エラー")
            Button("再試行") {
                viewModel.retry()
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

