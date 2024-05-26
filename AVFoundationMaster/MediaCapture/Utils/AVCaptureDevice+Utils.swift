//
//  AVCaptureDevice+Utils.swift
//
//  
//  Created by Naoya Maeda on 2024/05/26
//  
//

import AVFoundation

extension AVCaptureDevice {
    static var isAuthorizedCamera: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
}
