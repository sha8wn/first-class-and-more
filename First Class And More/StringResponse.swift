//
//  StringResponse.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/21/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

class StringResponse: Response {
    
    var data: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}
