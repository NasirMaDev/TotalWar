//
//  AddProductsViewController.swift
//  PanelDashBoard
//
//  Createdvar Asjd on 09/11/2021.
//  Copyright © 2021 AsjvarAll rights reserved.
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

struct ProductImage{
    var image : UIImage?
    var status : String?
    var barcode : String? = ""
    var ismatchbarcode : Bool = false
    var barCodeURLPostFix: String = ""
}

@available(iOS 13.0, *)
class AddProductsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,OpalImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
   
    
    var reploadIndex = 0

    var AWSUploadcount = 0

    var productImages :[ProductImage] = []
    
    @IBOutlet weak var reuploadStatus: UILabel!
    @IBOutlet weak var uploadtoaws: UIButton!
    
    @IBOutlet weak var urllabel: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var selectphotoview: UIView!
    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    @IBOutlet weak var cacelBtn: UIButton!
    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var uploadbtn: UIButton!
   

    var imagesarray : [UIImage]?
    var imageeUrl : String?
    var scanedBarcode : String?
    
    
    var barcodesArray : [String] = []
    var barcodesImagesArray : [String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Products"
  
      
        selectphotoview.isHidden = true
        collectionview.delegate = self
        collectionview.dataSource = self
        reuploadStatus.isHidden = true
       
        CornerRadius()
        searchBarCodeInGSheet()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    func CornerRadius(){
        
        selectphotoview.layer.cornerRadius = 15
        uploadbtn.layer.cornerRadius = 15
        uploadtoaws.layer.cornerRadius = 15

    }
    
    @IBAction func removeItemPressed(_ sender: UIButton) {
        print("Remove Pressed")
        
        let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to remove this Item", preferredStyle: .alert)
        let alertbutton = UIAlertAction(title: "YES", style: .default, handler:{(action: UIAlertAction!) in
            self.productImages.remove(at: sender.tag)
            self.imagesarray?.remove(at: sender.tag)
            self.barcodesArray.remove(at: sender.tag)
            self.barcodesImagesArray.remove(at: sender.tag)
            self.collectionview.reloadData()
            self.dismiss(animated: true, completion: nil)
        } )
        let alertbutton2 = UIAlertAction(title: "NO", style: .cancel, handler:{(action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        } )
        alertController.addAction(alertbutton)
        alertController.addAction(alertbutton2)
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func ReuploadPressed(_ sender: UIButton) {
        print("Add Pressed")
        guard let BarCodePrefix:String = UserDefaults.standard.value(forKey: "BarCodePrefix") as? String else{
            return
        }
        
        let alert = UIAlertController(title: "Add Barcode", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = BarCodePrefix
            textField.autocapitalizationType = .allCharacters

        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(textField!.text ?? "")")
            
            
            if((textField?.text?.contains(BarCodePrefix))!){
                self.productImages[sender.tag].barcode = textField?.text!
            }else{
                self.productImages[sender.tag].barcode = "\(BarCodePrefix)\((textField?.text!)!)"
            }
            
           
            let status = self.isBarCodePresentInArray(barCode: (textField?.text)!, IsBarCodeScan: false)
           
            
            if(status.0 == true){
                if(self.productImages[sender.tag].status == "Scanned"){
                    
                }else{
                   // self.AWSUploadcount = self.AWSUploadcount + 1
                }
               
                self.productImages[sender.tag].ismatchbarcode = true
                self.productImages[sender.tag].barCodeURLPostFix = status.1
                self.productImages[sender.tag].status = "Scanned"
            }
            DispatchQueue.main.async {
                self.collectionview.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
     
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
               
                self.navigationController?.popViewController(animated: true)
               
            } )
            alertController.addAction(alertbutton)
            self.present(alertController, animated: true, completion: nil)
           print("Okay")
       
       }){ error in
       
           SVProgressHUD.dismiss()
       }
        
    }
    
    
    func searchBarCodeInGSheet(){
        SVProgressHUD.show()
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
        guard let BaseURL = UserDefaults.standard.value(forKey: "BaseURL") else {
            return
        }

        RemoteRequest.requestPostURL("\(BaseURL)\(Constant.helperURL)", params: ["action":Constant.getSheetsProducts,"spreadSheetId":SheetID,"sheetName":SheetName,"barCodeSearchColumn":"\(StartingColumn):\(EndingColumn)"], success: { response in
             
                print(response)
            self.barcodesArray = (response as AnyObject).value(forKey: "allProducts") as! [String]
            self.barcodesImagesArray = (response as AnyObject).value(forKey: "allProductsUrlPostFix") as! [String]
            
           
            
            SVProgressHUD.dismiss()
                    
                }) { error in
                    
                }
         
    }
    
    func isBarCodePresentInArray(barCode:String,IsBarCodeScan:Bool)-> (Bool,String){
      
        guard let BarCodePrefix = UserDefaults.standard.value(forKey: "BarCodePrefix") else {
           return (false,"")
        }
       
        if(IsBarCodeScan == true){
            for i in 0..<barcodesArray.count{
                
                if(barCode.contains("\(BarCodePrefix)")){
                    if(barcodesArray[i] == barCode){
                       
                        return (true,barcodesImagesArray[i])
                    }
                }else{
                    if(barcodesArray[i] == "\(BarCodePrefix)\(barCode)"){
                       
                        return (true,barcodesImagesArray[i])
                    }
                }
            }
        }else{
            
            for i in 0..<barcodesArray.count{
                
                if(barCode.contains("\(BarCodePrefix)")){
                    if(barcodesArray[i] == barCode){
                       
                        return (true,barcodesImagesArray[i])
                    }
                }else{
                    if(self.barcodesArray[i] == "\(BarCodePrefix)\(barCode)"){
                       
                        return (true,barcodesImagesArray[i])
                    }
                }
               
            }
            
        }
        
        return (false,"")
    }
    
    func fetchCoreDataImage(){
        
        let appDe = (UIApplication.shared.delegate) as! AppDelegate
                let context = appDe.persistentContainer.viewContext
                do{
                    let cData = try context.fetch(ImageData.fetchRequest())
                    print("Data has been fetched successfully")
                    for duduobj in cData{
                        print(duduobj.imagedata ?? "")
                    }
                }
                catch

                   {
                        print("Eroor Occured while data saving")
        
                        
                    }
    }

    func scanwithBarCode(){

        guard let BarCodePrefix:String = UserDefaults.standard.value(forKey: "BarCodePrefix") as? String else{
            return
        }
        
        SVProgressHUD.show()
        for (index,item) in imagesarray!.enumerated() {
            
            createVisionRequest(image: item, index: index, callback: { [self]status,ind,symb  in
                print("\(status) \(ind) \(symb)")
                
                if(status == "Not Scanned"){
                    self.scanwithText(item: item, index: index)
        
                }else{
                    if(ind == imagesarray!.count - 1){
                        SVProgressHUD.dismiss()
                    }
                    self.productImages[ind].status = status
                    
                    if(symb.contains(BarCodePrefix)){
                        self.productImages[ind].barcode = symb
                    }else{
                        self.productImages[ind].barcode = "\(BarCodePrefix)\(symb)"
                    }
                  
                    
                    let status = self.isBarCodePresentInArray(barCode: symb, IsBarCodeScan: false)
                   
                    if(status.0 == true){
                       // AWSUploadcount = AWSUploadcount + 1
                        self.productImages[ind].ismatchbarcode = true
                        self.productImages[ind].barCodeURLPostFix = status.1
                    }
                    
                }
                DispatchQueue.main.async {
                    self.collectionview.reloadData()
                    
                }
                

            })

        }
        
    }
    
    func scanwithText(item: UIImage, index:Int){
        
        guard let BarCodePrefix:String = UserDefaults.standard.value(forKey: "BarCodePrefix") as? String else{
            return
        }
        
       // SVProgressHUD.show()
            createTextRequest(image: item, index: index, callback: { [self]status,ind,symb  in
                print("\(status) \(ind) \(symb)")
                
                if(status == "Not Scanned"){
                    if(ind == imagesarray!.count - 1){
                        SVProgressHUD.dismiss()
                    }
                }else{
                    if(ind == imagesarray!.count - 1){
                        SVProgressHUD.dismiss()
                    }
                    self.productImages[ind].status = status
                    if(symb.contains(BarCodePrefix)){
                        self.productImages[ind].barcode = symb
                    }else{
                        self.productImages[ind].barcode = "\(BarCodePrefix)\(symb)"
                    }
                  
                    
                    let status = self.isBarCodePresentInArray(barCode: symb, IsBarCodeScan: false)
                   
                    
                    if(status.0 == true){
                        //AWSUploadcount = AWSUploadcount + 1
                        self.productImages[ind].ismatchbarcode = true
                        self.productImages[ind].barCodeURLPostFix = status.1
                    }
                      
                }
                DispatchQueue.main.async {
                    self.collectionview.reloadData()
                }
            })

    }
  
   
    @IBAction func uploadawsPressed(_ sender: Any) {
        print("Upload to aws")
        SVProgressHUD.show()
        guard let BarCodePrefix = UserDefaults.standard.value(forKey: "BarCodePrefix") else{
            return
        }
        if(self.productImages.count < 1 ){
            
            let alertController = UIAlertController(title: "Alert", message: "Please Choose Image First", preferredStyle: .alert)
            let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            } )
            alertController.addAction(alertbutton)
            self.present(alertController, animated: true, completion: nil)
        }else{
            
             
           
            let prefix = BarCodePrefix as! String
            var newarraybarcode:[String] = []
            for i in 0..<self.productImages.count{
                
                if(self.productImages[i].barcode!.contains(prefix)){
                    
                    newarraybarcode.append(self.productImages[i].barcode!)
                    
                }else{
                    
                    newarraybarcode.append("\(prefix)\(self.productImages[i].barcode!)")
                }
               
                
                
           }
            let uniqueElements = newarraybarcode.uniqueElements()
            
            for i in 0..<uniqueElements.count{
                var index = 0
                for j in 0..<self.productImages.count{
                    
                    if(self.productImages[j].barcode == uniqueElements[i]){
                        if(self.productImages[j].barCodeURLPostFix.components(separatedBy: "-").count > 1){
                            if(index == 0){
                                index = Int((self.productImages[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 1
                                self.productImages[j].barCodeURLPostFix = "-\(Int((self.productImages[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 1)"
                            }
                            else if(index == 1){
                                if(Int((self.productImages[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! == 0){
                                    index = Int((self.productImages[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 2
                                    self.productImages[j].barCodeURLPostFix = "-\(Int((self.productImages[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + 2)"
                                }else{
                                    index = Int((self.productImages[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + index
                                    self.productImages[j].barCodeURLPostFix = "-\(Int((self.productImages[j].barCodeURLPostFix.components(separatedBy: "-")[1]))! + index)"
                                }
                               
                            }else{
                                
                                index = index + 1
                                self.productImages[j].barCodeURLPostFix = "-\(index)"
                            }
                        }
                       
                       
                    }
                }
            }
            
            //For counting Scanned Pictures We have
            
            for (i,item) in self.productImages.enumerated()
            {
                if(item.status == "Scanned")
                {
                    self.AWSUploadcount = self.AWSUploadcount + 1
                }
            }
            
            
            
             for (i,item) in self.productImages.enumerated()
             {
                 if(item.status == "Scanned")
                 {
                    
                     if(self.productImages[i].barcode!.contains("\(BarCodePrefix)")){
                         self.productImages[i].barcode = self.productImages[i].barcode!.replacingOccurrences(of: "\(BarCodePrefix)", with: "")
                         
                         UploadImageToAws(withImage: self.productImages[i].image!,barCode: self.productImages[i].barcode!, index: self.productImages[i].barCodeURLPostFix)
                     }else{
                         UploadImageToAws(withImage: self.productImages[i].image!,barCode: self.productImages[i].barcode!, index: self.productImages[i].barCodeURLPostFix)
                     }
                   
                 }
             }
            
        }
       
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
    
    
    @IBAction func uploadPressed(_ sender: Any) {
        selectphotoview.isHidden = false
    }
    
    @available(iOS 14, *)
    @IBAction func galleryPressed(_ sender: Any) {
        print("photolibrary Pressed")
        
        var configure: PHPickerConfiguration = PHPickerConfiguration()
        configure.filter = PHPickerFilter.images
        configure.selectionLimit = 30
        
        let imagePicker: PHPickerViewController = PHPickerViewController(configuration: configure)
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
        
        
        
//        var imagePicker: OpalImagePickerController!
//        imagePicker = OpalImagePickerController()
//        imagePicker.imagePickerDelegate = self as OpalImagePickerControllerDelegate
//        imagePicker.selectionImage = UIImage(named: "aCheckImg")
//        imagePicker.maximumSelectionsAllowed = 30 // Number of selected images
//        present(imagePicker, animated: true, completion: nil)
     
    }
 @IBAction func cameraPressed(_ sender: Any) {
        print("camera Pressed")
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Alright", style: .default, handler: { (alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let mypickercontroller = UIImagePickerController()
            mypickercontroller.delegate = self
            mypickercontroller.sourceType = UIImagePickerController.SourceType.camera
            self.present(mypickercontroller, animated: true, completion: nil)
        }
      
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        selectphotoview.isHidden = true
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectphotoview.isHidden = true
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageview.image = image
        if(imagesarray == nil || imagesarray!.count < 1 || productImages.count < 1 ){
            
            imagesarray = [image!]
            let productImage = ProductImage(image: UIImage(data: image!.jpegData(compressionQuality: 0.5)!), status: "")
            productImages.append(productImage)
        }else{
            
//            if((imagesarray!.count - 1) <= reploadIndex){
//                imagesarray?[reploadIndex] = image!
//                productImages[reploadIndex].image = image
//            }
//            else{
                imagesarray?.append(image!)
            let productImage = ProductImage(image: UIImage(data: image!.jpegData(compressionQuality: 0.3)!), status: "")
                productImages.append(productImage)
           // }
            
        }
       
        collectionview.reloadData()
        //self.AWSUploadcount = 0
        self.scanwithBarCode()
        
        self.dismiss(animated: true, completion: nil)
    
    }
  
    
}
extension UIImage {

  func resizedImage(newSize: CGSize) -> UIImage {
    guard self.size != newSize else { return self }

    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
   }

 }

extension Data {

  var format: String {
    let array = [UInt8](self)
    let ext: String
    switch (array[0]) {
    case 0xFF:
        ext = "jpg"
    case 0x89:
        ext = "png"
    case 0x47:
        ext = "gif"
    case 0x49, 0x4D :
        ext = "tiff"
    default:
        ext = "unknown"
    }
    return ext
   }

}

@available(iOS 13.0, *)
extension AddProductsViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell:ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ImageCollectionViewCell

        cell.image.image = productImages[indexPath.row].image
        cell.barcode.text! = self.productImages[indexPath.row].barcode ?? ""
        cell.reuploadBtn.tag = indexPath.row
        cell.removeItem.tag = indexPath.row
       // cell.reuploadBtn.isHidden = true
       // cell.removeItem.isHidden = true
        
    
        if self.productImages[indexPath.row].status == "Scanned"{
        
            cell.iconimage.image = UIImage(named: "check")
            //cell.reuploadBtn.isHidden = true
           // cell.removeItem.isHidden = true
            
        }else{
            
            cell.iconimage.image = UIImage(named: "decline")
           // cell.reuploadBtn.isHidden = false
            //cell.removeItem.isHidden = false
        }
        
        if(productImages[indexPath.row].ismatchbarcode == true){
            
            cell.googlesheetsearchstatus.text = "Present in Sheet"
        }else{
            
            cell.googlesheetsearchstatus.text = "Missing in Sheet"
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
   
        imageview.image = imagesarray![indexPath.item]
        
        scanedBarcode = productImages[indexPath.row].barcode
        
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 205)
    }
    
}

extension Array where Element: Hashable {
  func uniqueElements() -> [Element] {
    var seen = Set<Element>()
    var out = [Element]()

    for element in self {
      if !seen.contains(element) {
        out.append(element)
        seen.insert(element)
      }
    }

    return out
  }
}

@available(iOS 14.0, *)
extension AddProductsViewController:PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        dismiss(animated: true, completion: nil)
        if(results.count > 0){
            SVProgressHUD.show()
        }
        selectphotoview.isHidden = true
        var count = results.count
        
        
        for item in results{
            
            item.itemProvider.loadObject(ofClass: UIImage.self) { (image,error) in
                
                if let image = image as? UIImage{
                    let productImage = ProductImage(image: UIImage(data: image.jpegData(compressionQuality: 0.3)!), status: "")
                    
                    self.productImages.append(productImage)
                    if(self.imagesarray == nil || self.imagesarray?.count == 0){
                        self.imagesarray = [image]
                    }else{
                        self.imagesarray?.append(image)
                    }
                    count = count - 1
                    if(count <= 0){
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.collectionview.reloadData()
                            //self.AWSUploadcount = 0
                            self.scanwithBarCode()
                        }
                       
                    }
                    //print(image)
                }
            }
        }
        
       
        
    }
    
    
    
}
