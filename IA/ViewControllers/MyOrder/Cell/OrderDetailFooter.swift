//
//  OrderDetailFooter.swift
//  IA
//
//  Created by admin on 18/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class OrderDetailFooter: UITableViewHeaderFooterView {

    @IBOutlet weak var btnReturn: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var callback : ((String) -> Void)?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
    }
    
    
    func setCategoryData(_ data : CategoryDetail?, fullData : OrderDetailModel?)  {
        
        let calendar = Calendar.current
        if let orderDate = AppManager.convertStringUTCToLocal(toDate: fullData?.orderDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") {
            
            let cancelTime = calendar.date(byAdding: .minute, value: Int.convertToInt(anyValue: data?.cancelationTime as Any), to: orderDate) ?? Date()
            btnCancel.isHidden = Date() > cancelTime ? true : false
            btnReturn.isHidden = true
        }
        
        if let returnDate = AppManager.convertStringUTCToLocal(toDate: fullData?.deliveredDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") {
            
            let returnTime = calendar.date(byAdding: .minute, value: Int.convertToInt(anyValue: data?.returnTime as Any), to: returnDate) ?? Date()
         
            if fullData?.orderStatus == 2 {
                btnReturn.isHidden = Date() > returnTime ? true : false
                btnCancel.isHidden = true
            }
        }

        if (data?.products?.first?.orderStatus == 2) || (data?.products?.first?.orderStatus == 4) {
            btnReturn.isHidden = true
            btnCancel.isHidden = true
        }
       
    }
    
    
    @IBAction func btnReturnClick(_ sender: Any) {
        callback!("Return")
    }
    
    @IBAction func btnCancelClick(_ sender: Any) {
        callback!("Cancel")
    }

}
