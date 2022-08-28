//
//  SlideModel.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/29/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

struct SlideModel: Mappable, InfiniteScollingData {
    var id: String?
    var title: String?
    var shortTitle: String?
    var url: String?
    var imageUrl: String?
    var membership: Int?
    //var premium: Premium = .none
    //var access: Int?
    
    init(map: Map) { }

    mutating func mapping(map: Map) {
        id         <- map["_id"]
        title      <- map["title"]
        shortTitle <- map["short_title"]
        url        <- map["url"]
        imageUrl   <- map["featured"]
        membership <- map["membership"]
        //premium    <- (map["premium"], EnumTransform<Premium>())
        //access     <- map["access"]
    }
}
