//
//  SaveItemsViewController.swift
//  PanelDashBoard
//
//  Created by Sachin Siwal on 26/01/22.
//  Copyright © 2022 Asjd. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

enum ProcessItem {
    case none
    case inbound
    case outbound
    case returnItem
    case inventory
    case editItem
}

class SaveItemsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTitle: UILabel!
    var processItemType: ProcessItem = .none
    var storageCode = ""
    var selectedIndex = -1
    
    //MARK: View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        //temp calling
        //        updateGoogleSheet(type: .returnItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        SVProgressHUD.dismiss()
    }
    
    //MARK: Other class instance methods.
    
    func setupView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func showBarcodeScanner(title: String = "Scan item barcode"){
        let viewController = BarcodeScannerViewController()
        viewController.cameraViewController.barCodeFocusViewType = .animated
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.isOneTimeSearch = false
        viewController.messageViewController.regularTintColor = .black
        viewController.messageViewController.errorTintColor = .red
        viewController.messageViewController.textLabel.textColor = .black
        viewController.headerViewController.titleLabel.text = title
        viewController.headerViewController.closeButton.tintColor = .red
        present(viewController, animated: false, completion: nil)
    }
    
    func showConfirmationAlert() {
        switch processItemType {
        case .inbound:
            showAlert(message: "Are you sure you want to inbound \(appDelegate?.scannedItems.count ?? 0) scanned items to storage location \(storageCode)")
        case .outbound:
            showAlert(message: "Are you sure you want to mark outbound for the \(appDelegate?.scannedItems.count ?? 0) scanned items?")
        case .returnItem:
            showAlert(message: "Are you sure you want to return \(appDelegate?.scannedItems.count ?? 0) scanned items to storage location \(storageCode)")
        case .inventory:
            showAlert(message: "Are you sure you want to manage inventory for \(appDelegate?.scannedItems.count ?? 0) scanned items?")
        default:
            print("default case")
        }
    }
    
    func showAlert(message: String = "") {
        // create the alert
        let alert = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            // on confirm
            if let count = appDelegate?.scannedItems.count, count > 0 {
                SVProgressHUD.show()
                self.updateGoogleSheet(type: self.processItemType)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: { action in
            // on cancel
            self.processItemType = .none
            self.storageCode = ""
        }))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    //ID Objet : C
    // Emplacement (Storage location): V
    // Envoyé (sent): AG
    
    func updateGoogleSheet(type: ProcessItem = .none){
        
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
        guard let BarCodePrefix = UserDefaults.standard.value(forKey: "BarCodePrefix") else {
            return
        }
        
        guard let PrestaAPIKey = UserDefaults.standard.value(forKey: "PrestaAPIKey") else {
            return
        }
        
        var dict: [String: Any] = [:]
        let barcodes = appDelegate?.scannedItems.map{String($0)}.joined(separator: ",") ?? ""
        print("barcodes")
        print(barcodes)
        //        barcodes = "001TY"
        //        storageCode = "B135"
        //        appDelegate?.scannedItems.append("001TY")
        //        appDelegate?.scannedItems.append("001TZ")
        //        appDelegate?.scannedItems.append("001U0")
        //        ==============Temp values===============
        //        barcodes = "0011G,0011H,0011I,0011J"
        //        SheetID = "1B71FciMdZRHZbLYSbAfrve0yN_1ETNcZL5J8mJ8Dpsk"
        //        storageCode = "A000"
        //        ==========================
        switch type {
        case .inbound:
            //            dict = ["action": Constant.updateInbound ,"apiKey":PrestaAPIKey,"barCode":barcodes,"preFix":BarCodePrefix, "storage": storageCode] as [String: Any]
            //            dict = ["action": Constant.updateInbound ,"apiKey":PrestaAPIKey,"preFix":BarCodePrefix, "storage": storageCode] as [String: Any]
            dict = ["action": Constant.updateInbound ,"preFix":BarCodePrefix, "storage": storageCode] as [String: AnyObject]
            
            hitAPIToSaveOnPrestaShop(dict: dict)
        case .outbound:
            dict = ["action": Constant.updateOutbound ,"spreadSheetId":SheetID,"sheetName":SheetName,"barCodeSearchColumn":"\(StartingColumn):\(EndingColumn)","barCode":barcodes,"preFix":BarCodePrefix] as [String: Any]
            hitAPIToSaveOnGoogleSheet(dict: dict)
        case .returnItem:
            dict = ["action": Constant.updateReturn ,"spreadSheetId":SheetID,"sheetName":SheetName,"barCodeSearchColumn":"\(StartingColumn):\(EndingColumn)","barCode":barcodes,"preFix":BarCodePrefix, "storage": storageCode] as [String: Any]
            hitAPIToSaveOnGoogleSheet(dict: dict)
        case .inventory:
            dict = ["action": Constant.updateInventory ,"spreadSheetId":SheetID,"sheetName":SheetName,"barCodeSearchColumn":"\(StartingColumn):\(EndingColumn)","barCode":barcodes,"preFix":BarCodePrefix] as [String: Any]
            hitAPIToSaveOnGoogleSheet(dict: dict)
        default:
            print("default case")
        }
    }
    
    func hitAPIToSaveOnPrestaShop(dict: [String: Any]) {
        guard let BaseURL = UserDefaults.standard.value(forKey: "BaseURL") else {
            return
        }
        var dictObj = dict
        checkItems()
        func checkItems() {
            if let barcodes = appDelegate?.scannedItems, barcodes.count > 0 {
                if let item = barcodes.first {
                    dictObj["barCode"] = item
                    SVProgressHUD.show(withStatus: "Updating item P-\(item)")
                    callUpdateAPI(item: item)
                }
            }
        }
        
        func callUpdateAPI(item: String = ""){
            let parameters = [
                [
                    "key": "storage",
                    "value": storageCode,
                    "type": "text"
                ],
                [
                    "key": "barCode",
                    "value": item,
                    "type": "text"
                ],
                [
                    "key": "preFix",
                    "value": "P-",
                    "type": "text"
                ],
                [
                    "key": "action",
                    "value": "updateInbound",
                    "type": "text"
                ]] as [[String: Any]]
            
            let boundary = "Boundary-\(UUID().uuidString)"
            var body = ""
            for param in parameters {
                if param["disabled"] != nil { continue }
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                if param["contentType"] != nil {
                    body += "\r\nContent-Type: \(param["contentType"] as! String)"
                }
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                }
            }
            body += "--\(boundary)--\r\n";
            let postData = body.data(using: .utf8)
//            let urlString = "\(BaseURL)\(Constant.inboundURL)"
            var request = URLRequest(url: URL(string: "https://www.totalwargame.com/locationupdates")!,timeoutInterval: Double.infinity)
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                SVProgressHUD.dismiss()
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                print(String(data: data, encoding: .utf8)!)
                do {
                    if let value = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if appDelegate?.scannedItems.count == 1 {
                            DispatchQueue.main.async {
                                let message: String = value["message"] as? String ?? "Updated successfully"
                                let status: String = value["status"] as? String ?? "1"
                                if status == "1" {
                                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                    let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                                        appDelegate?.scannedItems.removeAll()
                                        self.processItemType = .none
                                        self.storageCode = ""
                                        self.navigationController?.popViewController(animated: true)
                                    } )
                                    alertController.addAction(alertbutton)
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                    let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                                        //do nothing
                                    } )
                                    alertController.addAction(alertbutton)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                
                            }
                        }else {
                            appDelegate?.scannedItems.removeFirst()
                            checkItems()
                        }
                        
                    } else {
                        print("Response data is not a dictionary")
                    }
                } catch {
                    print("Error decoding JSON response: \(error)")
                }
            }
            task.resume()
        }
    }
    
    func hitAPIToSaveOnGoogleSheet(dict: [String: Any]) {
        guard let BaseURL = UserDefaults.standard.value(forKey: "BaseURL") else {
            return
        }
        RemoteRequest.requestPostURL("\(BaseURL)\(Constant.helperURL)" , params: dict, success: { response in
            
            SVProgressHUD.dismiss()
            let alertController = UIAlertController(title: "Success", message: "Google Sheet Updated Sucessfully", preferredStyle: .alert)
            let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                //After google sheet update, clear saved items
                appDelegate?.scannedItems.removeAll()
                self.processItemType = .none
                self.storageCode = ""
                //                self.tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
                
            } )
            alertController.addAction(alertbutton)
            self.present(alertController, animated: true, completion: nil)
            
        }){ error in
            
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: Button instance methods
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addManualItemButtonAction(_ sender: Any) {
        showInputDialog(title: "Add Manual code",
                        subtitle: "Please enter the item code.",
                        actionTitle: "Add",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Item code",
                        inputKeyboardType: .default, actionHandler:
                            { (input:String?) in
            if let inputCode = input, inputCode.count > 0 {
                appDelegate?.scannedItems.append(inputCode)
                let unique = appDelegate?.scannedItems.uniqued()
                appDelegate?.scannedItems = unique ?? []
                self.tableView.reloadData()
            }
            
        })
    }
    
    @IBAction func addItemButtonAction(_ sender: Any) {
        showBarcodeScanner()
    }
    
    @IBAction func inboundButtonAction(_ sender: Any) {
        //        updateGoogleSheet(type: .inbound)
        //        return
        if let count = appDelegate?.scannedItems.count, count > 0 {
            processItemType = .inbound
            showBarcodeScanner(title: "Scan Storage barcode")
        } else {
            showAlert(message: "Please select items to proceed.")
        }
        
    }
    
    @IBAction func outboundButtonAction(_ sender: Any) {
        if let count = appDelegate?.scannedItems.count, count > 0 {
            processItemType = .outbound
            showConfirmationAlert()
        } else {
            showAlert(message: "Please select items to proceed.")
        }
        
    }
    
    @IBAction func returnButtonAction(_ sender: Any) {
        if let count = appDelegate?.scannedItems.count, count > 0 {
            processItemType = .returnItem
            showBarcodeScanner(title: "Scan Storage barcode")
        } else {
            showAlert(message: "Please select items to proceed.")
        }
        
    }
    
    @IBAction func inventoryButtonAction(_ sender: Any) {
        if let count = appDelegate?.scannedItems.count, count > 0 {
            processItemType = .inventory
            showConfirmationAlert()
        } else {
            showAlert(message: "Please select items to proceed.")
        }
        
    }
    
    
}

