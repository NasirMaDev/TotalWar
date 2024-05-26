//
//  MyTabBarController.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 26/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
            super.viewDidLoad()
            delegate = self

            //here's the code that creates no border, but has a shadow:

            tabBar.layer.shadowColor = UIColor.lightGray.cgColor
            tabBar.layer.shadowOpacity = 0.5
            tabBar.layer.shadowOffset = CGSize.zero
            tabBar.layer.shadowRadius = 5
            self.tabBar.layer.borderColor = UIColor.clear.cgColor
            self.tabBar.layer.borderWidth = 0
            self.tabBar.clipsToBounds = false
            self.tabBar.backgroundColor = UIColor.white
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
        }
    
    
    func navigateToManageProductsController() {
           guard let selectedNavController = selectedViewController as? UINavigationController else {
               print("Selected view controller is not a navigation controller")
               return
           }
           
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let newViewController = storyboard.instantiateViewController(withIdentifier: "ShowProductsViewController") as? ShowProductViewController {
               selectedNavController.pushViewController(newViewController, animated: true)
           } else {
               print("Could not instantiate view controller with identifier 'NewViewController'")
           }
       }
}


