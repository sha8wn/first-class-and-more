//
//  GlobalConfigs.swift
//  First Class And More
//
//  Created by Shawn Frank on 2/6/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation
import UIKit

let fcamBlue = UIColor.init(red: 0.0/255.0, green: 96.0/255.0, blue: 153.0/255.0, alpha: 1.0)
let fcamLightGrey = UIColor.init(red: 230.0/255.0, green: 231.0/255.0, blue: 232.0/255.0, alpha: 1.0)
let fcamDarkGrey = UIColor.init(red: 109.0/255.0, green: 110.0/255.0, blue: 113.0/255.0, alpha: 1.0)
let fcamGold = UIColor.init(red: 218.0/255.0, green: 165.0/255.0, blue: 31.0/255.0, alpha: 1.0)
let fcamDarkGold = UIColor.init(red: 183.0/255.0, green: 139.0/255.0, blue: 29.0/255.0, alpha: 1.0)

enum DealType: Int
{
    case Alle = 0
    case Favoriten
    case Endet_Bald
    case Flüge
    case Meilen_Programme
    case Vielflieger_Status
    case Hotels
    case Hotel_Programme
    case Kredit_Karten    
    case Meine_Deals
    case Ohne_Login
    case Gold_Highlights
    case Platin_Highlights
    case Filter_Definieren
    
    static func printEnumValue(oFDealType dealType: DealType) -> String
    {
        switch dealType
        {
            case .Alle: return "Alle Deals"
            case .Favoriten: return "Favoriten"
            case .Endet_Bald: return "Endet bald"
            case .Flüge: return "Flüge"
            case .Meilen_Programme: return "Meilenprogramme"
            case .Vielflieger_Status: return "Vielflieger-status"
            case .Hotels: return "Hotels"
            case .Hotel_Programme: return "Hotel-programme"
            case .Kredit_Karten: return "Kreditkarten"
            case .Meine_Deals: return "Meine Deals"
            case .Ohne_Login: return "Ohne Login"
            case .Gold_Highlights: return "GOLD Deals"
            case .Platin_Highlights: return "PLATIN Deals"
            case .Filter_Definieren: return "Filter Definieren"
        }
    }
}

// user defaults keys
let kUDApplicationLaunched          = "Was applicatio launched?"
let kUDDevicePushToken              = "Device push token identifier"
let kUDSharedUserModel              = "Shared user model identifier"
let kUDUserRegistered               = "userRegistered"
let kUDSharedAdvertisementsManager  = "Shared advertisement manager model"
let kUDCurrentAdvertisementPosition = "Current advertisements position"
let kUDSettingsAboutURL             = "Settings about url"
let kUDSettingsNewsletterURL        = "Settings newsletter url"
let kUDSettingsContactURL           = "Settings contact url"
let kUDSettingsFacebookURL          = "Settings facebook url"
let kUDSettingsInstagramURL         = "Settings instagram url"
let kUDSettingsTwitterURL           = "Settings twitter url"
let kUDSettingsPinterestURL         = "Settings pinterest url"
let kUDSettingsSideBarObjects       = "Settings sidebar objects"
let kUDSettingsPagesObjects         = "Settings pages objects"
let kUDSettingsCategoriesObjects    = "Settings categories objects"
let kUDSettingsDestinationsObjects  = "Settings destinations objects"
let kUDSettingsFilter               = "Settings filter object"
let kUDUnselectedFilters            = "Unselected filters identifiers"
let kUDSettingsPageDetails          = "Settings pageDetails object"
let kUDSettingsAllianceObject       = "Settings alliance object"
let kUDAdsLastDownloadDate          = "The last date ads were loaded"
let kUDTimerSettingsObject          = "Timer settings object"
let kUDAdsSettings                  = "Ads settings value"
let kUDExpiredDealsEnabled          = "Expired deals key"
