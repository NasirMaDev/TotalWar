//
//  WebService.swift
//  RozeePk
//
//  Created by nassrullah khan on 31/10/2020.
//  Copyright © 2020 nassrullah khan. All rights reserved.
//

import Foundation
import Alamofire

class RemoteRequest: NSObject {
    
    
    class func requestPostURL(_ strURL: String,params:Parameters, success:@escaping (Any) -> Void, failure:@escaping (NSError) -> Void) {
        let header = [
            "Content-Type":"application/json"
        ]
        Alamofire.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            print("POST \(strURL)")
            print(params)
            print(String(data: response.data!, encoding: .utf8) ?? "some data")
            print("Response : \(String(describing: response))")
            if response.error == nil {
                
                guard let value = response.value as? NSDictionary else{
                    print("Error while fetching : \(String(describing: response.value))")
                    return
                }
                success(value)
            }else{
                print(String(data: response.data!, encoding: .utf8) ?? "some data")
                print(response.error?.localizedDescription ?? "")
                failure(NSError(domain: response.error?.localizedDescription ?? "", code: 400, userInfo: nil))
            }
            
        }
    }
    
    class func requestPostURL(_ strURL: String, headers: HTTPHeaders, params: [String : Any], success:@escaping (Any) -> Void, failure:@escaping (NSError) -> Void) {
        
        var request = URLRequest(url: NSURL(string: strURL)! as URL)
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = 30
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            var imageIndex = 1
            for (key, value) in params {
                if key == "image", let image = value as? UIImage {
                    if let imageData = image.jpegData(compressionQuality: 0.5) {
                        let fileName = "image\(imageIndex).jpeg"
                        multipartFormData.append(imageData, withName: key, fileName: fileName, mimeType: "image/jpeg")
                        imageIndex += 1
                    }
                } else if key == "productImage", let productImageArray = value as? [UIImage] {
                    for productImage in productImageArray {
                        if let imageData = productImage.jpegData(compressionQuality: 0.5) {
                            let fileName = "productImage\(imageIndex).jpeg"
                            multipartFormData.append(imageData, withName: key, fileName: fileName, mimeType: "image/jpeg")
                            imageIndex += 1
                        }
                    }
                } else if let stringValue = value as? String {
                    multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
                }
            }
        }, to: strURL ,method: .post,headers: headers) { response in
            switch response {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseJSON
                {
                    response in
                    print("Response :\(response.result.value)")
                    if let result = response.result.value as? [String: Any],
                       let data = result["data"] as? [String: Any],
                       let urlValue = data["url"] as? String {
                        print("URL: \(urlValue)")
                        success(urlValue)
                    } else {
                        print("Failed to extract URL from response.")
                    }
                    
                }
                
            case .failure(let encodingError):
                print("no Error :\(encodingError)")
            }
        }
    }
    
    class func requestNewPostURL<T: Decodable>(_ strURL: String, success:@escaping (T) -> Void, failure:@escaping (NSError) -> Void) {
          let header = [
              "Content-Type":"application/json"
          ]
          
          Alamofire.request(strURL, method: .get, encoding: JSONEncoding.default, headers: header).responseData { response in
              print("POST \(strURL)")
              if let responseData = response.data {
                  print(String(data: responseData, encoding: .utf8) ?? "some data")
              }
              print("Response : \(String(describing: response))")
              
              if response.error == nil {
                  guard let responseData = response.data else {
                      let error = NSError(domain: "No data in response", code: 400, userInfo: nil)
                      failure(error)
                      return
                  }
                  
                  do {
                      let decodedObject = try JSONDecoder().decode(T.self, from: responseData)
                      success(decodedObject)
                  } catch {
                      print("Failed to decode JSON: \(error)")
                      let decodingError = NSError(domain: error.localizedDescription, code: 400, userInfo: nil)
                      failure(decodingError)
                  }
              } else {
                  if let responseData = response.data {
                      print(String(data: responseData, encoding: .utf8) ?? "some data")
                  }
                  print(response.error?.localizedDescription ?? "")
                  let networkError = NSError(domain: response.error?.localizedDescription ?? "", code: 400, userInfo: nil)
                  failure(networkError)
              }
          }
      }
        
        
    class func requestPostURLWithToken(_ strURL: String,params:Parameters, success:@escaping (Any) -> Void, failure:@escaping (NSError) -> Void) {
        let header = [
            "Content-Type":"application/json",
        //    "Authorization" : "\("Bearer ")\(Constants.user!.token!.accessToken)"
        ]
        Alamofire.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            print("POST \(strURL)")
            print(params)
            print(response)
            if response.error == nil {
                
                guard let value = response.value as? NSDictionary else{
                    print("Error while fetching : \(String(describing: response.value))")
                    return
                }
                success(value)
            }else{
                print(response.error?.localizedDescription ?? "")
                failure(NSError(domain: response.error?.localizedDescription ?? "", code: 400, userInfo: nil))
            }
            
        }
        
    }
    class func requestGetURL(_ strURL: String,params:Parameters, success:@escaping (Any) -> Void, failure:@escaping (NSError) -> Void) {
        let header = [
            "Content-Type":"application/json"
        ]
        Alamofire.request(strURL, method: .get, parameters: params, headers: header).responseJSON { response in
            print("GET \(strURL)")
            print(params)
            print(response)
            if response.error == nil {
                
                guard let value = response.value as? NSDictionary else{
                    print("Error while fetching : \(String(describing: response.value))")
                    return
                }
                success(value)
            }else{
                print(response.error?.localizedDescription ?? "")
                failure(NSError(domain: response.error?.localizedDescription ?? "", code: 400, userInfo: nil))
            }
            
        }
        
    }
    class func requestPutURL(_ strURL: String,params:Parameters, success:@escaping (Any) -> Void, failure:@escaping (NSError) -> Void) {
        let header = [
            "Content-Type":"application/json"
        ]
        Alamofire.request(strURL, method: .put, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            print("PUT \(strURL)")
            print(params)
            print(response)
            if response.error == nil {
                
                guard let value = response.value as? NSDictionary else{
                    print("Error while fetching : \(String(describing: response.value))")
                    return
                }
                success(value)
            }else{
                print(response.error?.localizedDescription ?? "")
                failure(NSError(domain: response.error?.localizedDescription ?? "", code: 400, userInfo: nil))
            }
            
        }
        
    }
    class func requestDeleteURL(_ strURL: String,params:Parameters, success:@escaping (Any) -> Void, failure:@escaping (NSError) -> Void) {
        let header = [
            "Content-Type":"application/json"
        ]
        Alamofire.request(strURL, method: .delete, parameters: params, headers: header).responseJSON { response in
            print("DELETE \(strURL)")
            print(params)
            print(response)
            if response.error == nil {
                
                guard let value = response.value as? NSDictionary else{
                    print("Error while fetching : \(String(describing: response.value))")
                    return
                }
                success(value)
            }else{
                print(response.error?.localizedDescription ?? "")
                failure(NSError(domain: response.error?.localizedDescription ?? "", code: 400, userInfo: nil))
            }
            
        }
        
    }
    
    
    
    
}



