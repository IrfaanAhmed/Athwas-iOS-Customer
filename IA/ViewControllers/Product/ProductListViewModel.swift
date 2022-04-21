//
//  ProductListViewModel.swift
//  IA
//
//  Created by admin on 12/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import Foundation
import UIKit



class ProductListViewModel {
    
    private var products : [ProductListDataModel]? {
        didSet {
            guard let v = products else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var productList : [ProductListDataModel]?
    private var dataService: ApiClient?
    var isReload : Bool?
    
    var showAlertClosure: (() -> ())?
    var didFinishFetch: (() -> ())?
    
    
    // MARK: - Constructor
    
    init(dataService: ApiClient) {
        self.dataService = dataService
    }
    
    func fetchRequestData(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.products = try? jsonDecoder.decode([ProductListDataModel].self, from: jsonData!)
            let currentPage = Int.convertToInt(anyValue: response?.value(forKeyPath: "data.page") as Any)
            let noOfPages = Int.convertToInt(anyValue: response?.value(forKeyPath: "data.totalPages") as Any)
            
            self.isReload = false
            if currentPage < noOfPages {
                self.isReload = true
            }
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    func fetchRequestOtherData(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.products = try? jsonDecoder.decode([ProductListDataModel].self, from: jsonData!)
            let currentPage = Int.convertToInt(anyValue: response?.value(forKeyPath: "data.page") as Any)
            let noOfPages = Int.convertToInt(anyValue: response?.value(forKeyPath: "data.totalPages") as Any)
            
            self.isReload = false
            if currentPage < noOfPages {
                self.isReload = true
            }
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    func fetchRequestDetailData(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data.productInventoriesData") as? [[String: Any]]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.products = try? jsonDecoder.decode([ProductListDataModel].self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    func updateFavStatus(_ url : String, param: [String : Any]) {
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            if let dic = response as? NSDictionary{
                AppManager.showToast(dic.value(forKey: "message") as! String)
            }
            self.didFinishFetch?()
        }, failureClosure: { (error) in
            self.error = error
        })
    }
    
    func additem_cart(_ url : String, param: [String : Any])  {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            if let dic = response as? NSDictionary{
                AppManager.showToast(dic.value(forKey: "message") as! String)
            }
            AppManager.stopActivityIndicator()
            let data = (response as? NSDictionary)?.value(forKey: "data") as? NSDictionary
            
            if let count = (data?["cart_count"] as? Int) {
                var userData = Constants.kAppDelegate.user
                userData?.cartCount = count
                Constants.kAppDelegate.user = userData
            }
            
            self.didFinishFetch?()
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    func notifyProduct(_ url : String, param: [String : Any])  {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            if let dic = response as? NSDictionary{
                AppManager.showToast(dic.value(forKey: "message") as! String)
            }
            AppManager.stopActivityIndicator()
            self.didFinishFetch?()
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    private func setupData(_ data : [ProductListDataModel]) {
        self.productList = data
    }
    
}


// MARK: - ProductListDataModel
struct ProductListDataModel: Codable {
    var id, productID, name, mainProductID, inventoryID : String?
    var images: [Image]?
    var businessCategory, category, subcategory: Category?
    var price, offerPrice, discountValue : Double?
    var isFavourite, availableQuantity: Int?
    var inventoryName: String?
    var isDiscount, discountType : Int?
    var rating: String?
    var isActive: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, images
        case businessCategory = "business_category"
        case category, subcategory, price
        case isFavourite = "is_favourite"
        case productID = "product_id"
        case inventoryID = "inventory_id"
        case offerPrice = "offer_price"
        case isDiscount = "is_discount"
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case inventoryName = "inventory_name"
        case mainProductID = "main_product_id"
        case availableQuantity = "available_quantity"
        case rating
        case isActive = "is_active"
        
    }
}

// MARK: - Category
struct Category: Codable {
    var id, name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - Image
struct Image: Codable {
    var id: String?
    var productImageURL, productImageThumbURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productImageURL = "product_image_url"
        case productImageThumbURL = "product_image_thumb_url"
    }
}
