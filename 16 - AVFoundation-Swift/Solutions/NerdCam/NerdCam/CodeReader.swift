//
//  CodeReader.swift
//  NerdCam
//
//  Created by Michael Ward on 9/19/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit
import AVFoundation

protocol CodeReaderDelegate: class {
    func codeReader(_ reader: CodeReader, didReadCode code: String)
}

class CodeReader: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: CodeReaderDelegate?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var session: AVCaptureSession?
    private let outputQueue = DispatchQueue(label: "AVMetadataOutput",
                                            qos: .userInteractive,
                                            attributes: [])
    private var featureOutlineLayer: CAShapeLayer?

    func start() -> Bool { // true on success
        guard let newSession = makeCaptureSession() else { return false }
        session = newSession
        
        let newPreview = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer = newPreview
        
        let newOutline = makeFeatureOutlineLayer()
        featureOutlineLayer = newOutline
        newOutline.frame = newPreview.bounds
        newPreview.addSublayer(newOutline)
        
        addMetadataOutput(to: newSession)
        session?.startRunning()
        
        return true
    }
    
    func stop() {
        session?.stopRunning()
        session = nil
        previewLayer = nil
        featureOutlineLayer = nil
    }
    
    private func makeCaptureSession() -> AVCaptureSession? {
        // Create a reference to a device such as the camera
        guard let videoCamera = AVCaptureDevice.default(for: .video) else {
            print("\(#function): couldn't get a video camera!")
            return nil
        }
        
        // Wrap the input device in an input object
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCamera)
        } catch {
            print("\(#function): failed to init \(videoCamera): \(error)")
            return nil
        }
        
        // Create the new capture session and attach the input object to it
        let session = AVCaptureSession()
        if (!session.canAddInput(videoInput)) {
            print("\(#function): cannot add input \(videoCamera)")
            return nil
        }
        session.addInput(videoInput)
        
        return session
    }
    
    private func addMetadataOutput(to session: AVCaptureSession) {
        let metadataOutput = AVCaptureMetadataOutput()
        assert(session.canAddOutput(metadataOutput))
        
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: outputQueue)
        metadataOutput.metadataObjectTypes = [.qr]
    }
    
    private func makeFeatureOutlineLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.lineDashPattern = [5,3]
        shapeLayer.fillColor = nil
        return shapeLayer
    }
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {

        guard let session = session, session.isRunning else { return }

        guard let qrCode =
            metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }

        DispatchQueue.main.async {
            let layer = self.previewLayer!
            var rect = layer.layerRectConverted(fromMetadataOutputRect: qrCode.bounds)
            rect = rect.insetBy(dx: -10, dy: -10)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 5)
            self.featureOutlineLayer!.path = path.cgPath
        }

        DispatchQueue.main.sync {
            if let words = qrCode.stringValue {
                self.delegate?.codeReader(self, didReadCode: words)
            }
        }
    }

}
