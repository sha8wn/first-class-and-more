//
//  DealModel.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/18/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import UIKit
import Foundation
import ObjectMapper

internal enum Premium: String {
    case platin = "PLATIN"
    case gold   = "GOLD"
    case none   = ""
    
    var ribbon: UIImage? {
        switch self {
            case .platin:
                return #imageLiteral(resourceName: "PlatinRibbon")
            case .gold:
                return #imageLiteral(resourceName: "GoldRibbon")
            default:
                return nil
        }
    }
    
    init(value: String) {
        switch value.lowercased() {
            case "platin":
                self = .platin
            case "gold":
                self = .gold
            default:
                self = .none
        }
    }
}

struct DealModel: Mappable {
    var id: Int?
    var title: String?
    var shortTitle: String?
    var date: String?
    var expireDate: String?
    var expire: ExpireModel?
    var imageUrlString: String?
    var teaser: String?
    var url: String?
    var premium: Premium = .none
    var access: Int?
    var sticky: Int?
    var appCat: Bool?
    var categories: [Int]?
    var rating: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id             <- map["id"]
        title          <- map["title"]
        shortTitle     <- map["short_title"]
        date           <- map["publish"]
        expireDate     <- map["expire_date"]
        expire         <- map["expire"]
        imageUrlString <- map["image"]
        teaser         <- map["teaser"]
        url            <- map["url"]
        premium        <- (map["premium"], EnumTransform<Premium>())
        access         <- map["access"]
        sticky         <- map["sticky"]
        appCat         <- map["app_cat"]
        categories     <- map["cat"]
        rating         <- map["miles_ratio"]
    }
}

extension DealModel: CustomStringConvertible {
    var description: String {
        var string: String = "Deal:\n"
        let mirrorObject = Mirror(reflecting: self)
        for (_, attr) in mirrorObject.children.enumerated() {
            if let property_name = attr.label as String? {
                string += "   \(property_name) = \(attr.value)\n"
            }
        }
        return string
    }
}

struct ExpireModel: Mappable {
    var type: String?
    var dateUnixTime: Int?
    var iso8601: String?
    var rfc2822: String?
    var ymd: String?
    var format: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        type         <- map["type"]
        dateUnixTime <- map["date_unixtime"]
        iso8601      <- map["ISO_8601"]
        rfc2822      <- map["RFC_2822"]
        ymd          <- map["Y-m-d"]
        format       <- map["date_format"]
    }
}

extension ExpireModel: CustomStringConvertible {
    var description: String {
        var string: String = "Expire:\n"
        let mirrorObject = Mirror(reflecting: self)
        for (_, attr) in mirrorObject.children.enumerated() {
            if let property_name = attr.label as String? {
                string += "   \(property_name) = \(attr.value)\n"
            }
        }
        return string
    }
}
