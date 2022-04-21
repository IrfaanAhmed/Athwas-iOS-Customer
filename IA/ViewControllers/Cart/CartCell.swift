//
//  CartCell.swift
//  IA
//
//  Created by Yogesh Raj on 21/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {
    
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameTxt: UILabel!
    @IBOutlet weak var discountTxt: UILabel!
    @IBOutlet weak var actualPriceTxt: UILabel!
    @IBOutlet weak var offerPriceTxt: UILabel!
    @IBOutlet weak var categoryNameTxt: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var qtyTxt: UILabel!
    @IBOutlet weak var viewOffer : UIView!
    @IBOutlet weak var viewButton : UIView!
    
    @IBOutlet weak var topConstraint : NSLayoutConstraint!
    var callbackDelete : (() -> Void)?
    var callbackAdd : ((Int) -> Void)?
    var callbackMinus : ((Int) -> Void)?
    
    
    var data : CategoryItem? {
        didSet {
            setData(data)
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
    
    func setData(_ data : CategoryItem?) {
        
        productNameTxt.text = "\(data?.name ?? "") - \(data?.inventoryName ?? "")"
        categoryNameTxt.text = "\(data?.subcategory?.name ?? "")" + " - " + "\(data?.category?.name ?? "")"
        if data?.availble == 0 {
            lblStatus.isHidden = false
            viewButton.isHidden = true
            lblStatus.text = "Not available"
        } else if data?.availableQuantity == 0 {
            lblStatus.isHidden = false
            viewButton.isHidden = true
            lblStatus.text = "Out of stock"
        } else if (data?.quantity ?? 0) > (data?.availableQuantity ?? 0) {
            lblStatus.isHidden = false
            viewButton.isHidden = false
            lblStatus.text = "\(data?.availableQuantity ?? 0) items in stocks"
        } else {
            lblStatus.isHidden = true
            viewButton.isHidden = false
        }
      
        qtyTxt.text = "\(data?.quantity ?? 0)"
        
        if  data?.images?.count ?? 0 > 0 {
            let url = data?.images?[0].productImageThumbURL
            productImage.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: ""))
        }
        
        if data?.isDiscount == 1 {
            
            offerPriceTxt?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.offerPrice ?? 0.0))x\(data?.quantity ?? 0)"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            actualPriceTxt?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
            
            let offerText = data?.discountType == 1 ? "\(data?.discountValue?.clean ?? "0")% off" : "\(Constants.KCurrency)\(data?.discountValue?.clean ?? "0") off"
            discountTxt.text = offerText
            viewOffer.isHidden  = false
            topConstraint.constant = 6.0
        }
        else {
            
            offerPriceTxt?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))x\(data?.quantity ?? 0)"
            actualPriceTxt?.attributedText = AppManager.strikeThroughAttribute(str: "")
            viewOffer.isHidden = true
            topConstraint.constant = -18.0
        }
        
    }
    
    @IBAction func pressAdd(_ sender: UIButton) {
        var qty = data?.quantity ?? 0
        qty = qty + 1
        callbackAdd?(qty)
    }
    
    @IBAction func pressMinus(_ sender: UIButton) {
        var qty = data?.quantity ?? 0
        if qty > 1 {
            qty = qty - 1
            callbackMinus?(qty)
        }
    }
    
    @IBAction func pressDelete(_ sender: UIButton) {
        callbackDelete?()
    }
}
