//
//  ImageEnchanceViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 27/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class ImageEnchanceViewController: UIViewController{


    @IBOutlet weak var imagesCV: UICollectionView!
    @IBOutlet weak var imagesPager: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var btnStackView: UIStackView!
    
    var imagesModel : [ProductImagesModel] = []
    var product : ProductToUpload?
    var showNextBtn = true
    var capturedImages : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = SettingsManager.shared
        
        for (index, item) in capturedImages.enumerated() {
            let isSelected = index == 0
            if settings.isInitialized{
                let enchanedImage = applyImageFilter(for: item)
                imagesModel.append(ProductImagesModel(OgImage: item, enchanedImage: enchanedImage, selected: isSelected, showOriginal: false))
            }else{
                imagesModel.append(ProductImagesModel(OgImage: item, enchanedImage: nil, selected: isSelected))
            }
        }
        
        imagesCV.isPagingEnabled = true
        imagesCV.delegate = self
        imagesCV.dataSource = self
        imagesPager.numberOfPages = imagesModel.count
        imagesPager.currentPage = 0
        btnStackView.isHidden = !showNextBtn
    }



    func createMultipartBody(parameters: [String: String], boundary: String) -> Data {
        var body = ""
        
        for (key, value) in parameters {
            body += "--\(boundary)\r\n"
            body += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
            body += "\(value)\r\n"
        }
        body += "--\(boundary)--\r\n"
        
        return body.data(using: .utf8) ?? Data()
    }
    
    func applyImageFilter(for image: UIImage) -> UIImage? {
        guard let sourceImage = CIImage(image: image) else { return nil }
        let settings = SettingsManager.shared
        let brightnessValue = (settings.currentBrightness - 50) / 50.0
        let exposureValue = (settings.currentExposure - 50) / 50.0
        let saturationValue = settings.currentSaturation / 50.0

        let brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        brightnessFilter?.setValue(brightnessValue, forKey: kCIInputBrightnessKey)
        brightnessFilter?.setValue(saturationValue, forKey: kCIInputSaturationKey)

        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(brightnessFilter?.outputImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(exposureValue, forKey: kCIInputEVKey)

        guard let output = exposureFilter?.outputImage else { return nil }

        // Convert currentAngle (0 to 100) to radians (0 to 2π)
        //let radians = Float(currentAngle) * (2 * .pi) / 100.0

        let outputImage = UIImage(ciImage: output, scale: image.scale, orientation: image.imageOrientation)

        return outputImage
    }
    
    @IBAction func enchanceWithAI(_ sender: Any) {

        if imagesModel[imagesPager.currentPage].enchanedImage != nil{
            return
        }
         //Usage
        let boundary = "---011000010111000001101001"
        let headers = [
            "x-rapidapi-key": "4f13651bb1msh2895d8696ad5e3cp14b5efjsn1913a6695fd2",
            "x-rapidapi-host": "picsart-remove-background2.p.rapidapi.com",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]

        let parameters = [
            "image": imagesModel[imagesPager.currentPage].OgImage,
            "bg_image_url": "https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L3JtMjctc2FzaS0wMi1sdXh1cnkuanBn.jpg",
            "bg_blur": "10",
            "format": "JPG"
        ] as [String : Any]


        let url = "https://picsart-remove-background2.p.rapidapi.com/removebg"
        SVProgressHUD.show()
        RemoteRequest.requestPostURL(url, headers: headers, params: parameters, success: { response in
            print("Response: \(response)")
            if let urlString = response as? String{
                let imageView = UIImageView()
                imageView.downloaded(from: urlString, contentMode: .scaleAspectFit) { result in
                    switch result {
                    case .success(let image):
                        print("Image downloaded successfully: \(image)")
                        self.imagesModel[self.imagesPager.currentPage].enchanedImage = image
                        self.imagesModel[self.imagesPager.currentPage].showOriginal = false
                        self.imagesCV.reloadData()
                        SVProgressHUD.dismiss()
                    case .failure(let error):
                        print("Failed to download image: \(error.localizedDescription)")
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }) { error in
            print("Error: \(error)")
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func resetButtonTapped(at: Int){
        self.imagesModel[at].showOriginal = true
        self.imagesCV.reloadData()
    }

    func editButtonTapped(at: Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let imageEditVC = storyboard.instantiateViewController(withIdentifier: "ImageEditViewController") as? ImageEditViewController {
            imageEditVC.image =  self.imagesModel[at].OgImage
            imageEditVC.completionHandler = { editedImage in
                self.imagesModel[at].enchanedImage = editedImage
                self.imagesModel[at].showOriginal = false
                self.imagesCV.reloadData()
            }
            self.navigationController?.pushViewController(imageEditVC, animated: true)
        }
    }
    
    func getImages(from models: [ProductImagesModel]) -> [UIImage] {
        return models.map { $0.enchanedImage ?? $0.OgImage }
    }
    
    @IBAction func nextScreenPressed(_ sender: Any) {
        product?.images = getImages(from: self.imagesModel)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let imageEditVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
            imageEditVC.product = self.product
            self.navigationController?.pushViewController(imageEditVC, animated: true)
        }
    }

    @IBAction func addProductPressed(_ sender: Any) {
        product?.images = getImages(from: self.imagesModel)
        if let product{
            ProductImageManager.shared.addProductImage(product)
        }

        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : ScanViewController = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        product?.images = getImages(from: self.imagesModel)
        if let product{
            ProductImageManager.shared.addProductImage(product)
        }

        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : ReviewProductsViewController = storyboard.instantiateViewController(withIdentifier: "ReviewProductsViewController") as! ReviewProductsViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension ImageEnchanceViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (self.imagesCV.dequeueReusableCell(withReuseIdentifier: "ImagesCell", for: indexPath) as? ImagesCell)!
        let image = self.imagesModel[indexPath.row]
        cell.itemImage.image = image.showOriginal ? image.OgImage : image.enchanedImage

        // Set the callbacks
        cell.resetAction = { [weak self] in
            self?.resetButtonTapped(at: indexPath.row)
        }

        cell.editAction = { [weak self] in
            self?.editButtonTapped(at: indexPath.row)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: width)
    }

}

extension ImageEnchanceViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        imagesPager.currentPage = currentPage
    }
}
