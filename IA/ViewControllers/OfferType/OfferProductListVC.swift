//
//  OfferProductListVC.swift
//  IA
//
//  Created by admin on 29/03/22.
//  Copyright © 2022 octal. All rights reserved.
//

import UIKit

class OfferProductListVC: BaseClassVC {

    @IBOutlet weak var tableView: UITableView!
    var productList : [OfferProductDataModel] = []
    let viewModel = ProductListViewModel(dataService: ApiClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
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
                         "product_id" : productList[index].productID ?? "",
                         "business_category_id" : productList[index].productData?[0].businessCategoryID ?? ""
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
            
            let param = ["product_id" : productList[index].productID ?? ""]
            
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
extension OfferProductListVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = productList.count
        tableView.setBackgroundMessage(rows == 0 ? "No Products" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ProductCell = self.tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cell.product = productList[indexPath.row]
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
    
}
