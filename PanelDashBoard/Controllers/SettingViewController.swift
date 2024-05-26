//
//  SettingViewController.swift
//  PanelDashBoard
//
//  Created by SilentSol PVT LTD on 29/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingViewController: UIViewController {

    @IBOutlet weak var txtSheetID:UITextField!
    @IBOutlet weak var txtSheetName:UITextField!
    @IBOutlet weak var txtStartingColumn:UITextField!
    @IBOutlet weak var txtEndingColumn:UITextField!
    @IBOutlet weak var txtBarCodePrefix:UITextField!
    
    @IBOutlet weak var txtS3BudketID:UITextField!
    @IBOutlet weak var txtAccessKeyAWS:UITextField!
    @IBOutlet weak var txtSecretKeyAWS:UITextField!
    @IBOutlet weak var txtBaseURL:UITextField!
    @IBOutlet weak var txtPrestaAPIKey:UITextField!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getValues()
        // Do any additional setup after loading the view.
    }
    
    func getValues(){
        if let SheetID = UserDefaults.standard.value(forKey: "SheetID") {
            self.txtSheetID.text = SheetID as? String
        }
        if let SheetName = UserDefaults.standard.value(forKey: "SheetName") {
            self.txtSheetName.text = SheetName as? String
        }
        if let StartingColumn = UserDefaults.standard.value(forKey: "StartingColumn") {
            self.txtStartingColumn.text = StartingColumn as? String
        }
        if let EndingColumn = UserDefaults.standard.value(forKey: "EndingColumn") {
            self.txtEndingColumn.text = EndingColumn as? String
        }
        if let BarCodePrefix = UserDefaults.standard.value(forKey: "BarCodePrefix") {
            self.txtBarCodePrefix.text = BarCodePrefix as? String
        }
        
        if let S3BudketID = UserDefaults.standard.value(forKey: "S3BudketID") {
            self.txtS3BudketID.text = S3BudketID as? String
        }
        if let AccessKeyAWS = UserDefaults.standard.value(forKey: "AccessKeyAWS") {
            self.txtAccessKeyAWS.text = AccessKeyAWS as? String
        }
        if let SecretKeyAWS = UserDefaults.standard.value(forKey: "SecretKeyAWS") {
            self.txtSecretKeyAWS.text = SecretKeyAWS as? String
        }
        if let BaseURL = UserDefaults.standard.value(forKey: "BaseURL") {
            self.txtBaseURL.text = BaseURL as? String
        }
        if let BaseURL = UserDefaults.standard.value(forKey: "PrestaAPIKey") {
            self.txtPrestaAPIKey.text = BaseURL as? String
        }
    }
    
    @IBAction func btnSaveClick(_ sender:Any){
        
       
        if(!self.txtSheetID.text!.isEmpty && !self.txtSheetName.text!.isEmpty && !self.txtStartingColumn.text!.isEmpty && !self.txtEndingColumn.text!.isEmpty && !self.txtBarCodePrefix.text!.isEmpty && !self.txtS3BudketID.text!.isEmpty && !self.txtSecretKeyAWS.text!.isEmpty && !self.txtAccessKeyAWS.text!.isEmpty && !self.txtBaseURL.text!.isEmpty){
            
            UserDefaults.standard.set(txtSheetID.text, forKey: "SheetID")
            UserDefaults.standard.set(txtSheetName.text, forKey: "SheetName")
            UserDefaults.standard.set(txtStartingColumn.text, forKey: "StartingColumn")
            UserDefaults.standard.set(txtEndingColumn.text, forKey: "EndingColumn")
            UserDefaults.standard.set(txtBarCodePrefix.text, forKey: "BarCodePrefix")
            
            
            UserDefaults.standard.set(txtS3BudketID.text, forKey: "S3BudketID")
            UserDefaults.standard.set(txtSecretKeyAWS.text, forKey: "SecretKeyAWS")
            UserDefaults.standard.set(txtAccessKeyAWS.text, forKey: "AccessKeyAWS")
            UserDefaults.standard.set(txtBaseURL.text, forKey: "BaseURL")
            UserDefaults.standard.set(txtPrestaAPIKey.text, forKey: "PrestaAPIKey")

            let alertController = UIAlertController(title: "Sucess", message: "Data Saved Sucessfully", preferredStyle: .alert)
            let alertbutton = UIAlertAction(title: "OK", style: .cancel, handler:{(action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
                
            } )
            alertController.addAction(alertbutton)
            self.present(alertController, animated: true, completion: nil)
            SVProgressHUD.dismiss()
            
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
