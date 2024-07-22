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

public class ManualVideoCapture: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var captureDevice: AVCaptureDevice?
    
    @Published var previewImage: UIImage?
    private var compressedData: Data?
    
    @Published var selectedFocusMode: AVCaptureDevice.FocusMode = .autoFocus
    
    @Published var smoothAutoFocusIs = true
    @Published var faceDrivenAutoFocusIs = true
    @Published var automaticallyAdjustsFaceDrivenAutoFocusIs = true
    @Published var minimumFocusDistance: Int = 0
    
    public override init() {
        super.init()
        Task { [weak self] in
            await self?.setupCamera()
            self?.getFocusSettingsState()
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
            
            captureDevice = defaultVideoDevice
            
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
        
        captureSession.startRunning()
    }
    
    private func getFocusSettingsState() {
        guard let captureDevice else { return }
        
        Task { @MainActor [weak self] in
            self?.smoothAutoFocusIs = captureDevice.isSmoothAutoFocusEnabled
            self?.faceDrivenAutoFocusIs = captureDevice.isFaceDrivenAutoFocusEnabled
            self?.automaticallyAdjustsFaceDrivenAutoFocusIs = captureDevice.automaticallyAdjustsFaceDrivenAutoFocusEnabled
            self?.minimumFocusDistance = captureDevice.minimumFocusDistance
        }
    }
    
    func changeFocus(with mode: FocusMode) {
        guard let captureDevice else { return }
        
        let focusMode: AVCaptureDevice.FocusMode?
        switch mode {
        case .autoFocus:
            focusMode = .autoFocus
            
        case .continuous:
            focusMode  = .continuousAutoFocus
            
        case .locked:
            focusMode = .locked
        }
        if let focusMode, captureDevice.isFocusModeSupported(focusMode) {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.focusMode = focusMode
                captureDevice.unlockForConfiguration()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func changeLensPosition(with value: Float) {
        guard let captureDevice else { return }
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.setFocusModeLocked(lensPosition: value) { value in
                print("Finished change lens position process.")
            }
            captureDevice.unlockForConfiguration()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func toggleCameraPosition() {
        guard let captureDevice else { return }
        
        captureSession.beginConfiguration()
        do {
            guard let defaultVideoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: captureDevice.position == .back ? .front : .back) else {
                captureSession.commitConfiguration()
                return
            }
            
            self.captureDevice = defaultVideoDevice
            
            captureSession.inputs.forEach { captureSession.removeInput($0) }
            
            let input = try AVCaptureDeviceInput(device: defaultVideoDevice)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
        } catch {
            print("Setup session error: \(error.localizedDescription))")
        }
        
        updateMinimumFocusDistance()
        
        captureSession.commitConfiguration()
        
        captureSession.startRunning()
    }
    
    func toggleSmoothAutoFocus(with isEnabled: Bool) {
        guard let captureDevice else { return }
        
        do {
            try captureDevice.lockForConfiguration()
            if captureDevice.isSmoothAutoFocusSupported {
                captureDevice.isSmoothAutoFocusEnabled = isEnabled
            }
            captureDevice.unlockForConfiguration()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func toggleFaceDrivenAutoFocus(with isEnabled: Bool) {
        guard let captureDevice else { return }
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.isFaceDrivenAutoFocusEnabled = isEnabled
            captureDevice.unlockForConfiguration()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func toggleAutomaticallyAdjustsFaceDrivenAutoFocus(with isEnabled: Bool) {
        guard let captureDevice else { return }
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.automaticallyAdjustsFaceDrivenAutoFocusEnabled = isEnabled
            captureDevice.unlockForConfiguration()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension ManualVideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let inputCIImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        if let cgImg = inputCIImage.toCGImage() {
            Task { @MainActor [weak self] in
                self?.previewImage = UIImage(cgImage: cgImg, scale: 1, orientation: .right)
            }
        }
    }
}
