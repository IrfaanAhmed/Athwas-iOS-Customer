//
//  SearchVC.swift
//  IA
//
//  Created by Yogesh Raj on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit


struct SearchOption {
    public var businessID : String?
    public var catID : String?
    public var subCatID : String?
}


class SearchVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var timer : Timer!
    var productList : [ProductListDataModel] = []
    let viewModel = ProductListViewModel(dataService: ApiClient())
    var offset = 1
    lazy var searchText = String()
    var searchIds: SearchOption?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        searchBar.becomeFirstResponder()
        self.tableView.separatorStyle  = .none
    }
    
    func setupUI() {
        self.headerTitle.text = "Search"
        if(searchText.count > 0){
            self.searchBar.text = searchText
            self.offset = 1
            self.fethProductList(self.offset)
        }
    }
    
    
    private func fethProductList(_ offset: Int){
        
        let param = [
            "page_no" : offset,
            "keyword" : self.searchBar.text ?? "",
            "business_category_id": searchIds?.businessID ?? "",
            "category_id": searchIds?.catID ?? "",
            "sub_category_id": searchIds?.subCatID ?? "",
            "filter" : "[]"
            
            ] as [String : Any]
        
        viewModel.fetchRequestData(URLMethods.getProductList, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            if offset <= 1 {
                self.offset = offset
                self.productList.removeAll()
                self.tableView.setContentOffset(.zero, animated:true)
            }
            self.view.endEditing(true)
            self.productList.append(contentsOf: self.viewModel.productList!)
            self.tableView.reloadData()
            
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

// MARK: - <UITableViewDelegate> / <UITableViewDataSource>
extension SearchVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = productList.count
        tableView.setBackgroundMessage(rows == 0 ? "No data found" : nil)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let title = cell.viewWithTag(101) as? UILabel
        let imgItem = cell.viewWithTag(102) as? UIImageView
        let data = self.productList[indexPath.row]
        
        title?.text = "\(self.productList[indexPath.row].name ?? "") - \(data.inventoryName ?? "")"
        if  data.images?.count ?? 0 > 0 {
            let url = data.images?[0].productImageThumbURL
            imgItem?.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: ""))
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CFRunLoopWakeUp(CFRunLoopGetCurrent())
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
        vc.productID = productList[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row == self.productList.count-4 {
            if viewModel.isReload! {
                print(viewModel.isReload!)
                offset = offset + 1
                self.fethProductList(offset)
                viewModel.isReload! = false
            }
            print("reload")
        }
    }
}



// MARK: - UISearchBarDelegate
extension SearchVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if timer != nil {
            timer.invalidate()
        }
        if searchBar.text!.count > 1 {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                print("search")
                self.offset = 1
                self.fethProductList(self.offset)
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 2 {
            self.view.endEditing(true)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789- "
        
        let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered = text.components(separatedBy: cs).joined(separator: "")
        
        return (text == filtered)
    }
}
