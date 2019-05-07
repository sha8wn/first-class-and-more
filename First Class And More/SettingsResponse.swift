//
//  SettingsResponse.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/24/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import ObjectMapper

class SettingsResponse: Response {
    
    var data: SettingsObject?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        data <- map["data"]
    }
}

struct SettingsObject: Mappable {
    
    var customer: Customer?
    var urls: SettingsURLs?
    var sideBar: [SideBarObject]?
    var pages: [FiltersObject]?
    var categories: [CategoryObject]?
    var destination: FilterDestinationObject?
    var filter: FilterObject?
    var pageDetails: PageDetails?
    var alliance: AllianceObject?
    var timerSettings: TimerSettings?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        customer      <- map["customer"]
        urls          <- map["urls"]
        sideBar       <- map["side_bar"]
        pages         <- map["pages"]
        categories    <- map["category"]
        destination   <- map["destination"]
        filter        <- map["filter"]
        pageDetails   <- map["page_details"]
        alliance      <- map["alliance"]
        timerSettings <- map["ad_frequency"]
    }
}

internal enum Membership: String {
    case none     = ""
    case platin   = "PLATIN"
    case diamont  = "DIAMANT"
    case gold     = "GOLD"
    case ghaGold  = "GHA-GOLD"
    case abKkGold = "AB-KK-GOLD"
    
    var image: UIImage {
        switch self {
            case .platin:
                return #imageLiteral(resourceName: "Platin-350px")
            case .diamont:
                return #imageLiteral(resourceName: "Diamant-350px")
            case .gold, .ghaGold, .abKkGold:
                return #imageLiteral(resourceName: "Gold-350px")
            default:
                return #imageLiteral(resourceName: "guest")
        }
    }
    
    var bigImage: UIImage? {
        switch self {
            case .platin:
                return #imageLiteral(resourceName: "card-platin-big")
            case .diamont:
                return #imageLiteral(resourceName: "card-diamant-big")
            case .gold, .ghaGold, .abKkGold:
                return #imageLiteral(resourceName: "card-gold-big")
            default:
                return nil
        }
    }
}

struct Customer: Mappable {
    var name: String?
    var surname: String?
    var membership: Membership?
    var membershipExpires: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        name              <- map["name"]
        surname           <- map["surname"]
        membership        <- (map["membership"], EnumTransform<Membership>())
        membershipExpires <- map["membership_expires"]
    }
}

struct SettingsURLs: Mappable {
    var about: String?
    var newsletter: String?
    var contact: String?
    var facebook: String?
    var instagram: String?
    var twitter: String?
    var pinterest: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        about      <- map["about"]
        newsletter <- map["newsletter"]
        contact    <- map["contact"]
        facebook   <- map["facebook"]
        instagram  <- map["instagram"]
        twitter    <- map["twitter"]
        pinterest  <- map["pinterest"]
    }
}

class SideBarObject: NSObject, NSCoding, Mappable {
    var title: String?
    var pages: [PageObject]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        title <- map["title"]
        pages <- map["pages"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String
        pages = aDecoder.decodeObject(forKey: "pages") as? [PageObject]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(pages, forKey: "pages")
    }
}

class FiltersObject: NSObject, NSCoding, Mappable {
    var title: String?
    var filters: [[PageObject]]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        title <- map["title"]
        filters <- map["filters"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String
        filters = aDecoder.decodeObject(forKey: "filters") as? [[PageObject]]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(filters, forKey: "filters")
    }
}

class PageObject: NSObject, NSCoding, Mappable {
    var title: String?
    var url: String?
    var ids: [Int]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        title <- map["title"]
        url   <- map["url"]
        ids   <- map["ids"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String
        url   = aDecoder.decodeObject(forKey: "url") as? String
        ids   = aDecoder.decodeObject(forKey: "ids") as? [Int]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(ids, forKey: "ids")
    }
}

class DestinationObject: NSObject, NSCoding, Mappable {
    
    var name: String?
    var id: Int?
    var selected: Bool = true
    
    init(name: String?, id: Int?, selected: Bool = true) {
        self.name = name
        self.id = id
        self.selected = selected
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        name <- map["name"]
        id   <- map["id"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        name     = aDecoder.decodeObject(forKey: "name") as? String
        id       = aDecoder.decodeObject(forKey: "id") as? Int
        selected = aDecoder.decodeBool(forKey: "selected")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(selected, forKey: "selected")
    }
}

class CategoryObject: NSObject, NSCoding, Mappable {
    
