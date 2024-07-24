//
//  ReviewProductsViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 02/06/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit
import OpalImagePicker
import AVFoundation
import Vision
import AWSS3
import AWSCore
import AWSCognito
import Alamofire
import SVProgressHUD
import PhotosUI

class ReviewProductsViewController: UIViewController {
    
    var allProducts = [ProductToUpload]()
    var AWSUploadcount = 0
    var imageeUrl : String?
    var scanedBarcode : String?
    var storageCode : String?

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
    
    @IBAction func scanPressed(_ sender: Any) {
        let viewController = BarcodeScannerViewController()
        viewController.cameraViewController.barCodeFocusViewType = .animated
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.isOneTimeSearch = false
        viewController.messageViewController.regularTintColor = .black
        viewController.messageViewController.errorTintColor = .red
        viewController.messageViewController.textLabel.textColor = .black
        viewController.headerViewController.titleLabel.text = "Scan item barcode"
        viewController.headerViewController.closeButton.tintColor = .red
        present(viewController, animated: false, completion: nil)
    }
    
    
    @IBAction func uploadPressed(_ sender: Any) {
        
        
        if storageCode == nil{
            let alertController = UIAlertController(title: "Alert", message: "Please scan code First", preferredStyle: .alert)
            let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            } )
            alertController.addAction(alertbutton)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        print("Upload to aws")
        SVProgressHUD.show()
        guard let BarCodePrefix = UserDefaults.standard.value(forKey: "BarCodePrefix") else{
            return
        }
        if(self.allProducts.count < 1 ){
            
            let alertController = UIAlertController(title: "Alert", message: "Please Choose Image First", preferredStyle: .alert)
            let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            } )
            alertController.addAction(alertbutton)
            self.present(alertController, animated: true, completion: nil)
        }else{
            let prefix = BarCodePrefix as! String
            var newarraybarcode:[String] = []
            for i in 0..<self.allProducts.count{
                
                if(self.allProducts[i].barcode!.contains(prefix)){
                    
                    newarraybarcode.append(self.allProducts[i].barcode!)
                    
                }else{
                    
                    newarraybarcode.append("\(prefix)\(self.allProducts[i].barcode!)")
                }
               
                
                
           }
            let uniqueElements = newarraybarcode.uniqueElements()
            
            for i in 0..<uniqueElements.count{
                var index = 0
                for j in 0..<self.allProducts.count{
                    
                    if(self.allProducts[j].barcode == uniqueElements[i]){
                        if(self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-").count > 1){
                            if(index == 0){
                                index = Int((self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 1
                                self.allProducts[j].barCodeURLPostFix = "-\(Int((self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 1)"
                            }
                            else if(index == 1){
                                if(Int((self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! == 0){
                                    index = Int((self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 2
                                    self.allProducts[j].barCodeURLPostFix = "-\(Int((self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 2)"
                                }else{
                                    index = Int((self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + index
                                    self.allProducts[j].barCodeURLPostFix = "-\(Int((self.allProducts[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + index)"
                                }
                               
                            }else{
                                
                                index = index + 1
                                self.allProducts[j].barCodeURLPostFix = "-\(index)"
                            }
                        }
                       
                       
                    }
                }
            }
            
            //For counting Scanned Pictures We have
            
            for (i,item) in self.allProducts.enumerated()
            {
                if(item.status == "Scanned")
                {
                    self.AWSUploadcount = self.AWSUploadcount + 1
                }
            }
            
            
            
             for (i,item) in self.allProducts.enumerated()
             {
                 if(item.status == "Scanned")
                 {
                    
                     if(self.allProducts[i].barcode!.contains("\(BarCodePrefix)")){
                         self.allProducts[i].barcode = self.allProducts[i].barcode!.replacingOccurrences(of: "\(BarCodePrefix)", with: "")
                         
                         UploadImageToAws(withImage: self.allProducts[i].images.first!,barCode: self.allProducts[i].barcode!, index: self.allProducts[i].barCodeURLPostFix)
                     }else{
                         UploadImageToAws(withImage: self.allProducts[i].images.first!,barCode: self.allProducts[i].barcode!, index: self.allProducts[i].barCodeURLPostFix)
                     }
                   
                 }
             }
            
        }
       
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func UploadImageToAws(withImage image: UIImage,barCode:String,index:String) {
        
        guard let S3BudketID = UserDefaults.standard.value(forKey: "S3BudketID") else{
            return
        }
        guard let AccessKeyAWS = UserDefaults.standard.value(forKey: "AccessKeyAWS") else {
            return
        }
        guard let SecretKeyAWS = UserDefaults.standard.value(forKey: "SecretKeyAWS") else {
            return
        }
        
        
        let access = AccessKeyAWS
        let secret = SecretKeyAWS
        let credentials = AWSStaticCredentialsProvider(accessKey: access as! String, secretKey: secret as! String)

        let configuration = AWSServiceConfiguration(region: AWSRegionType.EUWest3, credentialsProvider: credentials)

        AWSServiceManager.default().defaultServiceConfiguration = configuration

       // let compressedImage = image.resizedImage(newSize: CGSize(width: 500, height: 500))
        let data: Data = image.jpegData(compressionQuality: 1.0)!
        //let data : Data = image.pngData()!
        let remoteName = barCode+"\(index)."+data.format
        print("REMOTE NAME : ",remoteName)

        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, progress) in
            DispatchQueue.main.async(execute: {
                // Update a progress bar
            })
        }

       var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
            })
        }

        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(data, bucket: S3BudketID as! String, key: remoteName, contentType: "image/"+data.format, expression: expression, completionHandler: completionHandler).continueWith { [self] (task) -> Any? in
            
            AWSUploadcount = AWSUploadcount - 1
            if let error = task.error {
                print("Error : \(error.localizedDescription)")
                
            }
            

            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(S3BudketID as! String).appendingPathComponent(remoteName)
                if let absoluteString = publicURL?.absoluteString {
                    // Set image with URL
                    if(imageeUrl == nil){
                        imageeUrl = absoluteString
                        scanedBarcode = barCode
                    }else{
                        imageeUrl?.append(",\(absoluteString)")
                        scanedBarcode?.append(",\(barCode)")
                    }
                    print("Image URL : ",absoluteString)
                    print(imageeUrl)
                }
            }
            if(AWSUploadcount == 0 && self.imageeUrl != nil && self.imageeUrl != ""){
                
                self.uploadtoGoogleSheet()
            }

            return nil
        }

    }
    
    
    func uploadtoGoogleSheet(){
        
        guard let SheetID = UserDefaults.standard.value(forKey: "SheetID") else {
            return
        }
        guard let SheetName = UserDefaults.standard.value(forKey: "SheetName") else {
            return
        }
        guard let StartingColumn = UserDefaults.standard.value(forKey: "StartingColumn") else {
           return
        }
        guard let EndingColumn = UserDefaults.standard.value(forKey: "EndingColumn") else {
            return
        }
        guard let BarCodePrefix = UserDefaults.standard.value(forKey: "BarCodePrefix") else {
           return
        }
        guard let BaseURL = UserDefaults.standard.value(forKey: "BaseURL") else {
            return
        }
        
        
        RemoteRequest.requestPostURL("\(BaseURL)\(Constant.helperURL)" , params: ["action": Constant.updateGoogleSheet,"pictureUrl":self.imageeUrl!,"spreadSheetId":SheetID,"sheetName":SheetName,"barCodeSearchColumn":"\(StartingColumn):\(EndingColumn)","barCode":self.scanedBarcode!,"preFix":BarCodePrefix], success: { response in
           
            SVProgressHUD.dismiss()
            let alertController = UIAlertController(title: "Sucess", message: "Google Sheet Updated Sucessfully", preferredStyle: .alert)
            let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                ProductImageManager.shared.removeAllProducts()
                //self.navigationController?.popViewController(animated: true)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "CustomTabBarController") as! MyTabBarController
                mainTabBarController.selectedIndex = 1
                // Set the tab bar controller as the root view controller
                UIApplication.shared.windows.first?.rootViewController = mainTabBarController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
               
            } )
            alertController.addAction(alertbutton)
            self.present(alertController, animated: true, completion: nil)
           print("Okay")
       
       }){ error in
           SVProgressHUD.dismiss()
       }
        
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
        cell.productName.text = product.barcode
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
            //detailsVC.showbtnOptions = false
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}


extension ReviewProductsViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        appDelegate?.scannedItems.append(code)
        let unique = appDelegate?.scannedItems.uniqued()
        appDelegate?.scannedItems = unique ?? []
        //manageSaveItemButton()
        storageCode = code
    }
}

extension ReviewProductsViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension ReviewProductsViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
       //manageSaveItemButton()
    }
}
