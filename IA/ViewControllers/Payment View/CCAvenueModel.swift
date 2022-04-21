//
//  CCAvenueModel.swift
//  IA
//
//  Created by admin on 22/06/21.
//  Copyright © 2021 octal. All rights reserved.
//

import Foundation
import UIKit


private let accessCode = "AVTL07ID25BH87LTHB"
//private let rsaURLKey = "https://secure.ccavenue.com/transaction/getRSAKey" //-> Live
private let rsaURLKey = "https://test.ccavenue.com/transaction/getRSAKey" //-> Sandbox
private let currency = "INR"
private let merchantID = "376194"
private let rediectURL = "http://3.7.83.168:3060/user_service/customer/payment/complete_payment" // -> Payment Success URL
private let cancelURL = "http://3.7.83.168:3060/user_service/customer/payment/complete_payment"  // ->
//private let transURL =  "https://secure.ccavenue.com/transaction/initTrans" //-> Live
private let transURL =  "https://test.ccavenue.com/transaction/initTrans" //-> Sandbox



class CCAvenueModel {
    
    var error: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var msg: String? {
        didSet { self.showAlertClosure?() }
    }
    
    var showAlertClosure: (() -> ())?
    var didFinishFetch: (() -> ())?
    
    var responeRequest : NSMutableURLRequest? = nil
    private var dataService: ApiClient?
    var paymentData : PaymentDataModel?

    // MARK: - Constructor
    
    init(dataService: ApiClient) {
        self.dataService = dataService
    }
    
    func getRSAKey(_ orderID: String, amount: Double, merchnt_param: String)  {
        
        guard Reachability.isConnectedToNetwork() else {
            self.error = "Active internet connection required"
            return
        }
        
        AppManager.startActivityIndicator()
        let serialQueue = DispatchQueue(label: "serialQueue", qos: .userInitiated)
        
        serialQueue.sync {
            let rsaKeyDataStr = "access_code=\(accessCode)&order_id=\(orderID)"
            
            let requestData = rsaKeyDataStr.data(using: String.Encoding.utf8)
            
            guard let urlFromString = URL(string: rsaURLKey) else{
                return
            }
            var urlRequest = URLRequest(url: urlFromString)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = requestData
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            print("session",session)
            
            
            session.dataTask(with: urlRequest as URLRequest) {
                (data, response, error) -> Void in
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode{
                    
                    guard let data = data else{
                        print("Not proper data for RSA Key")
                        return
                    }
                    print("RSA Key data :: ",data)
                    self.encyptCardDetails(data: data, orderID: orderID, amount: amount, merchnt_param: merchnt_param)
                }
                else{
                    print("Unable to generate RSA Key please check")
                    self.error = "Unable to generate RSA Key please check"
                }
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator()
                }
                
            }.resume()
        }
    }
    
    
    
    private func encyptCardDetails(data: Data, orderID: String, amount: Double, merchnt_param: String){
        
        guard let rsaKeytemp = String(bytes: data, encoding: String.Encoding.ascii) else{
            print("No value for rsaKeyTemp")
            return
        }
        var rsaKey = rsaKeytemp
        rsaKey = rsaKey.trimmingCharacters(in: CharacterSet.newlines)
        rsaKey =  "-----BEGIN PUBLIC KEY-----\n\(rsaKey)\n-----END PUBLIC KEY-----\n"
        print("rsaKey :: ",rsaKey)
        
        let myRequestString = "amount=\(amount)&currency=\(currency)"
        
        let ccTool = CCTool()
        var encVal = ccTool.encryptRSA(myRequestString, key: rsaKey)
        
        encVal = CFURLCreateStringByAddingPercentEscapes(
            nil,
            encVal! as CFString,
            nil,
            "!*'();:@&=+$,/?%#[]" as CFString,
            CFStringBuiltInEncodings.UTF8.rawValue) as String?
        
        //Preparing for webview call
        let urlAsString = transURL
        let encryptedStr = "merchant_id=\(merchantID)&order_id=\(orderID)&redirect_url=\(rediectURL)&cancel_url=\(cancelURL)&enc_val=\(encVal!)&access_code=\(accessCode)&merchant_param1=\(merchnt_param)&merchant_param2=\(Constants.kAppDelegate.user?.id ?? "")"
        
        print("encValue :: \(encVal ?? "No val for encVal")")
        
        print("encryptedStr :: ",encryptedStr)
        let myRequestData = encryptedStr.data(using: String.Encoding.utf8)
        // request = NSMutableURLRequest(url: URL(string: urlAsString)!)
        
        let request : NSMutableURLRequest? = NSMutableURLRequest(url: URL(string: urlAsString)! as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30)
        
        request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request?.setValue(urlAsString, forHTTPHeaderField: "Referer")
        request?.httpMethod = "POST"
        request?.httpBody = myRequestData
        print("\n\nwebview :: ",request?.url as Any)
        print("\n\nwebview :: ",request?.description as Any)
        print("\n\nwebview :: ",request?.httpBody?.description as Any)
        print("\n\nwebview :: ",request?.allHTTPHeaderFields! as Any)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        session.dataTask(with: request! as URLRequest) {
            (data, response, error) -> Void in
            
            if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode{
                
                guard let data = data else{
                    print("No value for data")
                    return
                }
                DispatchQueue.main.async {
                    self.responeRequest = request
                    self.didFinishFetch?()
                }
                print("Payment gateway data :: ",data)
            }
            else{
                print("Unable to load webpage currently, Please try again later.")
                self.error = "Unable to load webpage currently, Please try again later."
            }
            
        }.resume()
                
    }
    
    
    func checkPaymentStatus(_ url : String, param: [String : Any]) {
        
        AppManager.startActivityIndicator()
        self.dataService?.apiCallMethod(url, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            let data = response?.value(forKeyPath: "data") as? [String: Any]
            let jsonData  = try? JSONSerialization.data(withJSONObject: data as Any, options:.prettyPrinted)
            let jsonDecoder = JSONDecoder()
            self.paymentData = try? jsonDecoder.decode(PaymentDataModel.self, from: jsonData!)
            self.didFinishFetch?()
            
        }, failureClosure: { (error) in
            AppManager.stopActivityIndicator()
            self.error = error
        })
    }
}





// MARK: - PaymentDataModel
struct PaymentDataModel: Codable {
    
    var amount, walletAmount, id, userID: String?
    var userType: Int?
    var transitionID, reason, paymentType, paymentFor: String?
    var amountType, requestType: Int?
    var orderID, paymentTransactionID, createdAt, updatedAt: String?
    var v: Int?
    var paymentDataModelID: String?

    enum CodingKeys: String, CodingKey {
        case amount
        case walletAmount = "wallet_amount"
        case id = "_id"
        case userID = "user_id"
        case userType = "user_type"
        case transitionID = "transition_id"
        case reason
        case paymentType = "payment_type"
        case paymentFor = "payment_for"
        case amountType = "amount_type"
        case requestType = "request_type"
        case orderID = "order_id"
        case paymentTransactionID = "payment_transaction_id"
        case createdAt, updatedAt
        case v = "__v"
        case paymentDataModelID = "id"
    }
}
