//
//  ReturnReasonVC.swift
//  IA
//
//  Created by admin on 13/01/21.
//  Copyright © 2021 octal. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ReturnReasonVC: UIViewController {

    @IBOutlet weak var txtReason : IQTextView!
    let viewModel = OrderHistoryViewModel(dataService: ApiClient())
    var callback : (() -> Void)?
    var orderID = ""
    var id = ""
    var type = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        
        if type == "Grocery" {
            
            guard txtReason.text?.count ?? 0 > 0 else {
                AppManager.showAlert(Constants.KAppName, "Please enter the reason of return", view: self)
                return
            }
            
            groceryReturnClick()
        }
        else {
            
            guard txtReason.text?.count ?? 0 > 0 else {
                AppManager.showAlert(Constants.KAppName, "Please enter the reason of return", view: self)
                return
            }
            returnClick()
        }
    }
    
    
    func returnClick() {
        
        let param = ["order_id" : orderID,
                     "sub_order_id" : id,
                     "reason" : txtReason.text ?? ""
        ] as [String : Any]
        
        self.viewModel.cancelOrder(URLMethods.returnOrder, param: param)
        self.viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        self.viewModel.didFinishFetch = {
            self.callback!()
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    
    func groceryReturnClick() {
       
        let param = ["order_id" : orderID,
                     "business_category_id" : id,
                     "reason" : txtReason.text ?? ""
        ] as [String : Any]
        
        self.viewModel.cancelOrder(URLMethods.groceryReturnOrder, param: param)
        self.viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        self.viewModel.didFinishFetch = {
            self.callback!()
            self.dismiss(animated: true, completion: nil)
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
