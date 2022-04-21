//
//  BaseClassVC.swift
//  IA
//
//  Created by Yogesh Raj on 11/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import AKSideMenu

class BaseClassVC: UIViewController {
    
    
    var yPos: Int = 0
    var statusBarSize = CGSize.zero
    var headerTitle: UILabel!
    var backBtn: UIButton!
    var menuBtn: UIButton!
    var cartBtn: MIBadgeButton!
    var searchBtn: UIButton!
    var editBtn: UIButton!
    var notificationBtn: UIButton!
    var deleteBtn: UIButton!
    var blockBg = UIView()
    var header = UIView()
    var bg = UIImageView()
    var statusBarBg = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
        
        navigationController?.isNavigationBarHidden = true
        //statusBarSize = UIApplication.shared.statusBarFrame.size
        yPos = Int(Constants.kAppDelegate.statusBarManager.statusBarFrame.size.height)
        bg = UIImageView(frame: CGRect(x: 0, y: 0, width: Int(Constants.kScreenWidth), height: yPos+44))
        bg.image = UIImage.init(named: "")
        bg.backgroundColor = UIColor.appLightGreen
        bg.contentMode = .scaleAspectFill
        bg.clipsToBounds = true
        view.addSubview(bg)
        
        
        statusBarBg = UIImageView(frame: CGRect(x: 0, y: 0, width: Int(Constants.kScreenWidth), height: yPos))
        statusBarBg.image = UIImage.init(named: "")
        statusBarBg.backgroundColor = UIColor.appDarkGreen
        statusBarBg.contentMode = .scaleAspectFill
        statusBarBg.clipsToBounds = true
        view.addSubview(statusBarBg)
        
        header = UIView(frame: CGRect(x: 0, y: yPos, width: Int(Constants.kScreenWidth), height: 44))
        header.backgroundColor = UIColor.clear
        view.addSubview(header)
        
        headerTitle = UILabel(frame: CGRect(x: 40, y: 0, width: Constants.kScreenWidth-80, height: 44))
        headerTitle.textAlignment = .center
        headerTitle.font = UIFont.init(name: "Linotte-Bold", size: 18)
        headerTitle.textColor = UIColor.white
        header.addSubview(headerTitle)
        
        // Menu Button
        menuBtn = UIButton(frame: CGRect(x: 15, y: 7, width: 30, height: 30))
        menuBtn.setImage( UIImage.init(named: "side_menu"), for: .normal)
        menuBtn.isHidden = true
        menuBtn.tintColor = .white
        menuBtn.addTarget(self, action: #selector(self.pressMenu(_:)), for: .touchUpInside)
        header.addSubview(menuBtn)
        
        // Back Button
        backBtn = UIButton(frame: CGRect(x: 10, y: 3, width: 40, height: 40))
        backBtn.setImage( UIImage.init(named: "back1"), for: .normal)
        backBtn.isHidden = true
        backBtn.addTarget(self, action: #selector(self.pressBack(_:)), for: .touchUpInside)
        header.addSubview(backBtn)
        
        // Cart Button
        cartBtn = MIBadgeButton(frame: CGRect(x: Constants.kScreenWidth - 55, y: 3, width: 40, height: 40))
        cartBtn.setImage( UIImage.init(named: "cart"), for: .normal)
        cartBtn.isHidden = true
        cartBtn.badgeBackgroundColor = .red
        cartBtn.badgeTextColor = .white
        //  cartBtn.badgeString = nil
        cartBtn.topOffset = 9.0
        cartBtn.leftOffset = 30
        cartBtn.addTarget(self, action: #selector(self.pressCart(_:)), for: .touchUpInside)
        header.addSubview(cartBtn)
        
        
        // Search Button
        searchBtn = UIButton(frame: CGRect(x: Constants.kScreenWidth - 88, y: 7, width: 30, height: 30))
        searchBtn.setImage( UIImage.init(named: "search_white"), for: .normal)
        searchBtn.isHidden = true
        searchBtn.addTarget(self, action: #selector(self.pressSearch(_:)), for: .touchUpInside)
        header.addSubview(searchBtn)
        
        
        // Edit Button
        editBtn = UIButton(frame: CGRect(x: Constants.kScreenWidth - 46, y: 7, width: 30, height: 30))
        editBtn.setImage( UIImage.init(named: "edit_profile"), for: .normal)
        editBtn.isHidden = true
        editBtn.addTarget(self, action: #selector(self.pressEdit(_:)), for: .touchUpInside)
        header.addSubview(editBtn)
        
        
        // Notification Button
        notificationBtn = UIButton(frame: CGRect(x: Constants.kScreenWidth - 76, y: 7, width: 30, height: 30))
        notificationBtn.setImage( UIImage.init(named: "notification"), for: .normal)
        notificationBtn.isHidden = true
        notificationBtn.addTarget(self, action: #selector(self.pressBack(_:)), for: .touchUpInside)
        header.addSubview(notificationBtn)
        
    }
    
    
    // MARK: - Press Menu
    @IBAction func pressMenu(_ sender: UIButton) {
        self.sideMenuViewController!.presentLeftMenuViewController()
    }
    
    // MARK: - Press Back
    @IBAction func pressBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Press Search
    @IBAction func pressSearch(_ sender: UIButton) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "SearchVC") as SearchVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - Press Cart
    @IBAction func pressCart(_ sender: UIButton) {
        if let _ = UserDataModel.isLoggedIn() {
            let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "CartVC") as CartVC
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            DispatchQueue.main.async {
                AppManager.showAlert_withTwoActions(Constants.KAppName, "To proceed, you need to login first", "Continue", "Cancel", self, successClosure: { (yes) in
                    Constants.kSceneDelegate.switchToLoginVC()
                }) { (no) in
                    
                }
            }
        }
    }
    
    // MARK: - Press Notification
    @IBAction func pressNotification(_ sender: UIButton) {
        
    }
    
    // MARK: - Press Cart
    @IBAction func pressEdit(_ sender: UIButton) {
        let vc: EditProfileVC = EditProfileVC(nibName :"EditProfileVC",bundle : nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

