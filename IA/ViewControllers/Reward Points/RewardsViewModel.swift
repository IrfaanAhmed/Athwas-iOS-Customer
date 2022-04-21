//
//  RewardsViewModel.swift
//  IA
//
//  Created by admin on 20/01/21.
//  Copyright © 2021 octal. All rights reserved.
//

import Foundation


class RewardsViewModel {
    
    private var reward : [RewardPointsModel]? {
        didSet {
            guard let v = reward else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var rewards : [RewardPointsModel]?
    private var dataService: ApiClient?
    
    var showAlertClosure: (() -> ())?
    var didFinishFetch: (() -> ())?
    var isReload : Bool?
    var totalRewards = 0
    
    
    
    // MARK: - Constructor
    
    init(dataService: ApiClient) {
        self.dataService = dataService
    }
    
    func fetchRequestData(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .get, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            let data = response?.value(forKeyPath: "data.docs") as? [[String: Any]]
            self.totalRewards = response?.value(forKeyPath: "data.earnedPoints") as? Int ?? 0

            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.reward = try? jsonDecoder.decode([RewardPointsModel].self, from: jsonData!)
            
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
    
    private func setupData(_ data : [RewardPointsModel]) {
        self.rewards = data
    }

    
}


// MARK: - RewardPointsModel
struct RewardPointsModel: Codable {
    
    var id: String?
    var earnedPoints, redeemPoints, isExpired: Int?
    var userID, expirationDate, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case earnedPoints = "earned_points"
        case redeemPoints = "redeem_points"
        case userID = "user_id"
        case expirationDate = "expiration_date"
        case createdAt, updatedAt, isExpired
    }
}