    var name: String?
    var subtitle: String?
    var note: String?
    var sections: [SectionObject]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        name     <- map["name"]
        subtitle <- map["subtitle"]
        note     <- map["note"]
        sections <- map["sections"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        name     = aDecoder.decodeObject(forKey: "name") as? String
        subtitle = aDecoder.decodeObject(forKey: "subtitle") as? String
        note     = aDecoder.decodeObject(forKey: "note") as? String
        sections = aDecoder.decodeObject(forKey: "sections") as? [SectionObject]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(subtitle, forKey: "subtitle")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(sections, forKey: "sections")
    }
}

class SectionObject: NSObject, NSCoding, Mappable {
    
    var name: String?
    var items: [DestinationObject]?
    var isOpened: Bool = false
    
    init(name: String?, items: [DestinationObject]?) {
        self.name = name
        self.items = items
    }
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        name  <- map["section_name"]
        items <- map["items"]
        _ = items?.map { $0.selected = true }
    }
    
    required init?(coder aDecoder: NSCoder) {
        name  = aDecoder.decodeObject(forKey: "name") as? String
        items = aDecoder.decodeObject(forKey: "items") as? [DestinationObject]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(items, forKey: "items")
    }
    
    var isAirlines: Bool {
        return name == "Airlines"
    }
}

class FilterObject: NSObject, NSCoding, Mappable {
    var title: String?
    var body: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        title <- map["title"]
        body  <- map["text"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String
        body  = aDecoder.decodeObject(forKey: "body") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(body, forKey: "body")
    }
}

class FilterDestinationObject: NSObject, NSCoding, Mappable {
    
    var name: String?
    var subtitle: String?
    var items: [DestinationObject]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        name <- map["name"]
        subtitle <- map["subtitle"]
        items <- map["items"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String
        subtitle = aDecoder.decodeObject(forKey: "subtitle") as? String
        items = aDecoder.decodeObject(forKey: "items") as? [DestinationObject]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(subtitle, forKey: "subtitle")
        aCoder.encode(items, forKey: "items")
    }
}

class PageDetails: NSObject, NSCoding, Mappable {
    
    var destinationsProfile: ProfileAndTest?
    var airlineProfile: ProfileAndTest?
    var hoteltest: ProfileAndTest?
    var flughafenLounges: ProfileAndTest?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        destinationsProfile <- map["destinationsprofile"]
        airlineProfile <- map["airlineprofile"]
        hoteltest <- map["hoteltest"]
        flughafenLounges <- map["flughafen-lounges"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        destinationsProfile = aDecoder.decodeObject(forKey: "destinationsProfile") as? ProfileAndTest
        airlineProfile      = aDecoder.decodeObject(forKey: "airlineProfile") as? ProfileAndTest
        hoteltest           = aDecoder.decodeObject(forKey: "hoteltest") as? ProfileAndTest
        flughafenLounges    = aDecoder.decodeObject(forKey: "flughafenLounges") as? ProfileAndTest
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(destinationsProfile, forKey: "destinationsProfile")
        aCoder.encode(airlineProfile, forKey: "airlineProfile")
        aCoder.encode(hoteltest, forKey: "hoteltest")
        aCoder.encode(flughafenLounges, forKey: "flughafenLounges")
    }
}

class ProfileAndTest: NSObject, NSCoding, Mappable {
    
    var title: String?
    var intro: String?
	
	var introWithLinks: String? {
		guard let intro = intro else { return nil }
		return intro.replacingOccurrences(of: "href=\'/", with: "href=\'\(Server.shared.baseUrl)/")
	}
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        title <- map["title"]
        intro <- map["intro"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String
        intro = aDecoder.decodeObject(forKey: "intro") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(intro, forKey: "intro")
    }
}

class AllianceObject: NSObject, NSCoding, Mappable {
    
    var dictionary: [String: [Int]]?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        dictionary = map.JSON as? [String: [Int]]
    }
    
    required init?(coder aDecoder: NSCoder) {
        dictionary = aDecoder.decodeObject(forKey: "dictionary") as? [String: [Int]]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dictionary, forKey: "dictionary")
    }
}

class TimerSettings: NSObject, NSCoding, Mappable {
    
    var firstAd: Int   = 0 // by default
    var frequency: Int = 0 // by default
    
    required init?(map: Map) { }
    
    override init() { super.init() }
    
    func mapping(map: Map) {
        firstAd   <- map["first_ad"]
        frequency <- map["frequency"]
    }
    
    required init?(coder aDecoder: NSCoder) {
        firstAd   = aDecoder.decodeInteger(forKey: "firstAd")
        frequency = aDecoder.decodeInteger(forKey: "frequency")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(firstAd, forKey: "firstAd")
        aCoder.encode(frequency, forKey: "frequency")
    }
}
