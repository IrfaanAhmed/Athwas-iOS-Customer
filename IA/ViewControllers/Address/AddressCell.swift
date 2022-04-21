//
//  AddressCell.swift
//  IA
//
//  Created by Yogesh Raj on 18/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {
    
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var addressTxt: UILabel!
    @IBOutlet weak var pinTxt: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var btnAddress: UIButton!
    var selectedAddress: AddressDataModel?
    
    var data : AddressDataModel? {
        didSet {
            titleTxt.text = data?.addressType
            addressTxt.text = data?.fullAddress
            pinTxt.text = data?.zipCode
            
            let btnTitle = data?.defaultAddress == 1 ? "Default" : "Set as Default"
            let btnColor : UIColor = data?.defaultAddress == 1 ? .white : .appBlueDarkColor
            let btnBg : UIColor = data?.defaultAddress == 1 ? .appBlueDarkColor : .white
            btnAddress.setTitle(btnTitle, for: .normal)
            btnAddress.setTitleColor(btnColor, for: .normal)
            btnAddress.backgroundColor = btnBg
            
            if data?.defaultAddress == 1 {
                var userData = Constants.kAppDelegate.user
                userData?.defaultAddress = data
                let user = try? JSONEncoder().encode(userData)
                Constants.kAppDelegate.user = userData
                Constants.kAppDelegate.user?.saveUser(user!)
            }
            
            if selectedAddress != nil {
                
                if selectedAddress?.id == data?.id {
                    self.backgroundColor = .appLightGreen
                    addressTxt.textColor = .white
                    pinTxt.textColor = .white
                            
                }else {
                    self.backgroundColor = .white
                    addressTxt.textColor = .secondaryLabel
                    pinTxt.textColor = .secondaryLabel
                }
            }
            else {
                addressTxt.textColor = data?.defaultAddress == 1 ? .white : .secondaryLabel
                pinTxt.textColor = data?.defaultAddress == 1 ? .white : .secondaryLabel
                self.backgroundColor = data?.defaultAddress == 1 ? .appLightGreen : .white

            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
