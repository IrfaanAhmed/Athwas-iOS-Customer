//
//  SimilarProductsCell.swift
//  IA
//
//  Created by admin on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class SimilarProductsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var cellData : [SimilarProductsModel]?
    var tappedCellAction: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = cellData?.count ?? 0
        collectionView.setBackgroundMessage(rows == 0 ? "No data found" : nil)
        return rows
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscountCell", for: indexPath as IndexPath)
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let image = cell.viewWithTag(1) as? UIImageView
        let name = cell.viewWithTag(2) as? UILabel
        let discountedPrice = cell.viewWithTag(3) as? UILabel
        let actualPrice = cell.viewWithTag(4) as? UILabel
        let offer = cell.viewWithTag(5) as? UILabel
        
        let data = cellData?[indexPath.row]
        if  data?.images?.count ?? 0 > 0 {
            let url = data?.images?[0].productImageURL
            image?.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: ""))
        }
        name?.text = "\(data?.name ?? "") - \(data?.inventoryName ?? "")"
        
        if data?.isDiscount == 1 {
            
            discountedPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.offerPrice ?? 0.0))"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            actualPrice?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
            
            let offerText = data?.discountType == 1 ? "\(data?.discountValue?.clean ?? "0")% off" : "\(Constants.KCurrency)\(data?.discountValue?.clean ?? "0") off"
            offer?.text = offerText
            offer?.isHidden  = false
        }
        else {
            
            discountedPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data?.price ?? 0.0))"
            actualPrice?.attributedText = AppManager.strikeThroughAttribute(str: "")
            offer?.isHidden = true
        }
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        self.tappedCellAction!(indexPath.row)
    }
}
