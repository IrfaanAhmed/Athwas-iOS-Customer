//
//  AppDelegate.swift
//  IA
//
//  Created by Yogesh Raj on 11/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var statusBarManager: UIStatusBarManager!
    var isReload: Bool!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        
        //Setup Google Services
        GMSServices.provideAPIKey(Constants.kGoogleAPIKey)
        GMSPlacesClient.provideAPIKey("AIzaSyC4MhJYysKpRFHe9Re--y5S0_PCtxGir9Q")
        
        GMSServices.openSourceLicenseInfo()
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async{
                    application.registerForRemoteNotifications()
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        LocationManager.shared.start()
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    
    //MARK:- Registered Push notification
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FIREBASE_TOKEN: \(fcmToken ?? "")")
        Constants.kfirebaseToken = fcmToken ?? ""
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        print(userInfo)
        application.applicationIconBadgeNumber = 0
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Handle tapped push from background, received: \n \(response.notification.request.content.userInfo)")
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if let msgType = userInfo[AnyHashable("custom_message_type")] as? String, let ID = userInfo[AnyHashable("id")] as? String {
            let notificationData = ["custom_message_type": msgType,
                                    "id": ID]
            kNotificationObject = notificationData as NSDictionary
            Constants.kSceneDelegate.switchToHome()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        
        print(notification.request.content.userInfo)
        
        let userInfo = notification.request.content.userInfo as NSDictionary
        if let msgType = userInfo[AnyHashable("custom_message_type")] as? String {
            if msgType == customMsgType.orderDetail.rawValue {
                NotificationCenter.default.post(name: Notification.Name("NotificationOrderUpdate"), object: nil)
            }
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
