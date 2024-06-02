//
//  ReviewProductsViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 02/06/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit

class ReviewProductsViewController: UIViewController {
    
    var allProducts = [ProductToUpload]()

    @IBOutlet weak var productsCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.allProducts = ProductImageManager.shared.getProducts()
        productsCV.reloadData()
    }
    
    func deletBtnTapped(at: Int){
        self.allProducts.remove(at: at)
        productsCV.reloadData()
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        
    }
    

}

extension ReviewProductsViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell:ShowProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowProductCell", for: indexPath as IndexPath) as! ShowProductCell
        let product = self.allProducts[indexPath.row]
        cell.imgBarCode.image = product.images.first!
        cell.productName.text = "product \(indexPath.row)"
        cell.deleteAction = { [weak self] in
            self?.deletBtnTapped(at: indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = allProducts[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
            detailsVC.product = model
            detailsVC.showbtnOptions = false
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
