//
//  Constant.swift
//  Mozzaa
//
//  Created by Yogesh Raj on 23/04/19.
//  Copyright © 2019 Yogesh Raj. All rights reserved.
//

import UIKit


var kNotificationObject          =  NSDictionary()

public struct Constants {
    
    
    //Necessary Macros
    static let kAppDelegate         = UIApplication.shared.delegate as! AppDelegate
    static let kUserDefaults        = UserDefaults.standard
    
    //SceneDelegate
    static let kScene               = UIApplication.shared.connectedScenes.first
    static let kSceneDelegate       = (kScene?.delegate as! SceneDelegate)
    
    static let kAppDisplayName      = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    static let KDeviceSystemVersion = UIDevice.current.systemVersion
    
    static let kAppVersion          = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
    static let KLocationMessage     = "Please give premission for location access in app setting."
    static let kScreenWidth         = UIScreen.main.bounds.width
    static let kScreenHeight        = UIScreen.main.bounds.height
    static let kGoogleAPIKey        = "AIzaSyCuN00mm1m9eA6j3ieQWqnYGoZdaFwOALc"
    static let kFirebaseKey         = "" // [Project-IOS]
    static let kPaystackKey         = "pk_test_4442ebbbe35d4e8b94027eda3be87e08ed07f8dd"
    static var kfirebaseToken       = ""
    
    static let kGoogelClient         = "631720660096-qlsmacuqpldlclti90dvrql390g4ocp4.apps.googleusercontent.com"
    static let kAPIVersion           = "1.0"
    static let kAuthAPIKey           = ""
    static let kDeviceType           = "IOS"
    static let KCurrency             = "₹"
    static let KQuantity             = " gm"
    static let KDistance             = " Km"
    static let KAppName              = "ATHWAS"
    static let KMainStoryboard       = UIStoryboard(name: "Main", bundle: nil)
    static let KHomeStoryboard       = UIStoryboard(name: "Home", bundle: nil)
    static let KOrderStoryboard      = UIStoryboard(name: "Orders", bundle: nil)
    static let KTabbarStoryboard    = UIStoryboard(name: "Tabbar", bundle: nil)
    
    
    //static let kDeviceId            = Constants.kUserDefaults.object(forKey: "device_token") as? String ?? ""
    
    static let kAppInfo = ["device_type": kDeviceType,
                           "device_model": UIDevice.init().name,
                           "os_version": KDeviceSystemVersion]
    
    public typealias CompletionHandler = (_ result : Any?, _ error: Error?) -> Void
    public typealias CompletionHandlerProgress = (_ bytes : Int?) -> Void
    
    // static var isOngoingEnabled: Bool = false
}


// MARK: - UICollectionViewDelegate protocol
public enum productListType : Int {

    case popular = 1
    case discount = 2
    case category = 3
}

public enum customMsgType: String {
    
    case admin = "1"
    case productDetail = "2"
    case orderDetail = "3"
    case orderList = "4"
    
}
