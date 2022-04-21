//
//  OfferListVC.swift
//  IA
//
//  Created by admin on 22/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class OfferListVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let viewModel = OfferViewModel(dataService: ApiClient())
    var offerList = [OfferListModel]()
    var productID = ""
    var timer : Timer!
    var offset = 1
    var offer : OfferType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        fetchOfferList(1, productID: productID)
    }
    
    
    func setupUI() {
        
        self.headerTitle.text = offer?.title
        self.backBtn.isHidden = false
        
    }
    
    // MARK: - Get Offer List
    
    private func fetchOfferList(_ offset: Int, productID: String) {
        
        let strWithNoSpace = self.searchBar.text?.replacingOccurrences(of: " ", with: "%20")
        let url = "\(URLMethods.offerLsit)?page_no=\(offset)&product_id=\(productID)&offer_type=\(offer?.tag ?? 0)&keyword=\(strWithNoSpace ?? "")"
        
        viewModel.fetchRequestData(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            
            var tempData = [OfferListModel]()
            for item in self.viewModel.offerList! {
                if Date() <= AppManager.convertString(toDate: item.endDate, dateFormate: "yyyy-MM-dd") ?? Date() {
                    tempData.append(item)
                }
            }
            self.offerList = tempData
            self.tableView.reloadData()
        }
    }
    
    @IBAction func btnCopyClipboard(_ sender: UIButton) {
        
        let buttonPostion = sender.convert(sender.bounds.origin, to: tableView)
        
        if let indexPath = tableView.indexPathForRow(at: buttonPostion) {
            UIPasteboard.general.string = offerList[indexPath.row].couponCode
            AppManager.showToast("Offer code copied")
        }
    }
    
}

class OfferCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var imgOffer : UIImageView!
    @IBOutlet weak var lblCode : UILabel!
    
}

extension OfferListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = offerList.count
        tableView.setBackgroundMessage(rows == 0 ? "No Offers Available" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell", for: indexPath) as! OfferCell
        
        cell.lblTitle.text = offerList[indexPath.row].title
        cell.lblDescription.text = offerList[indexPath.row].offerListModelDescription
        cell.lblCode.text = offerList[indexPath.row].couponCode
        
        let url = offerList[indexPath.row].imageThumbURL
        cell.imgOffer.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: "login_logo"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  offerList[indexPath.row].productID?.count ?? 0 > 0 {
            if (offerList[indexPath.row].offerType == "2") && (offerList[indexPath.row].product?.count ?? 0 > 0) {
                let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "OfferProductListVC") as OfferProductListVC
                vc.productList = offerList[indexPath.row].product ?? []
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let id = offerList[indexPath.row].productID?[0] else { return }
                let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
                vc.productID = id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


// MARK: - UISearchBarDelegate

extension OfferListVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if timer != nil {
            timer.invalidate()
        }
        if searchBar.text!.count > 1 {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                self.offset = 1
                self.fetchOfferList(self.offset, productID: self.productID)
            }
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 "
        
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = text.components(separatedBy: cs).joined(separator: "")
        
        return (text == filtered)
    }
}
