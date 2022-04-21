//
//  ProductCell.swift
//  IA
//
//  Created by Yogesh Raj on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import SDWebImage


class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameTxt: UILabel!
    @IBOutlet weak var categoryNameTxt: UILabel!
    @IBOutlet weak var offerPriceTxt: UILabel!
    @IBOutlet weak var actualPriceTxt: UILabel!
    @IBOutlet weak var lblItemNotAvailable: UILabel?
    @IBOutlet weak var offerTxt: UILabel!
    @IBOutlet weak var viewOffer : UIView!
    @IBOutlet weak var addCartBtn: GradientButton!
    @IBOutlet weak var btnFav: UIButton?
    @IBOutlet weak var topConstraint : NSLayoutConstraint!
    @IBOutlet weak var lblRating: UILabel!
    
    var callbackFavStatus : ((Int) -> Void)?
    var callbackCart : (() -> Void)?
    
    var data : ProductListDataModel? {
        didSet {
            setData(data)
        }
    }
    
    var product : OfferProductDataModel? {
        didSet {
            setupOfferProduct(product)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(_ data : ProductListDataModel?) {
        
        productNameTxt.text = "\(data?.name ?? "") - \(data?.inventoryName ?? "")"
        categoryNameTxt.text = "\(data?.subcategory?.name ?? "")" + " - " + "\(data?.category?.name ?? "")"
        
        if  data?.images?.count ?? 0 > 0 {
            let url = data?.images?[0].productImageURL
            productImage.sd_setImage(with: URL(string: url ?? ""), placeholderImage: #imageLiteral(resourceName: "login_logo"))
        }
        
        btnFav?.isSelected = data?.isFavourite == 1 ? true : false
        
        let btnTitle = (data?.availableQuantity ?? 0) <= 0 ? "Notify me" : "Add to Cart"
        addCartBtn.setTitle(btnTitle, for: .normal)
        
        lblRating.text = "\(String(format: "%.1f", (Double.convertToDouble(anyValue: data?.rating as Any))))"
        
        if data?.isDiscount == 1 {
            
            offerPriceTxt?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.offerPrice ?? 0.0))"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            actualPriceTxt?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
            
            let offerText = data?.discountType == 1 ? "\(data?.discountValue?.clean ?? "0")% off" : "\(Constants.KCurrency)\(data?.discountValue?.clean ?? "0") off"
            offerTxt.text = offerText
            viewOffer.isHidden  = false
            //  topConstraint.constant = 4.0
        }
        else {
            
            offerPriceTxt?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            actualPriceTxt?.attributedText = AppManager.strikeThroughAttribute(str: "")
            viewOffer.isHidden = true
            //    topConstraint.constant = -12.0
        }
        
    }
    
    func setupOfferProduct(_ product : OfferProductDataModel?) {
        
        productNameTxt.text = "\(product?.productData?[0].name ?? "")"
        categoryNameTxt.text = "\(product?.productData?[0].category?.name ?? "")" + " - " + "\(product?.productData?[0].subcategory?.name ?? "")"
        
        if  product?.productData?.count ?? 0 > 0 {
            let url = product?.productData?[0].images?[0].productImageURL
            productImage.sd_setImage(with: URL(string: url ?? ""), placeholderImage: #imageLiteral(resourceName: "login_logo"))
        }
        
        let btnTitle = (product?.availableQuantity ?? 0) <= 0 ? "Notify me" : "Add to Cart"
        addCartBtn.setTitle(btnTitle, for: .normal)
        
        if data?.isDiscount == 1 {
            
            offerPriceTxt?.text = "\(Constants.KCurrency)\(String(format: "%.2f", product?.offerPrice ?? 0.0))"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", product?.price ?? 0.0))"
            actualPriceTxt?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
        }
        else {
            
            offerPriceTxt?.text = "\(Constants.KCurrency)\(String(format: "%.2f", product?.price ?? 0.0))"
            actualPriceTxt?.attributedText = AppManager.strikeThroughAttribute(str: "")
        }
    }
    
    
    @IBAction func btnFav_Clicked(_ sender: UIButton) {
        self.callbackFavStatus?(data?.isFavourite == 0 ? 1 : 0)
    }
    
    @IBAction func btnCart_Clicked(_ sender: UIButton) {
        self.callbackCart?()
    }
}
