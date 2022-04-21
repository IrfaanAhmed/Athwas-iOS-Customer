//
//  BannerViewModel.swift
//  IA
//
//  Created by Yogesh Raj on 21/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class BannerViewModel {
    
    private var banner: [BannerDataModel]? {
        didSet {
            guard let v = banner else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var banners : [BannerDataModel]?
    var deals : [DealsDataModel]?
    
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
            do {
                let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
                let jsonData  = try JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
                let jsonDecoder = JSONDecoder()
                self.banner = try jsonDecoder.decode([BannerDataModel].self, from: jsonData)
            } catch {
                AppManager.showToast("Data is not in correct format")
            }
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [BannerDataModel]) {
        self.banners = data
    }
    
    
    func fetchDealsRequestData(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            do {
                let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
                let jsonData  = try JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
                let jsonDecoder = JSONDecoder()
                self.deals = try jsonDecoder.decode([DealsDataModel].self, from: jsonData)
                self.didFinishFetch?()
                
            } catch {
                AppManager.showToast("Data is not in correct format")
            }
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }

    
    
}

// MARK: - BannerDataModel
struct BannerDataModel: Codable {
    
    var bannerDataModelDescription, id, title: String?
    var bannerImageURL, bannerImageThumbURL: String?
    var businessCategory, category, subcategory, product: BusinessCategory?
    var isActive: Int?

    enum CodingKeys: String, CodingKey {
        case bannerDataModelDescription = "description"
        case id = "_id"
        case title
        case bannerImageURL = "banner_image_url"
        case bannerImageThumbURL = "banner_image_thumb_url"
        case businessCategory = "business_category"
        case category, subcategory, product
        case isActive = "is_active"
    }
}


// MARK: - DealsDataModel
struct DealsDataModel: Codable {
    
    var dealsDataModelDescription, id, title: String?
    var imageURL, imageThumbURL: String?
    var businessCategory, category, subcategory: BusinessCategory?
    var isActive: Int?

    enum CodingKeys: String, CodingKey {
        case dealsDataModelDescription = "description"
        case id = "_id"
        case title
        case imageURL = "image_url"
        case imageThumbURL = "image_thumb_url"
        case businessCategory = "business_category"
        case category, subcategory
        case isActive = "is_active"
    }
}
