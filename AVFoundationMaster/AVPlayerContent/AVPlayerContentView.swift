// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Foundation

public struct AVPlayerContentView: View {
    public var body: some View {
        let videoURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!

        CustomVideoPlayer(url: videoURL)
    }
}
