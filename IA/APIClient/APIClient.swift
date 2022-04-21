//
//  APIClient.swift
//  Mozzaa
//
//  Created by Yogesh Raj on 23/04/19.
//  Copyright © 2019 Yogesh Raj. All rights reserved.
//

import UIKit
import Alamofire
import CryptoKit



// MARK: - Server side Methods serviceDetail
public struct URLMethods {
    
    
    //QA Server
//    static let BaseURL              = "http://3.7.83.168:3063/"
    
    
    //Dev Server
//        static let BaseURL            = "http://13.235.188.102:3060/"
    
    
    
    //Live Server
    static let BaseURL                =  "http://3.7.83.168:3060/"
    
    
    
    
    static let login                  = "user_service/customer/login"
    static let signup                 = "user_service/customer/registration"
    static let logout                 = "user_service/customer/logout"
    static let verifyOTP              = "user_service/customer/verify_otp"
    static let resendOTP              = "user_service/customer/resend_otp"
    
    
    static let resetPass              = "user_service/customer/update_forgot_password"
    static let getBusinessCategory    = "user_service/customer/product/get_business_category"
    static let getCategory            = "user_service/customer/product/get_category"
    static let getSubCategory         = "user_service/customer/product/get_subcategory"
    
    
    static let getProductList         = "user_service/customer/product/get_products"
    static let getBrands              = "user_service/customer/product/brand/get_brands"
    static let productDetail          = "user_service/customer/product/get_product_detail"
    
    static let addMoney               = "user_service/customer/wallet/add_to_wallet"
    static let walletHistory          = "user_service/customer/wallet/get_transaction_history"
    
    
    static let addAddress             = "user_service/customer/address/create_address"
    static let getAddress             = "user_service/customer/address/get_addresses"
    static let deleteAddress          = "user_service/customer/address/delete_address"
    
    
    static let addFavourite          = "user_service/customer/product/add_favourite_item"
    static let favouriteList         = "user_service/customer/product/get_favourite_items"
    static let getProfile            = "user_service/customer/profile/get_profile"
    
    
    static let changePassword        = "user_service/customer/profile/change_password"
    static let similarProducts       = "user_service/customer/product/similar_products"
    static let updateProfile         = "user_service/customer/profile/update_profile"
    
    
    static let banner                = "user_service/customer/product/banner/get_banners"
    static let customiationList      = "user_service/customer/product/other_customization_products"
    static let notificationList      = "user_service/customer/notifications"
    
    
    static let notificationDelete    = "user_service/customer/notifications/"
    static let addToCart             = "user_service/customer/cart"
    static let deleteCart            = "user_service/customer/cart/"
    
    
    static let notify_me             = "user_service/customer/product/notifyme"
    static let customizationType     = "user_service/customer/product/customizationtype/"
    static let customizationSubType  = "user_service/customer/product/customizationsubtype/"
    
    
    static let checkout              = "user_service/customer/order/checkout"
    static let current_orders        = "user_service/customer/order/user_orders"
    static let past_orders           = "user_service/customer/order/past_orders"
    static let orderDetail           = "user_service/customer/order/order_details/"
    
    
    static let offerLsit             = "user_service/customer/offer"
    static let appliedOffer          = "user_service/customer/offer/apply_coupon"
    static let deliveryCharge        = "user_service/customer/order/calculate_delivery_fees"
    
    
    static let cancelOrder           = "user_service/customer/orders/cancel_order"
    static let groceryCancelOrder    = "user_service/customer/orders/cancel_grocery_order"
    static let returnOrder           = "user_service/customer/orders/return_request"
    static let groceryReturnOrder    = "user_service/customer/orders/grocery_return_request"
    
    
    static let badgeCount            = "user_service/customer/cart/get_cart_item_count"
    static let giveRating            = "user_service/customer/product/ratings"
    static let discountProduct       = "user_service/customer/product/discountproduct"
    
    
    static let popularProduct        = "user_service/customer/product/popularproduct"
    static let staticPages           = "content_service/customer/contents/"
    static let rewardPoints          = "user_service/customer/order/get_redeem_point"
    
    static let dealsOfday            = "user_service/customer/product/dealofday"
    static let downloadInvoice       = "user_service/customer/order/downloadOrderInvoice"
    static let generateOrder         = "user_service/customer/order/genrate_online_order"
    
    static let paymentStatus         = "user_service/customer/payment/check_status"
    static let defaultAddress        = "user_service/customer/address/set_default_address"
    
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        return NetworkReachabilityManager()!.isReachable
        
    }
}

