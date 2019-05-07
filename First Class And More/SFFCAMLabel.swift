//
//  SFFCAMLabel.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/21/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit

class SFFCAMLabel: UILabel
{
    enum LabelType
    {
        case Heading
        case Body
        case Subtitle
    }
    
    var fontSize: CGFloat
    {
        willSet(newValue)
        {
            font = UIFont(name: "RobotoCondensed-Regular", size: newValue)
        }
    }
    
    var type: LabelType {
        
        willSet(newType)
        {
            switch newType
            {
                case .Heading:
                    font = UIFont(name: "RobotoCondensed-Regular", size: 18)
                
                case .Body:
                    font = UIFont(name: "RobotoCondensed-Regular", size: 14)
                
                case .Subtitle:
                    font = UIFont(name: "RobotoCondensed-Regular", size: 12)
            }
        }
    }
    
    override init(frame: CGRect)
    {
        type = LabelType.Heading
        fontSize = 14
        
        super.init(frame: frame)
        
        font = UIFont(name: "RobotoCondensed-Regular", size: fontSize)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        type = LabelType.Heading
        fontSize = 14
        
        super.init(coder: aDecoder)
        
        font = UIFont(name: "RobotoCondensed-Regular", size: fontSize)
    }

}
