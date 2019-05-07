//
//  BoolResponse.swift
//  First Class And More
//
//  Created by Mikhail Kuzmenko on 9/27/18.
//  Copyright © 2018 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

class BoolResponse: Response {

    var data: ResponseStatus?

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        data <- map["data"]
    }
}
