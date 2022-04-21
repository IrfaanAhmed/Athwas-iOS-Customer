//
//  Validate.swift
//  SportsJunki
//
//  Created by octal on 08/03/19.
//  Copyright © 2019 Admin octal. All rights reserved.
//

import Foundation
import UIKit
//changes


protocol SignINViewModel {
    
    var message :String {get set}
    var isValid :Bool { mutating get }
}

struct SignInValidate : SignINViewModel {
    
    var message : String = ""
    var email :String = ""
    var password :String = ""
    var activeField = BindingTextField()
    var emailField = BindingTextField()
    var passField = BindingTextField()
    
    var isValid :Bool {
        mutating get {
            self.message = ""
            self.validate()
            return self.message.count == 0 ? true : false
        }
    }
    
    mutating func validate() {
        
        if  email.isEmptyString(){
            message = AppString.msgCommon
            activeField = emailField
            return
        }
        
        if Double(email) != nil {
            if  email.count != 10 {
                message = AppString.msgVaildPhone
                activeField = emailField
                return
            }
        } else {
            if !email.validateEmail() || email.count < 9 {
                message = AppString.msgValidEmail
                activeField = emailField
                return
            }
        }
        
        if password.isEmptyString() {
            message = AppString.msgPassword
            activeField = passField
            return
        }
        
    }
}


protocol SignUPViewModel {
    
    var message : String {get set}
    var isValid :Bool { mutating get }
}


struct SignUPValidate : SignUPViewModel {
    
    var message: String = ""
    var mobile :String = ""
    var password :String = ""
    var name :String = ""
    var email :String = ""
    var isSelected : Bool = false
    var activeField: BindingTextField?
    var mobileField = BindingTextField()
    var emailField = BindingTextField()
    var nameField = BindingTextField()
    var passwordField = BindingTextField()
    
    var isValid :Bool {
        mutating get {
            
            self.message = ""
            self.validate()
            return self.message.count == 0 ? true : false
        }
    }
    
    mutating func validate() {
        
        if name.isEmptyString() {
            message = AppString.msgNameLength
            activeField = nameField
            return
        }
        
        if name.count < 3 {
            message = AppString.msgNameLength
            activeField = nameField
            return
        }
        
        if mobile.isEmptyString() {
            message = AppString.msgVaildPhone
            activeField = mobileField
            return
        }
        
        if mobile.count != 10 {
            message = AppString.msgVaildPhone
            activeField = mobileField
            return
        }
        
        if email.isEmptyString() {
            message = AppString.msgEmail
            activeField = emailField
            return
        }
        
        if !email.validateEmail() {
            message = AppString.msgValidEmail
            activeField = emailField
            return
        }
        
        if  (email.count < 9) {
            message = AppString.msgEmailLength
            activeField = emailField
            return
        }
        
        if  password.isEmptyString() {
            message = AppString.msgVaildPassword
            activeField = passwordField
            return
        }
        
        if password.count < 6 {
            message = AppString.msgVaildPassword
            activeField = passwordField
            return
        }
        
        if isSelected == false {
            message = AppString.checkedTerms
            activeField = nil
            return
        }
        
    }
}




protocol ForgotViewModel {
    
    var message : String {get set}
    var isValid :Bool { mutating get }
}


struct ForgotValidate : ForgotViewModel {
    
    var message: String = ""
    var email :String = ""
    
    var isValid :Bool {
        mutating get {
            
            self.message = ""
            self.validate()
            return self.message.count == 0 ? true : false
        }
    }
    
    mutating func validate() {
        
        if  email.isEmptyString(){
            message = AppString.msgCommon
            return
        }
        
        if Double(email) != nil {
            if email.count != 10 {
                message = "Please enter valid mobile number"
                return
            }
        } else {
            if !email.validateEmail() {
                message = "Please enter valid email"
                return
            }
        }
        
    }
    
}

protocol ResetViewModel {
    
    var message : String {get set}
    var isValid :Bool { mutating get }
}


struct ResetValidate : ResetViewModel {
    
    var message: String = ""
    var password :String = ""
    var confirmPass :String = ""
    var activeField: BindingTextField?
    var passwordField = BindingTextField()
    var confirmPassField = BindingTextField()
    
    var isValid :Bool {
        mutating get {
            
            self.message = ""
            self.validate()
            return self.message.count == 0 ? true : false
        }
    }
    
    mutating func validate() {
        
        if  password.isEmptyString() {
            message = AppString.msgVaildPassword
            activeField = passwordField
            return
        }
        
        if password.count < 6 {
            message = AppString.msgVaildPassword
            activeField = passwordField
            return
        }
        
        if  confirmPass.isEmptyString() {
            message = AppString.msgConfirmPassword
            activeField = confirmPassField
            return
        }
        
        if  confirmPass != password {
            message = AppString.msgPasswordMatch
            activeField = confirmPassField
            return
        }
    }
}
