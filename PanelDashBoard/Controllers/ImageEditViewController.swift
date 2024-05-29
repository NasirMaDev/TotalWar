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
        case 2:
            optionLabel.text = "Filter"
        case 3:
            optionLabel.text = "Saturation"
        default:
            optionLabel.text = ""
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sliderValue.text = "\(sender.value)%"
    }
    
    
}
