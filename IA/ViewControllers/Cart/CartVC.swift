//
//  CartVC.swift
//  IA
//
//  Created by Yogesh Raj on 21/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CartVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var itemCountTxt: UILabel!
    @IBOutlet weak var priceTxt: UILabel!
    @IBOutlet weak var savedTxt: UILabel!
    @IBOutlet weak var viewBottom : UIView!
    
    var cartItems : [CartItemsModel] = []
    let viewModel = CartViewModel(dataService: ApiClient())
    var outofStoke = 0
    var itemNotAvailable = 0
    var moreThanStock = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        tableView.isHidden = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let _ = UserDataModel.isLoggedIn() else {
            return }
        fetchCartItems(1)
    }
    
    func setupUI() {
        
        self.headerTitle.text = "Cart"
        self.backBtn.isHidden = false
        
    }
    
    // MARK: - Get Cart List
    
    private func fetchCartItems(_ offset: Int) {
        
        let url = "\(URLMethods.addToCart)?page_no=\(offset)&limit=\(30)"
        
        viewModel.fetchRequestData(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.cartItems = self.viewModel.cart_items!
            self.tableView.reloadData()
            self.updateCart()
        }
        
    }
    
    func updateQuantity(_ row: Int, section: Int, quantity: Int, addAction: Bool)  {
        
        var data = self.cartItems[section].categoryItems?[row]
        if  addAction {
            guard (Int.convertToInt(anyValue: data?.availableQuantity as Any) >= quantity) else {
                AppManager.showAlert(Constants.KAppName, AppString.msgQuantity, view: self)
                return
            }
            
            if data?.minInventory != nil {
                
                let actualQty = (data?.minInventory ?? 0) > (data?.availableQuantity ?? 0) ? data?.availableQuantity : data?.minInventory
                
                guard Int.convertToInt(anyValue: actualQty as Any) >= quantity else {
                    AppManager.showAlert(Constants.KAppName, "You can't order more than \(data?.minInventory ?? 0) units", view: self)
                    return
                }
            }
        }
        
        let param = ["inventory_id" : data?.inventoryID ?? "",
                     "product_id" : data?.productID ?? "",
                     "business_category_id" : data?.businessCategory?.id ?? "",
                     "quantity" : quantity ] as [String : Any]
        
        viewModel.updateCartItem(URLMethods.addToCart, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            data?.quantity = quantity
            self.cartItems[section].categoryItems?[row] = data!
            self.tableView.reloadData()
            self.updateCart()
        }
    }
    
    func deleteItems(_ row: Int, section : Int)  {
        
        AppManager.showAlert_withTwoActions(Constants.KAppName, "Do you want to delete this item?", "Yes", "No", self, successClosure: { (yes) in
            
            let data = self.cartItems[section].categoryItems?[row]
            let url = "\(URLMethods.deleteCart)\(data?.cartID ?? "")"
            
            self.viewModel.deleteCartItem (url, param: [:])
            self.viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    AppManager.showToast(error)
                }
            }
            
            self.viewModel.didFinishFetch = {
                self.cartItems[section].categoryItems?.remove(at: row)
                if self.cartItems[section].categoryItems?.count == 0 {
                    self.cartItems.remove(at: section)
                }
                self.tableView.reloadData()
                self.updateCart()
            }
            
        }) { (no) in
            
        }
    }
    
    
    func updateCart() {
        
        var itemCount = 0
        var totalPrice = 0.0
        var discount = 0.0
        outofStoke = 0
        itemNotAvailable = 0
        moreThanStock = 0
        
        for item in self.cartItems {
            itemCount += item.categoryItems?.count ?? 0
            let cat = item.categoryItems ?? []
            for i in 0..<cat.count {
                
                var price = 0.0
                let quantity = Int.convertToInt(anyValue: cat[i].quantity as Any)
                if cat[i].isDiscount == 1 {
                    price = Double.convertToDouble(anyValue: cat[i].offerPrice as Any)
                    discount += (Double.convertToDouble(anyValue: cat[i].price as Any) - Double.convertToDouble(anyValue: cat[i].offerPrice as Any)) * Double(quantity)
                    
                }
                else {
                    price = Double.convertToDouble(anyValue: cat[i].price as Any)
                }
                totalPrice += price * Double(quantity)
                
                //  discount += (Double.convertToDouble(anyValue: cat[i].price as Any) - Double.convertToDouble(anyValue: cat[i].offerPrice as Any)) * Double(quantity)
                
                outofStoke += cat[i].availableQuantity == 0 ? 1 : 0
                itemNotAvailable += (cat[i].availble == 0 ? 1 : 0)
                moreThanStock += (quantity > cat[i].availableQuantity ?? 0) ? 1 : 0
            }
        }
        priceTxt.text = "\(Constants.KCurrency)\(String(format:"%.2f", totalPrice))"
        itemCountTxt.text = "\(itemCount) items"
        savedTxt.text = "Saved: \(Constants.KCurrency)\(String(format:"%.2f", discount))"
        
        if cartItems.count == 0 {
            viewBottom.isHidden = true
            tableView.isHidden = true
        }
        else {
            tableView.isHidden = false
            viewBottom.isHidden = false
            tableView.isHidden = false
        }
    }
    
    // MARK: - Checkout Action
    @IBAction func btnCheckout(_ sender: UIButton) {
        if self.cartItems.count > 0  {
            if itemNotAvailable > 0 {
                AppManager.showAlert(Constants.KAppName, "Some items are not available, kindly remove them from the cart", view: self)
                return
            }
            if outofStoke > 0 {
                AppManager.showAlert(Constants.KAppName, "Some items are out of stock, kindly remove from cart", view: self)
                return
            }
            if moreThanStock > 0 {
                AppManager.showAlert(Constants.KAppName, "Some items are more than stock, kindly decrease quantity to available stock", view: self)
                return
            }
            
            let vc: CheckoutVC = CheckoutVC(nibName: "CheckoutVC", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnBacktoHome(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: - UITableViewDelegate / UITableViewDataSource
extension CartVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems[section].categoryItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell") as! CartCell
        let cellData = cartItems[indexPath.section].categoryItems?[indexPath.row]
        cell.data = cellData
        cell.callbackDelete = {
            self.deleteItems(indexPath.row, section: indexPath.section)
        }
        cell.callbackAdd = { qty in
            self.fetchCartItems(1)
            let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                self.updateQuantity(indexPath.row, section: indexPath.section, quantity: qty, addAction: true)
            }
        }
        cell.callbackMinus = { qty in
            self.updateQuantity(indexPath.row, section: indexPath.section, quantity: qty, addAction: false)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vw = UIView()
        vw.backgroundColor = .appLightGrey
        
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 0, width: self.view.frame.width, height: 25.0)
        label.text = cartItems[section].id?.name
        label.textColor = .darkGray
        label.textAlignment = .left
        label.font = UIFont(name: "Linotte-Regular", size: 14.0)
        vw.addSubview(label)
        
        return vw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
        vc.productID = cartItems[indexPath.section].categoryItems?[indexPath.row].inventoryID ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

