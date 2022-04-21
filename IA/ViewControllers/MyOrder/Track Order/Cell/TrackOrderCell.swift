//
//  TrackOrderCell.swift
//  IA
//
//  Created by admin on 03/11/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class TrackOrderCell: UITableViewCell {
    
    @IBOutlet weak var viewround : UIView!
    @IBOutlet weak var viewLine : UIView!
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblDate : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
