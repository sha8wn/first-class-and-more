//
//  ProfilesAndTestsResponse.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 8/13/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

class ProfilesAndTestsResponse: Response {
    
    var data: [LocationModel]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        data <- map["data"]
    }
}

struct LocationModel: Mappable {
    var title: String?
    var imageUrl: String?
    var url: String?
    var access: Int?
    var color: UIColor = generateColor()
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        title    <- map["title"]
        imageUrl <- map["image"]
        url      <- map["url"]
        access   <- map["access"]
    }
}

fileprivate func generateColor() -> UIColor {
    srand48(Int(arc4random()))
    var red: CGFloat = 0.0
    while (red < 0.4 || red > 0.84) {
        red = CGFloat(drand48())
    }
    var green: CGFloat = 0.0
    while (green < 0.4 || green > 0.84) {
        green = CGFloat(drand48())
    }
    var blue: CGFloat = 0.0
    while (blue < 0.4 || blue > 0.84) {
        blue = CGFloat(drand48())
    }
    return UIColor(red: red, green: green, blue: blue, alpha: 0.7)
}
