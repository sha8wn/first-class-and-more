//
//  SFTableView.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/23/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class SFTableView: UITableView
{
    override func touchesShouldCancel(in view: UIView) -> Bool
    {
        if view.isKind(of: UIButton.self)
        {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
    
    func configure()
    {
        for case let x as UIScrollView in subviews
        {
            x.delaysContentTouches = false
        }
        
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        delaysContentTouches = false
        canCancelContentTouches = true
    }
}
