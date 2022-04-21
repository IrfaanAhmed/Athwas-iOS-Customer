//
//  SignUpVC.swift
//  IA
//
//  Created by Shrish Mishra on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
    private var viewModel : SignUPValidate = SignUPValidate()
    @IBOutlet weak var txtName: BindingTextField!{
        didSet {
            txtName.bind {self.viewModel.name = $0 }
            self.viewModel.nameField = txtName
        }
    }
    @IBOutlet weak var txtMobileNumber: BindingTextField!
        {
        didSet {
            txtMobileNumber.bind {self.viewModel.mobile = $0 }
            self.viewModel.mobileField = txtMobileNumber
        }
    }
    
    @IBOutlet weak var txtEmail: BindingTextField!
        {
        didSet {
            txtEmail.bind {self.viewModel.email = $0 }
            self.viewModel.emailField = txtEmail
        }
    }
    @IBOutlet weak var txtPassword: BindingTextField!
        {
        didSet {
            txtPassword.bind {self.viewModel.password = $0 }
            self.viewModel.passwordField = txtPassword
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnCheck_Clicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.isSelected = sender.isSelected
    }
    
    
    @IBAction func btnTerms_Click(_ sender: UIButton) {
        let vc = Constants.KMainStoryboard.instantiateViewController(identifier: "StaticPageVC") as StaticPageVC
        vc.isfromSideMenu = false
        vc.webTitle = "Terms of Use"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnSignUp_Click(_ sender: UIButton) {
        
        if viewModel.isValid {
            
            let param = ["username" : txtName.text!,
                         "email" : txtEmail.text!,
                         "country_code" : "+91",
                         "phone" : txtMobileNumber.text ?? "",
                         "password" : txtPassword.text!
                ] as [String : Any]
            
             AppManager.startActivityIndicator()
            ApiClient().apiCallMethod(URLMethods.signup, method: .post, parameter: param, successClosure: { (response) in
                
                AppManager.stopActivityIndicator()
                let msg = (response as? NSDictionary)?.value(forKey: "message") as? String ?? ""
                
                AppManager.showAlert_withOneAction(Constants.KAppName, msg, self) { (success) in
                    
                    let otp = (response as? NSDictionary)?.value(forKeyPath: "data.otp_number") as? Int
                    let data = ["otp_for" : "register",
                                "country_code" : "+91",
                                "phone" : self.txtMobileNumber.text ?? "",
                                "otp_number" : otp as Any
                        ] as [String : Any]
                    
                    self.performSegue(withIdentifier: "segueOTP", sender: data)
                }
                
            }) { (error) in
                AppManager.stopActivityIndicator()
                AppManager.showToast(error ?? "")
            }
        }
        else {
            if  viewModel.activeField == nil {
                 AppManager.showAlert(Constants.KAppName, viewModel.message, view: self)
            } else {
                viewModel.activeField?.showError(message: viewModel.message)
            }
        }
    }
    
    
    @IBAction func btnSign_Click(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
               self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnSkip_Click(_ sender: UIButton) {
        
         Constants.kSceneDelegate.switchToHome()
    }
    
    // MARK: - Press Back
    @IBAction func btnBack_Click(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueOTP" {
            let vc = segue.destination as! OTPVC
            vc.otpData = sender as! [String : Any]
        }
    }
    
    
}

extension SignUpVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For numers
        if textField == txtMobileNumber {
            let set = CharacterSet(charactersIn: "0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return set.isSuperset(of: characterSet)
        }
        else if textField == txtName {
            
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            return (string == filtered)
        }
        else if textField == txtPassword {
            if string == " " {
                return false
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtName {
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            txtName.text = trimmedString
        }
    }
}

