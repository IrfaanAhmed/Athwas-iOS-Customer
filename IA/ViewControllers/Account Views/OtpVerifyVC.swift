//
//  OtpVerifyVC.swift
//  IA
//
//  Created by admin on 21/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class OtpVerifyVC: BaseClassVC, UITextFieldDelegate {
    
    @IBOutlet weak var txtOTP1: UITextField!
    @IBOutlet weak var txtOTP2: UITextField!
    @IBOutlet weak var txtOTP3: UITextField!
    @IBOutlet weak var txtOTP4: UITextField!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var viewResend: UIView!
    var otpData = [String : Any]()
    var timer : Timer?
    var counter = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector:#selector(prozessTimer), userInfo: nil, repeats: true)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.showAlert(Constants.KAppName, String(self.otpData["otp_number"] as! Int), view: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         timer?.invalidate()
         timer = nil
     }
    
    func setupUI() {
        
        self.headerTitle.text = "OTP"
        self.backBtn.isHidden = false
        self.searchBtn.isHidden = true
        self.cartBtn.isHidden = true
    }
    
    @objc func prozessTimer() {
        if counter > 0 {
            counter -= 1
            lblTimer.text = "Resend OTP in 00:\(counter)"
        }
        else {
            timer?.invalidate()
            timer = nil
            viewResend.isHidden = false
            lblTimer.isHidden = true
        }
    }
    
    fileprivate func resetTimer() {
        self.counter = 60
        self.timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector:#selector(self.prozessTimer), userInfo: nil, repeats: true)
        self.viewResend.isHidden = true
        self.lblTimer.isHidden = false
    }
    
    @IBAction func btnResendOtp(_ sender: Any)  {
        
        let param : [String : Any] = otpData
        
        AppManager.startActivityIndicator()
        ApiClient().apiCallMethod(URLMethods.resendOTP, method: .post, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            let data = response as? NSDictionary
            let otp = data?.value(forKeyPath: "data.otp_number") as! Int
            AppManager.showAlert(Constants.KAppName, String(otp), view: self)
            self.resetTimer()
            
        }) { (error) in
            AppManager.stopActivityIndicator()
            AppManager.showAlert(Constants.KAppName, error ?? "", view: self)
        }
    }
    
    @IBAction func btnVerify(_ sender: Any) {
        
        guard let str1 = txtOTP1.text?.value,
            let str2 = txtOTP2.text?.value,
            let str3 = txtOTP3.text?.value,
            let str4 = txtOTP4.text?.value else {
                AppManager.showAlert(Constants.KAppName, "Please enter OTP.", view: self)
                return
        }
        let otp = str1+str2+str3+str4
        
        var param : [String : Any] = otpData
        param["otp_number"] = otp
        
        AppManager.startActivityIndicator()
        ApiClient().apiCallMethod(URLMethods.verifyOTP, method: .post, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            let msg = (response as? NSDictionary)?.value(forKey: "message") as? String
            AppManager.showToast(msg ?? "")
            self.navigationController?.popViewController(animated: true)
            
        }) { (error) in
            AppManager.stopActivityIndicator()
            AppManager.showToast(error ?? "")
        }
    }

    
    //MARK:- TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String) -> Bool {
        // Range.length == 1 means,clicking backspace
        if (range.length == 0){
            if textField == txtOTP1 {
                txtOTP2.becomeFirstResponder()
            }
            if textField == txtOTP2 {
                txtOTP3.becomeFirstResponder()
            }
            if textField == txtOTP3 {
                txtOTP4.becomeFirstResponder()
            }
            if textField == txtOTP4 {
                txtOTP4.resignFirstResponder()
            }
            textField.text? = string
            return false
        }else if (range.length == 1) {
            
            if textField == txtOTP4 {
                txtOTP4.text = ""
                txtOTP3.becomeFirstResponder()
            }
            if textField == txtOTP3 {
                txtOTP3.text = ""
                txtOTP2.becomeFirstResponder()
            }
            if textField == txtOTP2 {
                txtOTP2.text = ""
                txtOTP1.becomeFirstResponder()
            }
            if textField == txtOTP1 {
                txtOTP1.text = ""
                txtOTP1.resignFirstResponder()
            }
            
            return false
        }
        return true
    }
    
    
}
