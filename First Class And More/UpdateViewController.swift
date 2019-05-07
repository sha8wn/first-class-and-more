//
//  UpdateViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 10/22/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController {
    
    @IBOutlet weak var shadowView: UIView!

    @IBOutlet weak var updateBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = 3.0
        shadowView.layer.shadowOpacity = 0.6
        
        let attributedTitle = NSMutableAttributedString(string: "Hier App aktualisieren")
        attributedTitle.addAttributes([
            .font: UIFont(name: "Roboto-Light", size: 14.0)!,
            .foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ], range: NSRange(location: 0, length: attributedTitle.length))
        updateBtn.setAttributedTitle(attributedTitle, for: .normal)
        updateBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        updateBtn.titleLabel?.minimumScaleFactor = 0.7
    }

    @IBAction func updateBtnPressed() {
        if let url = URL(string: "itms-apps://itunes.apple.com/ua/app/vlc-for-mobile/id650377962?mt=8"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
