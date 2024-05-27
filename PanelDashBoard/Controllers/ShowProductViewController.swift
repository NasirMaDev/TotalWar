//
//  ShowProductViewController.swift
//  PanelDashBoard
//
//  Created by SilentSol PVT LTD on 29/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

struct allProducts{
    
    var barCode : String?
    var barCodePictureUrl : String?
}

import UIKit
import SVProgressHUD

class ShowProductViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var ShowProductCollectionView:UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var timer: Timer?
    var AllProducts = [Product]()
    var filteredData = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.GetAllProducts()
        
        
        searchBar.layer.cornerRadius = 10
        let searchTextField:UITextField = searchBar.value(forKey: "searchField") as? UITextField ?? UITextField()
        searchTextField.layer.cornerRadius = 15
        searchTextField.textAlignment = NSTextAlignment.left
        let image:UIImage = UIImage(named: "searchIcon")!
        let imageView:UIImageView = UIImageView.init(image: image)
        searchTextField.leftView = nil
        
        searchTextField.rightView = imageView
        searchBar.delegate = self
        //searchTextField.rightViewMode = UITextField.ViewMode.always
        //searchBar.searchTextField.rightView = UIImageView.init(image: UIImage.init(named: "searchIcon"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    
    func GetAllProducts(){
        
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
        
        
        guard let BaseURL = UserDefaults.standard.value(forKey: "BaseURL") else {
            return
        }
        
        RemoteRequest.requestPostURL("\(BaseURL)\(Constant.helperURL)", params: ["action":"getSheetsProductsWithUrl","spreadSheetId":SheetID,"sheetName":SheetName,"barCodeSearchColumn":StartingColumn], success: { response in
            
            print(response)
            if let allProducts = (response as? NSDictionary)?.value(forKey: "allProducts") as? [NSDictionary] {
                self.AllProducts = allProducts.compactMap { Product(dictionary: $0) }
                self.filteredData = self.AllProducts
                self.ShowProductCollectionView.reloadData()
            }
            SVProgressHUD.dismiss()
            
        }) { error in
            
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] _ in
            self?.filterData(searchText: searchText)
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredData = AllProducts
        DispatchQueue.main.async {
            self.ShowProductCollectionView.reloadData()
        }
    }
    
    // Filter data based on search text
    func filterData(searchText: String) {
        if searchText.isEmpty {
            filteredData = AllProducts
        } else {
            filteredData = AllProducts.filter { $0.barCode.lowercased().contains(searchText.lowercased()) }
        }
        DispatchQueue.main.async {
            self.ShowProductCollectionView.reloadData()
        }
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
        
    //MARK: IBActions
        

    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showScanner(_ sender: Any) {
        showBarcodeScanner()
    }
    
    @IBAction func addProductPressed(_ sender: Any) {
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : AddProductsViewController = storyboard.instantiateViewController(withIdentifier: "AddProductsViewController") as! AddProductsViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ShowProductViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (self.ShowProductCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowProductsCell", for: indexPath) as? ShowProductCell)!
        let product = self.filteredData[indexPath.row]
        let imgURl = product.barCodePictureUrl!
        cell.imgBarCode.downloaded(from: imgURl)
        cell.productName.text = product.barCode
        return cell
    }
    
    
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension ShowProductViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        appDelegate?.scannedItems.append(code)
        let unique = appDelegate?.scannedItems.uniqued()
        appDelegate?.scannedItems = unique ?? []
        //manageSaveItemButton()
    }
}

extension ShowProductViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension ShowProductViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
       //manageSaveItemButton()
    }
}
