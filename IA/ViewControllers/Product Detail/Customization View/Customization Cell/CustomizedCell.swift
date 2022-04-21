//
//  CustomizedCell.swift
//  IA
//
//  Created by admin on 17/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CustomizedCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblPrice : UILabel!
    @IBOutlet weak var lblActualPrice : UILabel!
    
    var data : CustomizationListModel? {
        didSet {
            setupData(data)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupData(_ data : CustomizationListModel?) {
        
        let str = NSMutableString()
        for item in data?.customize ?? [] {
            let value = item.value?.name ?? ""
            str.append(value)
            str.append(" - ")
        }
        lblTitle.text = String(String(str).dropLast(2))
        
        if data?.isDiscount == 1 {
    
            lblPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.offerPrice ?? 0.0))"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            lblActualPrice?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
        }
        else {
            
            lblPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            lblActualPrice?.attributedText = AppManager.strikeThroughAttribute(str: "")
        }
        viewBg.layer.borderColor = data?.isSelected == true ? UIColor.appDarkGreen.cgColor : UIColor.appLightGrey.cgColor
    }
}
