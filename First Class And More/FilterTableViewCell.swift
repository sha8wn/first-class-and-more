//
//  FilterTableViewCell.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/17/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var trailingToAdvancedBtn: NSLayoutConstraint!
    @IBOutlet weak var trailingToSuperview: NSLayoutConstraint!
    @IBOutlet weak var advancedBtn: UIButton!
    
    var advancedBtnTapped: ((UITableViewCell) -> Void)?
    
    var filter: FilterModel! {
        didSet {
            optionLabel.text = filter.optionName
            optionLabel.textColor = filter.selected ? #colorLiteral(red: 0.168627451, green: 0.6588235294, blue: 0.9490196078, alpha: 1) : #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
            checkboxImageView.image = filter.selected ? #imageLiteral(resourceName: "checkboxOn") : #imageLiteral(resourceName: "checkboxOff")
            if filter.haveAdvancedFilters {
                advancedBtn.isHidden = !filter.selected
                trailingToAdvancedBtn.isActive = filter.selected
                trailingToSuperview.isActive = !filter.selected
            }
        }
    }
    
    @IBAction func advancedBtnPressed() {
        advancedBtnTapped?(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let advancedBtnHeight = UIScreen.main.bounds.width * 0.05 + 8.0
        advancedBtn.layer.cornerRadius = advancedBtnHeight / 2
        advancedBtn.layer.borderWidth = 1.0
        advancedBtn.layer.borderColor = #colorLiteral(red: 0.168627451, green: 0.6588235294, blue: 0.9490196078, alpha: 1).cgColor
        advancedBtn.setTitle("Fortgeschritten", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
