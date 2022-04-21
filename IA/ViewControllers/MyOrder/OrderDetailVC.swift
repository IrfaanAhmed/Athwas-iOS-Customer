//
//  OrderDetailVC.swift
//  IA
//
//  Created by admin on 28/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class OrderDetailVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCartValue: UILabel!
    @IBOutlet weak var lblDeliveryCharges: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblPromocode: UILabel!
  //  @IBOutlet weak var lblVAT: UILabel!
    @IBOutlet weak var lblRewards: UILabel!
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnTrack: UIButton!
    @IBOutlet weak var btnInvoice: UIButton!
    
    let viewModel = OrderHistoryViewModel(dataService: ApiClient())
    var orderDetail : OrderDetailModel?
    var orderID = ""
    let textView = UITextView(frame: CGRect.zero)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        kNotificationObject = [:]
        NotificationCenter.default.addObserver(forName: Notification.Name("NotificationOrderUpdate"), object: nil, queue: nil) { (notification) in
            self.fetchOrderDetail()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("NotificationOrderUpdate"), object: nil)
    }
    
    func setupUI() {
        
        self.headerTitle.text = "Order Details"
        self.menuBtn.isHidden = true
        self.backBtn.isHidden = false
        
        let nib = UINib.init(nibName: "OrderSummeryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "OrderSummeryCell")
        
        let footerNib = UINib.init(nibName: "OrderDetailFooter", bundle:nil)
        tableView.register(footerNib, forHeaderFooterViewReuseIdentifier: "OrderDetailFooter")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        fetchOrderDetail()
    }
    
    
    // MARK: - Get Order Detail
    
    private func fetchOrderDetail() {
        
        let url = "\(URLMethods.orderDetail)\(orderID)"
        
        viewModel.fetchRequestDetail(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
                self.navigationController?.popViewController(animated: true)
            }
        }
        viewModel.didFinishFetch = {
            self.orderDetail = self.viewModel.orderDetail!
            self.setupData()
        }
    }
    
    func setupData() {
        
        self.lblTitle.text = self.orderDetail?.deliveryAddress?.addressType
        self.lblAddress.text = self.orderDetail?.deliveryAddress?.fullAddress
        self.lblDiscount.text = String(format: "%@%.2f", Constants.KCurrency, updateCart().discount)
        self.lblPromocode.text = self.orderDetail?.promoCode != "" ? "(\(self.orderDetail?.promoCode ?? ""))" : ""
        self.lblDeliveryCharges.text = String(format: "%@%.2f", Constants.KCurrency, (self.orderDetail?.deliveryFee ?? 0))
     //   self.lblVAT.text = String(format: "%@%.2f", Constants.KCurrency, (self.orderDetail?.vatAmount ?? 0))
        self.lblCartValue.text = String(format: "%@%.2f", Constants.KCurrency, (updateCart().cartValue))
        self.lblRewards.text = "\(self.orderDetail?.redeemPoints ?? 0)"
        self.lblGrandTotal.text = "\(Constants.KCurrency)\(String(format: "%.2f", self.orderDetail?.netAmount ?? 0.0))"
        
        if orderDetail?.orderStatus == 4 || orderDetail?.orderStatus == 3 || orderDetail?.currentTrackingStatus == "Delivered" {
            btnTrack.isHidden = true
        }
        if orderDetail?.orderStatus == 2 || orderDetail?.orderStatus == 1 || orderDetail?.currentTrackingStatus == "Delivered" {
            btnInvoice.isHidden = false
        }
        self.tableView.reloadData()
        
    }
    
    
    func updateCart() -> (subTotal: Double, cartValue: Double, discount: Double) {
        
        var itemCount = 0
        var subTotal = 0.0
        var cartValue = 0.0
        var discount = 0.0
        
        for item in orderDetail?.category ?? [] {
            itemCount += item.products?.count ?? 0
            let cat = item.products ?? []
            
            for i in 0..<cat.count {
                var price = 0.0
                let quantity = Int.convertToInt(anyValue: cat[i].quantity as Any)
                
                if cat[i].isDiscount == 1 {
                    price = Double.convertToDouble(anyValue: cat[i].offerPrice as Any)
                    discount += (Double.convertToDouble(anyValue: cat[i].price as Any) - Double.convertToDouble(anyValue: cat[i].offerPrice as Any)) * Double(quantity)
                }
                else {
                    price = Double.convertToDouble(anyValue: cat[i].price as Any)
                    discount = orderDetail?.discount ?? 0
                }
                subTotal += price * Double(quantity)
                cartValue += Double(quantity) * Double.convertToDouble(anyValue: cat[i].price as Any)
            }
        }
        //   discount += orderDetail?.discount ?? 0
        
        return (subTotal, cartValue, discount)
        
    }
    
    
    @IBAction func btnTrackOrder(_ sender: Any) {
        
        let vc: TrackOrderVC = TrackOrderVC(nibName :"TrackOrderVC",bundle : nil)
        vc.orderDetail = orderDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func reviewClick(_ row: Int, section: Int) {
        let vc: RatingVC = RatingVC(nibName :"RatingVC",bundle : nil)
        vc.row = row
        vc.section = section
        vc.orderDetail = orderDetail
        vc.callback = {
            self.fetchOrderDetail()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func cancelClick(_ row: Int, section: Int) {
        
        AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to cancel this item", "Yes", "No", self) { (success) in
            
            let data = self.orderDetail?.category?[section].products?[row]
            
            let param = ["order_id" : self.orderDetail?.id ?? "",
                         "sub_order_id" : data?.id ?? ""
            ] as [String : Any]
            
            self.viewModel.cancelOrder(URLMethods.cancelOrder, param: param)
            self.viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            
            self.viewModel.didFinishFetch = {
                self.fetchOrderDetail()
                self.tableView.reloadData()
            }
            
        } cancelClosure: { (error) in
            
        }
    }
    
    
    func returnClick(_ row: Int, section: Int) {
        
        AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to return this item", "Yes", "No", self) { (success) in
            
            let data = self.orderDetail?.category?[section].products?[row]
            let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "ReturnReasonVC") as ReturnReasonVC
            vc.orderID = self.orderDetail?.id ?? ""
            vc.id = data?.id ?? ""
            vc.callback = {
                self.fetchOrderDetail()
            }
            self.present(vc, animated: true, completion: nil)
            
        } cancelClosure: { (error) in
            
        }
    }
    
    
    func groceryCancelClick(_ section: Int) {
        
        AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to cancel this item", "Yes", "No", self) { (success) in
            
            let data = self.orderDetail?.category?[section]
            
            let param = ["order_id" : self.orderDetail?.id ?? "",
                         "business_category_id" : data?.id ?? ""
            ] as [String : Any]
            
            self.viewModel.cancelOrder(URLMethods.groceryCancelOrder, param: param)
            self.viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            
            self.viewModel.didFinishFetch = {
                self.fetchOrderDetail()
                self.tableView.reloadData()
            }
        } cancelClosure: { (error) in
            
        }
        
    }
    
    func groceryReturnClick(_ section: Int) {
        
        AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to return this item?", "Yes", "No", self) { (success) in
            
            let data = self.orderDetail?.category?[section]
            
            let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "ReturnReasonVC") as ReturnReasonVC
            vc.orderID = self.orderDetail?.id ?? ""
            vc.id = data?.id ?? ""
            vc.type = "Grocery"
            vc.callback = {
                self.fetchOrderDetail()
            }
            self.present(vc, animated: true, completion: nil)
            
        } cancelClosure: { (error) in
            
        }
    }
    
    func imageTapped(_ row: Int, section: Int) {
        
        let data = self.orderDetail?.category?[section].products?[row]
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
        vc.productID = data?.inventoryID ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnInnvoiceDownload(_ sender: Any) {
        
        let param = ["order_id" : self.orderDetail?.id ?? ""]
        
        self.viewModel.downloadInnvoice(URLMethods.downloadInvoice, param: param)
        self.viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        self.viewModel.didFinishFetch = {
            
            guard let url = URL(string: self.viewModel.urlPath) else {return}
            
            AppManager.showAlertControllerOfType(.alert, onView: self, withTitle: Constants.kAppDisplayName, andMessage: "Choose an option", otherButtonTitles: ["Preview Invoice", "Download Invoice"]) { handler in
                if handler == 0 {
                    let vc = Constants.KMainStoryboard.instantiateViewController(identifier: "StaticPageVC") as StaticPageVC
                    vc.isfromSideMenu = false
                    vc.webTitle = "Invoice"
                    vc.webURL = url
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if handler == 1 {
                    let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
                    let downloadTask = urlSession.downloadTask(with: url)
                    downloadTask.resume()
                }
            }
            
        }
    }
    
}


// MARK: - <UITableViewDelegate> / <UITableViewDataSource>

extension OrderDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (orderDetail?.category?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 1 : orderDetail?.category?[section - 1].products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section  == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell", for: indexPath) as! OrderDetailCell
            cell.data = orderDetail
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemsCell", for: indexPath) as! OrderItemsCell
            let catData = orderDetail?.category?[indexPath.section - 1]
            let productData = catData?.products?[indexPath.row]
            cell.setData(productData, catData: catData, fullData: orderDetail)
            
            cell.callback = { (result) -> Void in
                if result == "Review" {
                    self.reviewClick(indexPath.row, section: indexPath.section - 1)
                }
                if result == "Return" {
                    self.returnClick(indexPath.row, section: indexPath.section - 1)
                }
                if result == "Cancel" {
                    self.cancelClick(indexPath.row, section: indexPath.section - 1)
                }
                if result == "imageTapped" {
                    self.imageTapped(indexPath.row, section: indexPath.section - 1)
                }
            }
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 {
            return UIView()
        }
        if orderDetail?.category?[section - 1].allReturn == 1 {
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderDetailFooter") as! OrderDetailFooter
            footerView.setCategoryData(orderDetail?.category?[section - 1], fullData: orderDetail)
            footerView.callback = {(result) -> Void in
                
                if result == "Return" {
                    self.groceryReturnClick(section - 1)
                }
                if result == "Cancel" {
                    self.groceryCancelClick(section - 1)
                }
            }
            return footerView
        }
        return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        
        if orderDetail?.category?[section - 1].allReturn == 1 {
            
            let calendar = Calendar.current
            
            if ((orderDetail?.category?[section - 1].products?.first?.orderStatus ?? 0) >= 1) && ((orderDetail?.category?[section - 1].products?.first?.orderStatus ?? 0) <= 4) {
                
                return 0
            }
            
            if let returnDate = AppManager.convertStringUTCToLocal(toDate: orderDetail?.deliveredDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") {
                
                let returnTime = calendar.date(byAdding: .minute, value: Int.convertToInt(anyValue: orderDetail?.category?[section - 1].returnTime as Any), to: returnDate) ?? Date()
                
                if orderDetail?.orderStatus == 2 {
                    return Date() > returnTime ? 0 : 40
                }
            }
            
            if let orderDate = AppManager.convertStringUTCToLocal(toDate: orderDetail?.orderDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") {
                
                let cancelTime = calendar.date(byAdding: .minute, value: Int.convertToInt(anyValue: orderDetail?.category?[section - 1].cancelationTime as Any), to: orderDate) ?? Date()
                return Date() > cancelTime ? 0 : 40
            }
            return 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 {
            let vw = UIView()
            vw.backgroundColor = .appLightGrey
            
            let label = UILabel()
            label.frame = CGRect(x: 20, y: 0, width: self.view.frame.width, height: 25.0)
            label.text = orderDetail?.category?[section - 1].name
            label.textColor = .darkGray
            label.textAlignment = .left
            label.font = UIFont(name: "Linotte-Regular", size: 14.0)
            vw.addSubview(label)
            
            return vw
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1 : 25
    }
}
