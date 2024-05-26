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
    
    @IBOutlet weak var logoutview: UIView!
    @IBOutlet weak var customerview: UIView!
    @IBOutlet weak var productview: UIView!
    @IBOutlet weak var backview: UIView!
    @IBOutlet weak var scanItemButton: UIButton!
    @IBOutlet weak var saveItemButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backview.layer.cornerRadius = 15
        customerview.layer.cornerRadius = 15
        productview.layer.cornerRadius = 15
        logoutview.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manageSaveItemButton()
    }
    
    //MARK: Button action methods
    @IBAction func allproductsPressed(_ sender: Any) {
        print("Show All products pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : ShowProductViewController = storyboard.instantiateViewController(withIdentifier: "ShowProductsViewController") as! ShowProductViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func SettingButtonClick(_ sender: Any) {
        print("Setting Button pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : SettingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func addproducts(_ sender: Any) {
        print("add product pressed")
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : AddProductsViewController = storyboard.instantiateViewController(withIdentifier: "AddProductsViewController") as! AddProductsViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func scanItemAction(_ sender: Any) {
        showBarcodeScanner()
    }
    
    @IBAction func saveItemAction(_ sender: Any) {
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : SaveItemsViewController = storyboard.instantiateViewController(withIdentifier: "SaveItemsViewController") as! SaveItemsViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Other class instance methods
    
    func manageSaveItemButton() {
        self.saveItemButton.isHidden = appDelegate?.scannedItems.count == 0
        self.saveItemButton.isHidden = false
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
        manageSaveItemButton()
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
        manageSaveItemButton()
    }
}
