//
//  ProductVC.swift
//  IA
//
//  Created by Yogesh Raj on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
// Listing type : 1 - popular, 2 - dicounted, category listing - 3

import UIKit

class ProductVC: BaseClassVC {
    
    @IBOutlet weak var tableView: UITableView!
    var productObject = ProductCategoryDataModel()
    var productList : [ProductListDataModel] = []
    let viewModel = ProductListViewModel(dataService: ApiClient())
    
    //Variables
    var sortingString = ""
    var filterObject : Filter?
    var offset = 1
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        fetchProductList(1)
    }
    
    func setupUI() {
        self.headerTitle.text = ""
        self.backBtn.isHidden = false
        self.cartBtn.isHidden = false
        self.searchBtn.isHidden = false
        searchBtn.addTarget(self, action: #selector(self.searchClicked(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cartBtn.badgeString = Constants.kAppDelegate.user?.cartCount != nil ? String(Constants.kAppDelegate.user?.cartCount ?? 0):nil
    }
    
    @IBAction func searchClicked(_ sender: UIButton) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "SearchVC") as SearchVC
        vc.searchIds = SearchOption(
            businessID:  productObject.businessCategoryID?.id,
            catID:  productObject.parentID,
            subCatID: productObject.id)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - Get Product List
    
    private func fetchProductList(_ offset: Int) {
        
        let param = ["page_no" : offset,
                     "keyword" : "",
                     "business_category_id" : productObject.businessCategoryID?.id ?? "",
                     "category_id" :  (filterObject?.catId == nil || filterObject?.catId == "") ? productObject.parentID ?? "" : filterObject?.catId ?? "",
                     "sub_category_id" : (filterObject?.subCatId == nil || filterObject?.subCatId == "") ? productObject.id ?? "" : filterObject?.subCatId ?? "" ,
                     "brand_id" : filterObject?.brandId ?? "",
                     "price_start" : filterObject?.priceMin ?? "",
                     "price_end" : filterObject?.priceMax ?? "",
                     "sortby" : sortingString,
                     "rating" : filterObject?.rating ?? "",
                     "filter" : filterObject?.selectedFilter == nil ? "[]" : AppManager.json(from: filterObject?.selectedFilter as Any) ?? "[]"
                     
        ] as [String : Any]
        
        viewModel.fetchRequestData(URLMethods.getProductList, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.refreshControl.endRefreshing()
            if offset <= 1 {
                self.offset = offset
                self.productList.removeAll()
                self.tableView.setContentOffset(.zero, animated:true)
            }
            self.productList.append(contentsOf: self.viewModel.productList!)
            self.tableView.reloadData()
            
        }
        
    }
    
    
    //pending till value comes
    @objc fileprivate func updateFavStatus(favStatus : Int, pro_id:String, row_id:Int){
        
        guard let _ = UserDataModel.isLoggedIn() else {
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                    Constants.kSceneDelegate.switchToLoginVC()
                }) { (no) in
                    
                }
            }
            return }
        
        let param = ["product_id" : pro_id,
                     "status" : favStatus,
        ] as [String : Any]
        
        viewModel.updateFavStatus(URLMethods.addFavourite, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        viewModel.didFinishFetch = {
            
            self.productList[row_id].isFavourite = favStatus
            self.tableView.beginUpdates()
            let indexPath = IndexPath(row: row_id, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
        
    }
    
    func addCart(_ index : Int)  {
        
        guard let _ = UserDataModel.isLoggedIn() else {
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                    Constants.kSceneDelegate.switchToLoginVC()
                }) { (no) in
                    
                }
            }
            return }
        
        if productList[index].availableQuantity ?? 0 > 0 {
            
            let param = ["inventory_id" : productList[index].id ?? "",
                         "product_id" : productList[index].mainProductID ?? "",
                         "business_category_id" : productList[index].businessCategory?.id ?? ""
            ]
            
            viewModel.additem_cart(URLMethods.addToCart, param: param)
            viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModel.didFinishFetch = {
                self.cartBtn.badgeString = Constants.kAppDelegate.user?.cartCount != nil ? String(Constants.kAppDelegate.user?.cartCount ?? 0):nil
                self.tableView.reloadData()
            }
        }
        else {
            
            let param = ["product_id" : productList[index].id ?? ""]
            
            viewModel.notifyProduct(URLMethods.notify_me, param: param)
            viewModel.showAlertClosure = {
                if let error = self.viewModel.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModel.didFinishFetch = {
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    
    @IBAction func btnSort(_ sender: Any) {
        
        let vc: SortingVC = SortingVC(nibName: "SortingVC", bundle: nil)
        vc.sortStatus = sortingString
        vc.callback = { (status) -> Void in
            self.sortingString = status
            self.productList.removeAll()
            self.tableView.reloadData()
            self.fetchProductList(1)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnFilter(_ sender: Any) {
        
        if self.filterObject == nil {
            self.filterObject = Filter(priceMin: "", priceMax: "", rating: "", brandId: "", brandName: "", catName: "", catId: self.productObject.parentID, subCatId: self.productObject.id, subCatName: self.productObject.name)
        }
        
        let vc: FilterVC = FilterVC(nibName: "FilterVC", bundle: nil)
        vc.productObject = productObject
        vc.filterObject = self.filterObject ?? Filter()
        vc.callback = { (result) -> Void in
            self.filterObject = result
            self.productList.removeAll()
            self.tableView.reloadData()
            self.fetchProductList(1)
        }
        self.present(vc, animated: true, completion: nil)
        
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

// MARK: - UITableViewDelegate / UITableViewDataSource
extension ProductVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = productList.count
        tableView.setBackgroundMessage(rows == 0 ? "No Products" : nil)
        return rows
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:ProductCell = self.tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cell.data = productList[indexPath.row]
        cell.callbackFavStatus = {
            value in
            self.updateFavStatus(favStatus: value, pro_id: cell.data?.id ?? "",row_id: indexPath.row)
        }
        cell.callbackCart = {
            self.addCart(indexPath.row)
        }
        return cell
        
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                self.fetchProductList(offset)
                viewModel.isReload! = false
            }
            print("reload")
        }
    }
}

