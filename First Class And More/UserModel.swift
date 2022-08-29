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
    var email: String                            = "" {
        didSet {
            self.getIsSubscribed(email: self.email)
        }
    }
    var password: String                         = ""
    var token: String                            = "" {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "user_updated"), object: nil)
        }
    }
    var isLoggedIn: Bool                         = false
    var favorites: [Int]                         = []
    var notificationSetting: Int                 = 1
    var isSubscribed: Bool                       = false
    var salutation: Int                          = 1

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
        self.isLoggedIn          = aDecoder.decodeBool(forKey: "isLoggedIn")
        self.favorites           = aDecoder.decodeObject(forKey: "favorites") as! [Int]
        self.notificationSetting = aDecoder.decodeInteger(forKey: "notificationSetting")
        self.isSubscribed        = aDecoder.decodeBool(forKey: "isSubscribed")
        self.salutation          = aDecoder.decodeObject(forKey: "salutation") as? Int ?? 1
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
        aCoder.encode(isLoggedIn, forKey: "isLoggedIn")
        aCoder.encode(favorites, forKey: "favorites")
        aCoder.encode(notificationSetting, forKey: "notificationSetting")
        aCoder.encode(isSubscribed, forKey: "isSubscribed")
        aCoder.encode(salutation, forKey: "salutation")
    }
    
    
    private func getIsSubscribed(email: String) {
        Server.shared.checkSubscriber(email: email) { isSubscribed, error in
            guard error == nil else { return }
            guard let isSubscribed = isSubscribed as? Bool else { return }
            UserModel.sharedInstance.isSubscribed = isSubscribed
        }
    }
    
    func hasAccess(to accessLevel: Int) -> Bool {
        var userAccessLevel = 1
        
        if membership == .gold {
            userAccessLevel = 2
        }
        else if membership == .platin {
            userAccessLevel = 3
        }
        else if membership == .diamont {
            userAccessLevel = 4
        }
        
        return userAccessLevel >= accessLevel
    }
}
