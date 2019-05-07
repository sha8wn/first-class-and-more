//
//  Errors.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/18/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

enum Errors {
    case custom(String)
    case cantGetPasswordSalt
    case cantLogin
    case cantRegister
    case cantCheckSubscriber
    case cantSendForgotPassword
    case cantGetSettings
    case cantCheckUserToken
    case cantGetDeals
    case cantGetMyDeals
    case cantGetSliderData
    case cantGetFavoriteDeals
    case cantAddFavoriteDeal
    case cantDeleteFavoriteDeal
    case cantGetRecentDeals
    case pushNotificationsAreDisabled
    case cantUpdatePushNotifications
    case cantGetExpiringDeals
    case cantGetHighlights
    case cantGetAdvertisements
    case cantGetLocations
    case cantSubscribe
    case alreadySubscribe
    
    var description: String {
        get {
            switch self {
                case .custom(let error):
                    return error
                case .cantGetPasswordSalt, .cantLogin:
                    return "Login gescheitert"
                case .cantSendForgotPassword:
                    return "Fehlerhafte Anfrage"
                case .pushNotificationsAreDisabled:
                    return "Bitte aktivieren Sie Push-Benachrichtigungen in den Einstellungen"
                case .cantUpdatePushNotifications:
                    return "Push-Benachrichtigungen können nicht aktualisiert werden"
            case .alreadySubscribe:
                    return "Bitte nutzen Sie den Login für Premium-Mitglieder"
                default:
                    return "Vorgang konnte nicht abgeschlossen werden. Versuche es erneut."
            }
        }
    }
}
