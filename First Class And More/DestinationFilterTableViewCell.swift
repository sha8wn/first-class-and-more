//
//  DestinationFilterTableViewCell.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 8/21/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class DestinationFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sevenSwitch: SevenSwitch!
    
    var sevenSwitchTapped: ((UITableViewCell, Bool) -> Void)?
    
    @IBAction func sevenSwitchTapped(_ sender: SevenSwitch) {
        sevenSwitchTapped?(self, sender.on)
    }
}
