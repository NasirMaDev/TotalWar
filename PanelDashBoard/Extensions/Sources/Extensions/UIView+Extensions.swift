import UIKit

extension UIView {
  /// A helper function to add multiple subviews.
  func addSubviews(_ subviews: UIView...) {
    subviews.forEach {
      addSubview($0)
    }
  }
}


@IBDesignable
extension UIView {
    
    // Corner Radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    // Border Width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    // Border Color
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    // Shadow Color
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    // Shadow Opacity
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    // Shadow Offset
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    // Shadow Radius
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
}



extension UIButton {
    
    func setGradientBackground(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)) {
        // Remove any existing gradient layers to avoid layering multiple gradients
        layer.sublayers?.forEach {
            if $0 is CAGradientLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        // Add the gradient layer to the button's layer
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        // Optional: If you need to update the gradient when the button's size changes, you can add constraints or override layoutSubviews to update the gradient layer's frame.
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient layer frame when button's layout changes
        if let gradientLayer = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = self.bounds
        }
    }
}



extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit, completion: @escaping (Result<UIImage, Error>) -> Void) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data,
                let image = UIImage(data: data)
            else {
                let error = NSError(domain: "InvalidImageData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image data"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.image = image
                completion(.success(image))
            }
        }.resume()
    }

    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: link) else {
            let error = NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL from string"])
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        downloaded(from: url, contentMode: mode, completion: completion)
    }
}
