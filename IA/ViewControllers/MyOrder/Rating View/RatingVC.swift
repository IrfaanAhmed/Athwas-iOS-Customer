//
//  RatingVC.swift
//  IA
//
//  Created by admin on 21/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class RatingVC: BaseClassVC {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var txtView: UITextView!
    let viewModel = OrderHistoryViewModel(dataService: ApiClient())
    var orderDetail : OrderDetailModel?
    var callback : (() -> Void)?
    var section = 0
    var row = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let catData = orderDetail?.category?[section]
        let productData = catData?.products?[row]
        
        if  productData?.images?.count ?? 0 > 0 {
            let url = productData?.images?[0].productImageThumbURL
            imgItem.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: ""))
        }
        lblName.text = productData?.name
    }
    
    func setupUI() {
        ratingView.type = .wholeRatings
        self.headerTitle.text = "Write a Review"
        self.backBtn.isHidden = false
    }
    
    
    @IBAction func btnSubmit(_ sender: Any) {
        rateTheItem()
    }
    
    
    
    func rateTheItem() {
       
        let catData = orderDetail?.category?[section]
        let productData = catData?.products?[row]
        
        let param = ["product_id" : productData?.id ?? "",
                     "inventory_id" : productData?.inventoryID ?? "",
                     "order_id" : self.orderDetail?.id ?? "",
                     "rating" : self.ratingView.rating,
                     "review" : txtView.text ?? ""
        ] as [String : Any]
        
        self.viewModel.cancelOrder(URLMethods.giveRating, param: param)
        self.viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        self.viewModel.didFinishFetch = {
            self.callback!()
            self.navigationController?.popViewController(animated: true)
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
