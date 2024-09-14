//
//  ContentView.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/05/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Media Playback")) {
                    NavigationLink(destination: AVPlayerContentView()) {
                        Text("AVPlayerContentView")
                    }
                    NavigationLink(destination: AVAudioPlayerContentView()) {
                        Text("AVAudioPlayerContentView")
                    }
                    NavigationLink(destination: AudioRecorderView()) {
                        Text("AudioRecorderView")
                    }
                    NavigationLink(destination: AudioSessionView()) {
                        Text("AudioSessionView")
                    }
                }
                Section(header: Text("Media Capture")) {
                    NavigationLink(destination: PhotoCaptureContentView()) {
                        Text("Photo Capture")
                    }
                    NavigationLink(destination: VideoCaptureContentView()) {
                        Text("Video Capture")
                    }
                    NavigationLink(destination: ManualFocusCameraView()) {
                        Text("Manual Focus Camera")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("AVFoundationMaster")
        }
    }
}

#Preview {
    ContentView()
}
