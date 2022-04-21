//
//  ChangePassViewModel.swift
//  IA
//
//  Created by admin on 21/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import Foundation


protocol ChangePassViewModel {
    
    var message : String {get set}
    var isValid :Bool { mutating get }
}


struct ChangePassValidate : ChangePassViewModel {
    
    var message: String = ""
    var oldPassword :String = ""
    var newPassword :String = ""
    var confirmPass :String = ""
    var activeField: BindingTextField?
    var oldPasswordField = BindingTextField()
    var newPasswordField = BindingTextField()
    var confirmPassField = BindingTextField()
    
    var isValid :Bool {
        mutating get {
            
            self.message = ""
            self.validate()
            return self.message.count == 0 ? true : false
        }
    }
    
    mutating func validate() {
        
        if  oldPassword.isEmptyString() {
            message = AppString.msgOldPassword
            activeField = oldPasswordField
            return
        }
        
        if oldPassword.count < 6 {
            message = AppString.msgVaildPassword
            activeField = oldPasswordField
            return
        }
        
        if  newPassword.isEmptyString() {
            message = AppString.msgPassword
            activeField = newPasswordField
            return
        }
        
        if newPassword.count < 6 {
            message = AppString.msgVaildPassword
            activeField = newPasswordField
            return
        }
        
        if  confirmPass.isEmptyString() {
            message = AppString.msgConfirmPassword
            activeField = confirmPassField
            return
        }
        
        if  confirmPass != newPassword {
            message = AppString.msgPasswordMatch
            activeField = confirmPassField
            return
        }
    }
}
