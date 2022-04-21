//
//  UserDataModel.swift
//  YogaApp
//
//  Created by Yogesh Raj on 27/11/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import ObjectiveC

extension AppDelegate {
    
    private struct AssociatedKey {
        static var user  = Constants.kAppDisplayName+"user"
    }
    public var user: UserDataModel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.user) as? UserDataModel
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey.user, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}



// MARK: - UserDataModel

struct UserDataModel: Codable {
    
    var isUserVerified, isEmailVerified: Int?
    var authToken, id, username, countryCode: String?
    var phone, email, registerID: String?
    var userImageURL, userImageThumbURL: String?
    var userDataModelID: String?
    var cartCount: Int?
    var defaultAddress: AddressDataModel?
    
    
    enum CodingKeys: String, CodingKey {
        case isUserVerified = "is_user_verified"
        case isEmailVerified = "is_email_verified"
        case authToken = "auth_token"
        case id = "_id"
        case username
        case countryCode = "country_code"
        case phone, email
        case registerID = "register_id"
        case userImageURL = "user_image_url"
        case userImageThumbURL = "user_image_thumb_url"
        case userDataModelID = "id"
        case cartCount = "cart_count"
        case defaultAddress
    }
    
    public func saveUser(_ data: Data) {
        
        do {
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            UserDefaults.standard.set(archivedData, forKey: "user")
        } catch { print(error) }
        
        UserDefaults.standard.synchronize()
    }
    
    public static func isLoggedIn() -> UserDataModel? {
        
        guard let unarchivedObject = UserDefaults.standard.data(forKey: "user")
            else {return nil}
        guard let unarchivedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as? Data
            else {return nil}
        guard let user = decode(data: unarchivedData)
            else {return nil}
        
        return user
    }
    
    private static func decode(data: Data) -> UserDataModel? {
        return try? JSONDecoder().decode(UserDataModel.self, from: data)
    }
}






