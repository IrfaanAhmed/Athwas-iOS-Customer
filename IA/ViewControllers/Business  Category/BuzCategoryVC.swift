//
//  CategoryVC.swift
//  IA
//
//  Created by Yogesh Raj on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import SDWebImage


class BuzCategoryVC: BaseClassVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Variables
    var isMenu = false
    var catArray: [BusinessCatDataModel] = []
    let viewModel = BuzCategoryViewModel(dataService: ApiClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupUI()
        self.fetchBuisnessCategory()
    }
    
    func setupUI() {
        self.headerTitle.text = "Shop by Category"
        self.backBtn.isHidden = false
        if isMenu {
            self.menuBtn.isHidden = false
            self.backBtn.isHidden = true
        }
    }
    
    // MARK: - getBuisnessCategoryAPI
    private func fetchBuisnessCategory() {
        
        viewModel.fetchRequestData(URLMethods.getBusinessCategory, param: [:])
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.catArray.append(contentsOf: self.viewModel.businessCategory!)
            self.collectionView.reloadData()
            print("Success")
        }
        
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


extension BuzCategoryVC: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catArray.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath as IndexPath)
        
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let image = cell.viewWithTag(1) as? UIImageView
        let name = cell.viewWithTag(2) as? UILabel
        
        let data = catArray[indexPath.row]
        
        name?.text = data.name
        image!.sd_setImage(with: URL(string: data.categoryImageThumbURL), placeholderImage: UIImage(named: ""))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (Constants.kScreenWidth - 60)/4
        return CGSize(width: width, height: 105)
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let data = catArray[indexPath.row]
        self.navigateToSubCategory(Id: data.id, name: data.name)
        
    }
    
    func navigateToSubCategory(Id: String, name: String) {
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "CategoryVC") as CategoryVC
        vc.categoryId = Id
        vc.categoryName = name
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
