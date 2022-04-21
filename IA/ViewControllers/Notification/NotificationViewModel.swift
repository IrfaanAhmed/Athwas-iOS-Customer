//
//  NotificationViewModel.swift
//  IA
//
//  Created by admin on 28/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class NotificationViewModel {
    
    private var Notification : [NotificationListModel]? {
        didSet {
            guard let v = Notification else { return }
            self.setupData(v)
            self.didFinishFetch?()
        }
    }
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var notifications : [NotificationListModel]?
    private var dataService: ApiClient?
    
    var showAlertClosure: (() -> ())?
    var didFinishFetch: (() -> ())?
    var isReload : Bool?
    
    
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
            self.Notification = try? jsonDecoder.decode([NotificationListModel].self, from: jsonData!)
            
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
    
    private func setupData(_ data : [NotificationListModel]) {
        self.notifications = data
    }
    
    
    func deleteNotifcationtData(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .delete, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }

    
}

// MARK: - NotificationListModel

struct NotificationListModel: Codable {
    var id: String?
    var readStatus, notificationType: Int?
    var title, message, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case readStatus = "read_status"
        case notificationType = "notification_type"
        case title, message, createdAt
    }
}
