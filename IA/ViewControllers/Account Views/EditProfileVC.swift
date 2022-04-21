//
//  EditProfileVC.swift
//  Tivo
//
//  Created by admin on 08/07/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit
import Photos

class EditProfileVC: BaseClassVC, UITextFieldDelegate {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var lblNameError: UILabel!
    @IBOutlet weak var lblMobileError: UILabel!
    @IBOutlet weak var lblEmailError: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        txtName.text = Constants.kAppDelegate.user?.username
        txtPhone.text = Constants.kAppDelegate.user?.phone
        txtEmail.text = Constants.kAppDelegate.user?.email
        let imgURL = Constants.kAppDelegate.user?.userImageThumbURL
        imgUser.sd_setImage(with: URL(string: imgURL ?? ""), placeholderImage: #imageLiteral(resourceName: "user"))
        
    }
    
    func setupUI() {
        self.headerTitle.text = "Edit Profile"
        self.backBtn.isHidden = false
        self.searchBtn.isHidden = true
        self.cartBtn.isHidden = true
    }
    
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNameEdit(_ sender: Any) {
        
        let trimmedString = txtName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        txtName.text = trimmedString
        
        guard txtName.text?.count ?? 0 > 2 else {
       //     AppManager.showAlert(Constants.KAppName, AppString.msgNameLength, view: self)
            lblNameError.text = AppString.msgNameLength
            return
        }
        updateProfile("username", value: txtName.text!)
        
    }
    
    @IBAction func btnMobileEdit(_ sender: Any) {
        
        guard txtPhone.text?.count == 10 else {
     //       AppManager.showAlert(Constants.KAppName, AppString.msgVaildPhone, view: self)
            lblMobileError.text = AppString.msgVaildPhone
            return
        }
        
        updateProfile("new_phone", value: txtPhone.text!)
    }
    
    @IBAction func btnEmailEdit(_ sender: Any) {
        
        guard txtEmail.text!.count >= 9 else {
       //     AppManager.showAlert(Constants.KAppName, AppString.msgEmailLength, view: self)
            lblEmailError.text = AppString.msgEmailLength
            return
        }
        guard txtEmail.text?.validateEmail() ?? false else {
      //      AppManager.showAlert(Constants.KAppName, AppString.msgValidEmail, view: self)
            lblEmailError.text = AppString.msgValidEmail
            return
        }
       
        updateProfile("new_email", value: txtEmail.text!)
    }
    
    @IBAction func btnChangePassword(_ sender: Any) {
        let vc: ChangePassVC = ChangePassVC(nibName :"ChangePassVC",bundle : nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnChangePicture(_ sender: Any) {
        checkPhotoLibraryPermission()
    }
    
    
    func updateProfile(_ key : String, value : String) {
        
        let param : [String : Any] = [
            "field_key" : key,
            "field_value"  : value
        ]
        
        AppManager.startActivityIndicator()
        ApiClient().apiCallMethod(URLMethods.updateProfile, method: .post, parameter: param, successClosure: { (response) in
            AppManager.stopActivityIndicator()
            
            if key != "username" {
                
                let msg = (response as? NSDictionary)?.value(forKey: "message") as? String ?? ""
                
                AppManager.showAlert_withOneAction(Constants.KAppName, msg, self) { (success) in
                    
                    let data = (response as? NSDictionary)?.value(forKey: "data") as? [String : Any]
                    let vc: OtpVerifyVC = OtpVerifyVC(nibName :"OtpVerifyVC",bundle : nil)
                    vc.otpData = data ?? [:]
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                return
            }
            let msg = (response as? NSDictionary)?.value(forKey: "message") as? String
            AppManager.showToast(msg ?? "")
            
        }) { (error) in
            AppManager.stopActivityIndicator()
            AppManager.showToast(error ?? "")
        }
    }
    
    
    //MARK:- Check Permission & Open gallery
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.uploadPhotos()
            break
        case .denied, .restricted: break
        //    AlertController.showAlert(AppName, "This app does not have access to your gallery or camera.\n You can enable access in Privacy Setting".localized(), view: self)
        case .notDetermined:
            print("Permission not determined")
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    self.uploadPhotos()
                    break
                // as above
                case .denied, .restricted: break
                //      AlertController.showAlert(AppName, "This app does not have access to your gallery or camera.\n You can enable access in Privacy Setting".localized(), view: self)
                case .notDetermined:break
                @unknown default:
                    break
                }
            }
        @unknown default:
            break
        }
    }
    
    func uploadPhotos()  {
        
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            let alert = UIAlertController.init(title: "Select Photo", message: "", preferredStyle: .actionSheet)
            
            let galleryAction = UIAlertAction.init(title: "Gallery", style: .default) { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            alert.addAction(galleryAction)
            
            let cameraAction = UIAlertAction.init(title: "Camera", style: .default) { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            alert.addAction(cameraAction)
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK:- TextField Delegate
    
    let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtName {
            lblNameError.text = ""
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            
            return (string == filtered)
        } else if textField == txtPhone {
            lblMobileError.text = ""
        } else if textField == txtEmail {
            lblEmailError.text = ""
        }
       return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtName {
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            txtName.text = trimmedString
        }
    }
    
}

extension EditProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let choosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgUser.image = choosenImage
            
            ApiClient().api_MultipartData(URLMethods.updateProfile, imageData: ["field_value" : choosenImage], parameter: ["field_key" : "user_image"], successClosure: { (response) in
                
            }) { (error) in
                AppManager.showToast(error ?? "")
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
