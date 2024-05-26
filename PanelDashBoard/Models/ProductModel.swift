//
//  ProductModel.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 26/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation

struct Product {
    let barCode: String
    let barCodePictureUrl: URL?
    
    init?(dictionary: NSDictionary) {
        guard let barCode = dictionary["barCode"] as? String,
              let barCodePictureUrlString = dictionary["barCodePictureUrl"] as? String,
              let barCodePictureUrl = URL(string: barCodePictureUrlString) else {
            return nil
        }
        
        self.barCode = barCode
        self.barCodePictureUrl = barCodePictureUrl
    }
}
