//
//  OfferViewModel.swift
//  IA
//
//  Created by admin on 18/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import Foundation
import UIKit

class OfferViewModel {
    
    private var offers : [OfferListModel]? {
        didSet {
            guard let v = offers else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var offerList : [OfferListModel]?
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
            if let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]] {
                let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
                let jsonDecoder = JSONDecoder()
                self.offers = try? jsonDecoder.decode([OfferListModel].self, from: jsonData!)
            }

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
    
    
    private func setupData(_ data : [OfferListModel]) {
        self.offerList = data
    }
    
}

// MARK: - OfferListModel
struct OfferListModel: Codable {
    
    var offerType, offerListModelDescription, startDate, endDate: String?
    var id, couponCode, title: String?
    var productID: [String]?
    var image, imageThumbURL: String?
    var isActive: Int?
    var product: [OfferProductDataModel]?

    enum CodingKeys: String, CodingKey {
        case offerType = "offer_type"
        case offerListModelDescription = "description"
        case startDate, endDate, product
        case id = "_id"
        case couponCode = "coupon_code"
        case title, image
        case imageThumbURL = "image_path_thumb_url"
        case isActive = "is_active"
        case productID = "product_id"
    }
}


// MARK: - OfferProductDataModel
struct OfferProductDataModel: Codable {
    var id: String?
    var isActive, isDeleted: Int?
    var productID: String?
    var price: Double?
    var offerProductDataModelID: String?
    var offerPrice: Double?
    var discountType, availableQuantity: Int?
    var discountValue: Double?
    var isDiscount: Int?
    var productData: [ProductDatum]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isActive = "is_active"
        case isDeleted = "is_deleted"
        case productID = "product_id"
        case price
        case offerProductDataModelID = "id"
        case offerPrice = "offer_price"
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case isDiscount = "is_discount"
        case availableQuantity = "available_quantity"
        case productData
    }
}

// MARK: - ProductDatum
struct ProductDatum: Codable {
    var id: String?
    var images: [Image]?
    var isActive, isDeleted: Int?
    var name, businessCategoryID, brandID, categoryID: String?
    var subCategoryID, productDatumDescription, createdAt, updatedAt: String?
    var v: Int?
    var category, subcategory: Category?
    

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case images
        case isActive = "is_active"
        case isDeleted = "is_deleted"
        case name
        case businessCategoryID = "business_category_id"
        case brandID = "brand_id"
        case categoryID = "category_id"
        case subCategoryID = "sub_category_id"
        case productDatumDescription = "description"
        case createdAt, updatedAt
        case category, subcategory
    }
}

