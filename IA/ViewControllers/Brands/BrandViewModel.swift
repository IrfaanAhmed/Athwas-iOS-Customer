//
//  BrandViewModel.swift
//  IA
//
//  Created by admin on 14/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class BrandViewModel {
    
    private var brand: [BrandDataModel]? {
        didSet {
            guard let v = brand else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var brands : [BrandDataModel]?
    private var dataService: ApiClient?
    
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
            self.brand = try? jsonDecoder.decode([BrandDataModel].self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [BrandDataModel]) {
        self.brands = data
    }
    
}

// MARK: - BrandDataModel

struct BrandDataModel: Codable {
    var isActive, isDeleted: Int?
    var id, name, createdAt, updatedAt: String?
    var v: Int?
    var imagePath: String?
    var imagePathURL, imagePathThumbURL: String?
    var brandDataModelID: String?
    
    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
        case isDeleted = "is_deleted"
        case id = "_id"
        case name, createdAt, updatedAt
        case v = "__v"
        case imagePath = "image_path"
        case imagePathURL = "image_path_url"
        case imagePathThumbURL = "image_path_thumb_url"
        case brandDataModelID = "id"
    }
}
