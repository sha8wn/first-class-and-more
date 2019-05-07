//
//  AdvertisementsResponse.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 5/9/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

class AdvertisementsResponse: Response {
    
    var data: [AdvertisementModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        data <- map["data"]
    }
}
