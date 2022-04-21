//
//  Measurment.swift
//  IA
//
//  Created by admin on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class MeasurmentCell: UITableViewCell {

    @IBOutlet weak var txtMeasurement : BindingTextField!
    @IBOutlet weak var lblTitle : UILabel!
    
    var cellData : Customization? {
           didSet {
            lblTitle.text = cellData?.title?.name
            txtMeasurement.text = cellData?.title?.value?.name
           }
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txtMeasurement.RightViewImage(#imageLiteral(resourceName: "list_drop_arrow"))
        txtMeasurement.LeftView(of: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
