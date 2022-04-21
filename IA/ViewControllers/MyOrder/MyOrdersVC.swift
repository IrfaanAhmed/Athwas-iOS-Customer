//
//  MyOrdersVC.swift
//  IA
//
//  Created by Yogesh Raj on 17/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class MyOrdersVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentTabBtn: UIButton!
    @IBOutlet weak var pastTabBtn: UIButton!
    let viewModel = OrderHistoryViewModel(dataService: ApiClient())
    var orderHistory = [OrderHistoryModel]()
    var offset = 1
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupUI()
        self.btnTapAction(self.currentTabBtn)
        
    }
    
    func setupUI() {
        
        self.headerTitle.text = "My Orders"
        self.menuBtn.isHidden = false
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.orderHistory.removeAll()
        self.tableView.reloadData()
        fetchOrderList(1)
    }
    
    // MARK: - Get Order History List
    
    private func fetchOrderList(_ offset: Int) {
        
        var url = "\(URLMethods.current_orders)/?page_no=\(offset)"
        
        if pastTabBtn.isSelected == true {
            url = "\(URLMethods.past_orders)/?page_no=\(offset)"
        }

        viewModel.fetchRequestData(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        viewModel.didFinishFetch = {
            self.refreshControl.endRefreshing()
            if offset <= 1 {
                self.offset = offset
                self.orderHistory.removeAll()
                self.tableView.setContentOffset(.zero, animated:true)
            }
            self.orderHistory.append(contentsOf: self.viewModel.ordersList!)
            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - Press Tap Action
    @IBAction func btnTapAction(_ sender : UIButton) {
        currentTabBtn.isSelected = false
        pastTabBtn.isSelected = false
        sender.isSelected = true
        self.orderHistory.removeAll()
        self.tableView.reloadData()
        fetchOrderList(1)
    }
    
}


// MARK: - <UITableViewDelegate> / <UITableViewDataSource>

extension MyOrdersVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = orderHistory.count
        tableView.setBackgroundMessage(rows == 0 ? "No orders yet" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MyOrderCell = tableView.dequeueReusableCell(withIdentifier: "MyOrderCell", for: indexPath) as! MyOrderCell
        cell.data = orderHistory[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "OrderDetailVC") as OrderDetailVC
        vc.orderID = orderHistory[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.orderHistory.count-4 {
            
            if viewModel.isReload! {
                offset = offset + 1
                self.fetchOrderList(offset)
                viewModel.isReload! = false
            }
        }
    }
}

