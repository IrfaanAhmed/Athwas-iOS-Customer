//
//  CustomizationVC.swift
//  IA
//
//  Created by admin on 17/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class CustomizationVC: UIViewController {
    
    @IBOutlet weak var collectionViewCustom: UICollectionView!
    @IBOutlet weak var viewBg: UIView!
    let viewModel = CustomizationViewModel(dataService: ApiClient())
    var customizeList : [CustomizationListModel] = []
    var productID = ""
    var callback : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CustomizedCell", bundle: nil)
        collectionViewCustom.register(nib, forCellWithReuseIdentifier: "cellCustomise")
        fetchCustomizedProducts()
        
    }
    
    override func viewDidLayoutSubviews() {
        viewBg.roundCorners(corners: [.topLeft, .topRight], radius: 30.0)
    }
    
    private func fetchCustomizedProducts() {
        
        let param = ["main_product_id" : productID] as [String : Any]
        
        viewModel.fetchRequestData(URLMethods.customiationList, param: param)
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModel.didFinishFetch = {
            self.customizeList = self.viewModel.products!
            self.collectionViewCustom.reloadData()
        }
        
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnDone(_ sender: Any) {
        
        let filtered = customizeList.filter({ $0.isSelected == true})
        if filtered.count > 0 {
            callback?(filtered[0].id ?? "")
        }
        self.dismiss(animated: true, completion: nil)
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

extension CustomizationVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customizeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCustomise", for: indexPath) as! CustomizedCell
        cell.data = customizeList[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 145.0, height: 75.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0..<customizeList.count {
            customizeList[i].isSelected = false
        }
        customizeList[indexPath.row].isSelected = true
        collectionView.reloadData()
    }
    
}
