//
//  Response.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/24/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

class Response: Mappable {
    // error
    var code: String?
    var message: String?
    var errorData: ResponseStatus?
    // success
//    var data: String?
    var response: ResponseStatus?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        //code      <- map["code"]
        //message   <- map["message"]
        //errorData <- map["data"]
//        data      <- map["data"]
        response  <- map["0"]
    }
}

struct ResponseStatus: Mappable {
    var status: Int?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
    }
}
