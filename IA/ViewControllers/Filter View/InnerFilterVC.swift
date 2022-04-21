//
//  FilterVC.swift
//  IA
//
//  Created by admin on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class InnerFilterVC: UIViewController {
    
    @IBOutlet weak var tableViewCat: UITableView!
    @IBOutlet weak var tableViewSub: UITableView!
    let viewModel = FilterViewModel(dataService: ApiClient())
    var productObject = ProductCategoryDataModel()
    var filterTypeList = [FilterCustomType]()
    var filterSubTypeList = [FilterCustomSubType]()
    
    var selectedIFilterItems = [[String: [String]]]()
    var customizationTypeID = ""
    var callback : (([[String: [String]]]) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "FilterCatCell", bundle: nil)
        tableViewCat.register(nib, forCellReuseIdentifier: "FilterCatCell")
        
        let nib_1 = UINib(nibName: "FilterSubCatCell", bundle: nil)
        tableViewSub.register(nib_1, forCellReuseIdentifier: "FilterSubCatCell")
        
        fetchFilterCategory()
    }
   
    func fetchFilterCategory() {
        
        let url = URLMethods.customizationType + "\(productObject.parentID ?? "")"
        viewModel.fetchRequestData(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.filterTypeList = self.viewModel.filterList!
            self.tableViewCat.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableViewCat.delegate?.tableView!(self.tableViewCat, didSelectRowAt: indexPath)
            self.tableViewCat.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
        }
    }
    
    
    func fetchFilterSubCategory(_ id : String) {
        
        let url = URLMethods.customizationSubType + "\(id)"
        viewModel.fetchRequestSubCategoryData(url, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = { [self] in
            self.filterSubTypeList = self.viewModel.filterSubCatList!
            let filtered = self.selectedIFilterItems.filter({ $0.keys.first == id })
            if filtered.count > 0 {
                if let items = filtered[0].values.first as NSArray? {
                    
                    for item in items {
                        for i in 0 ..< self.filterSubTypeList.count {
                            if item as! String == self.filterSubTypeList[i].id ?? "" {
                                self.filterSubTypeList[i].isSelected = true
                                break
                            }
                        }
                    }
                }
            }
            self.tableViewSub.reloadData()
            
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnReset(_ sender: Any) {
        selectedIFilterItems = []
        tableViewCat.reloadData()
        tableViewSub.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableViewCat.delegate?.tableView!(self.tableViewCat, didSelectRowAt: indexPath)
        self.tableViewCat.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        
    }
    
    
    @IBAction func btnApply(_ sender: Any) {
        
        guard selectedIFilterItems.count > 0 else {
            return
        }
        callback?(selectedIFilterItems)
        self.dismiss(animated: true, completion: nil)
        
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


extension InnerFilterVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableViewCat {
            return filterTypeList.count
        }
        else {
            return filterSubTypeList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tableViewCat {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCatCell", for: indexPath) as! FilterCatCell
            cell.data = filterTypeList[indexPath.row]
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterSubCatCell", for: indexPath) as! FilterSubCatCell
            cell.data = filterSubTypeList[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewCat {
            customizationTypeID = filterTypeList[indexPath.row].id ?? ""
            fetchFilterSubCategory(customizationTypeID)
            
        }
        else {
            if filterSubTypeList[indexPath.row].isSelected == false {
                filterSubTypeList[indexPath.row].isSelected = true
                
                for i in 0 ..< selectedIFilterItems.count {
                    
                    let item = selectedIFilterItems[i]
                    if let key = item.keys.first, key == customizationTypeID {
                        var items = item[key]
                        items?.append(filterSubTypeList[indexPath.row].id ?? "")
                        selectedIFilterItems[i] = [customizationTypeID : items] as! [String : [String]]
                        tableView.reloadData()
                        return
                    }
                    
                }
                let data = [customizationTypeID : [filterSubTypeList[indexPath.row].id ?? ""]]
                selectedIFilterItems.append(data)
                print(selectedIFilterItems)
            }
            else {
                
                filterSubTypeList[indexPath.row].isSelected = false
                for i in 0 ..< selectedIFilterItems.count {
                    
                    let item = selectedIFilterItems[i]
                    if let key = item.keys.first, key == customizationTypeID {
                        var items = item[key]
                        for j in 0 ..< items!.count {
                            if items?[j] == filterSubTypeList[indexPath.row].id ?? "" {
                                items?.remove(at: j)
                                if items?.count ?? 0 > 0 {
                                    selectedIFilterItems[i] = [customizationTypeID : items] as! [String : [String]]
                                }
                                else {
                                    selectedIFilterItems.remove(at: i)
                                }
                                tableView.reloadData()
                                return
                            }
                        }
                    }
                }
            }
            tableView.reloadData()
        }
        
    }
    
}
