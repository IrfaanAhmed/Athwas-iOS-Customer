//
//  BannerCell.swift
//  IA
//
//  Created by Yogesh Raj on 14/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class BannerCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var page: UIPageControl!
    
    //Array
    var banners:[BannerDataModel] = []
    var tappedCellAction: ((ProductCategoryDataModel) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        page.numberOfPages = banners.count
        self.startTimer()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath as IndexPath)
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let image = cell.viewWithTag(1) as? UIImageView
        
        let data = banners[indexPath.row]
        image!.sd_setImage(with: URL(string: data.bannerImageURL ?? ""), placeholderImage: UIImage(named: ""))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.contentView.frame.width, height: 140)
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = banners[indexPath.row]
        var productObject = ProductCategoryDataModel()
        //
        var businessCategoryID = BusinessCategoryID()
        businessCategoryID.id = data.businessCategory?.id
        productObject.businessCategoryID = businessCategoryID
        //
        productObject.parentID = data.category?.id
        productObject.id = data.subcategory?.id
        tappedCellAction!(productObject)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let page = Int(round(scrollView.contentOffset.x/width))
        self.page.currentPage = page
    }
    
    
    @objc func scrollToNextCell(){
        
        //get cell size
        let cellSize = CGSize(width: self.contentView.frame.width, height: self.contentView.frame.height);
        
        //get current content Offset of the Collection view
        let contentOffset = collectionView.contentOffset;
        
        if page.currentPage >= page.numberOfPages-1 {
               collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        } else {
            //scroll to next cell
            self.collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true);
            
        }
    }
    
    /**
     Invokes Timer to start Automatic Animation with repeat enabled
     */
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 8.0, target: self, selector:#selector(scrollToNextCell), userInfo: nil, repeats: true);
    }
    
}
