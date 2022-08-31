//
//  WebrungViewController.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 8/6/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class WebrungViewController: SFSidebarViewController {
    
    enum PromotionsType: Int {
        case all
        case top
        case none
        
        var key: String {
            switch self {
            case .all: return "AllPromotions"
            case .top: return "TopPromotions"
            case .none: return "NonePromotions"
            }
        }
        
        var apiParameter: Int {
            switch self {
            case .all: return 1
            case .top: return 3
            case .none: return 4
            }
        }
        
        static func type(_ apiParameter: Int) -> PromotionsType {
            if apiParameter == 3 {
                return .top
            }
            
            if apiParameter == 4 {
                return .none
            }
            
            return .all
        }
        
        static var allCases: [PromotionsType] = [.all, .top, .none]
    }
    
    var appSettings: [String: Any] = [:]
    
    var selectedPromotionsType: PromotionsType = .all

    @IBOutlet weak var titleView: UIView!
    @IBOutlet private weak var titleLabel: SFFCAMLabel! {
        didSet { titleLabel.type = .Heading }
    }
    @IBOutlet private weak var textLabel: UILabel! {
        didSet {
            let text = NSMutableAttributedString()
            text
                .normal("Mit Promotion Pop-ups informieren wir Sie innerhalb der App über besondere Angebote und Aktionen.\n\n")
                .normal("Wenn Sie keine Promotion verpassen möchten, aktivieren Sie einfach ")
                .bold("„Alle Promotions“.\n\n")
                .normal("Wenn Sie nur über ausgewählte Top Promotions für unsere Premium-Mitglieder informiert werden möchten, wählen Sie ")
                .bold("„Nur Top Promotions“.\n\n")
                .normal("Alternativ können Sie die Promotion Pop-ups aber auch vollständig ")
                .bold("deaktivieren")
                .normal(".")
            textLabel.attributedText = text
        }
    }
    @IBOutlet var radioButtons: [DLRadioButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAdSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addHomeBtn()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        
            appDelegate.timer?.invalidate()
            appDelegate.timer = nil
        }
    }
    
    func setupUI() {
        selectRadioButton(for: selectedPromotionsType)
    }
    
    func getAdSettings() {
        if isConnectedToNetwork(repeatedFunction: getAdSettings) {
            startLoading(message: "Wird geladen..")
            
            Server.shared.getAdSettings { settings, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    }
                    else {
                        if let settings = settings as? [String: Any],
                            let adSetting = settings["ad_setting"] as? Int {
                            self.selectedPromotionsType = PromotionsType.type(adSetting)
                            self.setupUI()
                            self.appSettings = settings
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func radioBtnPressed(_ sender: DLRadioButton) {
        guard let index = radioButtons.firstIndex(of: sender),
            let type = PromotionsType(rawValue: index),
            type != selectedPromotionsType else {
                return
        }
        
        selectedPromotionsType = type
        selectRadioButton(for: type)
        appSettings["ad_setting"] = type.apiParameter
    }
    
    @IBAction func saveButtonPressed() {
        sendAndSave()
    }
    
    override func homeBtnTapped() {
        
        if let navigationVC = navigationController as? SFSidebarNavigationController {
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                
                appDelegate.timer?.invalidate()
                appDelegate.timer = nil
                
                if selectedPromotionsType == .none {
                    
                    appDelegate.getAdvertisements()
                    
                } else {
                    
                    appDelegate.restartTimer()
                    
                }
                
                navigationVC.setViewControllers([navigationVC.homeVC], animated: true)
            }
        }
    }

    func selectRadioButton(for type: PromotionsType) {
        radioButtons.forEach { $0.isSelected = false }
        radioButtons[type.rawValue].isSelected = true
        
        radioButtons.forEach { (btn) in
            btn.setTitleColor(btn.isSelected ? fcamGold : fcamBlue, for: .normal)
            btn.iconColor = btn.isSelected ? fcamGold : fcamBlue
        }
    }
    
    private func sendAndSave() {
        let value = selectedPromotionsType.apiParameter
        updateAdsSettings(value)
    }
    
    private func updateAdsSettings(_ ads: Int) {
        if isConnectedToNetwork(repeatedFunction: {
            self.updateAdsSettings(ads)
        }) {
            startLoading()
            Server.shared.changeAdsSettings(ads) { response, error in
                DispatchQueue.main.async {
                    self.stopLoading()
                    
                    var title = ""
                    var message = ""
                    
                    if let description = error?.description {
                        title = "Ein Fehler ist aufgetreten..."
                        message = description
                    } else {
                        title = "Promotions"
                        message = "Ihre Promotion Einstellungen wurden gespeichert."
                    }
                    
                    self.showPopupDialog(title: title, message: message)
                }
            }
        }
    }
    
}
