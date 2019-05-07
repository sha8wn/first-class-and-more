//
//  ForgotPasswordViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/15/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: SFSidebarViewController {

    let screen = UIScreen.main.bounds
    lazy var actualViewHeight: CGFloat = {
        return self.screen.height - self.navigationController!.navigationBar.frame.size.height -
            UIApplication.shared.statusBarFrame.size.height
    }()
    
    var titleLabel: UILabel!
    var emailTextField: MKTextField!
    var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    func setupNavBar() {
        addHomeBtn()
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backBtn.setImage(#imageLiteral(resourceName: "backBtn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        let backBarBtnItem = UIBarButtonItem(customView: backBtn)
        navigationItem.setLeftBarButton(backBarBtnItem, animated: false)
    }
    
    @objc func backBtnPressed() {
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            navigationVC.setViewControllers([navigationVC.loginVC], animated: true)
        }
    }
    
    override func homeBtnTapped() {
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            navigationVC.setViewControllers([navigationVC.homeVC], animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupUI() {
        view.backgroundColor = fcamBlue
        createTitleLabel()        
        createEmailTextField()
        addSendBtn()
    }
    
    func createTitleLabel() {
        let title = "Haben Sie Ihr Passwort vergessen?"
        let titleLabelFont = UIFont(name: "RobotoCondensed-Light", size: 27.0)!
        let constraintRect = CGSize(width: screen.width - 16.0 * 2, height: .greatestFiniteMagnitude)
        let titleLabelHeight = title.boundingRect(
            with: constraintRect,
            options: [],
            attributes: [NSAttributedString.Key.font: titleLabelFont],
            context: nil
        ).height
        titleLabel = UILabel(frame:
            CGRect(x: 16.0, y: actualViewHeight * 0.22, width: screen.width - 16.0 * 2, height: titleLabelHeight)
        )
        titleLabel.text = title
        titleLabel.font = titleLabelFont
        titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6243122799)
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)
    }
    
    func createEmailTextField() {
        emailTextField = MKTextField(frame:
            CGRect(
                x: screen.width * 0.15,
                y: titleLabel.frame.origin.y + titleLabel.frame.size.height + actualViewHeight * 0.13,
                width: screen.width * 0.7,
                height: actualViewHeight * 0.06
            )
        )
        emailTextField.mkDelegate         = self
        emailTextField.textColor          = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        emailTextField.font               = UIFont(name: "RobotoCondensed-Light", size: 24.0)!
        emailTextField.tintColor          = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        emailTextField.placeholder        = "E-mail"
        emailTextField.keyboardType       = .emailAddress
        emailTextField.correctionType     = .no
        emailTextField.capitalizationType = .none
        view.addSubview(emailTextField)
    }
    
    func addSendBtn() {
        sendBtn = UIButton(type: .system)
        sendBtn.frame = CGRect(
            x: screen.width * 0.15,
            y: emailTextField.frame.origin.y + emailTextField.frame.size.height + actualViewHeight * 0.15,
            width: screen.width * 0.7,
            height: actualViewHeight * 0.1
        )
        sendBtn.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        sendBtn.layer.cornerRadius = sendBtn.frame.size.height / 2
        sendBtn.clipsToBounds = true
        sendBtn.setAttributedTitle(NSAttributedString(
            string: "Senden",
            attributes: [
                NSAttributedString.Key.font: UIFont(name: "RobotoCondensed-Regular", size: 24.0)!,
                NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.3764705882, blue: 0.6, alpha: 1)
            ]
        ), for: .normal)
        sendBtn.addTarget(self, action: #selector(sendBtnPressed), for: .touchUpInside)
        view.addSubview(sendBtn)
    }
    
   @objc  func sendBtnPressed() {
        guard let email = emailTextField.text else { return }
        if email.isEmpty {
            showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "E-Mail fehlt!")
            return
        }
        if isConnectedToNetwork(repeatedFunction: sendBtnPressed) {
            startLoading(message: "Wird geladen..")
            Server.shared.forgotPassword(email: email) { success, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    } else {
                        if let success = success as? Bool, success {
                            if let navigationVC = self.navigationController as? SFSidebarNavigationController {
                                navigationVC.setViewControllers([navigationVC.loginVC], animated: true)
                                navigationVC.loginVC.showPopupDialog(
                                    title: "Erfolg",
                                    message: "Passwort zurücksetzen Anleitung per Mail gesendet",
                                    cancelBtn: false
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: MKTextField Delegate
extension ForgotPasswordViewController: MKTextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        guard let userInfo = sender.userInfo, let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        view.frame.origin.y = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.size.height ?? 0)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        avoidKeyboard(sender)
    }
    
    func avoidKeyboard(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let textField = emailTextField else {
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
