//
//  ShutterCameraView.swift
//  XSwift-SwiftUIExamples
//
//  Created by Jorge Mattei on 8/3/23.
//

import SwiftUI

public struct ShutterCameraView: View {
    @State var isCameraSessionRunning: Bool = false
    @State var cameraCapture: CameraCapture = .init()
    @State var fullscreenAction: FullscreenAction?
    var onCaptureConfirm: (UIImage) -> ()

    public init(onCaptureConfirm: @escaping (UIImage) -> ()) {
        self.onCaptureConfirm = onCaptureConfirm
    }
      
    public var body: some View {
        VStack {
            Spacer()
            Button("") {
                cameraCapture.isCapturing = true
            }
            .buttonStyle(ShutterButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: cameraCapture.capturedImage) { newValue in
            if let newValue {
                fullscreenAction = .confirmCapture(image: newValue)
            }
        }
        .background {
            CaptureCameraView(isRunning: $isCameraSessionRunning, capture: $cameraCapture)
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $fullscreenAction) { item in
            switch item {
            case let .confirmCapture(image):
                CaptureConfirmationView(image: image) { image in
                    fullscreenAction = nil
                    self.onCaptureConfirm(image)
                }
            }
        }
        .onAppear {
            isCameraSessionRunning = true
        }
        .onDisappear {
            isCameraSessionRunning = false
        }
    }

    enum FullscreenAction: Hashable, Identifiable {
        var id: String {
            switch self {
            case .confirmCapture: return "confirmCapture"
            }
        }
        case confirmCapture(image: UIImage)
    }
}

struct ShutterCameraView_Previews: PreviewProvider {
    static var previews: some View {
        ShutterCameraView(onCaptureConfirm: {_ in })
    }
}
