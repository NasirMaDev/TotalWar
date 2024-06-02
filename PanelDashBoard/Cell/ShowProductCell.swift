//
//  ShowProductCell.swift
//  PanelDashBoard
//
//  Created by SilentSol PVT LTD on 29/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import UIKit

class ShowProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBarCode:UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var deletebtn: UIButton!
    
    var deleteAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (deletebtn != nil){
            deletebtn.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
    
}
