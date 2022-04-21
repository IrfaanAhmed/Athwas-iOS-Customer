//
//  AboutProduct.swift
//  IA
//
//  Created by admin on 15/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit

class AboutProductCell: UITableViewCell {
    
    @IBOutlet weak var lblDes : UILabel!
    
    var cellData : ProductDetailModel? {
        didSet {
           // lblDes.attributedText = cellData?.productDetailModelDescription?.htmlToAttributedString
            lblDes.setHTMLFromString(htmlText: cellData?.productDetailModelDescription ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension UILabel {
    func setHTMLFromString(htmlText: String) {
        
     //   let fontSize = self.font!.pointSize >= 12.0 ? self.font!.pointSize : 12.0
        let modifiedFont = String(format:"<span style=\"font-family: 'Futura-Medium'; color: #555555; font-size: \(13.0)\">%@</span>", htmlText)

        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
            documentAttributes: nil)

        self.attributedText = attrStr
    }
}
