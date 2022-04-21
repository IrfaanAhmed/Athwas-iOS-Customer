//
//  LeftMenuVC.swift
//  Tiong Lian
//
//  Created by Yogesh Raj on 08/11/19.
//  Copyright © 2019 Yogesh Raj. All rights reserved.
//

import UIKit
import AKSideMenu

class LeftMenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    /// Variables //////
    
    var titles:[String] = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupUI()
        
    }
    
    func setupUI() {
        self.navigationController?.navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = UserDataModel.isLoggedIn() {
            titles = ["Home","Shop by Category","Offers","My Account","My Orders","Athwas Pay","FAQs","About us","Contact us","Terms of Use","Privacy Policy","Terms & Conditions","Logout"]
            lblName.text = Constants.kAppDelegate.user?.username
            let imgURL = Constants.kAppDelegate.user?.userImageThumbURL
            self.imgUser.sd_setImage(with: URL(string: imgURL ?? ""), placeholderImage: #imageLiteral(resourceName: "user"))
            self.imgUser.contentMode = .scaleAspectFit
        }
        else {
            titles = ["Home","Shop by Category","Offers","FAQs","About us","Contact us","Terms of Use","Privacy Policy","Terms & Conditions","Login"]
            self.imgUser.contentMode = .center
        }
        self.tableView.reloadData()
        
    }
    
}

// MARK: - <UITableViewDelegate> / <UITableViewDataSource>
extension LeftMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        return titles.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "Cell"
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        let title = cell.viewWithTag(1) as! UILabel
        
        title.text = self.titles[indexPath.row]
        title.textColor = UIColor.lightGray
        if selectedIndex == indexPath.row {
            title.textColor = UIColor.appDarkGreen
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        self.tableView.reloadData()
        let title = self.titles[indexPath.row]
        
        var controller: UIViewController!
        switch title {
        case "Home":
            controller = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
            
        case "Shop by Category":
            let controller: BuzCategoryVC = self.storyboard?.instantiateViewController(identifier: "BuzCategoryVC") as! BuzCategoryVC
            controller.isMenu = true
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
            
        case "My Orders":
            controller = Constants.KOrderStoryboard.instantiateViewController(identifier: "MyOrdersVC") as! MyOrdersVC
            
        case "Offers":
            if let _ = UserDataModel.isLoggedIn() {
                controller = Constants.KOrderStoryboard.instantiateViewController(identifier: "OfferTypeVC") as! OfferTypeVC
            } else {
                DispatchQueue.main.async {
                    AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                        Constants.kSceneDelegate.switchToLoginVC()
                    }) { (no) in
                        
                    }
                }
            }
            
        case "My Account":
            let vc: MyProfileVC = MyProfileVC(nibName: "MyProfileVC", bundle: nil)
            self.sideMenuViewController!.setContentViewController(vc, animated: true)
            
        case "Athwas Pay":
            let vc: WalletVC = WalletVC(nibName: "WalletVC", bundle: nil)
            self.sideMenuViewController!.setContentViewController(vc, animated: true)
            
        case "FAQs":
            let controller = Constants.KMainStoryboard.instantiateViewController(identifier: "FAQVC") as! FAQVC
            controller.webTitle = "FAQs"
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
            
        case "Contact us":
            let controller = Constants.KMainStoryboard.instantiateViewController(identifier: "StaticPageVC") as! StaticPageVC
            controller.webTitle = "Contact us"
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
            
        case "About us":
            let controller = Constants.KMainStoryboard.instantiateViewController(identifier: "StaticPageVC") as! StaticPageVC
            controller.webTitle = "About us"
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
            
        case "Privacy Policy":
            let controller = Constants.KMainStoryboard.instantiateViewController(identifier: "StaticPageVC") as! StaticPageVC
            controller.webTitle = "Privacy Policy"
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
            
        case "Terms of Use":
            let controller = Constants.KMainStoryboard.instantiateViewController(identifier: "StaticPageVC") as! StaticPageVC
            controller.webTitle = "Terms of Use"
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
            
        case "Terms & Conditions":
            let controller = Constants.KMainStoryboard.instantiateViewController(identifier: "StaticPageVC") as! StaticPageVC
            controller.webTitle = "Terms & Condition"
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
            
        case "Logout":
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "Are you sure you want to logout?", "Yes", "No", self, successClosure: { (yes) in
                    self.logoutApi()
                }) { (no) in
                    
                }
            }
            break
            
        case "Login":
            Constants.kSceneDelegate.switchToLoginVC()
            break
            
        default:
            break
        }
        if controller != nil {
            self.sideMenuViewController!.setContentViewController(controller, animated: true)
        }
        self.sideMenuViewController!.hideMenuViewController()
    }
    
    func logoutApi() {
        AppManager.startActivityIndicator()
        ApiClient().apiCallMethod(URLMethods.logout, method: .post, parameter: [:], successClosure: { (response) in
            AppManager.stopActivityIndicator()
            Constants.kSceneDelegate.switchToLoginVC()
            
        }) { (error) in
            AppManager.stopActivityIndicator()
            AppManager.showToast(error ?? "")
        }
        
    }
}
