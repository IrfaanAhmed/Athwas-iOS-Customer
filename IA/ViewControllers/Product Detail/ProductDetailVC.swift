//
//  ProductDetailVC.swift
//  IA
//
//  Created by admin on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import ZoomableImageSlider

class ProductDetailVC: BaseClassVC {
    
    @IBOutlet weak var tableDetails: UITableView!
    @IBOutlet weak var addCartBtn: GradientButton!
    var productData = ProductDetailModel()
    let viewModel = ProductDetailViewModel(dataService: ApiClient())
    var products : [SimilarProductsModel] = []
    let viewModelSimilar = SimilarProductViewModel(dataService: ApiClient())
    let viewModelFav = ProductListViewModel(dataService: ApiClient())
    var productID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
       // fetchProductDetail()
        kNotificationObject = [:]
    }
    
    func setupUI() {
        self.headerTitle.text = ""
        self.backBtn.isHidden = false
        self.searchBtn.isHidden = false
        self.cartBtn.isHidden = false
        searchBtn.addTarget(self, action: #selector(self.searchClicked(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cartBtn.badgeString = Constants.kAppDelegate.user?.cartCount != nil ? String(Constants.kAppDelegate.user?.cartCount ?? 0):nil
        fetchProductDetail()
    }
    
    @IBAction func searchClicked(_ sender: UIButton) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "SearchVC") as SearchVC
        vc.searchIds = SearchOption(
            businessID:  productData.businessCategory?.id,
            catID:  productData.category?.id,
            subCatID: productData.subcategory?.id)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    private func fetchProductDetail() {
        let param = ["product_id" : "\(productID)"]
        viewModel.fetchRequestData(URLMethods.productDetail, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.productData = self.viewModel.productData!
            self.fetchSimilarProducts()
            self.tableDetails.reloadData()
            let btnTitle = (self.productData.quantity ?? 0) <= 0 ? "Notify me" : "Add to Cart"
            self.addCartBtn.setTitle(btnTitle, for: .normal)
            self.addCartBtn.isHidden = self.productData.availble == 0 ? true : false
        }
        
    }
    
    private func fetchSimilarProducts() {
        
        let param = ["sub_category_id" : productData.subcategory?.id ?? "",
                     "product_id" : self.productData.id ?? ""
        ] as [String : Any]
        
        viewModelSimilar.fetchRequestData(URLMethods.similarProducts, param: param)
        viewModelSimilar.showAlertClosure = {
            if let error = self.viewModelSimilar.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModelSimilar.didFinishFetch = {
            self.products = self.viewModelSimilar.products!
            self.tableDetails.reloadData()
        }
        
    }
    
    @objc fileprivate func updateFavStatus(favStatus : Int, pro_id:String){
        
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
        
        viewModelFav.updateFavStatus(URLMethods.addFavourite, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModelFav.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        viewModelFav.didFinishFetch = {
            self.productData.isFavourite = favStatus
            self.tableDetails.reloadData()
            
        }
        
    }
    
    
    @IBAction func addToCart(_ sender: Any) {
        
        guard let _ = UserDataModel.isLoggedIn() else {
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                    Constants.kSceneDelegate.switchToLoginVC()
                }) { (no) in
                    
                }
            }
            return }
        
        if (productData.quantity ?? 0) > 0  {
            
            let param = ["inventory_id" : productData.id ?? "",
                         "product_id" : productData.mainProductID ?? "",
                         "business_category_id" : productData.businessCategory?.id ?? ""
            ]
            
            viewModelFav.additem_cart(URLMethods.addToCart, param: param)
            viewModelFav.showAlertClosure = {
                if let error = self.viewModelFav.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModelFav.didFinishFetch = {
                self.cartBtn.badgeString = Constants.kAppDelegate.user?.cartCount != nil ? String(Constants.kAppDelegate.user?.cartCount ?? 0):nil
                self.tableDetails.reloadData()
            }
        }
        else {
            
            let param = ["product_id" : productData.id ?? ""]
            
            viewModelFav.notifyProduct(URLMethods.notify_me, param: param)
            viewModelFav.showAlertClosure = {
                if let error = self.viewModelFav.error {
                    print(error)
                    AppManager.showToast(error)
                }
            }
            viewModelFav.didFinishFetch = {
                self.tableDetails.reloadData()
            }
        }
        
    }

}

extension ProductDetailVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (products.count > 0) ? 6 : 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? productData.customizations?.count ?? 0 : 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellImage") as! ProductImageCell
            cell.cellData = productData
            cell.collectionView.reloadData()
            
            cell.tappedCellAction = { (imageArray, index) -> Void in
                let vc = ZoomableImageSlider(images: imageArray, currentIndex: index, placeHolderImage: nil)
                self.present(vc, animated: true, completion: nil)
            }
            cell.callbackFavStatus = {
                value in
                self.updateFavStatus(favStatus: value, pro_id: self.productData.id ?? "")
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfo", for: indexPath) as! Product_InfoCell
            cell.cellData = productData
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMeasurement", for: indexPath) as! MeasurmentCell
            cell.cellData = productData.customizations?[indexPath.row]
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellOffer", for: indexPath) as! OffersCell
            
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAbout", for: indexPath) as! AboutProductCell
            cell.cellData = productData
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProducts", for: indexPath) as! SimilarProductsCell
            cell.cellData = products
            cell.collectionView.reloadData()
            cell.tappedCellAction = { (index) -> Void in
                let id = self.products[index].id ?? ""
                self.navigateToProductDetail(id)
            }
            return cell
            
        default:
            return UITableViewCell()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        
        case 2:
            let vc: CustomizationVC = CustomizationVC(nibName: "CustomizationVC", bundle: nil)
            vc.productID = self.productData.mainProductID ?? ""
            vc.callback = { (id) -> Void in
                self.productID = id
                self.fetchProductDetail()
            }
            self.present(vc, animated: true, completion: nil)
            
        case 3:
            guard let _ = UserDataModel.isLoggedIn() else {
                DispatchQueue.main.async {
                    AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                        Constants.kSceneDelegate.switchToLoginVC()
                    }) { (no) in
                        
                    }
                }
                return
            }
            let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "OfferTypeVC") as OfferTypeVC
            vc.isfromSideMenu = false
            vc.productID = productID
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
            
        }
    }
    
    // MARK: - navigateToProductDetail
    
    func navigateToProductDetail(_ id : String) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
        vc.productID = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
