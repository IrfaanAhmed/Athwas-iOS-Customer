//
//  FilterSubCatCell.swift
//  IA
//
//  Created by admin on 04/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class FilterSubCatCell: UITableViewCell {

    @IBOutlet weak var imgSelection: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var data : FilterCustomSubType? {
        didSet {
            lblTitle.text = data?.name
            imgSelection.image = data?.isSelected == true ? UIImage(named: "checked") : UIImage(named: "uncheck")
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
