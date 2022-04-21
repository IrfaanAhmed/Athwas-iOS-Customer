//
//  TableViewCell_PaymentMode.swift
//  IA
//
//  Created by admin on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class TableViewCell_PaymentMode: UITableViewCell {
    
    @IBOutlet weak var imgSelection: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblWalletBalance: UILabel!
    @IBOutlet weak var btnAddWallet: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imgSelection.image = selected ? #imageLiteral(resourceName: "checked") : #imageLiteral(resourceName: "uncheck")
    }
    
}
