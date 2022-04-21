//
//  MyProfileVC.swift
//  Tivo
//
//  Created by admin on 07/07/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit
import SDWebImage

class MyProfileVC: BaseClassVC {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getProfile()
    }
    
    func setupUI() {
        
        self.headerTitle.text = "My Account"
        self.menuBtn.isHidden = false
        self.editBtn.isHidden = false
    }
    
    
    func getProfile() {
        
        AppManager.startActivityIndicator()
        ApiClient().apiCallMethod(URLMethods.getProfile, method: .get, parameter: [:], successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            
            let data = (response as? NSDictionary)?.value(forKey: "data") as? NSDictionary
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                var user = try? JSONDecoder().decode(UserDataModel.self, from: jsonData) else { return }
            
            user.authToken = Constants.kAppDelegate.user?.authToken
            user.defaultAddress = Constants.kAppDelegate.user?.defaultAddress
            Constants.kAppDelegate.user = user
            let userData = try? JSONEncoder().encode(Constants.kAppDelegate.user)
            Constants.kAppDelegate.user?.saveUser(userData ?? Data())
            
            self.lblName.text = Constants.kAppDelegate.user?.username
            self.lblEmail.text = Constants.kAppDelegate.user?.email
            let imgURL = Constants.kAppDelegate.user?.userImageThumbURL
            self.imgUser.sd_setImage(with: URL(string: imgURL ?? ""), placeholderImage: #imageLiteral(resourceName: "user"))
            
        }) { (error) in
            AppManager.stopActivityIndicator()
            AppManager.showToast(error ?? "")
        }
        
    }
    
    //MARK:- Button Actions
    
    
    @IBAction func btnAddress(_ sender: Any) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "AddressVC") as! AddressVC
        vc.isfromProfile = true
        vc.getAddress = { (address) -> Void in}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnWishList(_ sender: Any) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "WishlistVC") as! WishlistVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnRewards(_ sender: Any) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "RewardPointsVC") as! RewardPointsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSettings(_ sender: Any) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        
        DispatchQueue.main.async {
            AppManager.showAlert_withTwoActions("Logout", "Are you sure you want to logout?", "Yes", "No", self, successClosure: { (yes) in
                
                Constants.kSceneDelegate.switchToLoginVC()
            }) { (no) in
                
            }
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
