//
//  File.swift
//  
//
//  Created by Jorge Mattei on 8/4/23.
//

import Foundation
import AVFoundation
import SwiftUI

class CameraViewCoordinator<View: UIViewRepresentable>: NSObject {
    var parent: View
    var view : UIView? {
        didSet {
            configure()
        }
    }

    lazy var captureSession: AVCaptureSession = {
        let captureSession: AVCaptureSession = .init()
        return captureSession
    }()

    lazy var photoOutput: AVCapturePhotoOutput = {
        let photoOutput = AVCapturePhotoOutput()
        return photoOutput
    }()

    var deviceInput: AVCaptureDeviceInput?
    var currentScannedCode: String?

    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        return previewLayer
    }()


    init(parent: View) {
        self.parent = parent
        super.init()
        configure()
    }

    func configure() {
        guard let view = view else { return }
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480
        let videoDevice = AVCaptureDevice.default(.builtInDualCamera,
                                                  for: .video,
                                                  position: .back)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
        else { return }
        self.deviceInput = videoDeviceInput
        captureSession.addInput(videoDeviceInput)
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        photoOutput.isLivePhotoCaptureEnabled = false
        captureSession.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.frame
        previewLayer.videoGravity = .resizeAspectFill
        self.view?.layer.addSublayer(previewLayer)
    }

    func start() {
        Task {
            await view?.layoutIfNeeded()
            if let size = await view?.frame.size {
                previewLayer.frame.size = size
            }
            captureSession.startRunning()
        }
    }

    func stop() {
        Task {
            captureSession.stopRunning()
        }
    }

}
