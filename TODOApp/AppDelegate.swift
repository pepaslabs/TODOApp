//
//  AppDelegate.swift
//  TODOApp
//
//  Created by Pepas Personal on 7/12/15.
//  Copyright (c) 2015 Pepas Personal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let vc = ListsTableViewController.instantiateFromStoryboard()
        let navC = UINavigationController(rootViewController: vc)
        
        window?.rootViewController = navC
        window?.makeKeyAndVisible()
        
        return true
    }
}