extension SaveItemsViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print(code)
        switch processItemType {
        case .inbound:
            storageCode = code
            controller.dismiss(animated: true, completion: {
                self.showConfirmationAlert()
            })
        case .returnItem:
            storageCode = code
            controller.dismiss(animated: true, completion: {
                self.showConfirmationAlert()
            })
        case .editItem:
            appDelegate?.scannedItems[selectedIndex] = code
            let unique = appDelegate?.scannedItems.uniqued()
            appDelegate?.scannedItems = unique ?? []
            self.tableView.reloadData()
            controller.dismiss(animated: true, completion: {
                self.selectedIndex = -1
                self.processItemType = .none
            })
        default:
            print("default case")
            appDelegate?.scannedItems.append(code)
            let unique = appDelegate?.scannedItems.uniqued()
            appDelegate?.scannedItems = unique ?? []
            self.tableView.reloadData()
        }
        
    }
}

extension SaveItemsViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
}

extension SaveItemsViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}

extension SaveItemsViewController: UITableViewDelegate, UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = appDelegate?.scannedItems.count {
            self.headerTitle.text = (count > 0) ? "\(count) scanned" : "No item scanned yet"
        }
        return appDelegate?.scannedItems.count ?? 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = appDelegate?.scannedItems[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            // remove the item from the data model
            appDelegate?.scannedItems.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        })
        deleteAction.backgroundColor = .red
        
        let editAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.selectedIndex = indexPath.row
            self.processItemType = .editItem
            self.showBarcodeScanner()
            success(true)
            
        })
        editAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
}
