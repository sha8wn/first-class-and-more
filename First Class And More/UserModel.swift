//
//  UserModel.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/15/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

class UserModel: NSObject, NSCoding {
    
    static var sharedInstance: UserModel = {
        if let decoded = UserDefaults.standard.object(forKey: kUDSharedUserModel) as? Data,
            let userModel = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? UserModel {
            return userModel
        } else {
            return UserModel()
        }
    }() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "user_updated"), object: nil)
        }
    }
	
	var isPremiuim: Bool {
		return membership != .none
	}
    
    var isGold: Bool {
        return membership == .gold || membership == .ghaGold || membership == .abKkGold
    }
    var name: String                             = "Gast"
    var surname: String                          = ""
    var membership: Membership                   = .none
    var unlockedFilters: Bool                    = false
    var membershipExpires: String                = ""
    var email: String                            = ""
    var password: String                         = ""
    var token: String                            = "" {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "user_updated"), object: nil)
        }
    }
    var logined: Bool                            = false
    var favorites: [Int]                         = []
    var notificationSetting: Int                 = 1
    var isSubscribed: Bool                       = false

    override init() { }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.name                = aDecoder.decodeObject(forKey: "name") as! String
        self.surname             = aDecoder.decodeObject(forKey: "surname") as! String
        self.membership          = Membership(rawValue: aDecoder.decodeObject(forKey: "membership") as! String)!
        self.unlockedFilters     = aDecoder.decodeBool(forKey: "unlockedFilters")
        self.membershipExpires   = aDecoder.decodeObject(forKey: "membershipExpires") as! String
        self.email               = aDecoder.decodeObject(forKey: "email") as! String
        self.password            = aDecoder.decodeObject(forKey: "password") as! String
        self.token               = aDecoder.decodeObject(forKey: "token") as! String
        self.logined             = aDecoder.decodeBool(forKey: "logined")
        self.favorites           = aDecoder.decodeObject(forKey: "favorites") as! [Int]
        self.notificationSetting = aDecoder.decodeInteger(forKey: "notificationSetting")
        self.isSubscribed        = aDecoder.decodeBool(forKey: "isSubscribed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(surname, forKey: "surname")
        aCoder.encode(membership.rawValue, forKey: "membership")
        aCoder.encode(unlockedFilters, forKey: "unlockedFilters")
        aCoder.encode(membershipExpires, forKey: "membershipExpires")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(logined, forKey: "logined")
        aCoder.encode(favorites, forKey: "favorites")
        aCoder.encode(notificationSetting, forKey: "notificationSetting")
        aCoder.encode(isSubscribed, forKey: "isSubscribed")
    }
}
