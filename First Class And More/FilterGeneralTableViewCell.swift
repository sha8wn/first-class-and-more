//
//  FilterGeneralTableViewCell.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 10/7/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class FilterGeneralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var filterSwitch: SevenSwitch!
    
    var filterSwitchTapped: ((UITableViewCell, Bool) -> Void)?
    
    @IBAction func filterSwitchValueChanged(_ sender: SevenSwitch) {
        filterSwitchTapped?(self, sender.on)
    }
}

class FilterButtonCell: UITableViewCell {
    
    var isSelectAllShowed: Bool = false {
        didSet {
            setupAppearance()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    func setupAppearance() {
        titleLabel.text = isSelectAllShowed ? "ALLE AIRLINES AUSWÄHLEN" : "KEINE AIRLINE AUSWÄHLEN"
        backgroundColor = isSelectAllShowed ? #colorLiteral(red: 0.8549019608, green: 0.6470588235, blue: 0.1215686275, alpha: 1) : #colorLiteral(red: 1, green: 0.3803921569, blue: 0.3803921569, alpha: 1)
    }
    
}
