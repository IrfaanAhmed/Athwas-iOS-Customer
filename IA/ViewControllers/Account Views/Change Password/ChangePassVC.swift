//
//  ChangePassVC.swift
//  Tivo
//
//  Created by admin on 01/07/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit

class ChangePassVC: BaseClassVC {
    
    private var viewModel : ChangePassValidate = ChangePassValidate()
    
    @IBOutlet weak var txtOldPassword: BindingTextField! {
        didSet {
            txtOldPassword.bind {self.viewModel.oldPassword = $0 }
            self.viewModel.oldPasswordField = txtOldPassword
        }
    }
    @IBOutlet weak var txtNewPassword: BindingTextField! {
        didSet {
            txtNewPassword.bind {self.viewModel.newPassword = $0 }
            self.viewModel.newPasswordField = txtNewPassword
        }
    }
    @IBOutlet weak var txtConfirmPass: BindingTextField! {
        didSet {
            txtConfirmPass.bind {self.viewModel.confirmPass = $0 }
            self.viewModel.confirmPassField = txtConfirmPass
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        self.headerTitle.text = "Change Password"
        self.backBtn.isHidden = false
        self.searchBtn.isHidden = true
        self.cartBtn.isHidden = true
    }
    
    
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        
        if viewModel.isValid {
            
            let param = ["old_password" : txtOldPassword.text ?? "",
                         "new_password" : txtNewPassword.text ?? ""] as [String : Any]
            
            AppManager.startActivityIndicator()
            ApiClient().apiCallMethod(URLMethods.changePassword, method: .post, parameter: param , successClosure: { (response) in
                
                AppManager.stopActivityIndicator()
                let msg = (response as? NSDictionary)?.value(forKey: "message") as? String
                AppManager.showToast(msg ?? "")
                self.navigationController?.popViewController(animated: true)
                
            }) { (error) in
                AppManager.stopActivityIndicator()
                AppManager.showToast(error ?? "")
            }
        }
        else {
           // AppManager.showAlert(Constants.kAppDisplayName, viewModel.message, view: self)
            viewModel.activeField?.showError(message: viewModel.message)
        }
        
    }
    
}
