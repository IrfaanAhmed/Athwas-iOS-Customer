//
//  DealCell.swift
//  IA
//
//  Created by admin on 24/05/21.
//  Copyright © 2021 octal. All rights reserved.
//

import UIKit

class DealCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var page: UIPageControl!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    
    var deals : [DealsDataModel] = [] {
        didSet {
            page.numberOfPages = deals.count
            if deals.count > 1 {
                btnLeft.isHidden = false
                btnRight.isHidden = false
            }
            collectionView.reloadData()
        }
    }
    var tappedCellAction: ((DealsDataModel) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deals.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dealCell", for: indexPath as IndexPath)
        let image = cell.viewWithTag(1) as? UIImageView
        
        let data = deals[indexPath.row]
        image!.sd_setImage(with: URL(string: data.imageURL ?? ""), placeholderImage: UIImage(named: ""))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.contentView.frame.width, height: 140)
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = deals[indexPath.row]
        tappedCellAction!(data)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let page = Int(round(scrollView.contentOffset.x/width))
        self.page.currentPage = page
        
        btnLeft.isHidden = page > 0 ? false : true
        btnRight.isHidden = deals.count-1 > page ? false : true
    }
    
    
    @IBAction func scrollChange(_ sender: UIButton) {
        
        if sender.tag == 1 {
            if deals.count-1 > page.currentPage {
                collectionView.scrollToItem(at: IndexPath(item: page.currentPage + 1, section: 0), at: .right, animated: true)
            }
        }
        else {
            if page.currentPage > 0 {
                collectionView.scrollToItem(at: IndexPath(item: page.currentPage - 1, section: 0), at: .right, animated: true)
            }
        }
    }
}
