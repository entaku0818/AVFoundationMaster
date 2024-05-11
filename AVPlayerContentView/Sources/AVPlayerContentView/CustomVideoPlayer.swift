//
//  CustomVideoPlayer.swift
//  
//
//  Created by 遠藤拓弥 on 2024/05/11.
//

import SwiftUI
import AVKit

public struct CustomVideoPlayer: View {
    private var player: AVPlayer

    public init(url: URL) {
        player = AVPlayer(url: url)
    }

    public var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()  // ビューが表示されたら自動的に再生開始
            }
            .onDisappear {
                player.pause() // ビューが非表示になったら一時停止
            }
    }
}
