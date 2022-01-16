//
//  SliderCollectionViewCell.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/29/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class SliderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
	@IBOutlet weak var slideShortTitleLabel: UILabel!
    @IBOutlet weak var slideShortTitleButton: UIButton!
    @IBOutlet weak var slideTitleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        slideShortTitleButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        slideShortTitleButton.layer.borderWidth = 1.0
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}
}
