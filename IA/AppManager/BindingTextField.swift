//
//  BindingTextBox.swift
//  Headlines
//
//  Created by Mohammad Azam on 10/20/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit


class BindingTextField : DTTextField {
    
    var textChanged :(String) -> () = { _ in }
 //   var padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 5)

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.floatingDisplayStatus = .never
    }
    
    func bind(callback :@escaping (String) -> ()) {
        
        self.textChanged = callback
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField :UITextField) {
        self.textChanged(textField.text!)
    }

  /*  override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    */
    @IBInspectable var rightImage : UIImage? {
        didSet {
            if let image = rightImage {
                rightViewMode = .always
                let imageView = UIImageView(frame: CGRect(x: -8, y: 7, width: 15, height: 15))
                imageView.image = image
                imageView.contentMode = .center
                imageView.tintColor = tintColor
                let view = UIView(frame : CGRect(x: -8, y: 7, width: 15, height: 15))
                view.addSubview(imageView)
                rightView = view
                rightView?.isUserInteractionEnabled = false
            } else {
                rightViewMode = .never
            }
            
        }
    }
}


