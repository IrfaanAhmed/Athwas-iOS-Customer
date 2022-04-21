//
//  CheckoutFooterView.swift
//  IA
//
//  Created by admin on 02/11/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CheckoutFooterView: UITableViewHeaderFooterView, UITextFieldDelegate {

    var viewModel : CheckoutValidate = CheckoutValidate()

    @IBOutlet weak var lblCartValue: UILabel!
    @IBOutlet weak var lblDeliveryCharges: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
//    @IBOutlet weak var lblVAT: UILabel!
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var txtPromocode: UITextField!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var lblPromocode: UILabel!
    @IBOutlet weak var lblPaymentMode: UILabel!
    @IBOutlet weak var lblRewardsPoint: UILabel!
    @IBOutlet weak var btnRewardsPoint: UIButton!
    @IBOutlet weak var txtName: BindingTextField!{
        didSet {
            txtName.bind {self.viewModel.name = $0 }
            self.viewModel.nameField = txtName
        }
    }
    @IBOutlet weak var txtMobile: BindingTextField!
        {
        didSet {
            txtMobile.bind {self.viewModel.mobile = $0 }
            self.viewModel.mobileField = txtMobile
        }
    }

    var callbackCode : ((String?) -> Void)?
    var callback : (() -> Void)?
    var callbackRewards : ((Bool) -> Void)?
    var callbackText : ((CheckoutValidate) -> Void)?
    var totalDiscount = 0.0
    
    
    var promoData : PormoCodeModel? {
        didSet {
            let promocodeTitle = promoData != nil ? "Applied" : "Apply"
            btnApply.setTitle(promocodeTitle, for: .normal)
            
            lblPromocode.isHidden = promoData != nil ? false : true
            let discount = totalDiscount + (promoData?.discountPrice ?? 0)
        
            lblDiscount.text = String(format: "%@%.2f", Constants.KCurrency, discount)
            txtPromocode.text = promoData?.promoCode ?? txtPromocode.text
        }
    }
    
    var deliveryData : DeliveryFeeModel? {
        didSet {
            lblDeliveryCharges.text = String(format: "%@%.2f", Constants.KCurrency, deliveryData?.deliveryFee ?? 0.00)
       //     lblVAT.text = String(format: "%@%.2f", Constants.KCurrency, deliveryData?.vatAmount ?? 0.00)
            lblRewardsPoint.text = "- Reward Points:- \(deliveryData?.redeemPoint ?? 0)"
            btnRewardsPoint.isHidden = (deliveryData?.redeemPoint ?? 0.0) > 0 ? false : true
        }
    }
    
    
    @IBAction func applyCode(_ sender : Any) {
        callbackCode!(txtPromocode.text ?? "")
    }
    
    @IBAction func btnChangePaymentMode(_ sender: Any) {
        callback!()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        callbackCode?(nil)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        callbackText!(viewModel)
        if textField == txtName {
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            txtName.text = trimmedString
        }
    }
    
    @IBAction func btnRewards(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        callbackRewards!(sender.isSelected)
    }
        
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtName {
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            return (string == filtered)
        } else if textField == txtMobile {
            let cs = NSCharacterSet(charactersIn: "0123456789").inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            return (string == filtered)
        }
        return true
    }
}
