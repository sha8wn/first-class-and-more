//
//  UIView+Ext.swift
//  First Class And More
//
//  Created by Vadim on 23/01/2019.
//  Copyright © 2019 Shawn Frank. All rights reserved.
//

import UIKit

extension UIView {
	func showBorder(_ color: UIColor = .red) {
		layer.borderWidth = 1
		layer.borderColor = color.cgColor
	}
}
