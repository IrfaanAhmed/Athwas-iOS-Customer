//
//  NotificationsVC.swift
//  WaadPay
//
//  Created by admin on 04/06/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit

class NotificationsVC: BaseClassVC {
    
    @IBOutlet weak var tableList: UITableView!
    let viewModel = NotificationViewModel(dataService: ApiClient())
    var notificationList : [NotificationListModel] = []
    var isfromHome = false
    var offset = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.setupUI()
        fetchNotifications(1)
    }
    
    func setupUI() {
        self.headerTitle.text = "Notifications"
        self.menuBtn.isHidden = isfromHome == false ? false : true
        self.backBtn.isHidden = isfromHome == false ? true : false
        self.searchBtn.isHidden = true
        self.cartBtn.isHidden = true
        
        
        // Delete Button
        deleteBtn = UIButton(frame: CGRect(x: Constants.kScreenWidth - 46, y: 7, width: 30, height: 30))
        deleteBtn.setImage( UIImage.init(named: "delete"), for: .normal)
        deleteBtn.isHidden = false
        deleteBtn.tintColor = .white
        deleteBtn.addTarget(self, action: #selector(self.pressDeleteAll(_:)), for: .touchUpInside)
        header.addSubview(deleteBtn)
    }
    
    
    
    private func fetchNotifications(_ offset: Int) {
        
        let url = "\(URLMethods.notificationList)?page_no=\(offset)"
        viewModel.fetchRequestData(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            
            if offset <= 1 {
                self.offset = offset
                self.notificationList.removeAll()
                self.tableList.setContentOffset(.zero, animated:true)
            }
            self.notificationList.append(contentsOf: self.viewModel.notifications!)
            self.tableList.reloadData()
        }
    }
    
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressDeleteAll(_ sender: UIButton) {
        
        if notificationList.count > 0 {
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to delete all notifications?", "Yes", "No", self, successClosure: { (yes) in
                    AppManager.startActivityIndicator()
                    ApiClient.init().apiCallMethod(URLMethods.notificationList, method: .delete, parameter: [:], successClosure: { result in
                        
                        self.notificationList.removeAll()
                        self.tableList.reloadData()
                        AppManager.stopActivityIndicator()
                    }) { (error) in
                        AppManager.showToast(error!)
                        AppManager.stopActivityIndicator()
                    }
                    
                }) { (no) in
                    
                }
            }
        }
    }
}

class TableViewCell_Notification: UITableViewCell {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDes : UILabel!
    @IBOutlet weak var lblDate : UILabel!
    
}

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = notificationList.count
        tableView.setBackgroundMessage(rows == 0 ? "No notifications yet" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! TableViewCell_Notification
        cell.lblTitle.text = notificationList[indexPath.row].title
        cell.lblDes.text = notificationList[indexPath.row].message
        cell.lblDate.text = AppManager.changeDateFormat(dateStr: notificationList[indexPath.row].createdAt ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", neededFormate: "dd MMMM yyyy, h:mm a")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to delete notification?", "Yes", "No", self, successClosure: { (yes) in
                    
                    let data = self.notificationList[indexPath.row]
                    let url = "\(URLMethods.notificationDelete)\(data.id ?? "")"
                    
                    self.viewModel.deleteNotifcationtData (url, param: [:])
                    self.viewModel.showAlertClosure = {
                        if let error = self.viewModel.error {
                            print(error)
                            AppManager.showToast(error)
                        }
                    }
                    
                    self.viewModel.didFinishFetch = {
                        self.notificationList.remove(at: indexPath.row)
                        self.tableList.deleteRows(at: [indexPath], with: .automatic)
                    }
                    
                }) { (no) in
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {        
        if indexPath.row == self.notificationList.count-4 {
            
            if viewModel.isReload! {
                offset = offset + 1
                self.fetchNotifications(offset)
                viewModel.isReload! = false
            }
            print("reload")
        }
    }
    
}


