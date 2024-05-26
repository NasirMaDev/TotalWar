//
//  VC+Vision.swift
//  ImageAnalyzer-ML
//
//  Created by Priya Talreja on 26/07/19.
//  Copyright © 2019 Priya Talreja. All rights reserved.
//

import UIKit
import Vision

enum DetectionTypes {
    case Rectangle
    case Face
    case Barcode
    case Text
}
@available(iOS 13.0, *)
extension AddProductsViewController
{
    func createVisionRequest(image: UIImage,index:Int,callback:@escaping ((String,Int,String)->Void))
    {
        guard let cgImage = image.cgImage else {
            return
        }
        // image.cgImageOrientation
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
        //Request Array
        //From now I am just passing text detection request.. You can pass vnDetectionRequest,vnFaceDetectionRequest,vnBarCodeDetectionRequest
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                callback("Not Scanned",index, "")
                return
            }
            else {
                
                guard let observations = request.results as? [VNBarcodeObservation]
                    else {
                        callback("Not Scanned",index, "")
                        return
                }
               
                if observations.count > 0 {
                    let symbology = observations.first?.payloadStringValue

                  print(symbology as Any)

                    
                    callback("Scanned",index,symbology!)
                   // print("Observations are \(observations)")

                  
                    
                }
                
                else{
                  
                    let symbology = observations.first?.payloadStringValue

                    callback("Not Scanned",index,"")

                   // print("Observations are \(observations)")
                    print("wrong images")
                    
                }
                
                self.visualizeObservations(observations: observations,type: .Barcode)
            }
        }
        let vnRequests = [request]
        
        DispatchQueue.global(qos: .background).async {
            do{
                try requestHandler.perform(vnRequests)
            }catch let error as NSError {
                print("Error in performing Image request: \(error)")
            }
        }
        
    }
   
    
    
    var vnDetectionRequest : VNDetectRectanglesRequest{
        let request = VNDetectRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
               // print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Rectangle)
            }
        }
        request.maximumObservations = 0
        return request
    }
    
    var vnFaceDetectionRequest : VNDetectFaceRectanglesRequest{
        let request = VNDetectFaceRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
                //print("Observations are \(observations)")
                self.visualizeObservations(observations: observations,type: .Face)
            }
        }
        return request
    }
    
    var vnBarCodeDetectionRequest : VNDetectBarcodesRequest{
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
                        return
                }
              
            

             if observations.count > 0 {
     
                 // print("Observations are \(observations)")
          
                    
                }
                else{

            // print("Observations are \(observations)")
                    print("wrong images")

                }

                self.visualizeObservations(observations: observations,type: .Barcode)
            }
        }
        
        return request
    }
    
    var vnTextDetectionRequest : VNDetectTextRectanglesRequest{
        let request = VNDetectTextRectanglesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                return
            }
            else {
                guard let observations = request.results as? [VNDetectedObjectObservation]
                    else {
           
                        return
                }
               // print("Observations are \(observations)")
                print(observations)
               
                self.visualizeObservations(observations: observations,type: .Text)
            }
        }
        
        return request
    }
    
    
    func createVisionRequest(image: UIImage)
        {
            guard let cgImage = image.cgImage else {
                return
            }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
            //Request Array
            //From now I am just passing text detection request.. You can pass vnDetectionRequest,vnFaceDetectionRequest,vnBarCodeDetectionRequest
            let vnRequests = [vnTextDetectionRequest]
            DispatchQueue.global(qos: .background).async {
                do{
                    try requestHandler.perform(vnRequests)
                }catch let error as NSError {
                    print("Error in performing Image request: \(error)")
                }
            }
            
        }
    
    func visualizeObservations(observations : [VNDetectedObjectObservation],type: DetectionTypes){
        DispatchQueue.main.async {
            guard let image = self.imageview.image
      
                else{
                    print("Failure in retriving image")
                    return
            }
            let imageSize = image.size
            var imageTransform = CGAffineTransform.identity.scaledBy(x: 1, y: -1).translatedBy(x: 0, y: -imageSize.height)
            imageTransform = imageTransform.scaledBy(x: imageSize.width, y: imageSize.height)
            UIGraphicsBeginImageContextWithOptions(imageSize, true, 0)
            let graphicsContext = UIGraphicsGetCurrentContext()
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            
            graphicsContext?.saveGState()
            graphicsContext?.setLineJoin(.round)
            graphicsContext?.setLineWidth(8.0)
            
            switch type
            {
            case .Face:
                graphicsContext?.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.red.cgColor)
            case .Barcode,.Text:
                graphicsContext?.setFillColor(red: 0, green: 1, blue: 0, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.red.cgColor)
            case .Rectangle:
                graphicsContext?.setFillColor(red: 0, green: 0, blue: 1, alpha: 0.3)
                graphicsContext?.setStrokeColor(UIColor.blue.cgColor)
                
            }
            
            
            observations.forEach { (observation) in
                let observationBounds = observation.boundingBox.applying(imageTransform)
                graphicsContext?.addRect(observationBounds)
            }
            graphicsContext?.drawPath(using: CGPathDrawingMode.fillStroke)
            graphicsContext?.restoreGState()
            
            let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageview.image = drawnImage
            
        }
    }
    
    @available(iOS 13.0, *)
    func createTextRequest(image: UIImage,index:Int,callback:@escaping ((String,Int,String)->Void))
        {
            guard let cgImage = image.cgImage else {
                return
            }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
            //Request Array
            //From now I am just passing text detection request.. You can pass vnDetectionRequest,vnFaceDetectionRequest,vnBarCodeDetectionRequest
            
            let request = VNRecognizeTextRequest { (request,error) in
                if let error = error as NSError? {
                    print("Error in detecting - \(error)")
                    callback("Not Scanned",index, "")
                    return
                }
                else {
                    guard let observations = request.results as? [VNRecognizedTextObservation]
                        else {
                            callback("Not Scanned",index, "")
                            return
                    }
                   
                    if observations.count > 0 {
                        
                        var i = 0
                        for currentObservation in observations {
                               i = i + 1
                            let topCandidate = currentObservation.topCandidates(1)
                            
                            if let recognizedText = topCandidate.first {
                            
                                let status = self.isBarCodePresentInArray(barCode: recognizedText.string, IsBarCodeScan: false)
                                if(status.0 == true){
                                    
                                    print(recognizedText.string)
                                    callback("Scanned",index,recognizedText.string)
                                    //print("Observations are \(observations)")
                                    break
                                }else{
                                    if(i == observations.count - 1){
                                        print(recognizedText.string)
                                        callback("Scanned But Not Present",index,recognizedText.string)
                                      //  print("Observations are \(observations)")
                                        break
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    else{
                        
                        for currentObservation in observations {
                                      
                            let topCandidate = currentObservation.topCandidates(1)
                            
                            if let recognizedText = topCandidate.first {
                            
                                print(recognizedText.string)
                             }
                        }
                        callback("Not Scanned",index,"")

                        //print("Observations are \(observations)")
                        print("wrong images")
                        
                    }
                    
                   // self.visualizeObservations(observations: observations,type: .Text)
                }
            }
            let vnRequests = [request]
            
            DispatchQueue.global(qos: .background).async {
                do{
                    try requestHandler.perform(vnRequests)
                }catch let error as NSError {
                    print("Error in performing Image request: \(error)")
                }
            }
            
        }
}



