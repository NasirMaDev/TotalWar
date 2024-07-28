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
    @IBOutlet weak var saveItemBtn: UIButton!
    
    var timer: Timer?
    var AllProducts = [Productv2]()
    var filteredData = [Productv2]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.GetAllProducts()
        self.setupToHideKeyboardOnTapOnView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }

    override func viewDidAppear(_ animated: Bool) {
        searchBar.delegate = self
        searchBar.searchTextField.layer.cornerRadius = 25
        searchBar.searchTextField.layer.masksToBounds = true
        let searchTextField:UITextField = searchBar.value(forKey: "searchField") as? UITextField ?? UITextField()
        searchTextField.layer.cornerRadius = 15
        searchTextField.textAlignment = NSTextAlignment.left
        let image:UIImage = UIImage(named: "searchIcon")!
        let imageView:UIImageView = UIImageView.init(image: image)
        searchTextField.leftView = nil
        searchTextField.rightView = imageView
        searchTextField.rightViewMode = UITextField.ViewMode.always
        searchBar.searchTextField.rightView = UIImageView.init(image: UIImage.init(named: "searchIcon"))

        DispatchQueue.main.async {
            self.searchBar.layoutSubviews()
            searchTextField.layoutSubviews()
            self.searchBar.layoutIfNeeded()
            searchTextField.layoutIfNeeded()
        }
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
        //using new base url
        guard let BaseURL = UserDefaults.standard.value(forKey: "BaseURLv2") else {
            return
        }
        let helperURL = "api/v2/Data/getSheetsProductsWithUrl?spreadsheetId=\(SheetID)&sheetName=\(SheetName)"
        RemoteRequest.requestNewPostURL("\(BaseURL)\(helperURL)", params: [:], success: { (products: [Productv2]) in
            print(products)
            
            self.AllProducts = products
            self.filteredData = products
            
            // Reload the collection view to display the products
            DispatchQueue.main.async {
                self.ShowProductCollectionView.reloadData()
            }
            
            SVProgressHUD.dismiss()
        }) { error in
            print("Network request failed: \(error)")
            SVProgressHUD.dismiss()
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
            filteredData = AllProducts.filter { $0.lotID!.lowercased().contains(searchText.lowercased()) }
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
    
    @IBAction func showSaveditems(_ sender: Any) {
        let storyboard :UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc : SaveItemsViewController = storyboard.instantiateViewController(withIdentifier: "SaveItemsViewController") as! SaveItemsViewController
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
        let imgURl = product.picURL ?? ""
        cell.imgBarCode.downloaded(from: imgURl, contentMode: .scaleAspectFit) { result in
            switch result {
            case .success(let image):
                print("Image downloaded successfully: \(image)")
                //SVProgressHUD.dismiss()
            case .failure(let error):
                print("Failed to download image: \(error.localizedDescription)")
                //SVProgressHUD.dismiss()
            }
        }
        cell.productName.text = product.lotID
        cell.productPrice.text = product.newValue ?? ""
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 5

        let totalSpacing = (2 * spacingBetweenCells) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) // Amount of total spacing in a row

        let width = (collectionView.frame.width - totalSpacing) / numberOfItemsPerRow

        return CGSize(width: width, height: width) // Assuming square cells
    }
}


extension ShowProductViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        appDelegate?.scannedItems.append(code)
        let unique = appDelegate?.scannedItems.uniqued()
        appDelegate?.scannedItems = unique ?? []
        self.saveItemBtn.isHidden = false
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
        self.saveItemBtn.isHidden = false
    }
}
