//
//  AdvertisementsManager.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 5/10/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

class AdvertisementsManager: NSObject, NSCoding {
    
    static var sharedInstance: AdvertisementsManager = {
        if let decoded = UserDefaults.standard.object(forKey: kUDSharedAdvertisementsManager) as? Data,
            let advertisementsManager = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? AdvertisementsManager {
            return advertisementsManager
        } else {
            return AdvertisementsManager()
        }
    }()
    
    var advertisements: [AdvertisementModel] = []
    
    override init() {
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        advertisements = (aDecoder.decodeObject(forKey: "advertisements") as? [AdvertisementModel]) ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(advertisements, forKey: "advertisements")
    }
}
