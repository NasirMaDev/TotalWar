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

       
//        let boundaryData = "--\(boundary)\r\n".data(using: .utf8)!
//        let endBoundaryData = "--\(boundary)--\r\n".data(using: .utf8)!
//
//        var body = Data()
//
//        for param in parameters {
//            let paramName = param["name"]!
//            body.append(boundaryData)
//            body.append("Content-Disposition: form-data; name=\"\(paramName)\"".data(using: .utf8)!)
//            
//            if let filename = param["fileName"] {
//                let contentType = param["contentType"]!
//                body.append("; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
//                body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
//                if let fileData = param["value"] as? Data {
//                    body.append(fileData)
//                }
//            } else if let paramValue = param["value"] as? String {
//                body.append("\r\n\r\n\(paramValue)".data(using: .utf8)!)
//            }
//        }
//
//        body.append(endBoundaryData)

        let url = "https://picsart-remove-background2.p.rapidapi.com/removebg"
        SVProgressHUD.show()
        RemoteRequest.requestPostURL(url, headers: headers, params: parameters, success: { response in
            print("Response: \(response)")
            self.shownImage.downloaded(from: response as! String)
            SVProgressHUD.dismiss()
        }) { error in
            print("Error: \(error)")
            SVProgressHUD.dismiss()
        }
        
//        let parameters = [
//            [
//                "fileName": "test.jpg",
//                "contentType": "image/jpeg",
//                "name": "image",
//                "value": self.shownImage.image?.jpegData(compressionQuality: 0.5)
//            ],
//            [
//                "name": "bg_image_url",
//                "value": "https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L3JtMjctc2FzaS0wMi1sdXh1cnkuanBn.jpg"
//            ]
//        ]
//
//        let boundary = "---011000010111000001101001"
//
//        var body = Data()
//        for param in parameters {
//            let paramName = param["name"]!
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            if let filename = param["fileName"] {
//                let contentType = param["contentType"]!
//                body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
//                body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
//                if let fileData = param["value"] as? Data {
//                    body.append(fileData)
//                }
//            } else if let paramValue = param["value"] as? String {
//                body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
//                body.append(paramValue.data(using: .utf8)!)
//            }
//            body.append("\r\n".data(using: .utf8)!)
//        }
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//
//        let url = URL(string: "https://picsart-remove-background2.p.rapidapi.com/removebg")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.timeoutInterval = 20
//        request.allHTTPHeaderFields = [
//            "accept": "application/json",
//            "content-type": "multipart/form-data; boundary=\(boundary)",
//            "X-Picsart-API-Key": "0e5c76754cmshc74c7e43b9a743bp1558b5jsn52d9e5a278d0"
//        ]
//        request.httpBody = body
//        SVProgressHUD.show()
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//                SVProgressHUD.dismiss()
//            } else if let data = data {
//                print("Response: \(String(data: data, encoding: .utf8) ?? "Empty response")")
//                SVProgressHUD.dismiss()
//            }
//        }.resume()
//        let boundary = "---011000010111000001101001"
//        let headers = [
//            "x-rapidapi-key": "386d2ffa7fmsh367f0d53d8669d7p160d7cjsn13fd10cb406c",
//            "x-rapidapi-host": "picsart-remove-background2.p.rapidapi.com",
//            "Content-Type": "multipart/form-data; boundary=\(boundary)"
//        ]
//
//        let parameters = [
//            [
//                "fileName": "test.jpg",
//                "contentType": "image/jpeg",
//                "name": "image",
//                "value": self.shownImage.image
//            ],
//            [
//                "name": "bg_image_url",
//                "value": "https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L3JtMjctc2FzaS0wMi1sdXh1cnkuanBn.jpg"
//            ],
//            [
//                "name": "bg_blur",
//                "value": "10"
//            ],
//            [
//                "name": "format",
//                "value": "JPG"
//            ]
//        ]
//
//       
//        let boundaryData = "--\(boundary)\r\n".data(using: .utf8)!
//        let endBoundaryData = "--\(boundary)--\r\n".data(using: .utf8)!
//
//        var body = Data()
//
//        for param in parameters {
//            let paramName = param["name"]!
//            body.append(boundaryData)
//            body.append("Content-Disposition: form-data; name=\"\(paramName)\"".data(using: .utf8)!)
//            
//            if let filename = param["fileName"] {
//                let contentType = param["contentType"]!
//                body.append("; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
//                body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
//                if let fileData = param["value"] as? Data {
//                    body.append(fileData)
//                }
//            } else if let paramValue = param["value"] as? String {
//                body.append("\r\n\r\n\(paramValue)".data(using: .utf8)!)
//            }
//        }
//
//        body.append(endBoundaryData)
//
//        let request = NSMutableURLRequest(url: NSURL(string: "https://picsart-remove-background2.p.rapidapi.com/removebg")! as URL,
//                                          cachePolicy: .useProtocolCachePolicy,
//                                          timeoutInterval: 10.0)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = body as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if let error = error {
//                print("Error: \(error)")
//            } else if let data = data {
//                do {
//                    if let httpResponse = response as? HTTPURLResponse {
//                        print("Status code: \(httpResponse.statusCode)")
//                    }
//                    
//                    // Parse JSON data
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print("Response JSON: \(json)")
//                } catch let parseError {
//                    print("Error while parsing: \(parseError)")
//                    print("Raw data: \(String(data: data, encoding: .utf8) ?? "")")
//                }
//            }
//        })
//
//        dataTask.resume()
//
//        dataTask.resume()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        self.shownImage.image = capturedImages!.first
    }
}
