//
//  PopularCell.swift
//  IA
//
//  Created by Yogesh Raj on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class PopularCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewAllBtn: UIButton!
    var tappedAction: (() -> Void)?
    var tappedCellAction: ((Int) -> Void)?
    var products : [ProductListDataModel] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscountCell", for: indexPath as IndexPath)
        let image = cell.viewWithTag(1) as? UIImageView
        let name = cell.viewWithTag(2) as? UILabel
        let discountedPrice = cell.viewWithTag(3) as? UILabel
        let actualPrice = cell.viewWithTag(4) as? UILabel
        let offer = cell.viewWithTag(5) as? UILabel
        
        let data = products[indexPath.row]
        if  data.images?.count ?? 0 > 0 {
            let url = data.images?[0].productImageURL
            image?.sd_setImage(with: URL(string: url ?? ""), placeholderImage: UIImage(named: ""))
        }
        name?.text = "\(data.name ?? "") - \(data.inventoryName ?? "")"
        
        if data.isDiscount == 1 {
            
            discountedPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data.offerPrice ?? 0.0))"
            let actualprice = "\(Constants.KCurrency)\(String(format: "%.2f", data.price ?? 0.0))"
            actualPrice?.attributedText = AppManager.strikeThroughAttribute(str: actualprice)
            
            let offerText = data.discountType == 1 ? "\(data.discountValue?.clean ?? "0")% off" : "\(Constants.KCurrency)\(data.discountValue?.clean ?? "0") off"
            offer?.text = offerText
            offer?.isHidden  = false
        }
        else {
            
            discountedPrice?.text = "\(Constants.KCurrency)\(String(format: "%.2f", data.price ?? 0.0))"
            actualPrice?.attributedText = AppManager.strikeThroughAttribute(str: "")
            offer?.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (Constants.kScreenWidth - 40)/3
        return CGSize(width: width, height: 180)
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tappedCellAction!(indexPath.row)
    }
    
    
    // MARK: - View All Action
    @IBAction func pressViewAllAction(_ sender: UIButton) {
        self.tappedAction!()
    }

}
