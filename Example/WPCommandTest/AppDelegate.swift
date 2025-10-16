//
//  AppDelegate.swift
//  WPCommand
//
//  Created by Developer on 07/16/2021.
//  Copyright (c) 2021 Developer. All rights reserved.
//

import UIKit
import WPCommand
//import IQKeyboardManagerSwift

//pod trunk register wenping.office@foxmail.com 'wenping-office' --description='iMac' --verbose
//pod trunk push WPCommand.podspec --allow-warnings

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: ViewController())
        self.window?.makeKeyAndVisible()
//        IQKeyboardManager.shared.enable = true

        return true
    }
}


