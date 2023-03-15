//
//  AppDelegate.swift
//  ACCESS_interview
//
//  Created by 賴永峰 on 2023/3/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    let gitHubUserListVC = GitHubUserListViewController()
    self.window?.rootViewController = gitHubUserListVC
    self.window?.backgroundColor = .white
    self.window?.makeKeyAndVisible()
    return true
  }
}

