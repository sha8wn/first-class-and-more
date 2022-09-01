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
    
    var url: String = ""
    var isExternal: Bool = false
    var title: String = ""
    var expiry: String = ""
    var imageUrl: String = ""
    
    required init?(map: Map) { }
    
    init(title: String, isExternal: Bool, imageUrl: String, url: String, expiry: String) {
        self.title    = title
        self.isExternal = isExternal
        self.imageUrl = imageUrl
        self.url      = url
        self.expiry   = expiry
    }
    
    func mapping(map: Map) {
        title           <- map["title"]
        isExternal      <- map["is_external"]
        imageUrl        <- map["image"]
        url             <- map["url"]
        expiry          <- map["expire_at"]
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: "title") as? String,
            let url = aDecoder.decodeObject(forKey: "url") as? String,
            let isExternal = aDecoder.decodeObject(forKey: "isExternal") as? Bool,
            let expiry = aDecoder.decodeObject(forKey: "expiry") as? String,
            let imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as? String else {
                print(#file, #line, "Decoding failed.")
                return nil
        }
        
        self.init(title: title, isExternal: isExternal, imageUrl: imageUrl, url: url, expiry: expiry)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(isExternal, forKey: "isExternal")
        aCoder.encode(imageUrl, forKey: "imageUrl")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(expiry, forKey: "expiry")
    }
}
