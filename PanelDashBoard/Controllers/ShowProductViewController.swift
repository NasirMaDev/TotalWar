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

class ShowProductViewController: UIViewController {

    @IBOutlet weak var ShowProductCollectionView:UICollectionView!
    
    var AllProducts = [NSDictionary]()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "All Products"
        self.GetAllProducts()
        // Do any additional setup after loading the view.
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
            let newResponseArray = (response as! NSDictionary).value(forKey: "allProducts")

            self.AllProducts = newResponseArray as! [NSDictionary]
            self.ShowProductCollectionView.reloadData()
            SVProgressHUD.dismiss()
                    
                }) { error in
                    
                }
         
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShowProductViewController:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AllProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (self.ShowProductCollectionView.dequeueReusableCell(withReuseIdentifier: "ShowProductsCell", for: indexPath) as? ShowProductCell)!
        cell.lblBarCode.text = self.AllProducts[indexPath.row].value(forKey: "barCode") as? String
        let imgURl = self.AllProducts[indexPath.row].value(forKey: "barCodePictureUrl") as? String
       
        cell.imgBarCode.downloaded(from: imgURl!)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 160)
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
