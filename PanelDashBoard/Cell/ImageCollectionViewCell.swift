//
//  ImageCollectionViewCell.swift
//  PanelDashBoard
//
//  Created by Asjd on 10/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var barcode: UILabel!
    @IBOutlet weak var iconimage: UIImageView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var googlesheetsearchstatus:UILabel!
    
    @IBOutlet weak var removeItem: UIButton!
    @IBOutlet weak var reuploadBtn: UIButton!
}
