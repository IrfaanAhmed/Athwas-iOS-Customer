//
//  FilterVC.swift
//  IA
//
//  Created by admin on 16/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

struct Filter {
    
    public var priceMin : String?
    public var priceMax : String?
    public var rating : String?
    public var brandId : String?
    public var brandName : String?
    public var catName : String?
    public var catId : String?
    public var subCatId : String?
    public var subCatName : String?
    public var selectedFilter : [[String: [String]]]?
}

class FilterVC: UIViewController {
    
    @IBOutlet weak var viewRadius: UIView!
    @IBOutlet weak var txtMax: UITextField!
    @IBOutlet weak var txtMin: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtSubCategory: UITextField!
    @IBOutlet weak var txtBrand: UITextField!
    @IBOutlet weak var ratingStackView1 : UIStackView!
    @IBOutlet weak var ratingStackView2 : UIStackView!
    @IBOutlet weak var btnCustomization : UIButton!
    
    var catData: [ProductCategoryDataModel] = []
    let viewModelCat = CategoryViewModel(dataService: ApiClient())
    
    var productObject = ProductCategoryDataModel()
    var catObject = ProductCategoryDataModel()
    
    let viewModelBrand = BrandViewModel(dataService: ApiClient())
    var brandData : [BrandDataModel] = []
    
    var filterObject = Filter(priceMin: "", priceMax: "", rating: "", brandId: "", brandName: "", catName: "", catId: "", subCatId: "", subCatName: "")
    
    var activeField = UITextField()
    var callback : ((Filter) -> Void)?
    var rating = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPickerView()
        txtCategory.LeftView(of: nil)
        txtSubCategory.LeftView(of: nil)
        txtBrand.LeftView(of: nil)
        
