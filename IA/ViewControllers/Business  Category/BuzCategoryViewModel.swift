//
//  CategoryViewModel.swift
//  IA
//
//  Created by Yogesh Raj on 06/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class BuzCategoryViewModel {
    
    private var category: [BusinessCatDataModel]? {
        didSet {
            guard let v = category else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var businessCategory : [BusinessCatDataModel]?
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
            self.category = try? jsonDecoder.decode([BusinessCatDataModel].self, from: jsonData!)
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [BusinessCatDataModel]) {
        self.businessCategory = data
    }
    
}



// MARK: - BusinessCatDataModel
struct BusinessCatDataModel: Codable {
    let id, name, createdAt, updatedAt: String
    let categoryImage: String
    let categoryImageURL, categoryImageThumbURL: String
    let businessCatDataModelID: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, createdAt, updatedAt
        case categoryImage = "category_image"
        case categoryImageURL = "category_image_url"
        case categoryImageThumbURL = "category_image_thumb_url"
        case businessCatDataModelID = "id"
    }
}
