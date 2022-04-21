//
//  Settings.swift
//  IA
//
//  Created by admin on 22/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class SettingsVC: BaseClassVC {
    
    @IBOutlet weak var my_switch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        if let value = Constants.kUserDefaults.value(forKey: "notification") as? Bool {
            my_switch.isOn = value
        }
        
    }
    
    func setupUI() {
        self.headerTitle.text = "Settings"
        self.backBtn.isHidden = false
        self.searchBtn.isHidden = true
        self.cartBtn.isHidden = true
    }
    
    
   @IBAction func switchChanged(sender: UISwitch!) {
        print("Switch value is \(sender.isOn)")

        if(sender.isOn){
            print("ON")
            UIApplication.shared.registerForRemoteNotifications()
        }
        else{
            print("Off")
            UIApplication.shared.unregisterForRemoteNotifications()
        }
        Constants.kUserDefaults.setValue(sender.isOn, forKey: "notification")
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
