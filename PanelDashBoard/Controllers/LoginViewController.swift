//
//  LoginViewController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 26/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  //MARK: IBActions
    @IBAction func loginPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "CustomTabBarController") as! MyTabBarController
        mainTabBarController.selectedIndex = 1
        // Set the tab bar controller as the root view controller
        UIApplication.shared.windows.first?.rootViewController = mainTabBarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
}
