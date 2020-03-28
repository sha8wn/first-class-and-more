//
//  AdvertisementModel.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 5/9/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

class AdvertisementModel: NSObject, NSCoding, Mappable {
    
    var title: String               = ""
    var mode: String                = ""
    var imageUrl: String            = ""
    var url: String                 = ""
    var expiry: String              = ""
    var classification: String      = ""
    
    required init?(map: Map) { }
    init(title: String, mode: String, imageUrl: String, url: String, expiry: String, classification: String) {
        self.title    = title
        self.mode     = mode
        self.imageUrl = imageUrl
        self.url      = url
        self.expiry   = expiry
        self.classification = classification
    }
    
    func mapping(map: Map) {
        title           <- map["title"]
        mode            <- map["mode"]
        imageUrl        <- map["image"]
        url             <- map["url"]
        expiry          <- map["expiry"]
        classification  <- map["classification"]
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let title           = aDecoder.decodeObject(forKey: "title") as! String
        let mode            = aDecoder.decodeObject(forKey: "mode") as! String
        let imageUrl        = aDecoder.decodeObject(forKey: "imageUrl") as! String
        let url             = aDecoder.decodeObject(forKey: "url") as! String
        let expiry          = aDecoder.decodeObject(forKey: "expiry") as! String
        let classification  = aDecoder.decodeObject(forKey: "classification") as! String
        self.init(title: title, mode: mode, imageUrl: imageUrl, url: url, expiry: expiry, classification: classification)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(mode, forKey: "mode")
        aCoder.encode(imageUrl, forKey: "imageUrl")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(expiry, forKey: "expiry")
        aCoder.encode(classification, forKey: "classification")
    }
}
