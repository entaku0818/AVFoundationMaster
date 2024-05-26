//
//  PhotoCapture.swift
//
//
//  Created by Naoya Maeda on 2024/05/25
//
//

import UIKit
import AVFoundation
import Photos

public class PhotoCapture: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    @Published var previewImage: UIImage?
    private var compressedData: Data?
    
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
            
            guard captureSession.canAddOutput(photoOutput) else { return }
            captureSession.addOutput(photoOutput)
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "mydispatchqueue"))
            
            guard captureSession.canAddOutput(videoDataOutput) else { return }
            captureSession.addOutput(videoDataOutput)
            
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        } catch {
            print("Setup session error: \(error.localizedDescription))")
        }
        captureSession.commitConfiguration()
        
        self.captureSession.startRunning()
    }
    
    func capturePhoto() async {
        guard await AVCaptureDevice.isAuthorizedCamera else { return }
        let settingsForMonitoring = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
}

extension PhotoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
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

extension PhotoCapture: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Error broken photo data: \(error!)")
            return
        }
        guard let photoData = photo.fileDataRepresentation() else {
            print("No photo data to write.")
            return
        }
        self.compressedData = photoData
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                            error: Error?) {
        guard error == nil else {
            print("Error capture photo: \(error!)")
            return
        }
        guard let compressedData = self.compressedData else {
            print("The expected photo data isn't available.")
            return
        }
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: compressedData, options: nil)
            } completionHandler: { success, error in
                if let _ = error {
                    print("Error save photo: \(error!)")
                }
            }
        }
    }
}
