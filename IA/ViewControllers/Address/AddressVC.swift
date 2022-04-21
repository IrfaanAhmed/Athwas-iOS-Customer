//
//  AddressVC.swift
//  IA
//
//  Created by Yogesh Raj on 18/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class AddressVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isfromProfile = false
    let viewModel = AddressViewModel(dataService: ApiClient())
    var addressArray:[AddressDataModel] = []
    var getAddress : ((AddressDataModel) -> Void)?
    var selectedAddress: AddressDataModel?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchAddressHistory()
    }
    
    // MARK: - setupUI
    func setupUI() {
        self.headerTitle.text = "My Addresses"
        self.menuBtn.isHidden = isfromProfile == false ? false : true
        self.backBtn.isHidden = isfromProfile == false ? true : false
        
    }
    
    // MARK: - fetchWalletHistory
    private func fetchAddressHistory() {
        
        viewModel.fetchRequestData(URLMethods.getAddress, param: [:], pages: 0)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.addressArray.removeAll()
            self.addressArray.append(contentsOf: self.viewModel.addresses!)
            self.tableView.reloadData()
            print("Success")
        }
        
    }
    
    // MARK: - Add Address Action
    @IBAction func btnAddAddress(_ sender : UIButton) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "AddAddressVC") as AddAddressVC
        vc.addressArray = addressArray
        self.navigationController?.pushViewController(vc, animated: true)
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AddressVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = addressArray.count
        tableView.setBackgroundMessage(rows == 0 ? "No address added yet" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressCell
        cell.selectedAddress = self.selectedAddress
        cell.data = addressArray[indexPath.row]
        cell.deleteBtn.tag = indexPath.row
        cell.btnAddress.tag = indexPath.row

        cell.deleteBtn.addTarget(self, action: #selector(deleteAddress), for: .touchUpInside)
        cell.btnAddress.addTarget(self, action: #selector(defaultAddress), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = addressArray[indexPath.row].geoLocation?.coordinates
        if data?.count ?? 0 > 0 {
            address.latitude = Double.convertToDouble(anyValue: data?[0] as Any)
            address.longitude = Double.convertToDouble(anyValue: data?[1] as Any)
            address.userAddress = addressArray[indexPath.row].fullAddress
            address.addressType = addressArray[indexPath.row].addressType
        }
        getAddress!(addressArray[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Delete Address Btn
    @IBAction func deleteAddress(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to delete this address?", "Yes", "No", self, successClosure: { (yes) in
                let data = self.addressArray[sender.tag]
                let param = ["address_id" : data.id ?? ""] as [String : Any]
                AppManager.startActivityIndicator()
                ApiClient.init().apiCallMethod(URLMethods.deleteAddress, method: .post, parameter: param, successClosure: { result in
                    AppManager.showToast(result!["message"] as! String)
                    
                    if self.addressArray[sender.tag].defaultAddress == 1 {
                        var userData = Constants.kAppDelegate.user
                        userData?.defaultAddress = nil
                        let user = try? JSONEncoder().encode(userData)
                        Constants.kAppDelegate.user = userData
                        Constants.kAppDelegate.user?.saveUser(user!)
                    }
                    self.addressArray.remove(at: sender.tag)
                    self.tableView.reloadData()
                    AppManager.stopActivityIndicator()
                }) { (msg) in
                    AppManager.showToast(msg!)
                    AppManager.stopActivityIndicator()
                }
                
            }) { (no) in
                
            }
        }
    }
    
    @IBAction func defaultAddress(_ sender: UIButton) {
        
        if addressArray[sender.tag].defaultAddress == 0 {
            
            viewModel.setDefaultAddress(URLMethods.defaultAddress, param: ["address_id": addressArray[sender.tag].id ?? ""])
            viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModel.didFinishFetch = {
                self.fetchAddressHistory()
                self.tableView.reloadData()
            }
        }
    }
    
}

