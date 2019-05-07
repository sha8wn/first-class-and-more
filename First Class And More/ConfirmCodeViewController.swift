//
//  ConfirmCodeViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 10/12/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

protocol ConfirmCodeDelegate {
    func showAuthDialog(email: String?)
    func updateFilters()
}

class ConfirmCodeViewController: UIViewController {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var code: String?
    var email: String?
    var delegate: ConfirmCodeDelegate?
    var labels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        if let email = email {
            subtitleLabel.text = "\(subtitleLabel.text ?? "")\n\(email)"
        }
        if let code = code {
            let viewWidth: CGFloat = UIScreen.main.bounds.width - 14.0 * 2
            for i in 0 ..< code.count {
                let x = (viewWidth - CGFloat(code.count) * 28.0 - CGFloat(code.count - 1) * 8.0) / 2 + CGFloat(i) * 28.0 + CGFloat(i) * 8.0
                let label = UILabel(frame: CGRect(x: x, y: 0, width: 28.0, height: 32.0))
                label.layer.borderWidth = 1.0
                label.layer.borderColor = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1).cgColor
                label.clipsToBounds = true
                label.textColor = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1)
                label.textAlignment = .center
                label.font = UIFont(name: "RobotoCondensed-Regular", size: 16.0)
                labels.append(label)
                containerView.addSubview(label)
            }
        }
    }
    
    @IBAction func digitBtnPressed(_ sender: UIButton) {
        if let digit = sender.title(for: .normal) {
            if let label = labels.filter({ ($0.text ?? "").isEmpty }).first {
                label.text = digit
            }            
            if labels.filter({ ($0.text ?? "").isEmpty }).isEmpty, let code = code {
                let userCode = labels.map({ $0.text ?? "" }).joined()
                if userCode == code {
                    let user = UserModel.sharedInstance
                    user.unlockedFilters = true
                    let data = NSKeyedArchiver.archivedData(withRootObject: user)
                    let defaults = UserDefaults.standard
                    defaults.set(data, forKey: kUDSharedUserModel)
                    defaults.synchronize()
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.updateFilters()
                } else {
                    showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Fehlerhafter Code!", cancelBtn: false)
                }
            }
        }
    }
    
    @IBAction func deleteBtnPressed() {
        if let label = labels.filter({ !($0.text ?? "").isEmpty }).last {
            label.text = String((label.text ?? "").dropLast())
        }
    }
    
    @IBAction func backBtnPressed() {
        dismiss(animated: true, completion: nil)
        delegate?.showAuthDialog(email: email)
    }
    
    @IBAction func closeBtnPressed() {
        dismiss(animated: true, completion: nil)
    }
}
