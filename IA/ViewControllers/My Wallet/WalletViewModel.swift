//
//  WalletViewModel.swift
//  IA
//
//  Created by Yogesh Raj on 14/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class WalletViewModel: NSObject {
    
    private var wallet: [WalletDataModel]? {
        didSet {
            guard let v = wallet else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var wallets : [WalletDataModel]?
    var walletAmount: Double!
    var isReload : Bool?
    private var dataService: ApiClient?
    
    var showAlertClosure: (() -> ())?
    var didFinishFetch: (() -> ())?
    
    
    // MARK: - Constructor
    
    init(dataService: ApiClient) {
        self.dataService = dataService
    }
    
    func fetchRequestData(_ url : String, param: [String : Any], pages: Int) {
        
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            
            // let data = (response as? NSDictionary)?["data"]
            self.walletAmount = response?.value(forKeyPath: "data.user_wallet") as? Double
            let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.wallet = try! jsonDecoder.decode([WalletDataModel].self, from: jsonData!)
            let currentPage = Int.convertToInt(anyValue: response?.value(forKeyPath: "data.page") as Any)
            let noOfPages = Int.convertToInt(anyValue: response?.value(forKeyPath: "data.totalPages") as Any)
            self.isReload = false
            if currentPage < noOfPages {
                self.isReload = true
            }
            
        }, failureClosure: { (error) in
            self.error = error
        })
    }
    
    private func setupData(_ data : [WalletDataModel]) {
        self.wallets = data
    }
    
}

struct WalletDataModel: Codable {
    var id, amount, userID, transitionID: String?
    var reason, senderID: String?
    var userType, amountType, requestType: Int?
    var createdAt: String?
    var user: User?
    var orderID: MyValue?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case amount
        case userID = "user_id"
        case transitionID = "transition_id"
        case reason
        case senderID = "sender_id"
        case userType = "user_type"
        case amountType = "amount_type"
        case requestType = "request_type"
        case orderID = "order_id"
        case createdAt, user
    }
}

// MARK: - User
struct User: Codable {
    var id, username: String?
    var phone: String?
    var email: String?
    var wallet: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, phone, email,wallet
    }
}


enum MyValue: Codable {
    
    case string(String)
    
    var stringValue: String? {
        switch self {
        case .string(let s):
            return s
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .string("\(x)")
            return
        }
        throw DecodingError.typeMismatch(MyValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MyValue"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        }
    }
}

/*enum OrderID: Codable {
 case integer(Int)
 case string(String)
 
 init(from decoder: Decoder) throws {
 let container = try decoder.singleValueContainer()
 if let x = try? container.decode(Int.self) {
 self = .integer(x)
 return
 }
 if let x = try? container.decode(String.self) {
 self = .string(x)
 return
 }
 throw DecodingError.typeMismatch(OrderID.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for OrderID"))
 }
 
 func encode(to encoder: Encoder) throws {
 var container = encoder.singleValueContainer()
 switch self {
 case .integer(let x):
 try container.encode(x)
 case .string(let x):
 try container.encode(x)
 }
 }
 }*/


