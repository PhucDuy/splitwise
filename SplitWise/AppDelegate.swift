//
//  AppDelegate.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/24/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let window = window {
            let sceneCoordinator = SceneCoordinator(window: window)
            AppManager.shared.migrationDatabase()
            AppManager.shared.startFromGroupsScene(sceneCoordinator: sceneCoordinator)
            window.makeKeyAndVisible()
        }
        return true
    }
}

