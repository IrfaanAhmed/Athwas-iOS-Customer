//
//  ForgotVC.swift
//  IA
//
//  Created by Yogesh Raj on 24/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class ForgotVC: UIViewController {
    
    private var viewModel : ForgotValidate = ForgotValidate()
    
    @IBOutlet weak var txtEmail: BindingTextField! {
        didSet {
            txtEmail.bind {self.viewModel.email = $0 }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Press Back
    @IBAction func forgotBtnAction(_ sender: UIButton) {
        
        if viewModel.isValid {
            
            let param = ["country_code" : "+91",
                         "phone" : txtEmail.text ?? "",
                         "otp_for" : "forgot_password"
                ] as [String : Any]
            
            AppManager.startActivityIndicator()
            ApiClient().apiCallMethod(URLMethods.resendOTP, method: .post, parameter: param, successClosure: { (response) in
                
                AppManager.stopActivityIndicator()
                let msg = (response as? NSDictionary)?.value(forKey: "message") as? String ?? ""
                
                AppManager.showAlert_withOneAction(Constants.KAppName, msg, self) { (success) in
                    
                    let otp = (response as? NSDictionary)?.value(forKeyPath: "data.otp_number") as? Int
                    let data = ["otp_for" : "register",
                                "country_code" : "+91",
                                "phone" : self.txtEmail.text ?? "",
                                "otp_number" : otp as Any
                        ] as [String : Any]
                    
                    self.performSegue(withIdentifier: "segueReset", sender: data)
                }
                
            }) { (error) in
                AppManager.stopActivityIndicator()
                AppManager.showToast(error ?? "")
            }
        }
        else {
          //  AppManager.showAlert(Constants.kAppDisplayName, viewModel.message, view: self)
            txtEmail.showError(message: viewModel.message)
        }
    }
    
    // MARK: - Press Back
    @IBAction func pressBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueReset" {
            let vc = segue.destination as! ResetVC
            vc.otpData = sender as! [String : Any]
        }
    }
    
    
}