        txtCategory.RightViewImage(#imageLiteral(resourceName: "list_drop_arrow"))
        txtSubCategory.RightViewImage(#imageLiteral(resourceName: "list_drop_arrow"))
        txtBrand.RightViewImage(#imageLiteral(resourceName: "list_drop_arrow"))
        
        txtMin.text = filterObject.priceMin
        txtMax.text = filterObject.priceMax
        txtCategory.text = filterObject.catName
        txtSubCategory.text = filterObject.subCatName
        txtBrand.text = filterObject.brandName
        
        let buttons1 : [UIButton] = ratingStackView1.subviews.compactMap{ $0 as? UIButton }
        let buttons2 : [UIButton] = ratingStackView2.subviews.compactMap{ $0 as? UIButton }
        let buttons = buttons1 + buttons2
        
        let index = Int.convertToInt(anyValue: filterObject.rating as Any)
        if index >= 0 {
            btnSelectRating(buttons[index])
        }
        fetchCategory()
        
        if filterObject.selectedFilter == nil || filterObject.selectedFilter == [] {
            self.btnCustomization.setTitle("Customization", for: .normal)
        }
        else {
            self.btnCustomization.setTitle("Customization Applied", for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        viewRadius.roundCorners(corners: [.topLeft, .topRight], radius: 35.0)
    }
    
    
    private func fetchCategory() {
        
        let param = ["business_category_id" : productObject.businessCategoryID?.id ?? ""] as [String : Any]
        viewModelCat.fetchRequestData(URLMethods.getCategory, param: param)
        viewModelCat.showAlertClosure = {
            if let error = self.viewModelCat.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModelCat.didFinishFetch = {
            self.catData = self.viewModelCat.businessCategory ?? []
            self.myPickerView.reloadAllComponents()
            let filtered = self.catData.filter({ $0.id == self.filterObject.catId})
            if filtered.count > 0 {
                self.catObject = filtered[0]
                self.filterObject.catName = filtered[0].name
                self.filterObject.catId = filtered[0].id
                self.txtCategory.text = filtered[0].name
            }
        }
    }
    
    private func fetchSubCategory() {
        
        let param = ["business_category_id" : productObject.businessCategoryID?.id ?? "",
                     "category_id" : (catObject.id != nil || catObject.id != "") ? catObject.id ?? "" : filterObject.catId ?? ""
        ] as [String : Any]
        
        viewModelCat.fetchRequestData(URLMethods.getSubCategory, param: param)
        viewModelCat.showAlertClosure = {
            if let error = self.viewModelCat.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModelCat.didFinishFetch = {
            self.catData = self.viewModelCat.businessCategory ?? []
            if self.catData.count == 0 {
                self.txtSubCategory.resignFirstResponder()
            }
            self.myPickerView.reloadAllComponents()
            print("Success")
        }
        
    }
    
    
    private func fetchBrands() {
        
        viewModelBrand.fetchRequestData(URLMethods.getBrands, param: [:])
        viewModelBrand.showAlertClosure = {
            if let error = self.viewModelBrand.error {
                print(error)
                AppManager.showToast(error)
            }
        }
        
        viewModelBrand.didFinishFetch = {
            self.brandData = self.viewModelBrand.brands ?? []
            self.myPickerView.reloadAllComponents()
            print("Success")
        }
        
    }
    
    
    
    
    //MARK:- Picker View
    
    var myPickerView = UIPickerView()
    
    func showPickerView() {
        
        myPickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        myPickerView.delegate = self
        myPickerView.dataSource = self
        myPickerView.backgroundColor = UIColor.appLightGrey
        txtCategory.inputView = myPickerView
        txtSubCategory.inputView = myPickerView
        txtBrand.inputView = myPickerView
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePickerView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPickerView))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtCategory.inputAccessoryView = toolBar
        txtSubCategory.inputAccessoryView = toolBar
        txtBrand.inputAccessoryView = toolBar
        
    }
    
    @objc func donePickerView() {
        self.view.endEditing(true)
        
        if activeField == txtCategory {
            activeField.text = catData[myPickerView.selectedRow(inComponent: 0)].name
            catObject = catData[myPickerView.selectedRow(inComponent: 0)]
            filterObject.catName = activeField.text
            filterObject.catId = catData[myPickerView.selectedRow(inComponent: 0)].id
            filterObject.subCatName = ""
            filterObject.subCatId = ""
            self.txtSubCategory.text = ""
        }
        else if activeField == txtSubCategory {
            activeField.text = catData[myPickerView.selectedRow(inComponent: 0)].name
            filterObject.subCatName = activeField.text
            filterObject.subCatId = catData[myPickerView.selectedRow(inComponent: 0)].id
        }
        else if activeField == txtBrand {
            activeField.text = brandData[myPickerView.selectedRow(inComponent: 0)].name
            filterObject.brandName = activeField.text
            filterObject.brandId = brandData[myPickerView.selectedRow(inComponent: 0)].id
        }
    }
    
    @objc func cancelPickerView() {
        self.view.endEditing(true)
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnReset(_ sender: Any) {
        
        filterObject = Filter(priceMin: "", priceMax: "", rating: "", brandId: "", brandName: "", catName: "", catId: "", subCatId: "", subCatName: "")
        filterObject.selectedFilter = []
        txtMax.text = ""
        txtMin.text = ""
        txtSubCategory.text = ""
        txtBrand.text = ""
        txtCategory.text = ""
        btnSelectRating(UIButton())
        self.btnCustomization.setTitle("Customization", for: .normal)
        callback!(Filter())
    }
    
    @IBAction func btnSelectRating(_ sender: UIButton) {
        
        let buttons1 : [UIButton] = ratingStackView1.subviews.compactMap{ $0 as? UIButton }
        let buttons2 : [UIButton] = ratingStackView2.subviews.compactMap{ $0 as? UIButton }
        let buttons = buttons1 + buttons2
        
        for btn in buttons {
            btn.isSelected = false
            btn.backgroundColor = .white
        }
        sender.isSelected = true
        sender.backgroundColor = UIColor.appDarkGreen
        rating = sender.tag
        print(rating)
    }
    
    @IBAction func btnCustomizationTap(_ sender: Any) {
        
        let vc: InnerFilterVC = InnerFilterVC(nibName: "InnerFilterVC", bundle: nil)
        vc.productObject = productObject
        vc.selectedIFilterItems = filterObject.selectedFilter ?? []
        vc.callback = {(filter) -> Void in
            self.filterObject.selectedFilter = filter
            self.btnCustomization.setTitle("Customization Applied", for: .normal)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnApply(_ sender: Any) {
        
        let minAmount:Int = (((txtMin.text?.isEmptyString()) == true) ? 0 : Int(txtMin.text ?? "0")!)
        let maxAmount:Int = (((txtMax.text?.isEmptyString()) == true) ? 0 : Int(txtMax.text ?? "0")!)
        
        if (txtMin.text?.isEmptyString() == false) && (txtMax.text?.isEmptyString() == false) {
            
            if maxAmount >= minAmount
            {
                setFilterValues()
            }
            else {
                AppManager.showToast("Max. price must be grater then min. price")
            }
        }
        else
        {
            setFilterValues()
        }
    }
    
    func setFilterValues() {
        
        filterObject.priceMin = txtMin.text
        filterObject.priceMax = txtMax.text
        filterObject.rating = String(rating)
        callback!(filterObject)
        self.dismiss(animated: true, completion: nil)
    }
}

extension FilterVC : UITextFieldDelegate {
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        if activeField == txtCategory {
            fetchCategory()
            return true
        }
        if activeField == txtSubCategory {
            if catObject.id != nil || filterObject.catId != nil {
                fetchSubCategory()
                return true
            }
            return false
        }
        if activeField == txtBrand {
            fetchBrands()
        }
        return true
    }
}

extension FilterVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activeField == txtBrand ? brandData.count : catData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activeField == txtBrand ? brandData[row].name : catData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.text = activeField == txtBrand ? brandData[row].name : catData[row].name
        label.textAlignment = .center
        label.font = UIFont.init(name: "Linotte Regular", size: 16.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }
}