// MARK: - API Call Methods
struct ApiClient {
    
    
    func apiCallMethod(_ strUrl: String, method: HTTPMethod, parameter: [String : Any], successClosure: @escaping (AnyObject?) -> (), failureClosure: @escaping (String?) -> ()){
        
        let fullURL = URLMethods.BaseURL + strUrl
        print("\n\n\(fullURL)")
        
        let data = self.finalRequest(from: parameter)
        let params = parameter.count == 0 ? nil : data.parameters
        
        guard Reachability.isConnectedToNetwork() else {
            print("Active internet connection required");
            failureClosure("Active internet connection required")
            return
        }
        
        AF.request(fullURL, method: method, parameters: params, encoding: JSONEncoding.default, headers: data.headers).validate(statusCode: 200..<300).responseJSON { (response) in
            print("Response------",response)
            
            switch response.result {
            case .success(let json):
                
                guard let dictResponse = json as? NSDictionary, dictResponse is Dictionary<AnyHashable,Any> else {
                    AppManager.showToast("Data is not in correct format")
                    return
                }
                let dataString =  String(data: response.data!, encoding: String.Encoding.utf8)
                print(dataString ?? "")
                successClosure(dictResponse)
                
            case .failure(_ ):
                AppManager.stopActivityIndicator()
                
                if response.response?.statusCode == 402 || response.response?.statusCode == 401 || response.response?.statusCode == 403 {
                    AppManager.showToast("Your session has been expired, Please login again")
                    Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (timer) in
                        Constants.kSceneDelegate.switchToLoginVC()
                    }
                    return
                }
                
                if let data = response.data {
                    if let json = try? (JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary) {
                        let error = MyError(str: json["message"] as? String ?? "") as Error
                        print(error.localizedDescription)
                        failureClosure(error.localizedDescription)
                        return
                    }
                    failureClosure(AppString.somethingWentWrong)
                }
                
            }
        }
    }
    
    
    func api_MultipartData(_ strUrl: String, imageData: [String: UIImage], parameter: NSDictionary, successClosure: @escaping (AnyObject?) -> (), failureClosure: @escaping (String?) -> ())  {
        
        let fullURL = URLMethods.BaseURL + strUrl
        print("\n\n\(fullURL)")
        print(parameter)
        
        guard Reachability.isConnectedToNetwork() else {
            print("Active internet connection required");
            failureClosure("Active internet connection required")
            return
        }
        
        let cryptLib = CryptLib()
        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: String(Int64(Date().timeIntervalSince1970) * 1000), key: "keMStjdies")
        
        let header: HTTPHeaders = ["X-Access-Token" : cipherText!,
                                   "Authorization" : "Bearer \(Constants.kAppDelegate.user?.authToken ?? "")"]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as? String ?? "")
            }
            
            for (key, value) in imageData {
                if value.size.width != 0 {
                    multipartFormData.append(value.jpegData(compressionQuality: 0.5)!, withName: key, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
            }
            
        }, to: fullURL, method: .post , headers: header).validate(statusCode: 200..<300).responseJSON { (response) in
            print("Response------",response)
            
            switch response.result {
            case .success(let json):
                
                guard let dictResponse = json as? NSDictionary, dictResponse is Dictionary<AnyHashable,Any> else {
                    AppManager.showToast("Data is not in correct format")
                    return
                }
                let dataString =  String(data: response.data!, encoding: String.Encoding.utf8)
                print(dataString ?? "")
                successClosure(dictResponse)
                
            case .failure(_ ):
                AppManager.stopActivityIndicator()
                
                if let data = response.data {
                    if let json = try? (JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary) {
                        let error = MyError(str: json["message"] as? String ?? "") as Error
                        print(error.localizedDescription)
                        failureClosure(error.localizedDescription)
                        return
                    }
                    failureClosure(AppString.somethingWentWrong)
                }
                
            }
        }
    }
    
    
    
    // MARK: - FinalRequest
    func finalRequest(from parameters: [String:Any]) -> (parameters: [String:Any], headers: HTTPHeaders) {
        
        var params = [String:Any]()
        params = parameters
        /// Configure Headers
        let cryptLib = CryptLib()
        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: String(Int64(Date().timeIntervalSince1970) * 1000), key: "keMStjdies")
        
        var headers : HTTPHeaders = ["X-Access-Token" : cipherText!]
        
        //        print(Constants.kAppDelegate.user?.authToken as Any)
        if let token = Constants.kAppDelegate.user?.authToken {
            headers = ["Authorization": "Bearer \(token)",
                       "api_access_key" : ""]
        }
        /// Add Additional Parameters
        params["device_token"] = Constants.kfirebaseToken
        params["device_type"] = 2
        params["device_id"] = UIDevice.current.identifierForVendor?.uuidString
        //        params["language"] = "en"
        //params["auth_token"] = token
        
        let finalParameters = params
        
        /// Print Request
        print("""
            
            *** Headers:
            \(headers)
            
            *** Parameters:
            \(parameters)
            
            """)
        
        /// Return Parameters and Headers
        return (finalParameters, headers)
        
    }
    
}


class MyError: NSObject, LocalizedError {
    var desc = ""
    init(str: String) {
        desc = str
    }
    override var description: String {
        get {
            return "\(desc)"
        }
    }
    //You need to implement `errorDescription`, not `localizedDescription`.
    var errorDescription: String? {
        get {
            return self.description
        }
    }
}
