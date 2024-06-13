//
//  ProductDetailViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 30/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var descView: UILabel!
    @IBOutlet weak var bottomStackView: UIStackView!
    var product : ProductToUpload?
    var selectedIndex : Int = 0
    //var showbtnOptions: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageCV.delegate = self
        imageCV.dataSource = self
        
        let image = product?.images[selectedIndex]
        self.selectedImage.image = image
        
//        if !showbtnOptions{
//            bottomStackView.isHidden = true
//        }
    }
    
    @IBAction func addNewProduct(_ sender: Any) {
        if let product{
            ProductImageManager.shared.addProductImage(product)
        }
        
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : ScanViewController = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func submitProduct(_ sender: Any) {
        if let product{
            ProductImageManager.shared.addProductImage(product)
        }
        
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : ReviewProductsViewController = storyboard.instantiateViewController(withIdentifier: "ReviewProductsViewController") as! ReviewProductsViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension ProductDetailViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product?.images.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (self.imageCV.dequeueReusableCell(withReuseIdentifier: "ImagesCell", for: indexPath) as? ImagesCell)!
        let image = self.product?.images[indexPath.row]
        cell.itemImage.image = image
        cell.deleteAction = {
            self.product?.images.remove(at: indexPath.row)
            
            if self.product?.images.count == 0{
                let alertController = UIAlertController(title: "Error", message: "All product images deleted", preferredStyle: .alert)
                let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                    ProductImageManager.shared.removeProductImage(at:indexPath.row)
                    self.navigationController?.popViewController(animated: true)
                } )
                alertController.addAction(alertbutton)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let image = self.product?.images[self.selectedIndex]
            self.selectedImage.image = image
            self.imageCV.reloadData()
            
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let image = product?.images[selectedIndex]
        self.selectedImage.image = image
    }

}
