//
//  ResetVC.swift
//  IA
//
//  Created by Yogesh Raj on 30/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class ResetVC: UIViewController {
    
    private var viewModel : ResetValidate = ResetValidate()
    @IBOutlet weak var newPasswordTxt: BindingTextField!{
        didSet {
            newPasswordTxt.bind {self.viewModel.password = $0 }
            self.viewModel.passwordField = newPasswordTxt
        }
    }
    @IBOutlet weak var newConfirmPasswordTxt: BindingTextField!{
        didSet {
            newConfirmPasswordTxt.bind {self.viewModel.confirmPass = $0 }
            self.viewModel.confirmPassField = newConfirmPasswordTxt
        }
    }
    
    @IBOutlet weak var txtOTP1: UITextField!
    @IBOutlet weak var txtOTP2: UITextField!
    @IBOutlet weak var txtOTP3: UITextField!
    @IBOutlet weak var txtOTP4: UITextField!
    var otpData = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.showAlert(Constants.KAppName, String(self.otpData["otp_number"] as! Int), view: self)
    }
    
    
    // MARK: - Press Back
    @IBAction func pressBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Press Reset
    @IBAction func btnResetAction(_ sender: UIButton) {
        
        guard let str1 = txtOTP1.text?.value,
            let str2 = txtOTP2.text?.value,
            let str3 = txtOTP3.text?.value,
            let str4 = txtOTP4.text?.value else {
                AppManager.showAlert(Constants.KAppName, "Please enter OTP.", view: self)
                return
             }
          let otp = str1+str2+str3+str4
        
        guard String(self.otpData["otp_number"] as! Int) == otp else {
            AppManager.showAlert(Constants.KAppName, "Please enter valid OTP.", view: self)
            return
        }
        
          if viewModel.isValid {
            
            let param : [String : Any] = [
                "country_code" : otpData["country_code"] ?? "",
                "phone"  : otpData["phone"] ?? "",
                "otp_number" : otp,
                "new_password" : newPasswordTxt.text ?? ""
            ]
            
            AppManager.startActivityIndicator()
            ApiClient().apiCallMethod(URLMethods.resetPass, method: .post, parameter: param, successClosure: { (response) in
                
                AppManager.stopActivityIndicator()
                
                let msg = (response as? NSDictionary)?.value(forKey: "message") as? String ?? ""
                AppManager.showAlert_withOneAction(Constants.KAppName, msg, self) { (success) in
                    
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: LoginVC.self) {
                            _ =  self.navigationController!.popToViewController(controller, animated: true)
                            return
                        }
                    }
                }
                
            }) { (error) in
                AppManager.stopActivityIndicator()
                AppManager.showToast(error ?? "")
            }
        }
        else {
           // AppManager.showAlert(Constants.KAppName, viewModel.message, view: self)
            viewModel.activeField?.showError(message: viewModel.message)
        }
    }
    
}

extension ResetVC: UITextFieldDelegate {
    
    
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
