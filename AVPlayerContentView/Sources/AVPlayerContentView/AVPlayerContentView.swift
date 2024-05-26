// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct AVPlayerContentView: View {
    public init(){}
    
    public var body: some View {
        let videoURL = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!

        CustomVideoPlayer(urls: [videoURL])
    }
}
