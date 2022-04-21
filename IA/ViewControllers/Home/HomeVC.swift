//
//  HomeVC.swift
//  IA
//
//  Created by Yogesh Raj on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
//need to remove this
import GoogleMaps
import Speech

class HomeVC: UIViewController, SearchViewDelegate {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var cartBtn: MIBadgeButton!
    @IBOutlet weak var notificationBtn: MIBadgeButton!
    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCityName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    
    var bannerArray: [BannerDataModel] = []
    let banneViewModel = BannerViewModel(dataService: ApiClient())
    
    var catArray: [BusinessCatDataModel] = []
    let catViewModel = BuzCategoryViewModel(dataService: ApiClient())
    
    var discountedProducts: [ProductListDataModel] = []
    let homeViewModel = ProductListViewModel(dataService: ApiClient())
    var popularProducts: [ProductListDataModel] = []
    
    var dealsArray: [DealsDataModel] = []
    let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        fetchBuisnessCategory()
        fetchBanner()
        fetchPopularProducts()
        NotificationCenter.default.addObserver(forName: Notification.Name("NotificationOrderUpdate"), object: nil, queue: nil) { (notification) in
            self.updateBadgeCount()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchTxt.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateBadgeCount()
        self.setCurrentLocation()
        
        guard kNotificationObject.count > 0 else {
            return
        }
        if kNotificationObject["custom_message_type"] as! String == customMsgType.orderDetail.rawValue {
            let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "OrderDetailVC") as OrderDetailVC
            vc.orderID = kNotificationObject["id"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if kNotificationObject["custom_message_type"] as! String == customMsgType.productDetail.rawValue {
            let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
            vc.productID = kNotificationObject["id"] as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK: - setupUI
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.searchTxt.LeftView(of: #imageLiteral(resourceName: "search"))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        lblAddress.isUserInteractionEnabled = true
        lblAddress.addGestureRecognizer(tap)
        
        let tap_1 = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        lblCityName.isUserInteractionEnabled = true
        lblCityName.addGestureRecognizer(tap_1)
        
        let tap_2 = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        imgLocation.isUserInteractionEnabled = true
        imgLocation.addGestureRecognizer(tap_2)
        
        if #available(iOS 10.0, *)
        {
            if obj.audioEngine.isRunning
            {
                obj.audioEngine.stop()
                obj.audioEngine.inputNode.removeTap(onBus: 0)
                obj.recognitionRequest = nil
                obj.recognitionTask = nil
                obj.StopDefault()
            }
        }
        sceneDelegate.window?.viewWithTag(101)?.removeFromSuperview()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        //        self.orderHistory.removeAll()
        //        self.tableView.reloadData()
        fetchPopularProducts()
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        
        if let _ = UserDataModel.isLoggedIn() {
            
            let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "AddressVC") as! AddressVC
            vc.getAddress = { (address) -> Void in}
            vc.isfromProfile = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            navigateToLogin()
        }
    }
    
    
    // MARK: - getBuisnessCategoryAPI
    private func fetchBuisnessCategory() {
        
        catViewModel.fetchRequestData(URLMethods.getBusinessCategory, param: [:])
        catViewModel.showAlertClosure = {
            if let error = self.catViewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        catViewModel.didFinishFetch = {
            self.catArray.append(contentsOf: self.catViewModel.businessCategory!)
            self.tableView.reloadData()
            print("Success")
        }
        
    }
    
    
    // MARK: - getBuisnessCategoryAPI
    private func fetchBanner() {
        
        banneViewModel.fetchRequestData(URLMethods.banner, param: [:])
        banneViewModel.showAlertClosure = {
            if let error = self.banneViewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        banneViewModel.didFinishFetch = { [self] in
            self.bannerArray.append(contentsOf: self.banneViewModel.banners ?? [])
            self.tableView.reloadData()
            self.perform(#selector(fetchDealsOfDay), with: nil, afterDelay: 0.1)
            
        }
        
    }
    
    @objc private func fetchDealsOfDay() {
        
        banneViewModel.fetchDealsRequestData(URLMethods.dealsOfday, param: [:])
        banneViewModel.showAlertClosure = {
            if let error = self.banneViewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        banneViewModel.didFinishFetch = {
            self.dealsArray.append(contentsOf: self.banneViewModel.deals ?? [])
            self.tableView.reloadData()
        }
        
    }
    
    
    
    private func fetchPopularProducts() {
        
        let url = "\(URLMethods.popularProduct)?limit=\(6)"
        
        homeViewModel.fetchRequestOtherData(url, param: [:])
        homeViewModel.showAlertClosure = {
            if let error = self.homeViewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        homeViewModel.didFinishFetch = {
            self.popularProducts = self.homeViewModel.productList!
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.fetchDiscountedProducts()
            
        }
    }
    
    private func fetchDiscountedProducts() {
        
        let url = "\(URLMethods.discountProduct)?limit=\(6)"
        
        homeViewModel.fetchRequestOtherData(url, param: [:])
        homeViewModel.showAlertClosure = {
            if let error = self.homeViewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        homeViewModel.didFinishFetch = {
            self.discountedProducts = self.homeViewModel.productList!
            self.tableView.reloadData()
            
        }
    }
    
    
    func updateBadgeCount() {
        
        cartBtn.badgeString = nil
        guard let _ = UserDataModel.isLoggedIn() else {
            return
        }
        ApiClient().apiCallMethod(URLMethods.badgeCount, method: .get, parameter: [:], successClosure: { (response) in
            let data = (response as? NSDictionary)?.value(forKey: "data") as? NSDictionary
            if let cartCount = (data?["cart_count"] as? Int), let notiCart = (data?["notification_count"] as? Int) {
                self.cartBtn.badgeString = cartCount == 0 ? nil : String(cartCount)
                self.notificationBtn.badgeString = notiCart == 0 ? nil : String(notiCart)
                
                var userData = Constants.kAppDelegate.user
                userData?.cartCount = cartCount == 0 ? nil : cartCount
                let user = try? JSONEncoder().encode(userData)
                Constants.kAppDelegate.user = userData
                Constants.kAppDelegate.user?.saveUser(user!)
            }
            
        }) { (error) in
            AppManager.showToast(error ?? "")
        }
    }
    
    func navigateToLogin() {
        DispatchQueue.main.async {
            AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                Constants.kSceneDelegate.switchToLoginVC()
            }) { (no) in
                
            }
        }
    }
    
    // MARK: - Menu Action
    @IBAction func pressMenuAction(_ sender: UIButton) {
        self.sideMenuViewController!.presentLeftMenuViewController()
    }
    
    // MARK: - notification Action
    @IBAction func notificationAction(_ sender: UIButton) {
        
        if let _ = UserDataModel.isLoggedIn() {
            let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "NotificationsVC") as NotificationsVC
            vc.isfromHome = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            navigateToLogin()
        }
    }
    
    // MARK: - Cart Action
    @IBAction func cartAction(_ sender: UIButton) {
        
        if let _ = UserDataModel.isLoggedIn() {
            let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "CartVC") as CartVC
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            navigateToLogin()
        }
    }
    
    
    @IBAction func wishlistAction(_ sender: UIButton) {
        
        if let _ = UserDataModel.isLoggedIn() {
            let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "WishlistVC") as WishlistVC
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            navigateToLogin()
        }
    }
    
    //************************* MARK: - Voice To Text *************************//
    //************************* Start *************************//
    // MARK: - Audio Action
    @IBAction func audioAction(_ sender: UIButton) {
        txtSearch.resignFirstResponder()
        if obj.audioEngine.isRunning{
            obj.StopDefault()
        }else{
            obj.setup()
            obj.delegate = self
            obj.startRecording()
        }
        
        
    }
    
    func Searchtext(_ SearchText: String){
        txtSearch.text = SearchText
    }
    
    func OnCompletion(){
        self.switchToSearchVC(searchText: txtSearch.text ?? "")
    }
    
    //************************* Action End *************************//
    
    
    func setCurrentLocation(){
        
        guard address.latitude == nil  else {
            lblCityName.text = address.addressType ?? address.userLocality
            lblAddress.text = address.userAddress
            return
        }
        
        guard let currentLocations = LocationManager.shared.currentLocation else{
            AppManager.showAlert(Constants.KAppName, "Please allow location services to move forward", view: self)
            return
        }
        guard let _ = UserDataModel.isLoggedIn() else{
            DispatchQueue.main.async {
                self.setLocation(currentLocations)
            }
            return
        }
        setLocation(currentLocations)
    }
    
    fileprivate func setLocation(_ currentLocations: CLLocationCoordinate2D) {
        AppManager.getAddressFromLatLon(pdblLatitude:currentLocations.latitude, withLongitude:currentLocations.longitude) { (address) in
            self.lblAddress.text = address?.userAddress ?? ""
            self.lblCityName.text = address?.userLocality ?? "Other"
        }
    }
    
}


// MARK: - UITableViewDelegate / UITableViewDataSource
extension HomeVC: UITableViewDelegate,UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return bannerArray.count > 0 ? 1 : 0
        }
        if section == 2 {
            return dealsArray.count > 0 ? 1 : 0
        }
        return 1
        
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell:CategoryCell = self.tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
            cell.data = catArray
            cell.collectionView.reloadData()
            
            cell.tappedCellAction = { (index) -> Void in
                let data = self.catArray[index]
                self.navigateToSubCategory(Id: data.id, name: data.name)
            }
            return cell
            
        }
        else if indexPath.section == 1 {
            
            let cell:BannerCell = self.tableView.dequeueReusableCell(withIdentifier: "BannerCell") as! BannerCell
            cell.banners = bannerArray
            cell.page.numberOfPages = bannerArray.count
            cell.collectionView.reloadData()
            cell.tappedCellAction = { (result) -> Void in
                let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductVC") as ProductVC
                vc.productObject = result
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
            
            
        } else if indexPath.section == 2 {
            
            let cell:DealCell = self.tableView.dequeueReusableCell(withIdentifier: "DealCell") as! DealCell
            cell.deals = dealsArray
            cell.collectionView.reloadData()
            
            cell.tappedCellAction = { (result) -> Void in
                let url = "\(URLMethods.dealsOfday)/\(result.id ?? "")"
                let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "OtherProductVC") as OtherProductVC
                vc.productUrl = url
                vc.isFromDeals = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
            
            
        }  else if indexPath.section == 3 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PopularCell") as! PopularCell
            cell.products = popularProducts
            cell.collectionView.reloadData()
            cell.tappedAction = {
                self.navigateToProduct(URLMethods.popularProduct)
            }
            cell.tappedCellAction = { (index) -> Void in
                let item = self.popularProducts[index]
                self.navigateToProductDetail(item.id ?? "")
            }
            return cell
            
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "DiscountOfferCell") as! DiscountOfferCell
            cell.products = discountedProducts
            cell.collectionView.reloadData()
            cell.tappedAction = {
                self.navigateToProduct(URLMethods.discountProduct)
            }
            cell.tappedCellAction = { (index) -> Void in
                let item = self.discountedProducts[index]
                self.navigateToProductDetail(item.id ?? "")
            }
            return cell
        }
        
    }
    
    
    
    // MARK: - navigateToProduct
    func navigateToProduct(_ url: String) {
        
        let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "OtherProductVC") as OtherProductVC
        vc.productUrl = url
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - navigateToProductDetail
    func navigateToProductDetail(_ id: String) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductDetailVC") as ProductDetailVC
        vc.productID = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - navigateToSubCategory
    func navigateToSubCategory(Id: String, name: String) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "CategoryVC") as CategoryVC
        vc.categoryId = Id
        vc.categoryName = name
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UItextFiledDelegate
extension HomeVC: UITextFieldDelegate {
    
    //************************* MARK: - Voice To Text Search *************************//
    //************************* Start *************************//
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if obj.audioEngine.isRunning {
            obj.audioEngine.stop()
            obj.recognitionRequest?.endAudio()
            obj.audioEngine.inputNode.removeTap(onBus: 0)
            obj.recognitionRequest = nil
            obj.recognitionTask = nil
            obj.StopDefault()
            sceneDelegate.window?.viewWithTag(101)?.removeFromSuperview()
        }else{
            self.switchToSearchVC(searchText: "")
        }
        return false
    }
    
    func switchToSearchVC(searchText:String) {
        
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "SearchVC") as SearchVC
        if searchText.count > 0{
            vc.searchText = searchText
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    //************************* End *************************//
}
