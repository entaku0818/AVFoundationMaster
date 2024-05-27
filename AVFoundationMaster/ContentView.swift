//
//  ContentView.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/05/11.
//

import SwiftUI
import AVPlayerContentView

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Media Playbac")) {
                    NavigationLink(destination: AVPlayerContentView()) {
                        Text("AVPlayerContentView")
                    }
                }
                Section(header: Text("Media Capture")) {
                    NavigationLink(destination: PhotoCaptureContentView()) {
                        Text("Photo Capture")
                    }
                    NavigationLink(destination: VideoCaptureContentView()) {
                        Text("Video Capture")
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
