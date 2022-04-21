//
//  LoginVC.swift
//  IA
//
//  Created by Shrish Mishra on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    private var viewModel : SignInValidate = SignInValidate()
    
    @IBOutlet weak var txtPassword: BindingTextField! {
        didSet {
            txtPassword.bind {self.viewModel.password = $0 }
            self.viewModel.passField = txtPassword
        }
    }
    @IBOutlet weak var txtEmail: BindingTextField! {
        didSet {
            txtEmail.bind {self.viewModel.email = $0 }
            self.viewModel.emailField = txtEmail
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtEmail.text = nil
        txtPassword.text = nil
    }
    
    
    // MARK: - Press Login
    @IBAction func btnLogin_Click(_ sender: UIButton) {
        
        if viewModel.isValid {
            
            let param = ["country_code" : "+91",
                         "phone" : txtEmail.text ?? "",
                         "password" : txtPassword.text ?? "",
                         "latitude" : address.latitude == nil ? "" : address.latitude as Any,
                         "longitude" : address.longitude == nil ? "" : address.longitude as Any
                         
            ] as [String : Any]
            
            AppManager.startActivityIndicator()
            ApiClient().apiCallMethod(URLMethods.login, method: .post, parameter: param, successClosure: { (response) in
                
                AppManager.stopActivityIndicator()
                let data = (response as? NSDictionary)?.value(forKey: "data") as? NSDictionary
                if data?["is_user_verified"] as? Int == 0 {
                    
                    let msg = response?["message"] as? String
                    AppManager.showAlert_withOneAction(Constants.KAppName, msg ?? "", self) { (success) in
                        
                        let temp = ["otp_number" : data?["otp_number"],
                                    "country_code" : data?["country_code"],
                                    "phone"  : data?["phone"],
                                    "otp_for" : "register"]
                        
                        self.performSegue(withIdentifier: "segueOTP", sender: temp)
                    }
                }else {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                          let user = try? JSONDecoder().decode(UserDataModel.self, from: jsonData),
                          let userData = try? JSONEncoder().encode(user) else {return }
                    
                    Constants.kAppDelegate.user = user
                    Constants.kAppDelegate.user?.saveUser(userData)
                    
                    Constants.kSceneDelegate.switchToHome()
                }
                
            }) { (error) in
                AppManager.stopActivityIndicator()
                AppManager.showToast(error ?? "")
            }
        }
        else {
           // AppManager.showAlert(Constants.kAppDisplayName, viewModel.message, view: self)
            viewModel.activeField.showError(message: viewModel.message)
        }
        
    }
    
    
    // MARK: - Press Skip
    @IBAction func btnSkip_CLicked(_ sender: UIButton) {
        Constants.kSceneDelegate.switchToHome()
    }
    
    // MARK: - Press Back
    @IBAction func pressBack(_ sender: UIButton) {
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

extension LoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        return true
    }
}
