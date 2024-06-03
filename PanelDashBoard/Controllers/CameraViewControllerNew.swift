//
//  CameraViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 27/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewControllerNew : UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var backBtn: UIButton!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCaptureVideoDataOutput!
    var capturedImages: [UIImage] = []
    var product : ProductToUpload?
    var takeMultiImage = false
    let PosterizeFilter = CIFilter(name: "CIColorPosterize", parameters: ["inputLevels" : 5])
    var captureImage: Bool = false
    var ciContext: CIContext!
    var filter: CIFilter!
    var filteredImageView: UIImageView!

    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "takeImageIcon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        return button
    }()

    let tickButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "tick"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(proceedToNextScreen), for: .touchUpInside)
        return button
    }()

    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt.fill"), for: .normal) // Use an appropriate icon for flash
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupCamera()
        addObservers()
        backBtn.layer.zPosition = 10
    }

    deinit {
        removeObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: captureSession)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: captureSession)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: captureSession)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: captureSession)
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        var camera: AVCaptureDevice?

        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            camera = backCamera
            print("Back camera accessed")
        } else if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            camera = frontCamera
            print("Back camera is not available, accessing front camera")
        }

        guard let camera else { return }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            photoOutput = AVCaptureVideoDataOutput()
            photoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)
                setupLivePreview()
            }
        } catch let error {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }

    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        view.layer.addSublayer(videoPreviewLayer)

        filteredImageView = UIImageView(frame: view.bounds)
        filteredImageView.contentMode = .scaleAspectFill
        view.addSubview(filteredImageView)

        ciContext = CIContext()
        filter = CIFilter(name: "CISepiaTone")
        filter.setValue(0.8, forKey: kCIInputIntensityKey)

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                strongSelf.setupVideoPreviewLayerFrame()
                strongSelf.setupUI()
            }
        }
    }

    private func setupVideoPreviewLayerFrame() {
        let sideLength = min(view.bounds.width, view.bounds.height)
        let squareFrame = CGRect(
            x: (view.bounds.width - sideLength) / 2,
            y: (view.bounds.height - sideLength) / 2,
            width: sideLength,
            height: sideLength
        )
        videoPreviewLayer.frame = squareFrame
        filteredImageView.frame = squareFrame
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        // Correct the orientation of the CIImage
        let orientation = connection.videoOrientation
        let transform = CGAffineTransform(rotationAngle: angleForVideoOrientation(orientation))
        ciImage = ciImage.transformed(by: transform)

        // Apply the filter
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputImage = filter.outputImage,
              let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else { return }

        let filteredUIImage = UIImage(cgImage: cgImage)
        DispatchQueue.main.async { [weak self] in
            self?.filteredImageView.image = filteredUIImage

        }

        if captureImage {
            self.capturedImages.append(filteredUIImage)
            captureImage = false
            DispatchQueue.main.async { [weak self] in
                self?.thumbnailImageView.image = filteredUIImage
            }
            if !takeMultiImage{
                proceedToNextScreen()
            }
        }
    }

    private func angleForVideoOrientation(_ orientation: AVCaptureVideoOrientation) -> CGFloat {
        switch orientation {
        case .portrait:
            return 0
        case .portraitUpsideDown:
            return .pi
        case .landscapeRight:
            return -.pi / 2
        case .landscapeLeft:
            return .pi / 2
        @unknown default:
            return 0
        }
    }

    func setupUI() {
        view.addSubview(captureButton)
        view.addSubview(tickButton)
        view.addSubview(thumbnailImageView)
        view.addSubview(flashButton)

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),

            tickButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            tickButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),

            thumbnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            thumbnailImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 50),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 50),

            flashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flashButton.widthAnchor.constraint(equalToConstant: 30),
            flashButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        thumbnailImageView.isHidden = true
    }

    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else { return }
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error.localizedDescription)")

        // If the media services were reset, stop and restart the session
        if error.code == .mediaServicesWereReset {
            captureSession?.startRunning()
        } else {
            // Handle other errors
        }
    }

    @objc func sessionWasInterrupted(notification: NSNotification) {
        print("Capture session was interrupted")

        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVCaptureSessionInterruptionReasonKey] as? NSNumber,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonValue.intValue) else {
            return
        }

        switch reason {
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            // Video device is not available with multiple foreground apps
            print("Video device is not available with multiple foreground apps")

        case .videoDeviceInUseByAnotherClient:
            // Video device is in use by another client
            print("Video device is in use by another client")

        case .audioDeviceInUseByAnotherClient:
            // Audio device is in use by another client
            print("Audio device is in use by another client")

        case .videoDeviceNotAvailableDueToSystemPressure:
            // Video device is not available due to system pressure
            print("Video device is not available due to system pressure")

        @unknown default:
            print("Capture session was interrupted for an unknown reason")
        }

        // Restart the session after a delay to give time for the interruption to resolve
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.captureSession.startRunning()
                }
            }
        }
    }

    @objc func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        // Handle end of interruption, e.g., restart session if needed
    }

    @objc func capturePhoto() {
        captureImage = true
        thumbnailImageView.isHidden = false
    }

    @objc func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            device.unlockForConfiguration()
        } catch {
            print("Flash could not be used")
        }
    }

    @objc func proceedToNextScreen() {
        product?.images = self.capturedImages
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let imageEditVC = storyboard.instantiateViewController(withIdentifier: "ImageEnchanceViewController") as? ImageEnchanceViewController {
            imageEditVC.capturedImages = self.capturedImages
            imageEditVC.product = self.product
            self.navigationController?.pushViewController(imageEditVC, animated: true)
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard let imageData = photo.fileDataRepresentation(), let fullImage = UIImage(data: imageData) else {
//            return
//        }
//
//        let croppedImage = cropToSquare(image: fullImage)
//        capturedImages.append(croppedImage)
//        thumbnailImageView.image = croppedImage
//        if !takeMultiImage{
//            proceedToNextScreen()
//        }
//
//    }
//
//    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
//    {
//        guard let filter = PosterizeFilter else
//        {
//            return
//        }
//
//        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
//
//        filter.setValue(cameraImage, forKey: kCIInputImageKey)
//
//        let filteredImage = UIImage(ciImage: filter.value(forKey: kCIOutputImageKey) as! CIImage!)
//        debugPrint("Filter images")
//        if self.captureImage {
//            capturedImages.append(filteredImage)
//            thumbnailImageView.image = filteredImage
//        }
//    }

    private func cropToSquare(image: UIImage) -> UIImage {
        let sideLength = min(image.size.width, image.size.height)
        let xOffset = (image.size.width - sideLength) / 2
        let yOffset = (image.size.height - sideLength) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
