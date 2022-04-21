//
//  AppManager.swift
//  Mozzaa
//
//  Created by Yogesh Raj on 23/04/19.
//  Copyright © 2019 Yogesh Raj. All rights reserved.
//

import UIKit
import Toast_Swift
import CoreLocation
import MBProgressHUD


class AppManager {
    
    // MARK: - Save Remember me
    public class func saveEmailPassword(email :String, password: String) {
        
        UserDefaults.standard.set(email, forKey: "remember_email")
        UserDefaults.standard.set(password, forKey: "remember_password")
    }
    
    
    // MARK: - UIView+Toast
    public class func showToast(_ msg: String) {
        Constants.kSceneDelegate.window?.hideAllToasts()
        Constants.kSceneDelegate.window?.makeToast(msg, duration: 3.0, position: .bottom)
    }
    
    // MARK: - UIView+Toast
    public class func showToastCenter(_ msg: String?, view:UIView) {
        Constants.kSceneDelegate.window?.makeToast(msg, duration: 3.0, position: .center)
    }
    
    public class func dismissToast(view:UIView) {
        Constants.kSceneDelegate.window?.hideAllToasts()
    }
    
    // MARK: - Alert Methods
    public  class func showAlert(_ title : String, _ msg : String, view: UIViewController) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let actionOK : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (alt) in
        }
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .white
        actionOK.setValue(UIColor.appDarkGreen, forKey: "titleTextColor")
        
        alert.addAction(actionOK)
        view.present(alert, animated: true, completion: nil)
    }
    
    public   class func showAlert_withOneAction(_ title : String, _ msg : String, _ view: UIViewController, successClosure: @escaping (String?) -> () ) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let actionOK : UIAlertAction = UIAlertAction(title: "OK", style: .default) { (alt) in
            successClosure("success")
        }
        actionOK.setValue(UIColor.appDarkGreen, forKey: "titleTextColor")
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .white
        
        alert.addAction(actionOK)
        view.present(alert, animated: true, completion: nil)
        
    }
    
    public  class func showAlert_withTwoActions(_ title : String, _ msg : String, _ btnTitle1 : String, _ btnTitle2 : String, _ view: UIViewController, successClosure: @escaping (String?) -> (), cancelClosure: @escaping (String?) -> ()) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let actionOK : UIAlertAction = UIAlertAction(title: btnTitle1, style: .cancel) { (alt) in
            successClosure("success")
        }
        actionOK.setValue(UIColor.appDarkGreen, forKey: "titleTextColor")
        let actionCancel : UIAlertAction = UIAlertAction(title: btnTitle2, style: .default) { (alt) in
            cancelClosure("cancel")
        }
        actionCancel.setValue(UIColor.appDarkGreen, forKey: "titleTextColor")
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .white
        
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        view.present(alert, animated: true, completion: nil)
    }
    
    public  class func showAlertControllerOfType(_ style: UIAlertController.Style, onView viewController: UIViewController?, withTitle title: String?, andMessage message: String?, otherButtonTitles buttonTitles: NSMutableArray?, completion: @escaping (_ handler : Int) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .white
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
            alertController.dismiss(animated: true)
            completion(11)
        })
        actionCancel.setValue(UIColor.appDarkGreen, forKey: "titleTextColor")
        alertController.addAction(actionCancel)
        
        for buttonTitle in buttonTitles! {
            let actionButton = UIAlertAction(title: buttonTitle as? String, style: .default, handler: { action in
                
                alertController.dismiss(animated: true)
                completion(buttonTitles!.index(of: buttonTitle) )
            })
            actionButton.setValue(UIColor.appDarkGreen, forKey: "titleTextColor")
            alertController.addAction(actionButton)
        }
        viewController?.present(alertController, animated: true)
    }
    
    // MARK: - ActivityIndicator
    public class func startActivityIndicator(_ msg: String?="") {
        
        let hud = MBProgressHUD.showAdded(to: Constants.kSceneDelegate.window!, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        if((msg?.count)! > 0) {
            hud.label.text = msg
        }
        
    }
    
    public class func stopActivityIndicator() {
        
        MBProgressHUD.hide(for: Constants.kSceneDelegate.window!, animated: true)
    }
    
    
    /*************************************************************/
    //MARK:- Clear All UserDefaults Values
    /*************************************************************/
    open class func clearAllAppUserDefaults() {
        
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if !(key == "device_token" || key == "remember_email" || key == "remember_password") {
                Constants.kUserDefaults.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    
  
    
    
    // MARK: - convertStringToDate UTC To Local
    public class func convertStringUTCToLocal(toDate dateStr: String, dateFormate formate: String?) -> Date? {
        // convert to date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = dateFormatter.date(from: dateStr)// create   date from string
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm a"
        dateFormatter.timeZone = NSTimeZone.local
        // change to a readable time format and change to local time zone
        return date
    }
    
    
    // MARK: - convertStringToDate
    public class func convertString(toDate dateStr: String?, dateFormate formate: String?) -> Date? {
        // convert to date
        let dateFormat = DateFormatter()
        // ignore +11 and use timezone name instead of seconds from gmt
        dateFormat.dateFormat = formate ?? ""
        let date: Date? = dateFormat.date(from: dateStr ?? "")
        return date
    }
    
    // MARK: - convertDateToString with UTC
    public class func convertDateUTC(toString date: Date?, dateFormate formate: String?) -> String? {
        let dateFormat2 = DateFormatter()
        dateFormat2.dateFormat = formate ?? ""
        dateFormat2.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        var dateString: String? = nil
        if let aDate = date {
            dateString = dateFormat2.string(from: aDate)
        }
    //    print("DateString: \(dateString ?? "")")
        return dateString
    }
    
    // MARK: - convertDateToString
    public class func convertDate(toString date: Date?, dateFormate formate: String?) -> String? {
        let dateFormat2 = DateFormatter()
        dateFormat2.dateFormat = formate ?? ""
        var dateString: String? = nil
        if let aDate = date {
            dateString = dateFormat2.string(from: aDate)
        }
     //   print("DateString: \(dateString ?? "")")
        return dateString
    }
    
    // MARK: - convertDateToString
    public class func changeDateFormat(dateStr: String, dateFormate formate: String?, neededFormate neededFormat: String) -> String? {
        
        let date = self.convertStringUTCToLocal(toDate: dateStr, dateFormate: formate)
        let dateString = self.convertDate(toString: date, dateFormate: neededFormat)
        return dateString
    }
    
    public class func compareDates(startDate: String, endDate: String, formate:String) -> Bool {
        
        let fromDate = self.convertString(toDate: startDate, dateFormate: formate)
        let toDate = self.convertString(toDate: endDate, dateFormate: formate)
        
        let fromInterval =  Int((fromDate?.timeIntervalSince1970)!)
        let toInterval = Int((toDate?.timeIntervalSince1970)!)
        
        if toInterval as Int > fromInterval as Int {
            return true
        } else {
            return false
        }
    }
    
    public class func getFormatedPrice(price: Double) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let numberAsString = numberFormatter.string(from: NSNumber(value: price))!
        return numberAsString
    }
    
    
    
    // MARK: - JsonEncoding
    public class func stringifyJson(_ value: Any, prettyPrinted: Bool = true) -> String! {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options!)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }  catch {
                return ""
            }
        }
        return ""
    }
    
    // MARK: - ResponceStatus
    public class func getInt(for value : Any?) -> Int? {
        
        if let stateCode = value as? String {
            return Int(stateCode)
            
        }else if let stateCodeInt = value as? Int {
            return stateCodeInt
            
        }
        return nil
        
    }
    
    // MARK: - StringToDictionary
    public class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    // MARK: - Array To JSON
   public class func json(from object: Any) -> String? {
    
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    // MARK: - tableEmpty Message
    public class func tableEmpty(msg: String, tableView: UITableView) {
        
        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text = msg
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = .center
        tableView.backgroundView = noDataLabel
        tableView.separatorStyle = .none
    }
    
    
    public class func diffrenceBetweenDatesHrs(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        let hrs = diffrance / (60 * 60)
        return hrs
    }
    
    public class func diffrenceBetweenDatesMin(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        let min = diffrance / (60)
        return min
    }
    
    public class func diffrenceBetweenDatesSec(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        
        return diffrance
    }
    
    public class func diffrenceBetweenDatesYear(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        let days = diffrance / (60 * 60 * 24)
        let month = days / 30
        let year = month / 12
        
        return year
    }
    
    public class func diffrenceBetweenDatesMonth(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        
        let days = diffrance / (60 * 60 * 24)
        let month = days / 30
        
        return month
    }
    
    public class func diffrenceBetweenDatesDays(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        
        let days = diffrance / (60 * 60 * 24)
        
        return days
    }
    
    
    public class func strikeThroughAttribute(str: String)-> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    // MARK: - Get Address From Lat Long
    public class func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double, completion completionBlock: @escaping (_ userAddress: userCurrentAddress?) -> Void) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        //let addressString : String = ""
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                if placemarks != nil {
                    
                    let pm = placemarks! as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        print(pm.country as Any)
                        print(pm.locality as Any)
                        print(pm.postalCode as Any)
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        address.userAddress = addressString
                        address.userLocality = pm.locality ?? ""
                        address.latitude = lat
                        address.longitude = lon
                        completionBlock(address)
                        
                    }
                }
        })
    }
    
    public class func getExtension(str: String) -> String {
        var lastKey = ""
        let array = str.components(separatedBy: ".")
        lastKey = array.last ?? ""
        return lastKey
    }
    
}

