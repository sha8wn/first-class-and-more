//
//  NewsletterViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 12/4/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import WebKit

class NewsletterViewController: UIViewController {

    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet private weak var textView: UITextView!
    
    fileprivate var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        emailContainer.layer.cornerRadius = 32.0 / 2
        emailContainer.layer.borderColor  = #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1).cgColor
        emailContainer.layer.borderWidth  = 1.0
        
        let attributedString = NSMutableAttributedString(string: "Mit dem Klick auf \"Abonnieren\" stimmen Sie unseren ")
        attributedString.append(
            NSAttributedString(string: "AGB",
                               attributes: [.link: URL(string: "https://www.first-class-and-more.de/agb/")!])
        )
        attributedString.append(NSAttributedString(string: " zu und nehmen unsere "))
        attributedString.append(
            NSAttributedString(string: "Datenschutzbestimmungen",
                               attributes: [.link: URL(string: "https://www.first-class-and-more.de/datenschutz/")!])
        )
        attributedString.append(NSAttributedString(string: " zur Kenntnis."))
        
        let font = UIFont(name: "RobotoCondensed-Regular", size: 13)!
        let range = NSRange(location: 0, length: attributedString.length - 1)
        attributedString.addAttributes(
            [.font:font,
             .foregroundColor: UIColor(red: 109/255, green: 110/255, blue: 113/255, alpha: 1.0)],
            range: range
        )
        
        self.textView.attributedText = attributedString
        self.textView.textAlignment = .center
    }
    
    @IBAction func subscribeBtnPressed() {
        guard let email = email, !email.isEmpty else {
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
            Server.shared.subscribeNewsletter(email) { answer, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        if error!.description == "Email Address already subscribe with us" {
                            self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "E-Mail-Adresse ist bereits registriert")
                        }
                        else {
                            self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                        }
                        
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
            emailTextField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if textField == emailTextField {
            email = text
        }
        return true
    }
}

extension NewsletterViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch url.absoluteString {
        case "https://www.first-class-and-more.de/agb/":
            FileProvider(viewController: self).open(.agb)
        case "https://www.first-class-and-more.de/datenschutz/":
            FileProvider(viewController: self).open(.datenschutz)
        default:
            break
        }
        return false
    }
    
}
