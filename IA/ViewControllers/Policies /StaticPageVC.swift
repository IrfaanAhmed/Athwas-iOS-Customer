//
//  StaticPageVC.swift
//  IA
//
//  Created by admin on 08/01/21.
//  Copyright © 2021 octal. All rights reserved.
//

import UIKit
import WebKit

class StaticPageVC: BaseClassVC, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var isfromSideMenu = true
    var webTitle = ""
    var webURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        switch webTitle {
        
        case "Terms of Use":
            getContent("term_of_use")
            break
            
        case "About us":
            getContent("about_us")
            break
            
        case "Privacy Policy":
            getContent("privacy_policy")
            break
            
        case "Contact us":
            getContent("contact_us")
            break
            
        case "Terms & Condition":
            getContent("terms_condition")
            break
            
        case "Invoice":
            let requestObj = URLRequest(url: webURL)
            self.webView.load(requestObj)
        break
        
        default:
            break
        }
    }
    
    
    func setupUI() {
        self.headerTitle.text = webTitle
        self.menuBtn.isHidden = isfromSideMenu == false ? true : false
        self.backBtn.isHidden = isfromSideMenu == false ? false : true
        self.webView.navigationDelegate = self

    }
    
    
    func getContent(_ key: String) {
        
        let url = "\(URLMethods.staticPages)\(key)"
        
        ApiClient().apiCallMethod(url, method: .get, parameter: [:], successClosure: { (response) in
            if let data = (response as? NSDictionary)?.value(forKey: "data") as? NSDictionary {
                
                let contentData = data["content_data"] as? String ?? ""
                let content = "<span style=\"font-size: \(24); color: #555555\"</span>" + contentData
                self.webView.loadHTMLString(content, baseURL: nil)
            }
            
        }) { (error) in
            AppManager.showToast(error ?? "")
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        AppManager.startActivityIndicator()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        AppManager.stopActivityIndicator()
        let javascript = "document.getElementsByTagName('body')[0].style.fontFamily= 'Futura-Medium'"

        webView.evaluateJavaScript(javascript) { (response, error) in
            print()
        }
    }
    
}