extension UITableView{
    
    public func setBackgroundMessage(_ message:String?) {
        let messageLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Linotte-Regular", size: 16)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
}

extension UICollectionView {
    
    public func setBackgroundMessage(_ message:String?) {
        let messageLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Linotte-Regular", size: 16)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
        
    }
    
}

public extension Dictionary {
    
    static func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach{ result[$0] = $1 }
        return result
    }
    
    mutating func merge(with dictionary: [Key: Value]) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: [Key: Value]) -> [Key: Value] {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}


public extension Double {
    
    static func convertToDouble(anyValue:Any) -> Double {
        var doubleValue = Double()
        let val = anyValue as? String ?? ""
        if val.isEmpty {
            doubleValue = anyValue as? Double ?? 0
        } else {
            doubleValue = Double(val) ?? 0
        }
        return doubleValue
    }
}


public extension Int {
    
    static func convertToInt(anyValue:Any) -> Int {
        var intValue = Int()
        let val = anyValue as? String ?? ""
        if val.isEmpty {
            intValue = anyValue as? Int ?? 0
        } else {
            intValue = Int(val) ?? 0
        }
        return intValue
    }
}

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}



extension Date {
    
    func dateString(_ format: String = "MMM-dd-YYYY, hh:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingYears(_ dYears: Int) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
}

class CustomTextField: UITextView {
    var enableLongPressActions = false
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return enableLongPressActions
    }
}
