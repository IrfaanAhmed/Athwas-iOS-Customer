//
//  CheckoutVC.swift
//  IA
//
//  Created by admin on 29/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CheckoutVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPlaceOrder: UIButton!
    @IBOutlet weak var btnPlaceOrderBg: UIButton!
    @IBOutlet weak var btnPlaceOrderUp: UIButton!
    
    var selectedAddress: AddressDataModel!
    var cartItems : [CartItemsModel] = []
    let viewModel = CartViewModel(dataService: ApiClient())
    
    let viewModelCheckout = CheckoutViewModel(dataService: ApiClient())
    var deliveryObject : DeliveryFeeModel?
    var promoCodeObject : PormoCodeModel?
    var paymentObject : PaymentOption?
    let viewModelCCAvenue = CCAvenueModel(dataService: ApiClient())
    var isRewardsSelected = false
    var checkoutValidateModel : CheckoutValidate = CheckoutValidate()
    let addressViewModel = AddressViewModel(dataService: ApiClient())
    var outofStoke = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchCartItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetButton()
    }
    
    func setupUI() {
        
        self.headerTitle.text = "Checkout"
        self.menuBtn.isHidden = true
        self.backBtn.isHidden = false
        
        let nib1 = UINib.init(nibName: "CheckoutItemCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "CheckoutItemCell")
        
        let headerNib = UINib.init(nibName: "CheckoutHeaderView", bundle:nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "CheckoutHeaderView")
        
        let footerNib = UINib.init(nibName: "CheckoutFooterView", bundle:nil)
        tableView.register(footerNib, forHeaderFooterViewReuseIdentifier: "CheckoutFooterView")
        
        btnPlaceOrderUp.addTarget(self, action: #selector(swiped(_:event:)), for: .touchDragInside)
        btnPlaceOrderUp.addTarget(self, action: #selector(swipeEnded(_:event:)), for: .touchUpInside)
        
        let swipableView = UIImageView.init()
        swipableView.frame = CGRect.init(x: 0, y: 0, width: 60, height: btnPlaceOrderUp.frame.size.height)
        swipableView.tag = 20
        swipableView.image = #imageLiteral(resourceName: "right_swipe_arrow")
        btnPlaceOrderUp.addSubview(swipableView)
        
    }
    
    
    // MARK: - Get Product List
    private func fetchCartItems() {
        
        let url = "\(URLMethods.addToCart)?page_no=\(1)&limit=\(30)"
        
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
            if Constants.kAppDelegate.user?.defaultAddress != nil {
                self.selectedAddress = Constants.kAppDelegate.user?.defaultAddress
                self.fetchDeliveryCharge()
            }
            else {
                self.fetchAddressHistory()
            }
        }
    }
    
    // MARK: - fetchWalletHistory
    private func fetchAddressHistory() {
        
        addressViewModel.fetchRequestData(URLMethods.getAddress, param: [:], pages: 0)
        addressViewModel.showAlertClosure = {
            if let error = self.addressViewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        addressViewModel.didFinishFetch = {
            let address = self.addressViewModel.addresses
            let filtered = address?.filter({$0.defaultAddress == 1})
            if (filtered?.count ?? 0) > 0 {
                self.selectedAddress = filtered?[0]
                self.fetchDeliveryCharge()
            }
        }
    }
    
    
    func updateCart() -> (subTotal: Double, total : Double, cartValue: Double, discount: Double, rewards: Int) {
        
        var itemCount = 0
        var totalPrice = 0.0
        var subTotal = 0.0
        var cartValue = 0.0
        var discount = 0.0
        var rewardDiscount = 0.0
        var usedRewards = 0
        outofStoke = 0
        
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
                subTotal += price * Double(quantity)
                cartValue += Double(quantity) * Double.convertToDouble(anyValue: cat[i].price as Any)
                outofStoke += cat[i].availableQuantity == 0 ? 1 : 0
            }
        }
        rewardDiscount = discount + (promoCodeObject?.discountPrice ?? 0)
        
        let deliveryPrice = (deliveryObject?.deliveryFee ?? 0) + (deliveryObject?.vatAmount ?? 0)
        totalPrice = subTotal + deliveryPrice - (promoCodeObject?.discountPrice ?? 0)
        totalPrice = ((totalPrice > 0) ? totalPrice : 0)
        
        if isRewardsSelected {
            if totalPrice >= (deliveryObject?.redeemPoint ?? 0) {
                discount += deliveryObject?.redeemPoint ?? 0
                totalPrice -= deliveryObject?.redeemPoint ?? 0
            }
            else {
                discount += totalPrice
                totalPrice -= discount
                if totalPrice < 0 {
                    totalPrice = 0
                }
            }
        }
        usedRewards = Int(discount - rewardDiscount)
        
        return (subTotal, totalPrice, cartValue, discount, usedRewards)
        
    }
    
    
    func generate_Order() {
        
        let param = ["payment_mode" : "Online",
                     "delivery_address" : selectedAddress.id ?? ""] as [String : Any]
        
        viewModelCheckout.generateOrder(URLMethods.generateOrder, param: param)
        viewModelCheckout.showAlertClosure = {
            if let error = self.viewModelCheckout.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModelCheckout.didFinishFetch = {
            let data = self.viewModelCheckout.orderData
            if let ID = data?["order_id"] as? Int {
                self.callCCAvenuePayment(String(ID))
            }
            self.tableView.reloadData()
        }
    }
    
    
    func callCCAvenuePayment(_ orderId: String) {
        
        viewModelCCAvenue.getRSAKey(orderId, amount: updateCart().total, merchnt_param: "Order")
        viewModelCCAvenue.showAlertClosure = {
            if let error = self.viewModelCCAvenue.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        viewModelCCAvenue.didFinishFetch = {
            let vc = CCAvenueWebVC(nibName: "CCAvenueWebVC", bundle: nil)
            vc.webRequest = self.viewModelCCAvenue.responeRequest!
            vc.callback = { Void in
                self.checkPaymentStatus(orderId)
                return
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func checkPaymentStatus(_ orderId: String) {
        
        let param = ["order_id" : orderId,
                     "payment_for" : "Order"] as [String : Any]
        
        viewModelCCAvenue.checkPaymentStatus(URLMethods.paymentStatus, param: param)
        viewModelCCAvenue.showAlertClosure = {
            if let error = self.viewModelCCAvenue.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModelCCAvenue.didFinishFetch = {
            let data = self.viewModelCCAvenue.paymentData!
            if data.requestType == 2 {
                self.checkoutAPI(data)
            }
            else {
                let vc = PaymentStatusVC(nibName: "PaymentStatusVC", bundle: nil)
                vc.paymentData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    // MARK: - Call Checkout API
    
    func checkoutAPI(_ paymentData: PaymentDataModel?) {
        
        
        var param = ["payment_mode" : paymentObject?.status ?? "Cash",
                     "promo_code" : promoCodeObject?.promoCode ?? "",
                     "promo_code_id" : promoCodeObject?.id ?? "",
                     "warehouse_id" : deliveryObject?.warehouse ?? "",
                     "delivery_address" : selectedAddress.id ?? "",
                     "delivery_fee" : deliveryObject?.deliveryFee ?? 0,
                     "vat_amount" : String(deliveryObject?.vatAmount ?? 0),
                     "discount_price" : promoCodeObject?.discountPrice ?? 0,
                     "redeem_points" : isRewardsSelected == true ? updateCart().rewards : 0,
                     "customer_name" : checkoutValidateModel.name,
                     "customer_phone" : checkoutValidateModel.mobile] as [String : Any]
        
        
        if paymentData != nil {
            param["order_id"] = paymentData?.orderID
        }
        
        viewModelCheckout.checkoutProcess(URLMethods.checkout, param: param)
        viewModelCheckout.showAlertClosure = {
            
            if let msg = self.viewModelCheckout.msg {
                
                if paymentData != nil {
                    
                    let vc = PaymentStatusVC(nibName: "PaymentStatusVC", bundle: nil)
                    vc.paymentData = paymentData
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                
                AppManager.showAlert_withOneAction(Constants.KAppName, msg, self) { (action) in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                return
            }
            
            if let error = self.viewModelCheckout.error {
                print(error)
                AppManager.showToast(error)
                self.fetchCartItems()
                self.resetButton()
                return
            }
        }
    }
    
    
    // MARK: - Get Delivery Charge
    
    private func fetchDeliveryCharge() {
        
        let param = ["order_amount" : updateCart().subTotal,
                     "delivery_address_id" : selectedAddress.id ?? ""] as [String : Any]
        
        viewModelCheckout.getDeliveryCharges(URLMethods.deliveryCharge, param: param)
        viewModelCheckout.showAlertClosure = {
            if let error = self.viewModelCheckout.error {
                print(error)
                //       AppManager.showToast(error)
            }
        }
        
        viewModelCheckout.didFinishFetch = {
            self.deliveryObject = self.viewModelCheckout.deliveryFee!
            self.tableView.reloadData()
        }
        
    }
    
    
    // MARK: - Get Discount
    
    private func applyCode(_ code : String?) {
        
        guard code != nil else {
            self.promoCodeObject = nil
            self.tableView.reloadSections(NSIndexSet(index: self.cartItems.count) as IndexSet, with: .none)
            return
        }
        
        guard code != "" else {
            self.promoCodeObject = nil
            self.tableView.reloadSections(NSIndexSet(index: self.cartItems.count) as IndexSet, with: .none)
            AppManager.showAlert(Constants.KAppName, AppString.msgPromoCode, view: self)
            return
        }
        
        let param = ["promo_code" : code!,
                     "order_amount" : updateCart().subTotal
        ] as [String : Any]
        
        viewModelCheckout.applyPromoCode(URLMethods.appliedOffer, param: param)
        viewModelCheckout.showAlertClosure = {
            if let error = self.viewModelCheckout.error {
                print(error)
                AppManager.showToast(error)
                self.promoCodeObject = nil
                self.tableView.reloadSections(NSIndexSet(index: self.cartItems.count) as IndexSet, with: .none)
            }
        }
        
        viewModelCheckout.didFinishFetch = {
            self.promoCodeObject = self.viewModelCheckout.promoCode!
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.reloadSections(NSIndexSet(index: self.cartItems.count) as IndexSet, with: .none)
            }
            
        }
        
    }
    
    
    @objc func swiped(_ sender : UIButton, event: UIEvent) {
        let swipableView = sender.viewWithTag(20)!
        let centerPosition = location(event: event, subView: swipableView, superView: sender,isSwiping: true)
        UIView.animate(withDuration: 0.2) {
            swipableView.center = centerPosition
            self.btnPlaceOrder.frame.origin.x = swipableView.frame.origin.x
        }
    }
    
    @objc func swipeEnded(_ sender : UIButton, event: UIEvent) {
        let swipableView = sender.viewWithTag(20)!
        let centerPosition = location(event: event, subView: swipableView, superView: sender, isSwiping: false)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            swipableView.center = centerPosition
            self.btnPlaceOrder.frame.origin.x = swipableView.frame.origin.x
            if self.btnPlaceOrder.frame.origin.x > (self.view.frame.width / 2) {
                self.placeOrder()
            }
            
        }) { _ in}
    }
    
    func location(event: UIEvent, subView: UIView, superView: UIButton, isSwiping: Bool) -> CGPoint {
        if let touch = event.touches(for: superView)?.first{
            let previousLocation = touch.previousLocation(in: superView)
            let location = touch.location(in: superView)
            let delta_x = location.x - previousLocation.x;
            print(subView.center.x + delta_x)
            var centerPosition = CGPoint.init(x: subView.center.x + delta_x, y: subView.center.y)
            let minX = subView.frame.size.width/2
            let maxX = superView.frame.size.width - subView.frame.size.width/2
            centerPosition.x = centerPosition.x < minX ? minX : centerPosition.x
            centerPosition.x = centerPosition.x > maxX ? maxX : centerPosition.x
            if !isSwiping{
                let normalPosition = superView.frame.size.width * 0.5
                centerPosition.x = centerPosition.x > normalPosition ? maxX : minX
                centerPosition.x = centerPosition.x <= normalPosition ? minX : centerPosition.x
            }
            return centerPosition
        }
        return CGPoint.zero
    }
    
    func resetButton()  {
        self.btnPlaceOrder.frame.origin.x = 0.0
        let swipableView = self.btnPlaceOrderUp.viewWithTag(20)!
        swipableView.frame.origin.x = 0.0
    }
    
    // MARK: - Place Order Action
    
    func placeOrder() {
        
        tableView.reloadData()
        
        if cartItems.count == 0 {
            AppManager.showAlert(Constants.KAppName, AppString.msgCartItem, view: self)
            resetButton()
            return
        }
        
        if outofStoke > 0 {
            AppManager.showAlert(Constants.KAppName, "Some items are out of stock, kindly remove from cart", view: self)
            return
        }
        
        if selectedAddress == nil {
            AppManager.showAlert(Constants.KAppName, AppString.msgAddressCheck, view: self)
            resetButton()
            return
        }
        
        if !checkoutValidateModel.isValid {
            //    AppManager.showAlert(Constants.KAppName, checkoutValidateModel.message, view: self)
            checkoutValidateModel.activeField?.showError(message: checkoutValidateModel.message)
            resetButton()
            return
        }
        
        if paymentObject == nil {
            AppManager.showAlert(Constants.KAppName, AppString.msgPaymentMode, view: self)
            resetButton()
            return
        }
        
        if (paymentObject?.status == "Wallet") && (Double.convertToDouble(anyValue: deliveryObject?.wallet as Any) < updateCart().total) {
            AppManager.showAlert(Constants.KAppName, AppString.msgInsufficient, view: self)
            resetButton()
            return
        }
        
        if paymentObject?.status == "Wallet" {
            
            if updateCart().total == 0 {
                paymentObject?.status = "Cash"
            }
        }
        
        if paymentObject?.status == "Credit" {
            
            if updateCart().total == 0 {
                paymentObject?.status = "Cash"
                checkoutAPI(nil)
                
            }else {
                generate_Order()
            }
        }
        else {
            checkoutAPI(nil)
        }
    }
    
    
}

// MARK: - <UITableViewDelegate> / <UITableViewDataSource>

extension CheckoutVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cartItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 0 : cartItems[section - 1].categoryItems?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutItemCell", for: indexPath) as! CheckoutItemCell
        let cellData = cartItems[indexPath.section - 1].categoryItems?[indexPath.row]
        cell.setData(cellData)
        cell.callbackDelete = {
            self.deleteItems(indexPath.row, section: indexPath.section - 1)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CheckoutHeaderView") as! CheckoutHeaderView
            headerView.btnChange.addTarget(self, action: #selector(btnSelectAddressAction), for: .touchUpInside)
            headerView.lblAddress.text = selectedAddress != nil ? selectedAddress.fullAddress: ""
            headerView.lblTitle.text = selectedAddress != nil ? selectedAddress.addressType: "Please select Address"
            
            return headerView
        }
        
        let vw = UIView()
        vw.backgroundColor = .appLightGrey
        
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 0, width: self.view.frame.width, height: 25.0)
        label.text = cartItems[section - 1].id?.name
        label.textColor = .darkGray
        label.textAlignment = .left
        label.font = UIFont(name: "Linotte-Regular", size: 14.0)
        vw.addSubview(label)
        
        return vw
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 110 : 25
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == cartItems.count {
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CheckoutFooterView") as! CheckoutFooterView
            
            footerView.lblCartValue.text = String(format: "%@%.2f", Constants.KCurrency, (updateCart().cartValue))
            footerView.lblGrandTotal.text = "\(Constants.KCurrency)\(String(format:"%.2f", updateCart().total))"
            footerView.totalDiscount = updateCart().discount
            footerView.deliveryData = deliveryObject
            footerView.promoData = promoCodeObject
            checkoutValidateModel = footerView.viewModel
            footerView.lblPaymentMode.text = "- \(paymentObject?.title ?? "Select a Payment Mode")"
            
            footerView.callbackCode = { (text) -> Void in
                self.applyCode(text)
            }
            footerView.callback = { () -> Void in
                self.selectPaymentMode()
            }
            
            footerView.callbackRewards = { (result) -> Void in
                self.isRewardsSelected = result
                self.tableView.reloadData()
                //  self.tableView.reloadSections(NSIndexSet(index: self.cartItems.count) as IndexSet, with: .none)
            }
            
            footerView.callbackText = {(result) -> Void in
                self.checkoutValidateModel = result
                self.tableView.reloadData()
            }
            
            return footerView
        }
        return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == cartItems.count ? 585 : 0
    }
    
    
    @objc func btnSelectAddressAction() {
        let VC = Constants.KHomeStoryboard.instantiateViewController(identifier: "AddressVC") as AddressVC
        VC.isfromProfile = true
        VC.selectedAddress = selectedAddress
        VC.getAddress = { (address) -> Void in
            self.selectedAddress = address
            self.fetchDeliveryCharge()
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    private func selectPaymentMode() {
        
        if selectedAddress == nil {
            AppManager.showAlert(Constants.KAppName, "Please select address first", view: self)
            return
        }
        
        let vc: PaymentModeVC = PaymentModeVC(nibName :"PaymentModeVC",bundle : nil)
        vc.deliveryObject = deliveryObject
        vc.callback = { (result) -> Void in
            self.paymentObject = result
            self.tableView.reloadData()
        }
        self.present(vc, animated: true, completion: nil)
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
                if self.cartItems.count == 0 {
                    self.navigationController?.popViewController(animated: true)
                }
                
                self.promoCodeObject = nil
                AppManager.showToast("Something has changed in cart item so you need to add the promocode again")
                self.tableView.reloadData()
            }
            
        }) { (no) in
            
        }
    }
}
