//
//  UnlockFIltersViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 10/11/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

protocol UnlockFiltersDelegate {
    func showConfirmCodeDialog(code: String, email: String)
    func updateFilters()
}

class UnlockFIltersViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    var delegate: UnlockFiltersDelegate?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        emailTextField.text = email
        emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        containerView.layer.cornerRadius = 32.0 / 2
        containerView.layer.borderColor  = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1).cgColor
        containerView.layer.borderWidth  = 1.0
    }
    
    @IBAction func subscribeBtnPressed() {
        let email = emailTextField.text ?? ""
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailRegEx = NSPredicate(format: "SELF MATCHES %@", regEx)
        let emaiIsValid = emailRegEx.evaluate(with: email)
        if !email.isEmpty && emaiIsValid {
            view.endEditing(true)
            startLoading()
            Server.shared.subscribe(email: email) { value, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else if let code = value as? String {
                        if code != "success" {
                            self.dismiss(animated: true, completion: nil)
                            self.delegate?.showConfirmCodeDialog(code: code, email: email)
                        } else {
                            let user = UserModel.sharedInstance
                            user.unlockedFilters = true
                            let data = NSKeyedArchiver.archivedData(withRootObject: user)
                            let defaults = UserDefaults.standard
                            defaults.set(data, forKey: kUDSharedUserModel)
                            defaults.synchronize()
                            self.dismiss(animated: true, completion: nil)
                            self.delegate?.updateFilters()
                        }
                    }
                }
            }
        } else {
            showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Ungültige E-Mail- Adresse!", cancelBtn: false)
        }
    }
    
    @IBAction func closeBtnPressed() {
        dismiss(animated: true, completion: nil)
    }
}

extension UnlockFIltersViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
