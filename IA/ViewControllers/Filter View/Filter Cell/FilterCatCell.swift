//
//  FilterCatCell.swift
//  IA
//
//  Created by admin on 04/12/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class FilterCatCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    var data : FilterCustomType? {
        didSet {
            lblTitle.text = data?.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      if selected {
            self.backgroundColor = .white
        }
        else {
            self.backgroundColor = .clear
        }
    }
    
}
