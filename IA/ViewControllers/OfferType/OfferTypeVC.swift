//
//  OfferTypeVC.swift
//  IA
//
//  Created by Yogesh Raj on 24/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit


struct OfferType {
    public var title : String
    public var imgItem : UIImage?
    public var tag : Int?
}


class OfferTypeVC: BaseClassVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var isfromSideMenu = true
    var productID = ""
    var offers : [OfferType] = [
        OfferType(title: "Promo code Offers", imgItem: UIImage.init(named: "offer1"), tag: 1),
        OfferType(title: "Bundle Offers", imgItem: UIImage.init(named: "offer2"), tag: 2),
        OfferType(title: "Promotional Offers", imgItem: UIImage.init(named: "offer3"), tag: 3),
        OfferType(title: "Bank Offers", imgItem: UIImage.init(named: "offer4"), tag: 4)
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupUI()
        //  fetchOfferList(1)
    }
    
    func setupUI() {
        self.headerTitle.text = "Offers"
        self.menuBtn.isHidden = isfromSideMenu == false ? true : false
        self.backBtn.isHidden = isfromSideMenu == false ? false : true
    }
    
    
   
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension OfferTypeVC: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath as IndexPath)
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let image = cell.viewWithTag(1) as? UIImageView
        let name = cell.viewWithTag(2) as? UILabel
        
        image?.image = offers[indexPath.row].imgItem
        name?.text = offers[indexPath.row].title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (Constants.kScreenWidth - 50)/4
        return CGSize(width: width, height: width+35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = Constants.KOrderStoryboard.instantiateViewController(identifier: "OfferListVC") as OfferListVC
        vc.offer = offers[indexPath.row]
        vc.productID = productID
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
