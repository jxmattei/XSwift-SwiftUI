//Copyright © 2023 ComponentsForSwift. All rights reserved.

import Vision
import SwiftUI
import AVFoundation


public struct CameraCapture {
    public var isCapturing: Bool = false
    public var capturedImage: UIImage?

    public init() { }
}

public struct CaptureCameraView: View {

    @Binding public var isRunning: Bool
    @Binding public var capture: CameraCapture

    public init(isRunning: Binding<Bool>, capture: Binding<CameraCapture>) {
        self._isRunning = isRunning
        self._capture = capture
    }

    public var body: some View {
#if targetEnvironment(simulator)
        Color.black
#else
        ZStack {
            Color.black
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            GeometryReader { proxy in
                let frame = proxy.frame(in: .global)
                CameraViewport(containedFrame: frame, isRunning: $isRunning, capture: $capture)
            }
            //Uncomment if you want a boxed frame
            //.aspectRatio(1.0, contentMode: .fit)
        }
#endif
    }
}

struct CameraViewport: UIViewRepresentable {

    var containedFrame: CGRect
    @Binding var isRunning: Bool
    @Binding var capture: CameraCapture

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        context.coordinator.view = view
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let size = self.containedFrame.size
        context.coordinator.previewLayer.frame = .init(origin: .zero, size: .init(width: size.width, height: size.height))
        if capture.isCapturing {
            context.coordinator.takePhoto()
            DispatchQueue.main.async {
                capture.isCapturing = false
            }
        }
        if isRunning && !context.coordinator.captureSession.isRunning  {
            context.coordinator.start()
        } else if !isRunning && context.coordinator.captureSession.isRunning {
            context.coordinator.stop()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject {
        var parent: CameraViewport
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

        var settings: AVCapturePhotoSettings {
            let settings = AVCapturePhotoSettings()
            settings.previewPhotoFormat = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)
                ,
                String(kCVPixelBufferWidthKey): 3072,
                String(kCVPixelBufferHeightKey): 3072,
            ]
            return settings
        }

        private let supportedMetadataOutput = [AVMetadataObject.ObjectType.qr]

        private let sequenceHandler = VNSequenceRequestHandler()

        let videoDataOutputQueue: DispatchQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        var requests: [VNRequest] = []

        init(parent: CameraViewport) {
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
            previewLayer = .init(session: captureSession)
            previewLayer.frame = view.layer.frame
            previewLayer.videoGravity = .resizeAspectFill
            self.view?.layer.addSublayer(previewLayer)
            captureSession.commitConfiguration()
        }

        func start() {
            Task {
                captureSession.startRunning()
            }
        }

        func stop() {
            Task {
                captureSession.stopRunning()
            }
        }

        func takePhoto() {
            photoOutput.capturePhoto(with: self.settings, delegate: self)
        }
    }
}

extension CameraViewport.Coordinator:  AVCapturePhotoCaptureDelegate, AVCaptureMetadataOutputObjectsDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }

        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
        guard let previewCGImage = photo.previewCGImageRepresentation()else { return }
        let width = CGFloat(previewCGImage.width)
        let height = CGFloat(previewCGImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)

        let croppedCGImage = previewCGImage.cropping(to: cropRect)!
        guard let resizedImage = croppedCGImage.resize(to: .init(width: 1024, height: 1024)) else  { return }
        let image = UIImage(cgImage: resizedImage, scale: 1, orientation: .right)
        parent.capture.capturedImage = image
    }
}

extension CGImage {
    func resize(to size:CGSize) -> CGImage? {
        let image = self
        var ratio: Double = 0.0
        let imageWidth = Double(image.width)
        let imageHeight = Double(image.height)
        let maxWidth: Double = Double(size.width)
        let maxHeight: Double = Double(size.height)

        // Get ratio (landscape or portrait)
        if (imageWidth > imageHeight) {
            ratio = maxWidth / imageWidth
        } else {
            ratio = maxHeight / imageHeight
        }

        // Calculate new size based on the ratio
        if ratio > 1 {
            ratio = 1
        }

        let width = imageWidth * ratio
        let height = imageHeight * ratio

        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(ceil(width)), height: Int(ceil(height)), bitsPerComponent: image.bitsPerComponent, bytesPerRow: image.bytesPerRow, space: colorSpace, bitmapInfo: image.alphaInfo.rawValue) else { return nil }

        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))

        // extract resulting image from context
        return context.makeImage()
    }
}
