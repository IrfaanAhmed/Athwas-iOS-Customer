//
//  SimilarProductViewModel.swift
//  IA
//
//  Created by admin on 21/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class SimilarProductViewModel {
    
    private var product : [SimilarProductsModel]? {
        didSet {
            guard let v = product else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var products : [SimilarProductsModel]?
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
            let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
                
                let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
                let jsonDecoder = JSONDecoder()
                self.product = try? jsonDecoder.decode([SimilarProductsModel].self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [SimilarProductsModel]) {
        self.products = data
    }
    
}


// MARK: - SimilarProductsModel

struct SimilarProductsModel: Codable {
    
    var id, name: String?
    var images: [Image_SI]?
    var businessCategory, category, subcategory: Category_SI?
    var isDiscount, discountType : Int?
    var price, offerPrice, discountValue: Double?
    var inventoryName: String?


    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, images
        case businessCategory = "business_category"
        case category, subcategory, price
        case offerPrice = "offer_price"
        case isDiscount = "is_discount"
        case inventoryName = "inventory_name"
        case discountType = "discount_type"
        case discountValue = "discount_value"
    }
}

// MARK: - Category
struct Category_SI: Codable {
    var id, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - Image
struct Image_SI: Codable {
    var id: String?
    var productImageURL, productImageThumbURL: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productImageURL = "product_image_url"
        case productImageThumbURL = "product_image_thumb_url"
    }
}
