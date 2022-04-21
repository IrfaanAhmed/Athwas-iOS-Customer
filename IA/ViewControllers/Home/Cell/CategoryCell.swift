//
//  CategoryCell.swift
//  IA
//
//  Created by Yogesh Raj on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var tappedCellAction: ((Int) -> Void)?
    var data : [BusinessCatDataModel]?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath as IndexPath)
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let image = cell.viewWithTag(1) as? UIImageView
        let name = cell.viewWithTag(2) as? UILabel
        
        name?.text = data?[indexPath.row].name
        image!.sd_setImage(with: URL(string: data?[indexPath.row].categoryImageThumbURL ?? ""), placeholderImage: UIImage(named: ""))
        
        return cell
        
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tappedCellAction!(indexPath.row)
        
    }
    
}
