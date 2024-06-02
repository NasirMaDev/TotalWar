//
//  ImageEditViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 29/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit

class ImageEditViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet var editOptionBtns: [UIButton]!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionSlider: UISlider!
    @IBOutlet weak var sliderValue: UILabel!
    var image : UIImage?
    var currentBrightness = 50.0
    var currentExposure = 50.0
    var currentSaturation = 50.0
    var filter: CIFilter? = CIFilter(name: "CIColorControls")
    
    var completionHandler: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image {
            self.imageToEdit.image = image
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {

        // Create the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.38, green: 0.69, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.525, green: 0.322, blue: 1, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0) // Start at the top center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1) // End at the bottom center

        // Add the gradient layer to the view
        DispatchQueue.main.async {
            self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
            gradientLayer.frame = self.gradientView.bounds
            self.backBtn.layer.zPosition = 10
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update the gradient layer's frame to match the gradientView's bounds
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientView.bounds
        }
    }


    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func editOptionTapped(_ sender: UIButton) {
        for button in editOptionBtns {
            button.isSelected = false
        }

        // Select the tapped button
        sender.isSelected = true
        switch sender.tag {
        case 1:
            optionLabel.text = "Brightness"
            sliderValue.text = "\(currentBrightness)%"
            optionSlider.value = Float(currentBrightness)
        case 2:
            optionLabel.text = "Exposure"
            sliderValue.text = "\(currentExposure)%"
            optionSlider.value = Float(currentExposure)
        case 3:
            optionLabel.text = "Saturation"
            sliderValue.text = "\(currentSaturation)%"
            optionSlider.value = Float(currentSaturation)
        default:
            optionLabel.text = ""
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let image = image else { return }
        //let beginImage = CIImage(image: image)
        
        if optionLabel.text == "Brightness" {
            sliderValue.text = "\(sender.value)%"
            currentBrightness = Double(Int(sender.value))
        } else if optionLabel.text == "Exposure" {
            sliderValue.text = "\(sender.value)%"
            currentExposure = Double(Int(sender.value))
        } else if optionLabel.text == "Saturation" {
            sliderValue.text = "\(sender.value)%"
            currentSaturation = Double(Int(sender.value))
        }
        imageToEdit.image = self.applyImageFilter(for: image)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        completionHandler?(image!)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func applyImageFilter(for image: UIImage) -> UIImage? {
        guard let sourceImage = CIImage(image: image) else { return nil }
        
        let brightnessValue = (currentBrightness - 50) / 50
        let exposureValue = (currentExposure - 50) / 50
        let saturationValue = currentSaturation / 50
        
        let brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        brightnessFilter?.setValue(brightnessValue, forKey: kCIInputBrightnessKey)
        brightnessFilter?.setValue(saturationValue, forKey: kCIInputSaturationKey)
        
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(brightnessFilter?.outputImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(exposureValue, forKey: kCIInputEVKey)
        
        guard let output = exposureFilter?.outputImage else { return nil }
        
        return UIImage(ciImage: output, scale: image.scale, orientation: image.imageOrientation)
    }

}
