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
                NavigationLink(destination: AVPlayerContentView()) {
                    VStack {
                        Text("AVPlayerContentView")
                    }
                    .padding()
                }
            }
            .navigationTitle("AVFoundationMaster") 
        }
    }
}

#Preview {
    ContentView()
}
