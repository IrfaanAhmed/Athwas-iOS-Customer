//
//  WishlistViewModel.swift
//  IA
//
//  Created by admin on 20/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import Foundation
import UIKit


class WishlistViewModel {
    
    private var products : [ProductListDataModel]? {
        didSet {
            guard let v = products else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var productList : [ProductListDataModel]?
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
            self.products = try? jsonDecoder.decode([ProductListDataModel].self, from: jsonData!)
            
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
    
    func updateFavStatus(_ url : String, param: [String : Any]) {
        
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            let msg = response?.value(forKey: "message") as? String ?? ""
            AppManager.showToast(msg)
            self.didFinishFetch?()
        }, failureClosure: { (error) in
            self.error = error
        })
    }
    
    private func setupData(_ data : [ProductListDataModel]) {
        self.productList = data
    }
    
}
