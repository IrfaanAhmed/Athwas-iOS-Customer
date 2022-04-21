//
//  OrderDetailCell.swift
//  IA
//
//  Created by admin on 28/10/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class OrderDetailCell: UITableViewCell {
    
    @IBOutlet weak var lblOrderID : UILabel!
    @IBOutlet weak var lblOrderDate : UILabel!
    @IBOutlet weak var lblDeliveryDate : UILabel!
    @IBOutlet weak var lblPaymentMode : UILabel!
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblPayment : UILabel!
    @IBOutlet weak var lblAmount : UILabel!

   
    var data : OrderDetailModel? {
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

    func setupData(_ data : OrderDetailModel?) {
        
        lblOrderID.text = "#\(data?.orderID ?? 0)"
        lblOrderDate.text = AppManager.changeDateFormat(dateStr: data?.orderDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", neededFormate: "dd MMMM yyyy, h:mm a")
        lblDeliveryDate.text = AppManager.changeDateFormat(dateStr: data?.expectedEndDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", neededFormate: "dd MMMM yyyy")
        lblPaymentMode.text = data?.paymentMode == "Cash" ? "COD" : data?.paymentMode
        
        lblStatus.text = "\(data?.currentTrackingStatus ?? "Acknowledged")"
        lblStatus.textColor = UIColor.appDarkGreen
        
        lblAmount.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.netAmount ?? 0.0))"
        lblPayment.text = data?.paymentMode == "Cash" ? "Payable Amount:" : "Paid Amount:"
        
        if data?.orderStatus == 4 {
            lblStatus.text = "Cancelled"
            lblStatus.textColor = .red
        }
        if data?.orderStatus == 3 {
            lblStatus.text = "Returned"
            lblStatus.textColor = UIColor.appBlueDarkColor
        }
    }
}
