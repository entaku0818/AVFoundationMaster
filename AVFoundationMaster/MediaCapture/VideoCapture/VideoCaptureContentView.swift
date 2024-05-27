//
//  VideoCaptureContentView.swift
//  
//  
//  Created by Naoya Maeda on 2024/05/27
//  
//

import SwiftUI

struct VideoCaptureContentView: View {
    @StateObject var videoCapture = VideoCapture()
    
    var body: some View {
        VStack() {
            if let img = videoCapture.previewImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
            } else {
                Spacer()
            }
            Button(action: {
                videoCapture.controlRecording()
            }) {
                Circle()
                    .foregroundColor(videoCapture.isRecording ? .red : .gray)
                    .frame(width: 80, height: 80)
            }
        }
    }
}

#Preview {
    VideoCaptureContentView()
}
