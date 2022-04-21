//
//  CustomizeViewModel.swift
//  IA
//
//  Created by admin on 23/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CustomizationViewModel {
    
    private var product : [CustomizationListModel]? {
        didSet {
            guard let v = product else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var products : [CustomizationListModel]?
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
            let data = response?.value(forKeyPath: "data") as? [[String: Any]]
                
                let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
                let jsonDecoder = JSONDecoder()
                self.product = try? jsonDecoder.decode([CustomizationListModel].self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [CustomizationListModel]) {
        self.products = data
    }
    
}

// MARK: - CustomizationListModel
struct CustomizationListModel: Codable {
    var id, name, inventoryName: String?
    var customize: [Customize]?
    var images: String?
    var price, isDiscount, discountType, discountValue: Double?
    var offerPrice: Double?
    var isSelected = false

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case inventoryName = "inventory_name"
        case customize, images, price
        case isDiscount = "is_discount"
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case offerPrice = "offer_price"
    }
}

// MARK: - Customize
struct Customize: Codable {
    var id, name: String?
    var value: Value?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, value
    }
}

// MARK: - Value
struct Value: Codable {
    var id, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}
