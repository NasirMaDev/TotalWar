//
//  AppDelegate.swift
//  PanelDashBoard
//
//  Created by Asjd on 09/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import UIKit
import AWSCognito
import IQKeyboardManagerSwift

var appDelegate = UIApplication.shared.delegate as? AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var scannedItems = [String]()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
        self.getAllValues()
        self.initializeS3()
        
       
        IQKeyboardManager.shared.enable = true
        return true
    }
    
    func getAllValues(){
        
        if(UserDefaults.standard.value(forKey: "SheetName") == nil){
            UserDefaults.standard.set(Constant.SheetID, forKey: "SheetID")
            UserDefaults.standard.set("Ventes", forKey: "SheetName")
            UserDefaults.standard.set("A2", forKey: "StartingColumn")
            UserDefaults.standard.set("AM100", forKey: "EndingColumn")
            UserDefaults.standard.set("P-", forKey: "BarCodePrefix")
            
            UserDefaults.standard.set("bazardeteclistest", forKey: "S3BudketID")
            UserDefaults.standard.set(Config.secretKeyAWS, forKey: "SecretKeyAWS")
            UserDefaults.standard.set(Config.accessKeyAWS, forKey: "AccessKeyAWS")
            UserDefaults.standard.set(Constant.BaseURL, forKey: "BaseURL")
            UserDefaults.standard.set("K1JT27KREG7M44965ME3YYCWL3QBGEYW", forKey: "PrestaAPIKey")
        }
        
    }
    
    // Initialize the Amazon Cognito credentials provider
    
    func initializeS3() {
            let poolId = "ap-southeast-1:af091873-5023-4ee0-a4de-330ee53da45d"
            let credentialsProvider = AWSCognitoCredentialsProvider(
                regionType: .APSoutheast1, //other regionType according to your location.
                identityPoolId: poolId
            )
        let configuration = AWSServiceConfiguration(region:.EUWest3, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
        }
    lazy  var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name:"")
                container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                    if let error = error as NSError? {
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    }
                })
                return container
            }()

        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }

        

    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

