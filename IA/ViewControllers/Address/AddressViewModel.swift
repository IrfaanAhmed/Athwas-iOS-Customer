//
//  AddressViewModel.swift
//  IA
//
//  Created by Yogesh Raj on 16/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class AddressViewModel: NSObject {
    
    private var address: [AddressDataModel]? {
        didSet {
            guard let v = address else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var addresses : [AddressDataModel]?
    private var dataService: ApiClient?
    
    var showAlertClosure: (() -> ())?
    var didFinishFetch: (() -> ())?
    
    
    // MARK: - Constructor
    
    init(dataService: ApiClient) {
        self.dataService = dataService
    }
    
    func fetchRequestData(_ url : String, param: [String : Any], pages: Int) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            
            do {
                let data = response?.value(forKeyPath: "data.addresslist") 
                let jsonData  = try JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
                let jsonDecoder = JSONDecoder()
                self.address = try jsonDecoder.decode([AddressDataModel].self, from: jsonData)
            } catch {
                AppManager.showToast("Data is not in correct format")
            }
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    private func setupData(_ data : [AddressDataModel]) {
        self.addresses = data
    }
    
    
    func setDefaultAddress(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
}


// MARK: - AddressDataModel
struct AddressDataModel: Codable {
    var type: String?
    var geoLocation: GeoLocation?
    var id, userID, locationName, mobile: String?
    var floor, way, building, addressType: String?
    var flat, landmark, fullAddress, zipCode: String?
    var defaultAddress: Int?

    enum CodingKeys: String, CodingKey {
        case type, geoLocation
        case id = "_id"
        case userID = "user_id"
        case locationName = "location_name"
        case mobile, floor, way, building
        case addressType = "address_type"
        case zipCode = "zip_code"
        case flat, landmark
        case fullAddress = "full_address"
        case defaultAddress = "default_address"
    }
}

// MARK: - GeoLocation
struct GeoLocation: Codable {
    var type: String?
    var coordinates: [Double]?
    var id: String?

    enum CodingKeys: String, CodingKey {
        case type, coordinates
        case id = "_id"
    }
}
