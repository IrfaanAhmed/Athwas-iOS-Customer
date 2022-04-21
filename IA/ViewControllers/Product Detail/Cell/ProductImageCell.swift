//
//  ProductImageCell.swift
//  IA
//
//  Created by admin on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class ProductImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var page: UIPageControl!
    @IBOutlet weak var btnFav : UIButton!
    
    var callbackFavStatus : ((Int) -> Void)?
    var tappedCellAction: (([String], Int) -> Void)?
    
    var cellData : ProductDetailModel? {
        didSet {
            page.numberOfPages = cellData?.images?.count ?? 0
            btnFav.isSelected = cellData?.isFavourite == 1 ? true : false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
      //  self.startTimer()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (cellData?.images?.count ?? 0) > 0 ? (cellData?.images?.count ?? 0) : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImage", for: indexPath)
        let cellImage = cell.viewWithTag(111) as? UIImageView
        guard (cellData?.images?.count ?? 0) > 0 else {
            cellImage?.image = #imageLiteral(resourceName: "login_logo")
            return cell
        }
        let imageData = cellData?.images?[indexPath.row]
        let imgURL = imageData?.productImageURL
        cellImage?.sd_setImage(with: URL(string: imgURL ?? ""), placeholderImage: #imageLiteral(resourceName: "login_logo"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.contentView.frame.width, height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var imageArray = [String]()
        for item in cellData?.images ?? [] {
            imageArray.append(item.productImageURL ?? "")
        }
        tappedCellAction!(imageArray, indexPath.row)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let page = Int(round(scrollView.contentOffset.x/width))
        self.page.currentPage = page
    }
    
    @IBAction func btnFav_Clicked(_ sender: UIButton) {
        self.callbackFavStatus?(cellData?.isFavourite == 0 ? 1 : 0)
    }
    
    
    @objc func scrollToNextCell(){
        
        let cellSize = CGSize(width: self.contentView.frame.width, height: self.contentView.frame.height);
        
        let contentOffset = collectionView.contentOffset;
        
        if page.currentPage >= page.numberOfPages-1 {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        } else {
            collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true);
        }
        
    }

    func startTimer() {
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector:#selector(scrollToNextCell), userInfo: nil, repeats: true);
    }
}
