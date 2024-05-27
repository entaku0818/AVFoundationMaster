//
//  VideoCapture.swift
//  
//  
//  Created by Naoya Maeda on 2024/05/27
//  
//

import UIKit
import AVFoundation
import Photos

public class VideoCapture: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private let movieFileOutput = AVCaptureMovieFileOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    @Published var previewImage: UIImage?
    @Published var isRecording = false
    
    public override init() {
        super.init()
        Task { [weak self] in
            await self?.setupCamera()
        }
    }
    
    private func setupCamera() async {
        guard await AVCaptureDevice.isAuthorizedCamera else { return }
        
        captureSession.beginConfiguration()
        do {
            guard let defaultVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                captureSession.commitConfiguration()
                return
            }
            
            let input = try AVCaptureDeviceInput(device: defaultVideoDevice)
            guard captureSession.canAddInput(input) else { return }
            captureSession.addInput(input)
            
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                captureSession.commitConfiguration()
                return
            }
            
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            guard captureSession.canAddInput(audioDeviceInput) else { return }
            captureSession.addInput(audioDeviceInput)
            
            guard captureSession.canAddOutput(videoDataOutput) else { return }
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "mydispatchqueue"))
            captureSession.addOutput(videoDataOutput)
            
            guard captureSession.canAddOutput(movieFileOutput) else { return }
            captureSession.addOutput(movieFileOutput)
            
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        } catch {
            print("Setup session error: \(error.localizedDescription))")
        }
        captureSession.commitConfiguration()
        
        captureSession.startRunning()
    }
    
    func controlRecording() {
        if isRecording {
            movieFileOutput.stopRecording()
            isRecording = false
            AudioServicesPlaySystemSound(1118)
        } else {
            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL: URL = tempDirectory.appendingPathComponent("sample.mov")
            movieFileOutput.startRecording(to: fileURL, recordingDelegate: self)
            isRecording = true
            AudioServicesPlaySystemSound(1117)
        }

    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let inputCIImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let cgImg = inputCIImage.toCGImage() {
            Task { @MainActor in
                self.previewImage = UIImage(cgImage: cgImg, scale: 1, orientation: .right)
            }
        }
    }
}

extension VideoCapture: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = true
                creationRequest.addResource(with: .video, fileURL: outputFileURL, options: nil)
            }) { _, error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}
