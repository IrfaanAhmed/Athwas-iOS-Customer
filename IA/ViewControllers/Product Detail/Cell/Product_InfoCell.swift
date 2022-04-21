//
//  Product_Info.swift
//  IA
//
//  Created by admin on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class Product_InfoCell: UITableViewCell {

    @IBOutlet weak var lblOffer : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblCat : UILabel!
    @IBOutlet weak var lblSubcat : UILabel!
    @IBOutlet weak var lblBrand : UILabel!
    @IBOutlet weak var lblRating : UILabel!
    @IBOutlet weak var lblDisPrice : UILabel!
    @IBOutlet weak var viewOffer : UIView!
    @IBOutlet weak var lblActualPrice : UILabel!
    @IBOutlet weak var viewRating : FloatRatingView!
    @IBOutlet weak var lblItemCount : UILabel!
    
    var cellData : ProductDetailModel? {
        didSet {
            setupData(cellData)
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

    func setupData(_ data : ProductDetailModel?) {
        
        lblTitle.text = "\(data?.name ?? "") - \(data?.inventoryName ?? "")"
        lblCat.text = "\(data?.category?.name ?? "") - "
        lblSubcat.text = data?.subcategory?.name
        lblRating.text = "\(data?.ratingCount ?? "0")"
        viewRating.rating = Double.convertToDouble(anyValue: data?.rating ?? "0")
        lblBrand.text = data?.brand?.name
        
        if data?.isDiscount == 1 {
            
            lblDisPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.offerPrice ?? 0.0))"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            lblActualPrice?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
            
            let offerText = data?.discountType == 1 ? "\(data?.discountValue?.clean ?? "0")% off" : "\(Constants.KCurrency)\(data?.discountValue?.clean ?? "0") off"
            lblOffer.text = offerText
            viewOffer.isHidden  = false
        }
        else {
            
            lblDisPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            lblActualPrice?.attributedText = AppManager.strikeThroughAttribute(str: "")
            viewOffer.isHidden = true
        }
        
        if ((data?.quantity ?? 0) <= 0) && (data?.quantity != nil) {
            lblItemCount.text = "Out of stock"
            lblItemCount.textColor = .red
        }
        else if ((data?.quantity ?? 0) <= (data?.minInventory ?? 0)) && (data?.quantity != nil) {
            lblItemCount.text = "Only \(data?.quantity ?? 0) items left in the stock"
            lblItemCount.textColor = UIColor.appBlueDarkColor
        }
        else {
            lblItemCount.text = ""
        }
        
    }
}
