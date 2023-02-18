//
//  SFSettingsViewController.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/25/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import UserNotifications

class SFSettingsViewController: SFSidebarViewController, UNUserNotificationCenterDelegate {

    @IBOutlet private weak var titleLabel: SFFCAMLabel! {
        didSet { titleLabel.type = .Heading }
    }
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet var options: [DLRadioButton]!
	var selectedOptionIndex: Int = 0

    var status: UNAuthorizationStatus = .notDetermined
    
    var appSettings: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNotificationSettings()
        NotificationCenter.default.addObserver(self, selector: #selector(checkNotificationSettings), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPushSettings()
    }
    
    @objc private func checkNotificationSettings() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.status = settings.authorizationStatus
            }
        }
    }
    
    func getPushSettings() {
        if isConnectedToNetwork(repeatedFunction: getPushSettings) {
            startLoading(message: "Wird geladen..")
            
            Server.shared.getMarketingSettings { settings, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    }
                    else {
                        if let settings = settings as? [String: Any] {
                            if let pushSetting = settings["push_settings"] as? Int {
                                UserModel.sharedInstance.notificationSetting = pushSetting
                                self.appSettings = settings
                            }
                            else {
                                UserModel.sharedInstance.notificationSetting = 1
                                self.appSettings = settings
                            }
                            
                            self.setupView()
                        }
                        else {
                            self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                        }
                    }
                }
            }
        }
    }

    private func setupView() {
		for radioButton in options {
			radioButton.titleLabel?.adjustsFontSizeToFitWidth = true
			radioButton.titleLabel?.minimumScaleFactor = 0.5
		}
		
        let text = NSMutableAttributedString()
        text.normal("Mit ").bold(" Push-Benachrichtigungen ").normal("informieren wir Sie regelmäßig über ").bold("aktuelle Deals, Insider Strategien")
            .normal(" und ").bold("exklusive Promotions.\n\n").normal("Wenn Sie kein wichtiges Angebot verpassen wollen, aktivieren Sie einfach \"")
            .bold("Alle Push-Benachrichtigungen").normal("\".\n\nMit \"").bold("Nur Top Push-Benachrichtigungen")
            .normal("\" werden Sie nur über ausgewählte Top-Angebote informiert.\n\nNatürlich können Sie Push-Benachrichtigungen aber auch vollständig")
            .bold(" deaktivieren.")
        topLabel.attributedText = text
        // setting selected button
        let setting = UserModel.sharedInstance.notificationSetting - 1
        options.forEach { $0.isSelected = false }
        if setting < options.count {
            options[setting].isSelected = true
			selectedOptionIndex = setting
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addHomeBtn()
    }
    
    override func homeBtnTapped() {
        self.goHome()
    }
    
    private func showSettingsAlert() {
        showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: "Bitte Push-Nachrichten aktivieren", cancelBtn: false, okBtnCompletion: nil)
    }
    
    @IBAction func optionBtnPressed(_ sender: DLRadioButton) {
		/* guard status == .authorized else {
			//showSettingsAlert()
			//setupView()
			return
		}*/
        
        let membership = UserModel.sharedInstance.membership
        let choosenTop = self.options.index(of: sender) == 1
        if choosenTop && !(membership == .platin || membership == .diamont) {
            sender.isSelected = false
            self.showPopupDialog(title: "Ein Fehler ist aufgetreten...", message: "Dieses Option ist nicht für Ihr Mitgliedschaftslevel freigegeben.")
            return
        }
        
		options.forEach { $0.isSelected = false }
		sender.isSelected = true
		selectedOptionIndex = (options.index(of: sender) ?? 0)
        appSettings["push_settings"] = (self.options.index(of: sender) ?? 0) + 1
    }
	
	@IBAction func saveButtonPressed(_ sender: UIButton) {
		updatePushNotificationSettings(with: selectedOptionIndex + 1)
	}

//    func updatePushNotificationSettings(with setting: Int) {
//        guard isConnectedToNetwork(repeatedFunction: {
//            self.updatePushNotificationSettings(with: setting)
//        }) else { return }
//        startLoading()
//        Server.shared.updatePushNotificationSettings(setting: setting) { success, error in
//            DispatchQueue.main.async {
//                self.stopLoading()
//                if error != nil {
//                    self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
//                    self.options.forEach { $0.isSelected = false }
//                } else {
//                    if let success = success as? Bool, success {
//                        let user = UserModel.sharedInstance
//                        user.notificationSetting = setting
//                        let data = NSKeyedArchiver.archivedData(withRootObject: user)
//                        UserDefaults.standard.set(data, forKey: kUDSharedUserModel)
//                        UserDefaults.standard.synchronize()
//
//                        self.showPopupDialog(title: "Push Nachrichten", message: "Ihre Push-Nachrichten Einstellungen wurden gespeichert.") {
//                            self.goHome()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    private func updatePushNotificationSettings(with setting: Int) {
        if isConnectedToNetwork(repeatedFunction: {
            self.updatePushNotificationSettings(with: setting)
        }) {
            startLoading()
            
            do {
                let userSettings = try appSettings.toJson()
                
                Server.shared.changeUserSettings(userSettings) { response, error in
                    DispatchQueue.main.async {
                        self.stopLoading()
                        
                        if let description = error?.description {
                            self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: description)
                        }
                        else {
                            let user = UserModel.sharedInstance
                            user.notificationSetting = setting
                            let data = NSKeyedArchiver.archivedData(withRootObject: user)
                            UserDefaults.standard.set(data, forKey: kUDSharedUserModel)
                            UserDefaults.standard.synchronize()
                            
                            self.showPopupDialog(title: "Push Nachrichten", message: "Ihre Push-Nachrichten Einstellungen wurden gespeichert.") {
                                self.goHome()
                            }
                        }
                    }
                }
            }
            catch {
                self.showPopupDialog(title: "Ein Fehler ist aufgetreten...",
                                     message: "Vorgang konnte nicht abgeschlossen werden. Versuche es erneut.")
            }
        }
    }
    
    private func goHome() {
        guard let controller = self.navigationController as? SFSidebarNavigationController else {
            return
        }
        controller.setViewControllers([controller.homeVC], animated: true)
    }
    
}
