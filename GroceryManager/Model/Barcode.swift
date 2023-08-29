//
//  Barcode.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/4/20.
//

import SwiftUI
import AVFoundation

public struct Barcode: UIViewRepresentable {

    public var supportBarcode: [AVMetadataObject.ObjectType]
    public typealias UIViewType = CameraPreview

    let delegate = Delegate()
    let session = AVCaptureSession()
    
    public init(supportBarcode: [AVMetadataObject.ObjectType]){
        self.supportBarcode = supportBarcode
    }
    
    public func interval(delay:Double)-> Barcode {
        delegate.scanInterval = delay
        return self
    }

    public func found(r: @escaping (String) -> Void) -> Barcode {
        delegate.onResult = r
        return self
    }

    func setupCamera(_ uiView: CameraPreview) {
        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video) {
            if let input = try? AVCaptureDeviceInput(device: backCamera) {

                let metadataOutput = AVCaptureMetadataOutput()
                session.sessionPreset = .photo

                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(metadataOutput) {
                    session.addOutput(metadataOutput)
                    metadataOutput.metadataObjectTypes = supportBarcode
                    metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                }
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)

                uiView.backgroundColor = UIColor.gray
                previewLayer.videoGravity = .resizeAspectFill
                uiView.layer.addSublayer(previewLayer)
                uiView.previewLayer = previewLayer

                DispatchQueue.global(qos: .background).async {
                    session.startRunning()
                }
            }
        }
    }

    public func makeUIView(context: UIViewRepresentableContext<Barcode>) -> Barcode.UIViewType {
        return CameraPreview(frame: .zero)
    }

    public func updateUIView(_ uiView: CameraPreview, context: UIViewRepresentableContext<Barcode>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if cameraAuthorizationStatus == .authorized {
            setupCamera(uiView)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.sync {
                    if granted {
                        self.setupCamera(uiView)
                    }
                }
            }
        }
    }

}

public class CameraPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    override public func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = self.bounds
    }
}

class Delegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    var scanInterval:Double = 3.0
    var lastTime = Date(timeIntervalSince1970: 0)
    var onResult: (String) -> Void = { _ in }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            let now = Date()
            if now.timeIntervalSince(lastTime) >= scanInterval {
                lastTime = now
                var correctCode = ""
                if readableObject.type == AVMetadataObject.ObjectType.ean13 && stringValue.hasPrefix("0"){
                    let index = stringValue.index(stringValue.startIndex, offsetBy: 1)
                    correctCode = String(stringValue[index...])
                }
                else {
                    correctCode = stringValue
                }
                self.onResult(correctCode)
            }
        }

    }
}
