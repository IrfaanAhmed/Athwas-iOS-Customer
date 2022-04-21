//
//  UIApplication.swift
//  ASAP
//
//  Created by Mac106 on 12/05/17.
//  Copyright © 2017 Octal IT Solution LLP. All rights reserved.
//

import UIKit
//import AKSideMenu //SlideMenuControllerSwift

public extension UIApplication {
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.k?.rootViewController) -> UIViewController? {
        
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        
      /*  if let slide = viewController as? AKSideMenu {
            if let controller = slide.contentViewController as? UINavigationController {
                return controller.viewControllers.last
            }
        }*/
        
        /*if let slide = viewController as? SlideMenuController {
            return topViewController(slide.mainViewController)
        }*/
        return viewController
    }
}

extension UINavigationBar {
    
    func shouldRemoveShadow(_ value: Bool) -> Void {
        if value {
            self.setValue(true, forKey: "hidesShadow")
        } else {
            self.setValue(false, forKey: "hidesShadow")
        }
    }
}

