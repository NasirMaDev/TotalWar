//
//  ViewController.swift
//  PanelDashBoard
//
//  Created by Asjd on 09/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import UIKit
import SVProgressHUD

@available(iOS 13.0, *)
class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var manageProductView: UIStackView!
    @IBOutlet weak var uploadProductView: UIStackView!
    @IBOutlet weak var scanCodeView: UIStackView!
    @IBOutlet weak var enhanceView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(allproductsPressed))
        manageProductView.isUserInteractionEnabled = true
        manageProductView.addGestureRecognizer(tapGesture)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(ScanCode))
        uploadProductView.isUserInteractionEnabled = true
        uploadProductView.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(showScanner))
        scanCodeView.isUserInteractionEnabled = true
        scanCodeView.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(enchancePressed))
        enhanceView.isUserInteractionEnabled = true
        enhanceView.addGestureRecognizer(tapGesture3)
        
        ProductImageManager.shared.removeAllProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //manageSaveItemButton()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @objc func allproductsPressed() {
        print("Show All products pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : ShowProductViewController = storyboard.instantiateViewController(withIdentifier: "ShowProductViewController") as! ShowProductViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func SettingButtonClick() {
        print("Setting Button pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : SettingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func ScanCode() {
        print("ScanCode pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : ScanViewController = storyboard.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func addproducts() {
        print("add product pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : AddProductsViewController = storyboard.instantiateViewController(withIdentifier: "AddProductsViewController") as! AddProductsViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @objc func enchancePressed() {
        print("Enchance with AI pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : CameraViewControllerNew = storyboard.instantiateViewController(withIdentifier: "CameraViewControllerNew") as! CameraViewControllerNew
        vc.hidesBottomBarWhenPushed = true
        vc.takeMultiImage = false
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showScanner(_ sender: Any) {
        showBarcodeScanner()
    }
    
    func showBarcodeScanner(){
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
    
}

extension WelcomeViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        appDelegate?.scannedItems.append(code)
        let unique = appDelegate?.scannedItems.uniqued()
        appDelegate?.scannedItems = unique ?? []
        //manageSaveItemButton()
    }
}

extension WelcomeViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension WelcomeViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
       //manageSaveItemButton()
    }
}
