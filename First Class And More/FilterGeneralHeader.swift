//
//  FilterGeneralHeader.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 10/8/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class FilterGeneralHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var expandBtn: UIButton!
    
    var indexPath: IndexPath?
    var expanded: Bool = false {
        didSet {
            expandBtn.transform = expanded ? CGAffineTransform(rotationAngle: .pi / 2) : .identity
        }
    }
    var expandBtnTapped: ((IndexPath?) -> Void)?
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            if newValue.width == 0 {
                return
            }
            super.frame = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        expandBtnTapped?(indexPath)
    }
    
    @IBAction func expandBtnPressed() {
        expandBtnTapped?(indexPath)
    }
}
