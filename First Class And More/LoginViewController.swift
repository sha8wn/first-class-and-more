//
//  LoginViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/15/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class LoginViewController: SFSidebarViewController {
    
    let screen = UIScreen.main.bounds
    lazy var actualViewHeight: CGFloat = {
        return self.screen.height - (self.navigationController?.navigationBar.frame.size.height ?? 0) -
            UIApplication.shared.statusBarFrame.size.height
    }()
    
    lazy var forgotPasswordVC: ForgotPasswordViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordViewController
    }()
    
    var logoImageView: UIImageView!
    var emailTextField: MKTextField!
    var passwordTextField: MKTextField!
    var loginBtn: UIButton!
    
    var currentTextField: MKTextField?
    var shouldReturn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        setupUI()
        // REMOVE LATER
        emailTextField.text = "jani2003@gmail.com"
        passwordTextField.text = "123456"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addHomeBtn()
    }
    
    override func homeBtnTapped() {
        shouldReturn = false
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            navigationVC.setViewControllers([navigationVC.homeVC], animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		loginBtn.layer.cornerRadius = loginBtn.frame.size.height / 2
		loginBtn.clipsToBounds = true
		passwordTextField.accesoryBtnRoundedCornerRadius = true
	}
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupUI() {
        view.backgroundColor = fcamBlue
        addLogoImageView()
        createEmailTextField()
        createPasswordTextField()
        addLoginBtn()
    }
    
    func addLogoImageView() {
		logoImageView = UIImageView(image: #imageLiteral(resourceName: "loginLogo"))
		logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
		
		NSLayoutConstraint.activate([
			logoImageView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: actualViewHeight * 0.18),
			logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.62),
			logoImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.62 / 12.18)
		])
    }
    
    func createEmailTextField() {
		emailTextField = MKTextField()
		emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.mkDelegate              = self
        emailTextField.textColor               = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        emailTextField.font                    = UIFont(name: "RobotoCondensed-Light", size: 24.0)!
        emailTextField.tintColor               = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        emailTextField.placeholder             = "E-mail"
        emailTextField.keyboardType            = .emailAddress
        emailTextField.returnKeyType           = .next
        emailTextField.correctionType          = .no
        emailTextField.capitalizationType      = .none
        emailTextField.highlighterDefaultColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5004676496)
        emailTextField.highlighterFocusedColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.addSubview(emailTextField)
		
		NSLayoutConstraint.activate([
			emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: actualViewHeight * 0.11),
			emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
			emailTextField.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.06)
			])
    }
    
    func createPasswordTextField() {
		passwordTextField = MKTextField(withAccessoryButton: true)
		passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.mkDelegate                     = self
        passwordTextField.font                           = UIFont(name: "RobotoCondensed-Light", size: 24.0)!
        passwordTextField.textColor                      = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        passwordTextField.tintColor                      = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        passwordTextField.placeholder                    = "Passwort"
        passwordTextField.accesoryBtnFont                = UIFont(name: "RobotoCondensed-Regular", size: 15.0)!
        passwordTextField.accesoryBtnTitle               = "?"
        passwordTextField.accesoryBtnTapped              = passwordAccesoryBtnTapped
        passwordTextField.isSecureTextEntry              = true
        passwordTextField.accesoryBtnTitleColor          = #colorLiteral(red: 0.8549019608, green: 0.6470588235, blue: 0.1215686275, alpha: 1)
        passwordTextField.accesoryBtnBorderColor         = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        passwordTextField.accesoryBtnBorderWidth         = 0.8
        passwordTextField.highlighterDefaultColor        = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5004676496)
        passwordTextField.highlighterFocusedColor        = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.addSubview(passwordTextField)
		
		NSLayoutConstraint.activate([
			passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: actualViewHeight * 0.08),
			passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor),
			passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor)
			])
    }
    
    func addLoginBtn() {
        loginBtn = UIButton(type: .system)
		loginBtn.translatesAutoresizingMaskIntoConstraints = false
        loginBtn.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        loginBtn.setAttributedTitle(NSAttributedString(
            string: "Anmeldung",
            attributes: [
                NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 24.0)!,
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1)
            ]
        ), for: .normal)
        loginBtn.addTarget(self, action: #selector(loginBtnPressed), for: .touchUpInside)
        view.addSubview(loginBtn)
		
		NSLayoutConstraint.activate([
			loginBtn.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: actualViewHeight * 0.15),
			loginBtn.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
			loginBtn.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
			loginBtn.widthAnchor.constraint(equalTo: emailTextField.widthAnchor),
			loginBtn.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
			])
    }

    func passwordAccesoryBtnTapped() {
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            navigationVC.setViewControllers([forgotPasswordVC], animated: true)
            // hide menu if its open
            if navigationVC.sideBarIsOpened() {
                navigationVC.toggleMenu()
            }
        }
    }
    
   @objc  func loginBtnPressed() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        if email.isEmpty || password.isEmpty {
            let error = email.isEmpty ? "E-Mail fehlt!" : "Passwort fehlt!"
            showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error, cancelBtn: false)
            return
        }
        if isConnectedToNetwork(repeatedFunction: loginBtnPressed) {
            startLoading(message: "Wird geladen..")
            Server.shared.getPasswordSalt(email: email) { salt, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self.stopLoading()
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description, cancelBtn: false)
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
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
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
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else {
                        if let success = success as? Bool, success {
                            if let navigationVC = self.navigationController as? SFSidebarNavigationController {
                                navigationVC.sidebarContainer.updateUserView()
                                if let topViewController = navigationVC.topViewController as? SFSidebarViewController {
                                    topViewController.updateNavigationButtons()
                                }
                                if self.shouldReturn {
                                    self.shouldReturn = false
                                    navigationVC.setViewControllers([navigationVC.webVC], animated: false)
                                } else {
                                    navigationVC.setViewControllers([navigationVC.homeVC], animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: MKTextField Delegate
extension LoginViewController: MKTextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func mkTextFieldShouldReturn(_ mkTextField: MKTextField) {
        if mkTextField == emailTextField {
            _ = passwordTextField.becomeFirstResponder()
        } else {
            _ = mkTextField.resignFirstResponder()
        }
    }
    
    func mkTextFieldDidBeginEditing(_ mkTextField: MKTextField) {
        currentTextField = mkTextField
    }
    
    func mkTextFieldDidEndEditing(_ mkTextField: MKTextField) {
        currentTextField = nil
    }
    
   @objc  func keyboardWillHide(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        view.frame.origin.y = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.size.height ?? 0)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
   @objc  func keyboardWillShow(_ sender: Notification) {
        avoidKeyboard(sender)
    }
    
    func avoidKeyboard(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let textField = currentTextField else {
                return
        }
        let keyboardHeight: CGFloat = keyboardSize.size.height
        let keyboardY = screen.height - keyboardHeight
        let textFieldY: CGFloat = textField.frame.origin.y + textField.frame.size.height
        if textFieldY > keyboardY {
            let animationValue = textFieldY - keyboardY
            view.frame.origin.y -= animationValue + 10 // 10 - padding from keyboard to textField
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
