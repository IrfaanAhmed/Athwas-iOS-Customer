//
//  CCAvenueWebVC.swift
//  IA
//
//  Created by admin on 22/06/21.
//  Copyright © 2021 octal. All rights reserved.
//

import UIKit
import WebKit

class CCAvenueWebVC: BaseClassVC, WKNavigationDelegate {
    
    @IBOutlet weak var webCCV: WKWebView!
    var webRequest : NSMutableURLRequest? = nil
    var callback: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerTitle.text = "Payment"
        self.backBtn.isHidden = false
        
        AppManager.startActivityIndicator()
        self.webCCV.navigationDelegate = self
        
        self.webCCV.load(webRequest! as URLRequest)
    }
    
    
    
    //MARK:- WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
        
        if let url = webView.url?.absoluteString {
            print("url = \(url)")
            
            if url.contains("http://3.7.83.168:3060/user_service/customer/payment/complete_payment") {
                
                webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (result, error) in
                    if error == nil {
                        print(result as Any)
                        
                        self.callback!(true)
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        AppManager.stopActivityIndicator()
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
