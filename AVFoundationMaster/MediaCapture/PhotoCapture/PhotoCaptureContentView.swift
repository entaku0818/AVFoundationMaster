//
//  PhotoCaptureContentView.swift
//  
//  
//  Created by Naoya Maeda on 2024/05/25
//  
//

import SwiftUI

struct PhotoCaptureContentView: View {
    @StateObject var videoCapture = PhotoCapture()
    
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
                Task {
                    await videoCapture.capturePhoto()
                }
            }) {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 80)
            }
        }
    }
}

#Preview {
    PhotoCaptureContentView()
}
