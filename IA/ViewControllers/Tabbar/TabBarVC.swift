//
//  TabBarVC.swift
//  Lifferent
//
//  Created by sumit sharma on 29/01/21.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.backgroundColor = UIColor.white
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 2
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        self.setUpTabBarItems()
        navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }

    // MARK: - this is fun for create tabbar item
    func setUpTabBarItems() {
        
        let homeItem = (self.tabBar.items?[0])! as UITabBarItem
        homeItem.image = UIImage(named: "home-unselected")?.withRenderingMode(.alwaysOriginal)
        homeItem.selectedImage = UIImage(named: "home-selected")?.withRenderingMode(.alwaysOriginal)
        homeItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        homeItem.title = "Home"
       
        let contestItem = (self.tabBar.items?[1])! as UITabBarItem
        contestItem.image = UIImage(named: "contest-unselected")?.withRenderingMode(.alwaysOriginal)
        contestItem.selectedImage = UIImage(named: "contest-selected")?.withRenderingMode(.alwaysOriginal)
        contestItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contestItem.title = "My Contest"

        let moreItem = (self.tabBar.items?[2])! as UITabBarItem
        moreItem.image = UIImage(named: "more-unselected")?.withRenderingMode(.alwaysOriginal)
        moreItem.selectedImage = UIImage(named: "more-selected")?.withRenderingMode(.alwaysOriginal)
        moreItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        moreItem.title = "More"
        
        let supportItem = (self.tabBar.items?[3])! as UITabBarItem
        supportItem.image = UIImage(named: "help-unselected")?.withRenderingMode(.alwaysOriginal)
        supportItem.selectedImage = UIImage(named: "help-selected")?.withRenderingMode(.alwaysOriginal)
        supportItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        supportItem.title = "Help"
        
        let selectedColor   = UIColor.red
        let unselectedColor = UIColor.darkGray

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .selected)

    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //        let indexOfTab = tabBar.items?.index(of: item)
        //        print("pressed tabBar: \(String(describing: indexOfTab))")
//        if item.tag == 3{
//            //do our animations
//            UIApplication.shared.applicationIconBadgeNumber = 0
//        }
        
    }
   
    let simpleCompleationHandler:()->Void =  {
        print("From The Compleation handler!")
    }
}


func completionhandler()-> Void{
    
}
