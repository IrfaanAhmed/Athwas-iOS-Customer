//
//  WalletVC.swift
//  WaadPay
//
//  Created by admin on 05/06/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit



class WalletVC: BaseClassVC {
    
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var lblWallet: UILabel!
    
    var isfromProfile = false
    var offset = 1
    var walletArray: [WalletDataModel] = []
    let viewModel = WalletViewModel(dataService: ApiClient())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchWalletHistory(offset: 1)
    }
    
    
    func setupUI() {
        
        self.headerTitle.text = "Athwas Pay"
        self.menuBtn.isHidden = isfromProfile == false ? false : true
        self.backBtn.isHidden = isfromProfile == false ? true : false
        
        // Setup Cell
        let nibPay = UINib.init(nibName: "TableViewCell_Wallet", bundle: nil)
        tableList.register(nibPay, forCellReuseIdentifier: "cellWallet")
    }
    
    // MARK: - getBuisnessCategoryAPI
    private func fetchWalletHistory(offset: Int) {
        
        let url = "\(URLMethods.walletHistory)/?page_no=\(offset)"
        viewModel.fetchRequestData(url, param: [:], pages: offset)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            
            if offset <= 1 {
                self.offset = offset
                self.walletArray.removeAll()
                self.tableList.setContentOffset(.zero, animated:true)
            }
            self.walletArray.append(contentsOf: self.viewModel.wallets!)
            self.lblWallet.text = "\(Constants.KCurrency)\(String(format: "%.2f", self.viewModel.walletAmount ?? 0))"
            self.tableList.reloadData()
        }
        
    }
    
    
    @IBAction func btnAddWallet(_ sender : Any) {
        let vc: AddWalletVC = AddWalletVC(nibName :"AddWalletVC",bundle : nil)
        vc.callback = {
            self.fetchWalletHistory(offset: 1)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension WalletVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = walletArray.count
        tableView.setBackgroundMessage(rows == 0 ? "No data found" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellWallet", for: indexPath) as! TableViewCell_Wallet
        let data = walletArray[indexPath.row];
        let amount = Double.convertToDouble(anyValue: data.amount!)
        cell.lblAmount.text = Constants.KCurrency + (String(format: "%.2f", amount))
        cell.lblDate.text = AppManager.changeDateFormat(dateStr: data.createdAt!, dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z", neededFormate: "dd MMMM yyyy, hh:mm a")
        cell.lblDes.text = data.reason
        if data.orderID?.stringValue != "" {
            cell.lblTitle.text = "Txn ID: \(data.transitionID ?? "")/Order ID: \(data.orderID?.stringValue ?? "")"
        } else {
            cell.lblTitle.text = "Txn ID: \(data.transitionID ?? "")"
        }
        cell.lblAmount.textColor = data.amountType == 1 ? UIColor.appDarkGreen : .red
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row == self.walletArray.count-4 {
            
            if viewModel.isReload! {
                print(viewModel.isReload!)
                offset = offset + 1
                self.fetchWalletHistory(offset: offset)
                viewModel.isReload! = false
            }
            print("reload")
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
