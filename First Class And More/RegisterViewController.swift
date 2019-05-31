//
//  RegisterViewController.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 9/24/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var newUserView: UIView!

    @IBOutlet weak var manRadioBtn: DLRadioButton!

    @IBOutlet weak var womenRadioBtn: DLRadioButton!

    @IBOutlet weak var surnameTextField: UITextField!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var newsLetterYesBtn: UIButton!

    @IBOutlet weak var newsLetterNoBtn: UIButton!

    @IBOutlet weak var newsLetterUserView: UIView!

    @IBOutlet weak var newsLetterEmailTextField: UITextField!

    @IBOutlet weak var premiumUserView: UIView!

    @IBOutlet weak var premiumEmailTextField: UITextField!

    @IBOutlet weak var premiumPasswordTextField: UITextField!

    var type: RegisterType?

    var state: Int?
    var wantSubscribe: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    private func setupView() {
        guard let type = type else { return }
        switch type {
        case .new:
            newUserView.isHidden = false
        case .newsletter:
            newsLetterUserView.isHidden = false
        case .premium:
            premiumUserView.isHidden = false
        }

        newsLetterYesBtn.backgroundColor = #colorLiteral(red: 0.9313626885, green: 0.6842990518, blue: 0.1191969439, alpha: 1)
        newsLetterYesBtn.layer.cornerRadius = 5.0
        newsLetterYesBtn.layer.borderColor = #colorLiteral(red: 0.9294117647, green: 0.6823529412, blue: 0.1176470588, alpha: 1).cgColor
        newsLetterYesBtn.layer.borderWidth = 1.0
        newsLetterNoBtn.layer.cornerRadius = 5.0
        newsLetterNoBtn.layer.borderColor = #colorLiteral(red: 0.9313626885, green: 0.6842990518, blue: 0.1191969439, alpha: 1).cgColor
        newsLetterNoBtn.layer.borderWidth = 1.0

    }

    @IBAction func manRadioBtnPressed() {
        state = 1
        womenRadioBtn.isSelected = false
    }

    @IBAction func womenRadioBtnPressed() {
        state = 2
        manRadioBtn.isSelected = false
    }

    @IBAction func newsLetterYesBtnPressed() {
        wantSubscribe = true
        newsLetterYesBtn.backgroundColor = #colorLiteral(red: 0.9313626885, green: 0.6842990518, blue: 0.1191969439, alpha: 1)
        newsLetterNoBtn.backgroundColor = .clear
    }

    @IBAction func newsLetterNoBtnPressed() {
        wantSubscribe = false
        newsLetterNoBtn.backgroundColor = #colorLiteral(red: 0.9313626885, green: 0.6842990518, blue: 0.1191969439, alpha: 1)
        newsLetterYesBtn.backgroundColor = .clear
    }

    @IBAction func registerBtnPressed() {
        guard let state = state else {
            showPopupDialog(title: String(.errorOccured), message: String(.selectGender), cancelBtn: false)
            return
        }
		guard let surname = surnameTextField.text, !surname.isEmpty else {
			showPopupDialog(title: String(.errorOccured), message: String(.emptyName), cancelBtn: false)
			return
		}
		guard let email = emailTextField.text, !email.isEmpty else {
			showPopupDialog(title: String(.errorOccured), message: String(.emptyEmail), cancelBtn: false)
			return
		}
		guard email.isValidEmail else {
			showPopupDialog(title: String(.errorOccured), message: String(.invalidEmail), cancelBtn: false)
			return
		}
        if isConnectedToNetwork(repeatedFunction: registerBtnPressed) {
            startLoading(message: String(.loading))
            Server.shared.register(state: state, email: email, surname: surname, wantSubscribe: wantSubscribe) { success, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    
                    if let error = error {
                        switch error {
                        case .alreadySubscribe:
                            self.showPopupDialog(title: "Sie sind bereits für den Newsletter registriert.", message: error.description, cancelBtn: false) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        default:
                            self.showPopupDialog(title: String(.errorOccured), message: error.description, cancelBtn: false)
                        }
                    }
                    else {
                        if let success = success as? Bool, success {
                            let title = "Herzlich willkommen bei der First Class & More App!"
                            let message = "Wenn Sie erfahren möchten, wie die App genau funktioniert, dann wählen Sie im Menü bitte da Tutorial aus."
                            self.showPopupDialog(title: title, message: message) {
                                self.performSegue(withIdentifier: "showHome", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func signInBtnPressed() {
        guard let email = newsLetterEmailTextField.text else { return }
		
        if email.isEmpty {
            showPopupDialog(title: String(.errorOccured), message: String(.emptyEmail), cancelBtn: false)
            return
        }
		if !email.isValidEmail {
			showPopupDialog(title: String(.errorOccured), message: String(.invalidEmail), cancelBtn: false)
			return
		}
        if isConnectedToNetwork(repeatedFunction: loginBtnPressed) {
            startLoading(message: String(.loading))
            Server.shared.checkSubscriber(email: email) { isSubscribed, error in
                DispatchQueue.main.async {
                    self.stopLoading()
					if let error = error {
						self.showPopupDialog(title: String(.errorOccured), message: error.description, cancelBtn: false)
						return
					}
					if let isSubscribed = isSubscribed as? Bool, isSubscribed {
						self.performSegue(withIdentifier: "showHome", sender: nil)
					}
					else {
						self.showPopupDialog(title: String(.errorOccured), message: String(.notSubscriber), cancelBtn: false)
					}
                }
            }
        }
    }

    @IBAction func loginBtnPressed() {
        guard let email = premiumEmailTextField.text, let password = premiumPasswordTextField.text else { return }
        if email.isEmpty || password.isEmpty {
            let error = email.isEmpty ? String(.emptyEmail) : String(.emptyPassword)
            showPopupDialog(title: String(.errorOccured), message: error, cancelBtn: false)
            return
        }
        if isConnectedToNetwork(repeatedFunction: loginBtnPressed) {
            startLoading(message: String(.loading))
            Server.shared.getPasswordSalt(email: email) { salt, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.stopLoading()
                        self.showPopupDialog(title: String(.errorOccured), message: "E-Mail-Adresse ist unbekannt.", cancelBtn: false)
                    } else {
                        if let salt = salt as? String {
                            self.performLogin(email: email, password: password, salt: salt)
                        }
                    }
                }
            }
        }
    }

    func performLogin(email: String, password: String, salt: String) {
        if isConnectedToNetwork(repeatedFunction: loginBtnPressed) {
            Server.shared.login(email: email, password: password, salt: salt) { success, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.stopLoading()
                        self.showPopupDialog(title: String(.errorOccured), message: "Das Passwort ist inkorrekt")
                    } else {
                        if let success = success as? Bool, success {
                            self.getUserInfo()
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            }
        }
    }

    func getUserInfo() {
        if isConnectedToNetwork(repeatedFunction: getUserInfo) {
            Server.shared.getSettings() { success, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        self.showPopupDialog(title: String(.errorOccured), message: error!.description)
                    } else {
                        if let success = success as? Bool, success {
                            UserDefaults.standard.set(true, forKey: kUDUserRegistered)
                            self.performSegue(withIdentifier: "showHome", sender: nil)
                        }
                    }
                }
            }
        }
    }

    @IBAction func closeBtnPressed() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
