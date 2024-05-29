//
//  CameraViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 27/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewControllerNew : UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var backBtn: UIButton!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    var capturedImages: [UIImage] = []
    var takeMultiImage = false

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
        
        guard let camera else {return}
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            photoOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)
                setupLivePreview()
            }
        } catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        view.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.videoPreviewLayer.frame = (self?.view.bounds)! //?? CGRect.zero
                self?.setupUI()
            }
        }
    }
    
    func setupUI() {
        view.addSubview(captureButton)
        view.addSubview(tickButton)
        view.addSubview(thumbnailImageView)

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
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 50)
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
            // Handle interruption, e.g., show UI message
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }

        @objc func sessionInterruptionEnded(notification: NSNotification) {
            print("Capture session interruption ended")
            // Handle end of interruption, e.g., restart session if needed
        }

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        thumbnailImageView.isHidden = false
    }

    @objc func proceedToNextScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let imageEditVC = storyboard.instantiateViewController(withIdentifier: "ImageEnchanceViewController") as? ImageEnchanceViewController {
            imageEditVC.capturedImages = self.capturedImages
            self.navigationController?.pushViewController(imageEditVC, animated: true)
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData) {
                capturedImages.append(image)
                thumbnailImageView.image = image
                if !takeMultiImage{
                    proceedToNextScreen()
                }
            }
        }
    }
}
