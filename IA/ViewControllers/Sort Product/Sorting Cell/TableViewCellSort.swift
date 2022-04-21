//
//  TableViewCellSort.swift
//  IA
//
//  Created by admin on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class TableViewCellSort: UITableViewCell {
    
    @IBOutlet weak var imgSelection: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imgSelection.image = selected ? #imageLiteral(resourceName: "list_check") : nil
    }
    
}
