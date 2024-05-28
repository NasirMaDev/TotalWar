//
//  barCodeScanner.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 28/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate: AnyObject {
    func didFindCode(code: String)
    func didFailToFindCode()
}

class CameraView: UIView {

    weak var delegate: CameraViewDelegate?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    private var scanningRectView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2.0
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        checkCameraPermission()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        checkCameraPermission()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupPreviewLayerFrame()
        setupScanningRect()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            // Handle denied or restricted access
            print("Camera access denied or restricted")
        @unknown default:
            break
        }
    }

    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if (self.captureSession.canAddInput(videoInput)) {
                self.captureSession.addInput(videoInput)
            } else {
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (self.captureSession.canAddOutput(metadataOutput)) {
                self.captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .code128, .code39, .code93]
            } else {
                return
            }

            DispatchQueue.main.async {
                self.setupPreviewLayer()
                self.captureSession.startRunning()
            }
        }
    }

    private func setupPreviewLayer() {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            layer.insertSublayer(previewLayer, at: 0)
        }
        setupPreviewLayerFrame()
    }

    private func setupPreviewLayerFrame() {
        previewLayer?.frame = bounds
    }

    private func setupScanningRect() {
        if scanningRectView.superview == nil {
            addSubview(scanningRectView)
        }

        let scanningRectSize: CGFloat = 200
        let xPos = (bounds.width - scanningRectSize) / 2
        let yPos = (bounds.height - scanningRectSize) / 2
        scanningRectView.frame = CGRect(x: xPos, y: yPos, width: scanningRectSize, height: scanningRectSize)
    }

    func resetScanner() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
}

extension CameraView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.stopRunning()
        }

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            DispatchQueue.main.async {
                self.delegate?.didFindCode(code: stringValue)
            }
        } else {
            DispatchQueue.main.async {
                self.delegate?.didFailToFindCode()
            }
        }
    }
}
