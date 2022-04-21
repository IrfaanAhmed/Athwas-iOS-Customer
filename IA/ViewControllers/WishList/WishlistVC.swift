//
//  WishlistVC.swift
//  IA
//
//  Created by Yogesh Raj on 18/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class WishlistVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    var productList : [ProductListDataModel] = []
    let viewModel = WishlistViewModel(dataService: ApiClient())
    let viewModelCart = ProductListViewModel(dataService: ApiClient())
    
    //Variables
    var offset = 1
    private let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        self.setupUI()
        fetchProductList(1)
    }
    
    
    // MARK: - setupUI
    func setupUI() {
        self.headerTitle.text = "Wish List"
        self.menuBtn.isHidden = true
        self.backBtn.isHidden = false
    }
    
    
    @objc private func refreshData(_ sender: Any) {
        fetchProductList(1)
    }
    
    // MARK: - Get Product List
    
    private func fetchProductList(_ offset: Int) {
        
        let url = "\(URLMethods.favouriteList)/?page_no=\(offset)"
        
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
                self.productList.removeAll()
                self.tableView.setContentOffset(.zero, animated:true)
            }
            self.productList.append(contentsOf: self.viewModel.productList!)
            self.tableView.reloadData()
        }
        
    }
    
    @objc fileprivate func updateFavStatus(pro_id:String, row_id:Int){
        
        let param = ["product_id" : pro_id,
                     "status" : 0,
            ] as [String : Any]
        
        viewModel.updateFavStatus(URLMethods.addFavourite, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        viewModel.didFinishFetch = {
            self.productList.remove(at: row_id)
            self.tableView.reloadData()
        }
        
    }
    
    func addCart(_ index : Int)  {
                
        if productList[index].availableQuantity ?? 0 > 0 {
            
            let param = ["inventory_id" : productList[index].inventoryID ?? "",
                         "product_id" : productList[index].productID ?? "",
                         "business_category_id" : productList[index].businessCategory?.id ?? ""
            ]
            
            viewModelCart.additem_cart(URLMethods.addToCart, param: param)
            viewModelCart.showAlertClosure = {
                if let error = self.viewModelCart.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModelCart.didFinishFetch = {
                self.tableView.reloadData()
            }
        }
        else {
            
            let param = ["product_id" : productList[index].inventoryID ?? ""]
            
            viewModelCart.notifyProduct(URLMethods.notify_me, param: param)
            viewModelCart.showAlertClosure = {
                if let error = self.viewModelCart.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModelCart.didFinishFetch = {
                self.tableView.reloadData()
            }
        }

        
    }
    
}


// MARK: - UITableViewDelegate / UITableViewDataSource
extension WishlistVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = productList.count
        tableView.setBackgroundMessage(rows == 0 ? "No items in your wishlist" : nil)
        return rows
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:ProductCell = self.tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cell.data = productList[indexPath.row]
        cell.addCartBtn.isHidden = productList[indexPath.row].isActive == 0 ? true : false
        cell.callbackFavStatus = {
            value in
            self.updateFavStatus(pro_id: cell.data?.inventoryID ?? "", row_id: indexPath.row)
        }
        cell.callbackCart = {
            self.addCart(indexPath.row)
        }
        return cell
        
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
        vc.productID = productList[indexPath.row].inventoryID ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row == self.productList.count-4 {
            
            if viewModel.isReload! {
                print(viewModel.isReload!)
                offset = offset + 1
                self.fetchProductList(offset)
                viewModel.isReload! = false
            }
        }
    }
}

