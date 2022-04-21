//
//  TrackOrderVC.swift
//  IA
//
//  Created by admin on 02/11/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class TrackOrderVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverNo: UILabel!
    @IBOutlet weak var viewDriver: UIView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    var orderDetail : OrderDetailModel?
    var orderStatus = [Acknowledged]()
    private let refreshControl = UIRefreshControl()
    let viewModel = OrderHistoryViewModel(dataService: ApiClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        NotificationCenter.default.addObserver(forName: Notification.Name("NotificationOrderUpdate"), object: nil, queue: nil) { (notification) in
            self.fetchOrderDetail()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchOrderDetail()
    }
    
    func setupUI() {
        
        self.headerTitle.text = "Order Status"
        self.menuBtn.isHidden = true
        self.backBtn.isHidden = false
        
        let nib = UINib(nibName: "TrackOrderCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TrackOrderCell")
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    
    @objc private func refreshData(_ sender: Any) {
        fetchOrderDetail()
    }
    
    private func fetchOrderDetail() {
        
        let url = "\(URLMethods.orderDetail)\(orderDetail?.id ?? "")"
        
        viewModel.fetchRequestDetail(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
                self.navigationController?.popViewController(animated: true)
            }
        }
        viewModel.didFinishFetch = {
            self.refreshControl.endRefreshing()
            self.orderDetail = self.viewModel.orderDetail!
            self.orderStatus.removeAll()
            self.tableView.reloadData()
            self.setupData()
        }
    }
    
    func setupData() {
        
        if orderDetail?.driver?.count ?? 0 > 0  {
            lblDriverName.text = orderDetail?.driver?.first?.username
            lblDriverNo.text = orderDetail?.driver?.first?.phone
            viewDriver.isHidden = false
            heightView.constant = 75
        }
        else {
            viewDriver.isHidden = true
            heightView.constant = 0
        }
        
        orderStatus.append((orderDetail?.trackingStatus?.acknowledged)!)
        orderStatus.append((orderDetail?.trackingStatus?.packed)!)
        orderStatus.append((orderDetail?.trackingStatus?.inTransit)!)
        orderStatus.append((orderDetail?.trackingStatus?.delivered)!)
        tableView.reloadData()
    }
    
    @IBAction func btnCallDriver(_ sender: Any) {
        
        let phone = String(orderDetail?.driver?.first?.phone ?? "")
        
        if let url = URL(string: "tel://\(phone)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnTrackMap(_ sender: Any) {
        
        if (orderDetail?.currentTrackingStatus == "Delivered") || (orderDetail?.orderStatus == 2) {
            AppManager.showAlert(Constants.KAppName, "Order is delivered. can't track anymore.", view: self)
            return
        }
        
        if (orderDetail?.driver?.count ?? 0 > 0) && (orderDetail?.currentTrackingStatus == "In_Transit") {
            
            let vc: OrderTrackMapVC = OrderTrackMapVC(nibName :"OrderTrackMapVC",bundle : nil)
            vc.orderDetail = orderDetail
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            AppManager.showAlert(Constants.KAppName, "Order has not been dispatched yet", view: self)
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension TrackOrderVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackOrderCell", for: indexPath) as! TrackOrderCell
        let data = orderStatus[indexPath.row]
        cell.lblStatus.text = data.statusTitle
        if let dateTime = data.time {
            cell.lblDate.text = AppManager.changeDateFormat(dateStr: dateTime, dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", neededFormate: "dd MMM yyyy, h:mm a")
        }
        if data.status == 1 {
            cell.viewround.backgroundColor = UIColor.appDarkGreen
            cell.lblDate.isHidden = false
        } else {
            cell.lblDate.isHidden = true
            cell.viewround.backgroundColor = UIColor.systemGray6
        }
        
        if orderStatus.count - 1 == indexPath.row {
            cell.viewLine.isHidden = true
        } else {
            cell.viewLine.isHidden = false
            if let status = orderStatus[indexPath.row + 1].status {
                if status == 1 {
                    cell.viewLine.backgroundColor = UIColor.appDarkGreen
                } else {
                    cell.viewLine.backgroundColor = UIColor.systemGray6
                }
            }
        }
        return cell
    }
    
}
