//
//  PhotoCaptureContentView.swift
//
//
//  Created by Naoya Maeda on 2024/05/25
//
//

import SwiftUI
import AVFoundation

struct ManualFocusCameraView: View {
    @StateObject private var videoCapture = ManualVideoCapture()
    @State private var selectedFocus = FocusMode.autoFocus
    @State private var focusVal: Float = 0
    @State private var isPresented: Bool = false
    
    var body: some View {
        VStack() {
            ZStack(alignment: .top) {
                if let img = videoCapture.previewImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                } else {
                    Spacer()
                }
                Button(action: {
                    videoCapture.toggleCameraPosition()
                }) {
                    HStack {
                        Image(systemName: "arrow.circlepath")
                    }
                }
            }
            Spacer()
            VStack {
                HStack {
                    Text("MinimumFocusDistance")
                    Text(videoCapture.minimumFocusDistance.description)
                }
                Text((round(focusVal * 1000) / 1000).description)
                HStack {
                    Text("Lens Position")
                    Slider(value: $focusVal, in: 0...1.0)
                        .padding(.horizontal)
                        .onChange(of: focusVal) {
                            videoCapture.changeLensPosition(with: focusVal)
                        }
                }
                Picker("Focus", selection: $selectedFocus) {
                    ForEach(FocusMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedFocus) {
                    switch selectedFocus {
                    case .autoFocus:
                        videoCapture.changeFocus(with: .autoFocus)
                        
                    case .continuous:
                        videoCapture.changeFocus(with: .continuous)
                        
                    case .locked:
                        videoCapture.changeFocus(with: .locked)
                    }
                }
                Button(action: {
                    isPresented.toggle()
                }) {
                    Text("Option")
                }
                .padding()
                .accentColor(Color.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal, 30)
        }
        .sheet(isPresented: $isPresented) {
            VStack {
                Toggle(isOn: $videoCapture.smoothAutoFocusIs) {
                    Text("isSmoothAutoFocusEnabled")
                }
                .toggleStyle(.switch)
                .onChange(of: videoCapture.smoothAutoFocusIs) {
                    videoCapture.toggleSmoothAutoFocus(with: videoCapture.smoothAutoFocusIs)
                }
                
                Toggle(isOn: $videoCapture.smoothAutoFocusIs) {
                    Text("isFaceDrivenAutoFocusEnabled")
                }
                .toggleStyle(.switch)
                .onChange(of: videoCapture.faceDrivenAutoFocusIs) {
                    videoCapture.toggleFaceDrivenAutoFocus(with: videoCapture.faceDrivenAutoFocusIs)
                }
                
                Toggle(isOn: $videoCapture.automaticallyAdjustsFaceDrivenAutoFocusIs) {
                    Text("automaticallyAdjustsFaceDrivenAutoFocusEnabled")
                }
                .toggleStyle(.switch)
                .onChange(of: videoCapture.automaticallyAdjustsFaceDrivenAutoFocusIs) {
                    videoCapture.toggleFaceDrivenAutoFocus(with: videoCapture.automaticallyAdjustsFaceDrivenAutoFocusIs)
                }
            }
            .padding(20)
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    ManualFocusCameraView()
}
