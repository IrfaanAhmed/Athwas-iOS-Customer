//
//  OrderHistoryViewModel.swift
//  IA
//
//  Created by admin on 10/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import Foundation
import UIKit

class OrderHistoryViewModel {
    
    private var orders : [OrderHistoryModel]? {
        didSet {
            guard let v = orders else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var ordersList : [OrderHistoryModel]?
    var orderDetail : OrderDetailModel?
    private var dataService: ApiClient?
    var isReload : Bool?
    
    var urlPath = ""
    
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
            self.orders = try? jsonDecoder.decode([OrderHistoryModel].self, from: jsonData!)
            
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
    
    private func setupData(_ data : [OrderHistoryModel]) {
        self.ordersList = data
    }
    
    
    func cancelOrder(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    func reviewOrder(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    
    func fetchRequestDetail(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            let data = response?.value(forKeyPath: "data") as? [String: Any]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.orderDetail = try? jsonDecoder.decode(OrderDetailModel.self, from: jsonData!)
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
    
    
    func downloadInnvoice(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            if let data = response?.value(forKeyPath: "data") as? [String: Any], let urlPath = data["path"] as? String {
                
                self.urlPath = urlPath
                self.didFinishFetch?()
            }
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
    
}


extension OrderDetailVC : URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("File Downloaded Location- ",  location)
        
        guard let url = downloadTask.originalRequest?.url else {
            return
        }
        let docsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationPath = docsPath.appendingPathComponent(url.lastPathComponent)
        
        try? FileManager.default.removeItem(at: destinationPath)
        
        do{
            try FileManager.default.copyItem(at: location, to: destinationPath)
            print("File Downloaded Location- ",  destinationPath)
            
            DispatchQueue.main.async {
                AppManager.showToast("Invoice downloaded successfully")
            }
            
        }catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
}





// MARK: - OrderHistoryModel
struct OrderHistoryModel: Codable {
    var orderStatus: Int?
    var currentTrackingStatus, paymentMode, id, userID: String?
    var orderID: Int?
    var totalAmount: Double?
    var discount, deliveryFee: Double?
    var netAmount, vatAmount: Double?
    var expectedStartDate, expectedEndDate, warehouseID, createdAt: String?
    var orderHistoryModelID: String?

    enum CodingKeys: String, CodingKey {
        case orderStatus = "order_status"
        case currentTrackingStatus = "current_tracking_status"
        case paymentMode = "payment_mode"
        case id = "_id"
        case userID = "user_id"
        case orderID = "order_id"
        case totalAmount = "total_amount"
        case discount
        case netAmount = "net_amount"
        case vatAmount = "vat_amount"
        case deliveryFee = "delivery_fee"
        case expectedStartDate = "expected_start_date"
        case expectedEndDate = "expected_end_date"
        case warehouseID = "warehouse_id"
        case createdAt
        case orderHistoryModelID = "id"
    }
}



// MARK: - OrderDetailModel

struct OrderDetailModel: Codable {
    var id: String?
    var category: [CategoryDetail]?
    var orderID: Int?
    var driver: [Driver]?
    var orderStatus: Int?
    var currentTrackingStatus: String?
    var trackingStatus: TrackingStatus?
    var paymentMode: String?
    var expectedStartDate, expectedEndDate: String?
    var totalAmount, discount, netAmount, redeemPoints : Double?
    var deliveryFee, vatAmount: Double?
    var deliveryAddress: DeliveryAddress?
    var orderDate, deliveredDate: String?
    var promoCode: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case category
        case orderID = "order_id"
        case driver
        case orderStatus = "order_status"
        case currentTrackingStatus = "current_tracking_status"
        case trackingStatus = "tracking_status"
        case paymentMode = "payment_mode"
        case promoCode = "promo_code"
        case totalAmount = "total_amount"
        case discount
        case netAmount = "net_amount"
        case vatAmount = "vat_amount"
        case redeemPoints = "redeem_points"
        case deliveryFee = "delivery_fee"
        case deliveryAddress = "delivery_address"
        case orderDate = "order_date"
        case expectedStartDate = "expected_start_date"
        case expectedEndDate = "expected_end_date"
        case deliveredDate = "delivered_date"
    }
}

// MARK: - Category
struct CategoryDetail: Codable {
    var id, name: String?
    var cancelationTime, returnTime, allReturn: Int?
    var categoryImage: String?
    var products: [Product]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case cancelationTime = "cancelation_time"
        case returnTime = "return_time"
        case allReturn = "all_return"
        case categoryImage = "category_image"
        case products
    }
}

// MARK: - Product
struct Product: Codable {
    var id: String?
    var images: [Image]?
    var productInventryData: ProductInventryData?
    var isActive, isDeleted: Int?
    var name, businessCategoryID, brandID, categoryID: String?
    var categoryData, subCategoryData: CategoryData?
    var subCategoryID, productDescription, createdAt, updatedAt: String?
    var quantity, isDiscount, orderStatus: Int?
    var price, offerPrice : Double?
    var inventoryID: String?
    
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
        case productDescription = "description"
        case createdAt, updatedAt
        case productInventryData
        case categoryData = "CategoryData"
        case subCategoryData = "SubCategoryData"
        case quantity
        case price
        case isDiscount = "is_discount"
        case offerPrice = "offer_price"
        case orderStatus = "order_status"
        case inventoryID = "inventory_id"
    }
}


// MARK: - CategoryData
struct CategoryData: Codable {
    var id, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - DeliveryAddress
struct DeliveryAddress: Codable {
    var id, fullAddress, addressType: String?
    var addressLocation: AddressLocation?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullAddress = "full_address"
        case addressType = "address_type"
        case addressLocation = "address_location"
    }
}


// MARK: - AddressLocation
struct AddressLocation: Codable {
    var type: String?
    var coordinates: [Double]?
    var id: String?

    enum CodingKeys: String, CodingKey {
        case type, coordinates
        case id = "_id"
    }
}


// MARK: - Driver
struct Driver: Codable {
    var id, username, phone: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, phone
    }
}


// MARK: - TrackingStatus
struct TrackingStatus: Codable {
    var acknowledged, packed, inTransit, delivered: Acknowledged?

    enum CodingKeys: String, CodingKey {
        case acknowledged = "Acknowledged"
        case packed = "Packed"
        case inTransit = "In_Transit"
        case delivered = "Delivered"
    }
}

// MARK: - Acknowledged
struct Acknowledged: Codable {
    var status: Int?
    var statusTitle, time: String?

    enum CodingKeys: String, CodingKey {
        case status
        case statusTitle = "status_title"
        case time
    }
}

// MARK: - ProductInventryData
struct ProductInventryData: Codable {
    var id, inventoryName: String?
    var review: [Review]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case inventoryName = "inventory_name"
        case review
    }
}

// MARK: - Review
struct Review: Codable {
    var id, userID: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "user_id"
    }
}
