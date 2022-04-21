//
//  PaymentStatusVC.swift
//  IA
//
//  Created by admin on 24/06/21.
//  Copyright © 2021 octal. All rights reserved.
//

import UIKit

class PaymentStatusVC: BaseClassVC {

    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblTransactionID: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    var paymentData : PaymentDataModel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        
        self.headerTitle.text = "Payment Response"
        self.backBtn.isHidden = false
        
        lblHeading.text = paymentData?.reason
        lblTransactionID.text = paymentData?.transitionID
        lblAmount.text = "\(Constants.KCurrency)\(paymentData?.amount ?? "0")"
        lblOrderID.text = paymentData?.orderID
        
        if paymentData?.requestType == 2 {
            lblHeading.text = "Order Placed Successfully"
            self.backBtn.isHidden = true
        }
    }

    
    @IBAction func btnBacktoHome(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
