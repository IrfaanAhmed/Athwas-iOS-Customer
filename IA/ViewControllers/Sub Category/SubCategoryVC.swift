//
//  SubCategoryVC.swift
//  IA
//
//  Created by Yogesh Raj on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class SubCategoryVC: BaseClassVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Variable
    var catObject = ProductCategoryDataModel()
    var subCatArray : [ProductCategoryDataModel] = []
    let viewModel = CategoryViewModel(dataService: ApiClient())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupUI()
        self.fetchSubCategory()
    }
    
    func setupUI() {
        self.headerTitle.text = catObject.name
        self.backBtn.isHidden = false
    }
    
    // MARK: - getBuisnessCategoryAPI
    private func fetchSubCategory() {
        
        
        let param = ["business_category_id" : catObject.businessCategoryID?.id ?? "",
                     "category_id" : catObject.id ?? ""
            ] as [String : Any]
        viewModel.fetchRequestData(URLMethods.getSubCategory, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.subCatArray.append(contentsOf: self.viewModel.businessCategory!)
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

extension SubCategoryVC: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = subCatArray.count
        collectionView.setBackgroundMessage(rows == 0 ? "No Products" : nil)
        return rows
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath as IndexPath)
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let image = cell.viewWithTag(1) as? UIImageView
        let name = cell.viewWithTag(2) as? UILabel
        
        let data = subCatArray[indexPath.row]
        
        name?.text = data.name
        image!.sd_setImage(with: URL(string: data.imagePathThumbURL ?? ""), placeholderImage: UIImage(named: ""))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (Constants.kScreenWidth - 50)/3
        // In this function is the code you must implement to your code project if you want to change size of Collection view
        return CGSize(width: width, height: width+35)
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        //  self.navigateToProduct(listType: productListType.category.rawValue)
        let vc = Constants.KHomeStoryboard.instantiateViewController(identifier: "ProductVC") as ProductVC
        vc.productObject = subCatArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
