//
//  FullScreenCardViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 12/27/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class FullScreenCardViewController: UIViewController {

    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardImageViewHeight: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = UserModel.sharedInstance
        let image = user.membership.bigImage
        let userInfo = "\(user.name) \(user.surname)\n\(user.membershipExpires.date(format: "yyyy-MM-dd")?.string(format: "MM/yyyy") ?? "")".uppercased()
        let imageHeight = UIScreen.main.bounds.width - 16.0 * 2
        if let image = image {
            let yValue = image.size.height - userInfo.size(font: UIFont(name: "RobotoCondensed-Regular", size: 30.0)!, numberOfLines: 2).height - image.size.height * 0.08
            cardImageView.image = userInfo.draw(in: image, at: CGPoint(x: image.size.height * 0.08, y: yValue))
        }
        cardImageView.transform = CGAffineTransform(rotationAngle: 90.0 * CGFloat.pi / 180.0)
        cardImageViewHeight.constant = imageHeight
    }
    
    @IBAction func closeBtnPressed() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restartTimer()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension String {
    func draw(in image: UIImage, at point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "RobotoCondensed-Regular", size: 30.0)!
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let rect = CGRect(origin: point, size: image.size)
        (self as NSString).draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
