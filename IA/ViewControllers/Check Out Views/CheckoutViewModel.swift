//
//  CheckoutViewModel.swift
//  IA
//
//  Created by admin on 24/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import Foundation
import UIKit




protocol CheckoutModel {
    
    var message : String {get set}
    var isValid :Bool { mutating get }
}


struct CheckoutValidate : CheckoutModel {
    
    var message: String = ""
    var mobile :String = ""
    var name :String = ""
    var activeField: BindingTextField?
    var mobileField = BindingTextField()
    var nameField = BindingTextField()
    
    var isValid :Bool {
        mutating get {
            
            self.message = ""
            self.validate()
            return self.message.count == 0 ? true : false
        }
    }
    
    mutating func validate() {
        
        if name.isEmptyString() && !mobile.isEmptyString() {
            message = AppString.msgName
            activeField = nameField
            return
        }
        
        if mobile.isEmptyString() && !name.isEmptyString() {
            message = AppString.msgPhone
            activeField = mobileField
            return
        }
        
        if (mobile.count != 10) && !name.isEmptyString() {
            message = AppString.msgVaildPhone
            activeField = mobileField
            return
        }
    }
}



class CheckoutViewModel {
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var msg: String? {
        didSet { self.showAlertClosure?() }
    }
    private var dataService: ApiClient?
    
    var deliveryFee : DeliveryFeeModel?
    var promoCode : PormoCodeModel?
    var orderData : [String : Any]?
    
    var showAlertClosure: (() -> ())?
    var didFinishFetch: (() -> ())?

    
    // MARK: - Constructor
    
    init(dataService: ApiClient) {
        self.dataService = dataService
    }
    
    func getDeliveryCharges(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data") as? [String: Any]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.deliveryFee = try? jsonDecoder.decode(DeliveryFeeModel.self, from: jsonData!)
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    func checkoutProcess(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            self.msg = response?["message"] as? String
            self.error = nil
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    func applyPromoCode(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data") as? [String: Any]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.promoCode = try? jsonDecoder.decode(PormoCodeModel.self, from: jsonData!)
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    func generateOrder(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data") as? [String: Any]
            self.orderData = data ?? [:]
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
}


// MARK: - DeliveryFeeModel

struct DeliveryFeeModel: Codable {
    var deliveryFee, wallet, redeemPoint: Double?
    var warehouse: String?
    var vat: Int?
    var vatAmount: Double?

    enum CodingKeys: String, CodingKey {
        case deliveryFee = "delivery_fee"
        case redeemPoint = "redeem_point"
        case warehouse, wallet, vat
        case vatAmount = "vat_amount"
    }
}



// MARK: - PormoCodeModel
struct PormoCodeModel: Codable {
    var id: String?
    var discountPrice: Double?
    var promoCode, offerType: String?

    enum CodingKeys: String, CodingKey {
        case id
        case discountPrice = "discount_price"
        case promoCode = "promo_code"
        case offerType = "offer_type"
    }
}
