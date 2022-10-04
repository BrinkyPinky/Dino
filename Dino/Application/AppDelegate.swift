//
//  AppDelegate.swift
//  Dino
//
//  Created by Егор Шилов on 29.09.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        var orientation: UIInterfaceOrientationMask!
        orientation = [UIInterfaceOrientationMask.landscape]
        return orientation
    }
}
