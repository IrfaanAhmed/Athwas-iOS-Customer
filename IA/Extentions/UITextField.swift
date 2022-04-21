//
//  UITextField.swift
//  HPM
//
//  Created by mac-110 on 27/06/18.
//  Copyright © 2018 octal-mac. All rights reserved.
//

import UIKit
import Foundation

private var kAssociationKeyMaxLength: Int = 0

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
    
    public func LeftView(of image: UIImage?) {
        
        //setting left image
        if(image == nil)
        {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            self.leftView = paddingView
        }
        else
        {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            if let image = image {
                let paddingImage = UIImageView()
                paddingImage.image = image
                paddingImage.contentMode = .left
                paddingImage.frame = CGRect(x: 8, y: 0, width: 18, height: 40)
                paddingView.addSubview(paddingImage)
            }
            self.leftView = paddingView
        }
        self.leftView?.isUserInteractionEnabled = false
        self.leftViewMode = UITextField.ViewMode.always
        
        
    }
    
    public func RightViewImage(_ textFieldImg: UIImage?) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        if let image = textFieldImg {
            let paddingImage = UIImageView()
            paddingImage.image = image
            paddingImage.contentMode = .center
            paddingImage.frame = CGRect(x: 0, y: 6, width: 10, height: 10)
            paddingView.addSubview(paddingImage)
        }
        self.rightView = paddingView
        self.rightView?.isUserInteractionEnabled = false
        self.rightViewMode = UITextField.ViewMode.always
    }
    
    public func showBottomLine(color: UIColor) {
        
        let line = UIView(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 1.0))
        line.backgroundColor = color
        self.addSubview(line)
    }
    
    public func appTextFiled() {
        
        layer.cornerRadius = 8.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0.5
        backgroundColor = .white
        LeftView(of: nil)
    }
    public func appTextClear() {
        
        layer.cornerRadius = 8.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        backgroundColor = .clear
        LeftView(of: nil)
    }
    
    public func appSearchBar(image:UIImage!) {
        
        layer.cornerRadius = 8
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        LeftView(of: image)
    }
    
}

