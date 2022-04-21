//
//  CartViewModel.swift
//  IA
//
//  Created by admin on 03/11/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CartViewModel {
    
    private var items : [CartItemsModel]? {
        didSet {
            guard let v = items else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    var cart_items : [CartItemsModel]?
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
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.items = try? jsonDecoder.decode([CartItemsModel].self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    func deleteCartItem(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .delete, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            let data = (response as? NSDictionary)?.value(forKey: "data") as? NSDictionary
            
            if let count = (data?["cart_count"] as? Int) {
                var userData = Constants.kAppDelegate.user
                userData?.cartCount = count == 0 ? nil : count
                Constants.kAppDelegate.user = userData
            }
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    func updateCartItem(_ url : String, param: [String : Any]) {
        self.dataService?.apiCallMethod(url, method: .put, parameter: param, successClosure: { (response) in
       
            self.didFinishFetch?()
        }, failureClosure: { (error) in
            self.error = error
        })
    }
    
    private func setupData(_ data : [CartItemsModel]) {
        self.cart_items = data
    }
    
}

// MARK: - CartItemsModel
struct CartItemsModel: Codable {
    var id: ID?
    var categoryItems: [CategoryItem]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryItems = "category_items"
    }
}

// MARK: - CategoryItem
struct CategoryItem: Codable {
    var id, cartID, productID, inventoryID: String?
    var availableQuantity, isDiscount, discountType: Int?
    var minInventory, quantity, availble: Int?
    var name, inventoryName: String?
    var images: [Image]?
    var businessCategory, category, subcategory: ID?
    var price, offerPrice, discountValue : Double?
    var categoryItemDescription, rating: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case cartID = "cart_id"
        case productID = "product_id"
        case inventoryID = "inventory_id"
        case quantity
        case minInventory = "min_inventory"
        case availableQuantity = "available_quantity"
        case name
        case inventoryName = "inventory_name"
        case images
        case isDiscount = "is_discount"
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case businessCategory = "business_category"
        case category, subcategory, price
        case categoryItemDescription = "description"
        case offerPrice = "offer_price"
        case rating, availble
    }
}

// MARK: - ID
struct ID: Codable {
    var id, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

