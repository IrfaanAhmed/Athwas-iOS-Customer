//
//  MyOrderCell.swift
//  IA
//
//  Created by Yogesh Raj on 17/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class MyOrderCell: UITableViewCell {

    @IBOutlet weak var lblOrderID : UILabel!
    @IBOutlet weak var lblOrderDate : UILabel!
    @IBOutlet weak var lblDeliveryDate : UILabel!
    @IBOutlet weak var lblPaymentMode : UILabel!
    @IBOutlet weak var lblAmount : UILabel!
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblPayment : UILabel!
    
    var data : OrderHistoryModel? {
        didSet {
            setupData(data)
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

    func setupData(_ data : OrderHistoryModel?) {
        
        lblOrderID.text = "#\(data?.orderID ?? 0)"
        lblOrderDate.text = AppManager.changeDateFormat(dateStr: data?.createdAt ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", neededFormate: "dd MMMM yyyy, h:mm a")
        lblDeliveryDate.text = AppManager.changeDateFormat(dateStr: data?.expectedEndDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", neededFormate: "dd MMMM yyyy")
        
        lblPaymentMode.text = data?.paymentMode == "Cash" ? "COD" : data?.paymentMode
        lblAmount.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.netAmount ?? 0.0))"
        
        lblStatus.text = "Status: \(data?.currentTrackingStatus ?? "")"
        lblStatus.textColor = UIColor.appDarkGreen
        
        lblPayment.text = data?.paymentMode == "Cash" ? "Payable Amount:" : "Paid Amount:"
        
        if data?.orderStatus == 4 {
            lblStatus.text = "Status: Cancelled"
            lblStatus.textColor = .red
        }
        if data?.orderStatus == 3 {
            lblStatus.text = "Status: Returned"
            lblStatus.textColor = UIColor.appBlueDarkColor
        }
    }
}
