//
//  OtherProductVC.swift
//  IA
//
//  Created by admin on 15/01/21.
//  Copyright © 2021 octal. All rights reserved.
//

import UIKit

class OtherProductVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    var productList : [ProductListDataModel] = []
    let viewModel = ProductListViewModel(dataService: ApiClient())
    
    //Variables
    var productUrl = ""
    var offset = 1
    var isFromDeals = false
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.setupUI()
        
        if isFromDeals == true {
            fetchProductDetailList()
        }
        else {
            fetchProductList(1)
        }
    }
    
    func setupUI() {
        self.headerTitle.text = ""
        self.backBtn.isHidden = false
        self.cartBtn.isHidden = false
        self.searchBtn.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cartBtn.badgeString = Constants.kAppDelegate.user?.cartCount != nil ? String(Constants.kAppDelegate.user?.cartCount ?? 0) : nil
    }
    
    @objc private func refreshData(_ sender: Any) {
        
        if isFromDeals == true {
            fetchProductDetailList()
        }
        else {
            fetchProductList(1)
        }
    }
    
    
    // MARK: - Get Product List
    
    private func fetchProductList(_ offset: Int) {
        
        let url = "\(productUrl)?page_no=\(offset)&limit=\(6)"
        
        viewModel.fetchRequestOtherData(url, param: [:])
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
                self.productList.removeAll()
                self.tableView.setContentOffset(.zero, animated:true)
            }
            self.productList.append(contentsOf: self.viewModel.productList!)
            self.tableView.reloadData()
            
        }
        
    }
    
    
    private func fetchProductDetailList() {
        
        viewModel.fetchRequestDetailData(productUrl, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            
            self.refreshControl.endRefreshing()
            self.productList.removeAll()
            self.productList = self.viewModel.productList!
            self.tableView.reloadData()
            
            
        }
        
    }
    
    
    //pending till value comes
    @objc fileprivate func updateFavStatus(favStatus : Int, pro_id:String, row_id:Int){
        
        guard let _ = UserDataModel.isLoggedIn() else {
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                    Constants.kSceneDelegate.switchToLoginVC()
                }) { (no) in
                    
                }
            }
            return }
        
        let param = ["product_id" : pro_id,
                     "status" : favStatus,
        ] as [String : Any]
        
        viewModel.updateFavStatus(URLMethods.addFavourite, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        viewModel.didFinishFetch = {
            
            self.productList[row_id].isFavourite = favStatus
            self.tableView.beginUpdates()
            let indexPath = IndexPath(row: row_id, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
        
    }
    
    
    func addCart(_ index : Int)  {
        
        guard let _ = UserDataModel.isLoggedIn() else {
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                    Constants.kSceneDelegate.switchToLoginVC()
                }) { (no) in
                    
                }
            }
            return }
        
        if productList[index].availableQuantity ?? 0 > 0 {
            
            let param = ["inventory_id" : productList[index].id ?? "",
                         "product_id" : productList[index].mainProductID ?? "",
                         "business_category_id" : productList[index].businessCategory?.id ?? ""
            ]
            
            viewModel.additem_cart(URLMethods.addToCart, param: param)
            viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModel.didFinishFetch = {
                self.cartBtn.badgeString = Constants.kAppDelegate.user?.cartCount != nil ? String(Constants.kAppDelegate.user?.cartCount ?? 0):nil
                self.tableView.reloadData()
            }
        }
        else {
            
            let param = ["product_id" : productList[index].id ?? ""]
            
            viewModel.notifyProduct(URLMethods.notify_me, param: param)
            viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModel.didFinishFetch = {
                self.tableView.reloadData()
            }
        }
        
    }
    
}

// MARK: - UITableViewDelegate / UITableViewDataSource
extension OtherProductVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = productList.count
        tableView.setBackgroundMessage(rows == 0 ? "No Products" : nil)
        return rows
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:ProductCell = self.tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cell.data = productList[indexPath.row]
        cell.callbackFavStatus = {
            value in
            self.updateFavStatus(favStatus: value, pro_id: cell.data?.id ?? "",row_id: indexPath.row)
        }
        cell.callbackCart = {
            self.addCart(indexPath.row)
        }
        return cell
        
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
        vc.productID = productList[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isFromDeals == false {
            if indexPath.row == self.productList.count-4 {
                
                if viewModel.isReload! {
                    print(viewModel.isReload!)
                    offset = offset + 1
                    self.fetchProductList(offset)
                    viewModel.isReload! = false
                }
                print("reload")
            }
        }
    }
}

