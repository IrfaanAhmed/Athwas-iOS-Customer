//
//  SceneDelegate.swift
//  IA
//
//  Created by Yogesh Raj on 11/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import AKSideMenu
let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
let obj = Speech()
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        if let appUser = UserDataModel.isLoggedIn() {
            Constants.kAppDelegate.user = appUser
            self.switchToHome()
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        if let statusBarFrame = windowScene.statusBarManager?.statusBarFrame {
            Constants.kAppDelegate.statusBarManager = windowScene.statusBarManager
            print(statusBarFrame)
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
    }
    
    
}

extension SceneDelegate: AKSideMenuDelegate {
    
    
    
    // MARK:- Switch To Home
    func switchToHome()  {
        
        UIView.transition(with: self.window!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: { () -> Void in
            
//            let VC = Constants.KTabbarStoryboard.instantiateViewController(identifier: "TabBarVC") as! TabBarVC
            let VC = Constants.KHomeStoryboard.instantiateViewController(identifier: "HomeVC") as! HomeVC
            let navigationController = UINavigationController(rootViewController: VC)
            let leftMenuViewController = Constants.KHomeStoryboard.instantiateViewController(identifier: "LeftMenuVC") as! LeftMenuVC
            
            // Create side menu controller
            let sideMenuViewController: AKSideMenu = AKSideMenu(contentViewController: navigationController, leftMenuViewController: leftMenuViewController, rightMenuViewController: nil)
            
            sideMenuViewController.menuPreferredStatusBarStyle = .darkContent
            sideMenuViewController.delegate = self
            sideMenuViewController.contentViewShadowColor = .black
            sideMenuViewController.contentViewShadowOffset = CGSize(width: 0, height: 0)
            sideMenuViewController.contentViewShadowOpacity = 0.6
            sideMenuViewController.contentViewShadowRadius = 12
            sideMenuViewController.contentViewShadowEnabled = true
            let nvc = UINavigationController(rootViewController: sideMenuViewController)
            nvc.navigationBar.isHidden = true
            self.window?.rootViewController = nvc
            self.window?.makeKeyAndVisible()
        })
    }
    
    func switchToLoginVC() {
        address = userCurrentAddress()
        Constants.kAppDelegate.user = nil
        Constants.kUserDefaults.removeObject(forKey: "user")
        UIView.transition(with: self.window!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: { () -> Void in
            
            let VC = Constants.KMainStoryboard.instantiateViewController(identifier: "LoginVC") as! LoginVC
            let nvc = UINavigationController(rootViewController: VC)
            nvc.navigationBar.isHidden = true
            self.window?.rootViewController = nvc
            self.window?.makeKeyAndVisible()
        })
    }
}
