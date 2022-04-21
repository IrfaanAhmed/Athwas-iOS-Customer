//
//  TableViewCell_Rewards.swift
//  Tivo
//
//  Created by admin on 26/08/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit

class RewardsCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    var data: RewardPointsModel? {
        didSet {
            lblTitle.text = "You earned: \(data?.earnedPoints ?? 0) Points"
            lblDate.text = "Expiry: \(AppManager.changeDateFormat(dateStr: data?.expirationDate ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", neededFormate: "dd MMMM yyyy") ?? "")"
            lblPoints.text = AppManager.changeDateFormat(dateStr: data?.createdAt ?? "", dateFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", neededFormate: "dd MMM yyyy")
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
