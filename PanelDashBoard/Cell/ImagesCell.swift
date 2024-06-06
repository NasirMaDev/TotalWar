//
//  ImagesCell.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 29/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation
import UIKit

class ImagesCell: UICollectionViewCell {
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var resetAction: (() -> Void)?
    var editAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (resetBtn != nil){
            resetBtn.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
            editBtn.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }

        if deleteBtn != nil{
            deleteBtn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        }
    }
    
    @objc private func resetButtonTapped() {
        resetAction?()
    }
    
    @objc private func editButtonTapped() {
        editAction?()
    }

    @objc private func deleteBtnTapped() {
        deleteAction?()
    }


}
