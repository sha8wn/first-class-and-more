//
//  FilterModel.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/17/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

struct FilterModel {
    var optionName: String
    var selected: Bool
    var haveAdvancedFilters: Bool
    
    init(optionName: String, selected: Bool = false, haveAdvancedFilters: Bool = true) {
        self.optionName = optionName
        self.selected = selected
        self.haveAdvancedFilters = haveAdvancedFilters
    }
}
