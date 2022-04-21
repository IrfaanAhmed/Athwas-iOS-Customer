//
//  AddWalletVC.swift
//  IA
//
//  Created by admin on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class AddWalletVC: UIViewController {
    
    @IBOutlet weak var txtAmountField: UITextField!
    @IBOutlet weak var viewBg: UIView!
    
    var callback : (() -> Void)?
    let viewModelCCAvenue = CCAvenueModel(dataService: ApiClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtAmountField.LeftView(of: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);

    }
    
    override func viewDidLayoutSubviews() {
        viewBg.roundCorners(corners: [.topLeft, .topRight], radius: 30.0)
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.layoutIfNeeded()
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSelectAmount(_ sender: UIButton) {
        txtAmountField.text = String(sender.tag)
    }
    
    @IBAction func btnApply(_ sender: Any) {
        
        guard txtAmountField.text?.count ?? 0 > 0 && Double.convertToDouble(anyValue: txtAmountField.text as Any) != 0 else {
            AppManager.showAlert(Constants.KAppName, "Please enter amount", view: self)
            return
        }
        callCCAvenuePayment()
    }
    
    // MARK: - Add Amount Action
    func addAmountAPI(amount: String) {
        
        let param = ["amount" : amount,
                     "reason": ""] as [String : Any]
        ApiClient.init().apiCallMethod(URLMethods.addMoney, method: .post, parameter: param, successClosure: { (response) in
            AppManager.showToast(response!["message"] as! String)
            self.dismiss(animated: true, completion: {
                self.callback!()
            })
        }) { (msg) in
            AppManager.showToast(msg ?? "")
        }
    }
    
    
    func callCCAvenuePayment() {
        
        let amount = Double.convertToDouble(anyValue: txtAmountField.text as Any)
        let randomOrder = Int.random(in: 1000...999999)

        viewModelCCAvenue.getRSAKey("\(randomOrder)", amount: amount, merchnt_param: "Wallet")
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
                self.checkPaymentStatus("\(randomOrder)")
                return
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func checkPaymentStatus(_ orderId: String) {
        
        let param = ["order_id" : orderId,
                     "payment_for" : "Wallet"] as [String : Any]
                
        viewModelCCAvenue.checkPaymentStatus(URLMethods.paymentStatus, param: param)
        viewModelCCAvenue.showAlertClosure = {
            if let error = self.viewModelCCAvenue.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModelCCAvenue.didFinishFetch = {
      
            let data = self.viewModelCCAvenue.paymentData!
            if data.requestType == 1 {
                AppManager.showAlert_withOneAction(Constants.KAppName, "Money added successfully", self) { (action) in
                    self.dismiss(animated: true, completion: {
                        self.callback!()
                    })
                }
            }
        }
    }
   
    
}

