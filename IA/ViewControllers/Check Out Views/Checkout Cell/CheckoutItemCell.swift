//
//  CheckoutItemCell.swift
//  IA
//
//  Created by admin on 29/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CheckoutItemCell: UITableViewCell {
    
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblOfferPrice: UILabel!
    @IBOutlet weak var lblActualPrice: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblofferText: UILabel!
    @IBOutlet weak var viewOffer : UIView!
    @IBOutlet weak var lblCateName: UILabel!
    @IBOutlet weak var topConstraint : NSLayoutConstraint!
    var callbackDelete : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        //lblActualPrice?.attributedText = AppManager.strikeThroughAttribute(str: "₹200")
    }
    
    func setData(_ data : CategoryItem?) {
        
        lblItemName.text = "\(data?.name ?? "") - \(data?.inventoryName ?? "")"
        lblCateName.text = "\(data?.subcategory?.name ?? "")" + " - " + "\(data?.category?.name ?? "")"
        
        if  data?.images?.count ?? 0 > 0 {
            let url = data?.images?[0].productImageThumbURL
            imgItem.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: ""))
        }
        lblStatus.isHidden = data?.availableQuantity == 0 ? false : (data?.availble == 0 ? false : true)
        
        if data?.isDiscount == 1 {
            
            lblOfferPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.offerPrice ?? 0.0))x\(data?.quantity ?? 0)"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            lblActualPrice?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
            
            let offerText = data?.discountType == 1 ? "\(data?.discountValue?.clean ?? "0")% off" : "\(Constants.KCurrency)\(data?.discountValue?.clean ?? "0") off"
            lblofferText.text = offerText
            viewOffer.isHidden  = false
            topConstraint.constant = 6.0
        }
        else {
            
            lblOfferPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))x\(data?.quantity ?? 0)"
            lblActualPrice?.attributedText = AppManager.strikeThroughAttribute(str: "")
            viewOffer.isHidden = true
            topConstraint.constant = -18.0
        }
    }
    
    @IBAction func pressDelete(_ sender: UIButton) {
        callbackDelete?()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
