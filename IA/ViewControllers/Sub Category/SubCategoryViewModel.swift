//
//  SubCategoryViewModel.swift
//  IA
//
//  Created by Yogesh Raj on 06/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class SubCategoryViewModel {
    
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
