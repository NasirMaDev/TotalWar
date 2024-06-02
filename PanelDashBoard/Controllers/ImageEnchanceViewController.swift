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

    var capturedImages = [UIImage.init(named: "test1"),UIImage.init(named: "jiuce")]
    @IBOutlet weak var imagesCV: UICollectionView!
    var imagesModel : [ProductImagesModel] = []
    var product : ProductToUpload?
    @IBOutlet weak var imagesPager: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if let capturedImages = capturedImages {
            for (index, item) in capturedImages.enumerated() {
                let isSelected = index == 0
                imagesModel.append(ProductImagesModel(OgImage: item!, enchanedImage: nil, selected: isSelected))
            }
        //}
        product = ProductToUpload(image: [], status: "", barcode: "", ismatchbarcode: true, barCodeURLPostFix: "")
        imagesCV.isPagingEnabled = true
        imagesCV.delegate = self
        imagesCV.dataSource = self
       // imagesCV.minimumLineSpacing = 0
        imagesPager.numberOfPages = imagesModel.count
        imagesPager.currentPage = 0
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
    
    @IBAction func enchanceWithAI(_ sender: Any) {

        if imagesModel[imagesPager.currentPage].enchanedImage != nil{
            return
        }
         //Usage
        let boundary = "---011000010111000001101001"
        let headers = [
            "x-rapidapi-key": "386d2ffa7fmsh367f0d53d8669d7p160d7cjsn13fd10cb406c",
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
