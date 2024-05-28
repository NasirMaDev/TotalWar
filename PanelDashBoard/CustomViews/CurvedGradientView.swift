//
//  CurvedViewTop.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 28/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CurvedGradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    @IBInspectable var startColor: UIColor = UIColor(red: 0.38, green: 0.69, blue: 1, alpha: 1) {
        didSet {
            updateGradientColors()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor(red: 0.525, green: 0.322, blue: 1, alpha: 1) {
        didSet {
            updateGradientColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }
    
    private func setupGradientLayer() {
        updateGradientColors()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradientLayer)
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        applyMask()
    }
    
    private func applyMask() {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        
        // Customize the path to match the desired shape
        path.move(to: CGPoint(x: 0, y: height * 1)) // Adjusted Y value for the curve start
        path.addCurve(to: CGPoint(x: width, y: height * 0.4), // Adjusted control points for a smoother curve
                      controlPoint1: CGPoint(x: width * 0.1, y: height * 0.4),
                      controlPoint2: CGPoint(x: width , y: height * 1.2))
        path.addLine(to: CGPoint(x: width * 1.3, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        gradientLayer.mask = shapeLayer
    }
}
