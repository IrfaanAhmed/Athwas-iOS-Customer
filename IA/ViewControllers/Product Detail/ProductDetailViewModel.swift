//
//  ProductDetailViewModel.swift
//  IA
//
//  Created by admin on 16/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit


class ProductDetailViewModel {
    
    private var product : ProductDetailModel? {
        didSet {
            guard let v = product else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var productData : ProductDetailModel?
    private var dataService: ApiClient?
    
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
            let data = response?.value(forKeyPath: "data.product")
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.product = try? jsonDecoder.decode(ProductDetailModel.self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : ProductDetailModel) {
        self.productData = data
    }
    
}

// MARK: - ProductDetailModel

struct ProductDetailModel: Codable {
    var id, name: String?
    var offerPrice, price, discountValue : Double?
    var quantity, minInventory, availble: Int?
    var productCode, mainProductID : String?
    var images: [Images]?
    var businessCategory, category, subcategory: BusinessCategory?
    var customizations: [Customization]?
    var productDetailModelDescription: String?
    var isFavourite: Int?
    var rating, ratingCount: String?
    var brand: Brand?
    var inventoryName: String?
    var isDiscount, discountType : Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, price, quantity
        case minInventory = "min_inventory"
        case productCode = "product_code"
        case images
        case businessCategory = "business_category"
        case category, subcategory, customizations
        case productDetailModelDescription = "description"
        case isFavourite = "is_favourite"
        case brand, availble
        case offerPrice = "offer_price"
        case rating, ratingCount
        case mainProductID = "main_product_id"
        case inventoryName = "inventory_name"
        case isDiscount = "is_discount"
        case discountType = "discount_type"
        case discountValue = "discount_value"
    }
}

// MARK: - Brand
struct Brand: Codable {
    var id, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - BusinessCategory
struct BusinessCategory: Codable {
    var id, name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - Customization
struct Customization: Codable {
    var id: String?
    var title: Title?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
    }
}

// MARK: - Title
struct Title: Codable {
    var id, name: String?
    var value: BusinessCategory?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, value
    }
}

// MARK: - Image
struct Images: Codable {
    var id: String?
    var productImageURL, productImageThumbURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productImageURL = "product_image_url"
        case productImageThumbURL = "product_image_thumb_url"
    }
}


