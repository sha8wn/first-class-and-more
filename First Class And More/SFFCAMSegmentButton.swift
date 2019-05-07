//
//  SFFCAMButton.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/22/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class SFFCAMSegmentButton: UIButton
{
    override var isEnabled: Bool
    {
        willSet
        {
            if newValue
            {
                backgroundColor = fcamLightGrey
            }
            else
            {
                backgroundColor = fcamBlue
            }
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont(name: "RobotoCondensed-Regular", size: 16)
        setTitleColor(.white, for: .disabled)
        setTitleColor(fcamBlue, for: .normal)
    }
    
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

}
