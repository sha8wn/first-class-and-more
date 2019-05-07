//
//  NewsletterViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 12/4/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class NewsletterViewController: UIViewController {

    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var maleBtn: DLRadioButton!
    @IBOutlet weak var femaleBtn: DLRadioButton!
    
    fileprivate var email: String?
    fileprivate var name: String?
    private var gender: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        emailContainer.layer.cornerRadius = 32.0 / 2
        emailContainer.layer.borderColor  = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1).cgColor
        emailContainer.layer.borderWidth  = 1.0
        nameContainer.layer.cornerRadius = 32.0 / 2
        nameContainer.layer.borderColor  = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1).cgColor
        nameContainer.layer.borderWidth  = 1.0
    }
    
    @IBAction func maleBtnPressed(_ sender: DLRadioButton) {
        maleBtn.isSelected = true
        femaleBtn.isSelected = false
        gender = 1
    }
    
    @IBAction func femaleBtnPressed(_ sender: DLRadioButton) {
        femaleBtn.isSelected = true
        maleBtn.isSelected = false
        gender = 2
    }
    
    @IBAction func subscribeBtnPressed() {
        guard let email = email, let name = name, !email.isEmpty, !name.isEmpty, gender != -1 else {
            showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Füllen Sie alle notwendigen Felder aus!", cancelBtn: false)
            return
        }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailRegEx = NSPredicate(format: "SELF MATCHES %@", regEx)
        let emaiIsValid = emailRegEx.evaluate(with: email)
        if !emaiIsValid {
            showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Ungültige E-Mail-Adresse!", cancelBtn: false)
            return
        }
        startLoading()
        if isConnectedToNetwork(repeatedFunction: subscribeBtnPressed) {
            Server.shared.subscribeNewsletter(email, name: name, gender: gender) { answer, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else if let success = answer as? Bool, success {
                        self.showPopupDialog(title: "Erfolg!", cancelBtn: false, okBtnCompletion: {
                            self.closeBtnPressed()
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func closeBtnPressed() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewsletterViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            nameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if textField == emailTextField {
            email = text
        } else {
            name = text
        }
        return true
    }
}
