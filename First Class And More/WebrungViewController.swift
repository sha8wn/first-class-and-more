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
        
        static var allCases: [PromotionsType] = [.all, .top, .none]
    }
    
    var selectedPromotionsType: PromotionsType = .all

    @IBOutlet weak var titleView: UIView!
    @IBOutlet var radioButtons: [DLRadioButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        addHomeBtn()
        createTopTitle()
        
        var hasStoredValue = false
        if let dict = UserDefaults.standard.value(forKey: kUDAdsSettings) as? [String: Bool] {
            for type in PromotionsType.allCases {
                if let isSelected = dict[type.key], isSelected {
                    selectedPromotionsType = type
                    selectRadioButton(for: type)
                    hasStoredValue = true
                }
            }
        }
        
        if !hasStoredValue {
            selectRadioButton(for: .all)
        }
    }
    
    func createTopTitle() {
        let titleLabel       = SFFCAMLabel()
        titleLabel.type      = .Heading
        titleLabel.textColor = fcamBlue
        titleLabel.text      = "Promotions"
        titleLabel.sizeToFit()
        titleLabel.frame.origin.x = (UIScreen.main.bounds.width - titleLabel.frame.size.width) / 2
        titleLabel.frame.origin.y = (titleView.frame.size.height - titleLabel.frame.size.height) / 2
        titleView.addSubview(titleLabel)
    }
    
    @IBAction func radioBtnPressed(_ sender: DLRadioButton) {
        guard let index = radioButtons.firstIndex(of: sender),
            let type = PromotionsType(rawValue: index),
            type != selectedPromotionsType else {
                return
        }
        
        selectedPromotionsType = type
        selectRadioButton(for: type)
        sendAndSave()
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
        let dict: [String: Bool] = [
            PromotionsType.all.key: selectedPromotionsType == .all,
            PromotionsType.top.key: selectedPromotionsType == .top,
            PromotionsType.none.key: selectedPromotionsType == .none
        ]
        UserDefaults.standard.set(dict, forKey: kUDAdsSettings)
        UserDefaults.standard.synchronize()
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
                    if error != nil {
                        self.showPopupDialog(title: "Ein Fehler ist aufgetreten..", message: error!.description)
                    }
                }
            }
        }
    }
}
