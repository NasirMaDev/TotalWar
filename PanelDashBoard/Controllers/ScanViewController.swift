//
//  ScanViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 28/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController , CameraViewDelegate {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var gradientView: UIView!
    
    private var previewView: CameraView!
    var barcodesArray : [String] = []
    var barcodesImagesArray : [String] = []
    var currentCode : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraView()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.backBtn.layer.zPosition = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        searchBarCodeInGSheet()
        
        // Create the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.38, green: 0.69, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.525, green: 0.322, blue: 1, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0) // Start at the top center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1) // End at the bottom center
        
        // Add the gradient layer to the view
        DispatchQueue.main.async {
            self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
            gradientLayer.frame = self.gradientView.bounds
            self.backBtn.layer.zPosition = 10
        }

        previewView.resetScanner()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewView.stopScanner()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the gradient layer's frame to match the gradientView's bounds
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientView.bounds
        }
    }

    private func setupCameraView() {
        previewView = CameraView()
        previewView.delegate = self
        previewView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.addSubview(previewView)

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: cameraView.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor)
        ])
    }

    func didFindCode(code: String) {
        self.currentCode = code
        self.previewView.stopScanner()
        showAlert(title: "BarCode Scan Successfully", message: "Code: \(code)", hasBarCode: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.previewView.resetScanner()
        }
    }

    func didFailToFindCode() {
        self.previewView.stopScanner()
        showAlert(title: "Scan Failed", message: "No barcode found.", hasBarCode: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.previewView.resetScanner()
        }
    }

    private func showAlert(title: String, message: String,hasBarCode: Bool) {
        let checkmarkImage = UIImage(systemName: hasBarCode ? "checkmark.circle.fill" : "cross.circle.fill")?.withTintColor(.purple, renderingMode: .alwaysOriginal)

        let button1 = UIButton(type: .system)
        button1.setTitle(hasBarCode ? "Next" : "Retry", for: .normal)
        button1.backgroundColor = UIColor.systemBlue
        button1.tintColor = .white
        button1.layer.cornerRadius = 15
        button1.addTarget(self, action: #selector(nextAction), for: .touchUpInside)

        let popupView = BarCodePopup(image: checkmarkImage, title: title, message: message, buttons: [button1])
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalToConstant: 300),
            popupView.heightAnchor.constraint(equalToConstant: 300)
        ])

        popupView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            popupView.alpha = 1
        }
    }

    func searchBarCodeInGSheet(){
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

        }) { error in
            debugPrint("Error getting barcodes")
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

    func isBarcodePresent(currentCode: String) -> Bool {
        return ProductImageManager.shared.getProducts().contains(where: { product in
            product.barcode == currentCode
        })
    }

    
    @objc func nextAction() {
        print("Next button tapped")
        self.previewView.stopScanner()
        if let popupView = view.subviews.compactMap({ $0 as? BarCodePopup }).first {
            popupView.removeFromSuperview()
        }
        let result = isBarCodePresentInArray(barCode: currentCode, IsBarCodeScan: true)
        if isBarcodePresent(currentCode: currentCode) || result.0 == true{
            showAlert(title: "BarCode Already Present in product list", message: "Code: \(currentCode)", hasBarCode: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.previewView.resetScanner()
            }
            return
        }
        let product = ProductToUpload(image: [], status: "", barcode: currentCode, ismatchbarcode: result.0, barCodeURLPostFix: result.1)
        debugPrint(result)
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : CameraViewControllerNew = storyboard.instantiateViewController(withIdentifier: "CameraViewControllerNew") as! CameraViewControllerNew
        vc.hidesBottomBarWhenPushed = true
        vc.takeMultiImage = true
        vc.product = product
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
