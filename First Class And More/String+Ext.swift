//
//  String+Ext.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/21/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

extension String {
    var md5: String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest  = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: .utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format: "%02x", byte)
        }
        return hexString
    }
    
    func date(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT +0:00")
        return dateFormatter.date(from: self)
    }
    
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
	
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
	
	var isValidEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: self)
	}
    
    func size(withConstrainedWidth width: CGFloat = .greatestFiniteMagnitude, withConstrainedHeight height: CGFloat = .greatestFiniteMagnitude, font: UIFont, numberOfLines: Int = 1) -> CGSize {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = self
        label.sizeToFit()
        return label.frame.size
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "RobotoCondensed-Bold", size: 13)!,
            .foregroundColor: #colorLiteral(red: 0, green: 0.3775922954, blue: 0.6005169749, alpha: 1)
        ]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }

    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "RobotoCondensed-Regular", size: 13)!,
            .foregroundColor: #colorLiteral(red: 0, green: 0.3775922954, blue: 0.6005169749, alpha: 1)
        ]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
