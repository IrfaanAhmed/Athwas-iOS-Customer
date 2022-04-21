//
//  SubCategoryViewModel.swift
//  IA
//
//  Created by Yogesh Raj on 06/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CategoryViewModel {
    
    private var category: [ProductCategoryDataModel]? {
        didSet {
            guard let v = category else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var businessCategory : [ProductCategoryDataModel]?
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
            self.category = try? jsonDecoder.decode([ProductCategoryDataModel].self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [ProductCategoryDataModel]) {
        self.businessCategory = data
    }
    
}


// MARK: - ProductCategoryDataModel
struct ProductCategoryDataModel: Codable {
    var parentID, id, name: String?
    var businessCategoryID: BusinessCategoryID?
    var createdAt, updatedAt, imagePath: String?
    var imagePathURL, imagePathThumbURL: String?
    var productCategoryDataModelID: String?
    
    enum CodingKeys: String, CodingKey {
        case parentID = "parent_id"
        case id = "_id"
        case name
        case businessCategoryID = "business_category_id"
        case createdAt, updatedAt
        case imagePath = "image_path"
        case imagePathURL = "image_path_url"
        case imagePathThumbURL = "image_path_thumb_url"
        case productCategoryDataModelID = "id"
    }
}

// MARK: - BusinessCategoryID

struct BusinessCategoryID: Codable {
    var id, name: String?
    var categoryImageURL, categoryImageThumbURL: String?
    var businessCategoryIDID: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case categoryImageURL = "category_image_url"
        case categoryImageThumbURL = "category_image_thumb_url"
        case businessCategoryIDID = "id"
    }
}
