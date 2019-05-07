//
//  SFSidebarItem.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/24/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

class SFSidebarItem
{
    var sectionName: String?
    var optionName: [String]? // now gets image, extend to get text
    var destinationIdentifier: [String]?
    var dealType: [DealType?]?
    
    init(section: String?, option: [String]?, destination: [String]?, deal: [DealType?]?)
    {
        self.sectionName = section
        self.optionName = option
        self.destinationIdentifier = destination
        self.dealType = deal
    }
}
