//
//  ImageEditViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 27/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class ImageEditViewController: UIViewController {
    
    var capturedImages: [UIImage]?
    @IBOutlet weak var shownImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shownImage.image = capturedImages!.first
        
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
         //Usage
        let boundary = "---011000010111000001101001"
        let headers = [
            "x-rapidapi-key": "386d2ffa7fmsh367f0d53d8669d7p160d7cjsn13fd10cb406c",
            "x-rapidapi-host": "picsart-remove-background2.p.rapidapi.com",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]

        let parameters = [
            "image": self.shownImage.image,
            "bg_image_url": "https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L3JtMjctc2FzaS0wMi1sdXh1cnkuanBn.jpg",
            "bg_blur": "10",
            "format": "JPG"
        ] as [String : Any]


        let url = "https://picsart-remove-background2.p.rapidapi.com/removebg"
        SVProgressHUD.show()
        RemoteRequest.requestPostURL(url, headers: headers, params: parameters, success: { response in
            print("Response: \(response)")
            if let urlString = response as? String{
                self.shownImage.downloaded(from: urlString, contentMode: .scaleAspectFit) { result in
                    switch result {
                    case .success(let image):
                        print("Image downloaded successfully: \(image)")
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
    
    @IBAction func resetPressed(_ sender: Any) {
        self.shownImage.image = capturedImages!.first
    }
}
