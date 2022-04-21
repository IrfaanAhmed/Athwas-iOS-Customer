//
//  FilterViewModel.swift
//  IA
//
//  Created by admin on 04/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import Foundation
import UIKit

class FilterViewModel {
    
    private var categories : [FilterCustomType]? {
        didSet {
            guard let v = categories else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    private var subCategories : [FilterCustomSubType]? {
        didSet {
            guard let v = subCategories else { return }
            self.setupData_1(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var filterList : [FilterCustomType]?
    var filterSubCatList : [FilterCustomSubType]?
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
            self.categories = try? jsonDecoder.decode([FilterCustomType].self, from: jsonData!)
            
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    func fetchRequestSubCategoryData(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            let data = response?.value(forKeyPath: "data.customizationsub_type") as? [[String: Any]]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.subCategories = try? jsonDecoder.decode([FilterCustomSubType].self, from: jsonData!)
            
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [FilterCustomType]) {
        self.filterList = data
    }
    
    private func setupData_1(_ data : [FilterCustomSubType]) {
        self.filterSubCatList = data
    }
}


struct FilterCustomType: Codable {
    var id, name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}


struct FilterCustomSubType: Codable {
    var id, name: String?
    var isSelected = false
    
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}
