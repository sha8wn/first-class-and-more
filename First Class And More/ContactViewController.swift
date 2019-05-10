//
//  NewsletterViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 12/4/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

extension UIColor {
    static var placeholderGray: UIColor {
        return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    }
}

class ContactViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderContainer: UIView!
    @IBOutlet weak var manRadioBtn: DLRadioButton!
    @IBOutlet weak var womenRadioBtn: DLRadioButton!
    @IBOutlet weak var nameContainer: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameContainer: UIView!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var subjectContainer: UIView!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    
    fileprivate var email: String?
    fileprivate var genderTitle: String?
    fileprivate var name: String?
    fileprivate var surname: String?
    fileprivate var subject: String?
    fileprivate var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textFieldsLayers = [emailTextField.layer,
                               nameTextField.layer,
                               surnameTextField.layer,
                               subjectTextField.layer,
                               messageTextView.layer]
        let containersLayers = [emailContainer.layer,
                                nameContainer.layer,
                                surnameContainer.layer,
                                subjectContainer.layer,
                                messageContainer.layer]
        textFieldsLayers.forEach { $0.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0) }
        containersLayers.forEach { (layer) in
            layer.cornerRadius = 32.0 / 2
            layer.borderColor  = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1).cgColor
            layer.borderWidth  = 1.0
        }
        
        setTextViewPlaceholder()
        
        if UserModel.sharedInstance.logined {
            stackView.removeArrangedSubview(emailContainer)
            emailContainer.removeFromSuperview()
            stackView.removeArrangedSubview(genderContainer)
            genderContainer.removeFromSuperview()
            stackView.removeArrangedSubview(nameContainer)
            nameContainer.removeFromSuperview()
            stackView.removeArrangedSubview(surnameContainer)
            surnameContainer.removeFromSuperview()
        }
    }
    
    private func setTextViewPlaceholder() {
        messageTextView.text = "Ihre Nachricht"
        messageTextView.textColor = UIColor.placeholderGray
    }
    
    @IBAction func manRadioButtonPressed() {
        self.genderTitle = self.manRadioBtn.title(for: .normal)
        self.womenRadioBtn.isSelected = false
    }
    
    @IBAction func womanRadioButtonPressed() {
        self.genderTitle = self.womenRadioBtn.title(for: .normal)
        self.manRadioBtn.isSelected = false
    }
    
    @IBAction func sendBtnPressed() {
        let isLoggedIn = UserModel.sharedInstance.logined
        if isLoggedIn {
            name = UserModel.sharedInstance.name
            surname = UserModel.sharedInstance.surname
            email = UserModel.sharedInstance.email
        }
        let isEmailEmpty = (message?.isEmpty ?? true)
        let isNameEmpty = (name?.isEmpty ?? true)
        let isSurnameEmpty = (surname?.isEmpty ?? true)
        let isSubjectEmpty = (subject?.isEmpty ?? true)
        let isMessageEmpty = (message?.isEmpty ?? true)
        
        let isFormFilled = !isEmailEmpty && !isNameEmpty && !isSurnameEmpty && !isSubjectEmpty && !isMessageEmpty
        
        if !isFormFilled {
            showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Füllen Sie alle notwendigen Felder aus!", cancelBtn: false)
            return
        }
        
        if !isLoggedIn {
            let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailRegEx = NSPredicate(format: "SELF MATCHES %@", regEx)
            let emaiIsValid = emailRegEx.evaluate(with: email)
            if !emaiIsValid {
                showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Ungültige E-Mail-Adresse!", cancelBtn: false)
                return
            }
        }
        
        startLoading()
        if isConnectedToNetwork(repeatedFunction: sendBtnPressed) {
            Server.shared.sendMessage(email: email ?? "", title: genderTitle ?? "", name: name ?? "", surname: surname ?? "", subject: subject ?? "", message: message ?? "") { (answer, error) in
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

extension ContactViewController: UITextFieldDelegate, UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            nameTextField.becomeFirstResponder()
        } else if textField == nameTextField {
            surnameTextField.becomeFirstResponder()
        } else if textField == surnameTextField {
            subjectTextField.becomeFirstResponder()
        } else if textField == subjectTextField {
            messageTextView.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if textField == emailTextField {
            email = text
        } else if textField == nameTextField {
            name = text
        } else if textField == surnameTextField {
            surname = text
        } else if textField == subjectTextField {
            subject = text
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholderGray {
            textView.text = nil
            textView.textColor = #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setTextViewPlaceholder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let text = (textView.text as NSString?)?.replacingCharacters(in: range, with: text) ?? ""
        message = text
        return true
    }
}
