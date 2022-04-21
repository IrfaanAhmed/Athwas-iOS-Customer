//
//  OrderItemsCell.swift
//  IA
//
//  Created by admin on 28/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class OrderItemsCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameTxt: UILabel!
    @IBOutlet weak var categoryNameTxt: UILabel!
    @IBOutlet weak var offerPriceTxt: UILabel!
    @IBOutlet weak var actualPriceTxt: UILabel!
    @IBOutlet weak var btnReview : UIButton!
    @IBOutlet weak var btnCancel : UIButton!
    @IBOutlet weak var btnReturn : UIButton!
    @IBOutlet weak var lblItemStatus: UILabel!
    var callback : ((String) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setData(_ data : Product?, catData: CategoryDetail?, fullData: OrderDetailModel?) {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(tapGestureRecognizer)
        
        productNameTxt.text = "\(data?.name ?? "")" //" - \(data?.inventoryName ?? "")"
        categoryNameTxt.text = "\(data?.categoryData?.name ?? "") - \(data?.subCategoryData?.name ?? "")"
        
        offerPriceTxt?.text = data?.isDiscount == 0 ? "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))x\(data?.quantity ?? 0)" : "\(Constants.KCurrency)\(String(format: "%.2f", data?.offerPrice ?? 0.0))x\(data?.quantity ?? 0)"
        
        let actualprice = data?.isDiscount == 1 ? "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))" : ""
        actualPriceTxt?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
        
        if  data?.images?.count ?? 0 > 0 {
            let url = data?.images?[0].productImageThumbURL
            productImage.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: ""))
        }
        
        btnReview.isHidden = fullData?.orderStatus == 2 ? false : true
        if fullData?.orderStatus == 2 && (data?.productInventryData?.review?.count ?? 0) > 0 {
            btnReview.isHidden = true
        }
        
        if catData?.allReturn == 0 {
            
            if (data?.orderStatus == 1) || (data?.orderStatus == 2) || (data?.orderStatus == 3) || (data?.orderStatus == 4){
                btnReturn.isHidden = true
                btnCancel.isHidden = true
                lblItemStatus.isHidden = false
                
                switch data?.orderStatus {
                case 1:
                    lblItemStatus.text = "Item return requested"
                    lblItemStatus.textColor = UIColor.appBlueDarkColor
                case 2:
                    lblItemStatus.text = "Item Returned"
                    lblItemStatus.textColor = UIColor.appBlueDarkColor
                case 3:
                    lblItemStatus.text = "Item return request rejected"
                    lblItemStatus.textColor = .red
                case 4:
                    lblItemStatus.text = "Item Cancelled"
                    lblItemStatus.textColor = .red
                default:
                    lblItemStatus.text = ""
                    break
                }
            }
            else {
                lblItemStatus.isHidden = true
                
                let calendar = Calendar.current
                if let orderDate = AppManager.convertStringUTCToLocal(toDate: fullData?.orderDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") {
                    
                    let cancelTime = calendar.date(byAdding: .minute, value: Int.convertToInt(anyValue: catData?.cancelationTime as Any), to: orderDate) ?? Date()
                    
                    btnCancel.isHidden = Date() > cancelTime ? true : false
                    btnReturn.isHidden = true
                    
                }
                
                if let deliveredDate = AppManager.convertStringUTCToLocal(toDate: fullData?.deliveredDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") {
                    
                    let returnTime = calendar.date(byAdding: .minute, value: Int.convertToInt(anyValue: catData?.returnTime as Any), to: deliveredDate) ?? Date()
                    
                    if fullData?.orderStatus == 2 {
                        btnReturn.isHidden = Date() > returnTime ? true : false
                        btnCancel.isHidden = true
                    }
                }
            }
        }
        else {
            
            switch data?.orderStatus {
            case 1:
                lblItemStatus.text = "Item return requested"
                lblItemStatus.textColor = UIColor.appBlueDarkColor
            case 2:
                lblItemStatus.text = "Item Returned"
                lblItemStatus.textColor = UIColor.appBlueDarkColor
            case 3:
                lblItemStatus.text = "Item return request rejected"
                lblItemStatus.textColor = .red
            case 4:
                lblItemStatus.text = "Item Cancelled"
                lblItemStatus.textColor = .red
            default:
                lblItemStatus.text = ""
                break
            }
            btnReturn.isHidden = true
            btnCancel.isHidden = true
        }
    }
    
    
    @IBAction func btnReviewClick(_ sender: Any) {
        callback!("Review")
    }
    
    @IBAction func btnReturnClick(_ sender: Any) {
        callback!("Return")
    }
    
    @IBAction func btnCancelClick(_ sender: Any) {
        callback!("Cancel")
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        callback!("imageTapped")
    }
}
