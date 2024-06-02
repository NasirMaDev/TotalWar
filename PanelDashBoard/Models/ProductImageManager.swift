//
//  ProductImageManager.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 02/06/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation
import UIKit
class ProductImageManager {
    static let shared = ProductImageManager()

    private init() {}
    
    private var productImages: [ProductToUpload] = []

    // Add a product image
    func addProductImage(_ productImage: ProductToUpload) {
        productImages.append(productImage)
        saveToUserDefaults()
    }

    // Remove a product image
    func removeProductImage(at index: Int) {
        productImages.remove(at: index)
        saveToUserDefaults()
    }

    // Get all product images
    func getProducts() -> [ProductToUpload] {
        return productImages
    }

    // Save to UserDefaults
    private func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(productImages) {
            UserDefaults.standard.set(encoded, forKey: "productImages")
        }
    }

    // Load from UserDefaults
    func loadFromUserDefaults() {
        if let savedProductImages = UserDefaults.standard.object(forKey: "productImages") as? Data {
            let decoder = JSONDecoder()
            if let loadedProductImages = try? decoder.decode([ProductToUpload].self, from: savedProductImages) {
                productImages = loadedProductImages
            }
        }
    }
}


