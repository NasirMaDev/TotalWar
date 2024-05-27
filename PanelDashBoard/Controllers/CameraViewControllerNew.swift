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

    var captureSession: AVCaptureSession!
       var videoPreviewLayer: AVCaptureVideoPreviewLayer!
       var photoOutput: AVCapturePhotoOutput!
       var capturedImages: [UIImage] = []

       let captureButton: UIButton = {
           let button = UIButton(type: .system)
           button.tintColor = .white
           button.backgroundColor = .blue
           button.layer.cornerRadius = 35
           button.translatesAutoresizingMaskIntoConstraints = false
           button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
           return button
       }()

       let tickButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("✔️", for: .normal)
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
           setupUI()
       }

       func setupCamera() {
           captureSession = AVCaptureSession()
           captureSession.sessionPreset = .photo

           guard let backCamera = AVCaptureDevice.default(for: .video) else {
               print("Unable to access back camera!")
               return
           }

           do {
               let input = try AVCaptureDeviceInput(device: backCamera)
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

           DispatchQueue.global(qos: .userInitiated).async { [weak self] in
               self?.captureSession.startRunning()
               DispatchQueue.main.async {
                   self?.videoPreviewLayer.frame = self?.view.bounds ?? CGRect.zero
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

               tickButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
               tickButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),

               thumbnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               thumbnailImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
               thumbnailImageView.widthAnchor.constraint(equalToConstant: 50),
               thumbnailImageView.heightAnchor.constraint(equalToConstant: 50)
           ])
       }

       @objc func capturePhoto() {
           let settings = AVCapturePhotoSettings()
           photoOutput.capturePhoto(with: settings, delegate: self)
       }

       @objc func proceedToNextScreen() {
//           let nextVC = NextViewController()
//           nextVC.capturedImages = self.capturedImages
//           nextVC.hidesBottomBarWhenPushed = true // Hide the tab bar
//           self.navigationController?.pushViewController(nextVC, animated: true)
       }

    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
           if let imageData = photo.fileDataRepresentation() {
               if let image = UIImage(data: imageData) {
                   capturedImages.append(image)
                   thumbnailImageView.image = image
               }
           }
       }
   }
