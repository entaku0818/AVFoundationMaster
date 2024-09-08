
import SwiftUI
import AVKit
import Foundation

public struct CustomVideoPlayer: View {
    private var player: AVPlayer

    public init(url: URL) {
        player = AVPlayer(url: url)
    }

    public var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()
            }
            .onDisappear {
                player.pause()
            }
    }
}
