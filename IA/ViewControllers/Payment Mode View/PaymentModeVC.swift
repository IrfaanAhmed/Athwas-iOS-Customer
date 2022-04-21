 //
//  PaymentModeVC.swift
//  IA
//
//  Created by admin on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

struct PaymentOption {
    public var title : String?
    public var selectImg : UIImage?
    public var status : String?
}

class PaymentModeVC: UIViewController {
    
    @IBOutlet weak var tableViewPayments: UITableView!
    var callback : ((PaymentOption) -> Void)?
    var deliveryObject : DeliveryFeeModel?
    
    var paymentMode : [PaymentOption] = [
        PaymentOption(title: "Pay on Delivery", selectImg: #imageLiteral(resourceName: "uncheck"), status: "Cash"),
        PaymentOption(title: "Athwas Pay", selectImg: #imageLiteral(resourceName: "uncheck"), status: "Wallet"),
        PaymentOption(title: "Credit/Debit Card/UPI", selectImg: #imageLiteral(resourceName: "uncheck"), status: "Credit")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TableViewCell_PaymentMode", bundle: nil)
        tableViewPayments.register(nib, forCellReuseIdentifier: "cellPayments")
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnApply(_ sender: Any) {
        
        guard let indexPath = tableViewPayments.indexPathForSelectedRow else {
            AppManager.showAlert(Constants.KAppName, "Please select payment option", view: self)
            return
        }
        let temp = paymentMode[indexPath.row]
        self.dismiss(animated: true) {
            self.callback!(temp)
        }
    }
    
    @IBAction func btnAddWallet(_ sender: Any) {
        
        weak var pvc = self.presentingViewController

        self.dismiss(animated: true) {
            let vc: AddWalletVC = AddWalletVC(nibName :"AddWalletVC",bundle : nil)
            pvc?.present(vc, animated: true, completion: nil)
        }
    
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

extension PaymentModeVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMode.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPayments", for: indexPath) as! TableViewCell_PaymentMode
        cell.lblTitle.text = paymentMode[indexPath.row].title
        cell.lblWalletBalance.text = "Available Credit: \(Constants.KCurrency) \(deliveryObject?.wallet ?? 0)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 75 : 50
    }
}
