//
//  RouterOther.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/29/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

enum RouterOther: URLRequestConvertible {
    case getSliderData(token: String)
    case updatePushNotificationSettings(setting: Int, token: String, deviceToken: String)
    case getAdvertisements(token: String)
    case getProfilesAndTests(token: String, id: Int, page: Int)
    case subscribeNewsletter(email: String, name: String, gender: Int)
    case changeAdsSettings(ads: Int, pushToken: String)
    case sendMessage(email: String, name: String, surname: String, subject: String, message: String)
    
    var method: HTTPMethod {
        switch self {
            case .getSliderData, .getAdvertisements, .getProfilesAndTests:
                return .get
        case .updatePushNotificationSettings, .subscribeNewsletter, .changeAdsSettings, .sendMessage:
                return .post
        }
    }
    
    var params: Parameters {
        switch self {
            case .getSliderData(let token), .getAdvertisements(let token):
                return [
                    "token": token
                ]
            case .updatePushNotificationSettings(let setting, let token, let deviceToken):
                return [
                    "noti": setting,
                    "token": token,
                    "device": deviceToken
                ]
            case .getProfilesAndTests(let token, let id, let page):
                return [
                    "token": token,
                    "page": page,
                    "cat": id
                ]
            case .subscribeNewsletter(let email, let name, let gender):
                let params: Parameters = [
                    "title_id": gender,
                    "name": name,
                    "email": email
                ]
                return params
            case .changeAdsSettings(let ads, let pushToken):
                return [
                    "ads": ads,
                    "device": pushToken
                ]
        case .sendMessage(let email, let name, let surname, let subject, let message):
            return [
                "email": email,
                "name": name,
                "surname": surname,
                "subject": subject,
                "message": message
            ]
        }
    }
    
    var url: String {
        switch self {
        case .getSliderData:
            return "/slider/"
        case .updatePushNotificationSettings:
            return "/notifications/"
        case .getAdvertisements:
            return "/advertisements/"
        case .getProfilesAndTests:
            return "/category-deals/"
        case .subscribeNewsletter:
            return "/subscribe/"
        case .changeAdsSettings:
            return "/ad-settings"
        case .sendMessage:
            return "/contact-request"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = try Server.shared.url.asURL()
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(url))
        urlRequest.httpMethod = method.rawValue
        var params = self.params
        params["auth"] = Server.shared.apiKey
        urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
        return urlRequest
    }
}
