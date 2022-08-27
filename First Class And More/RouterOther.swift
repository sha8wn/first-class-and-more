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
    case updatePushNotificationSettings(setting: Int, token: String, deviceToken: String, fcmToken: String)
    case getAdvertisements(token: String)
    case getProfilesAndTests(token: String, id: Int, page: Int)
    case subscribeNewsletter(email: String)
    case changeAdsSettings(ads: Int, pushToken: String, fcmToken: String)
    case sendMessage(email: String, title: String, name: String, surname: String, subject: String, message: String)
    case getAppVersion(token: String)
    
    var method: HTTPMethod {
        switch self {
            case .getSliderData, .getAdvertisements, .getProfilesAndTests, .getAppVersion:
                return .get
        case .updatePushNotificationSettings, .subscribeNewsletter, .changeAdsSettings, .sendMessage:
                return .post
        }
    }
    
    var params: Parameters {
        switch self {
            case .getSliderData(_):
        
                let userModel = UserModel.sharedInstance
                
                if !userModel.token.isEmpty {
                    return [
                        "query": "{\"key\":\"app_slider_members\"}"
                    ]
                }
            
                return [
                    "query": "{\"key\":\"app_slider_guest\"}"
                ]
            
            case .getAdvertisements(let token), .getAppVersion(let token):
                return [
                    "token": token
                ]
            case .updatePushNotificationSettings(let setting, let token, let deviceToken, let fcmToken):
                return [
                    "noti": setting,
                    "token": token,
                    "device": deviceToken,
                    "fcm_token":fcmToken,
                ]
            case .getProfilesAndTests(let token, let id, let page):
                return [
                    "token": token,
                    "page": page,
                    "cat": id
                ]
            case .subscribeNewsletter(let email):
                let params: Parameters = [
                    "email": email
                ]
                return params
            case .changeAdsSettings(let ads, let pushToken, let fcmToken):
                return [
                    "ads": ads,
                    "device": pushToken,
                    "fcm_token":fcmToken
                ]
        case .sendMessage(let email, let title, let name, let surname, let subject, let message):
            return [
                "email": email,
                "title": title,
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
            return "/settings/"
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
        case .getAppVersion:
            return "/app-version/"
        }
    }
    
    private var encoding: ParameterEncoding {
        if self.method == .post {
            return JSONEncoding.default
        }
        return URLEncoding.default
    }
    
    func asURLRequest() throws -> URLRequest {
        var baseURL = try Server.shared.url.asURL()
        
        switch self {
        case .getSliderData:
            baseURL =  try Server.shared.sliderURL.asURL()
        default:
            break
        }
        
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(url))
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json",
                            forHTTPHeaderField: "Content-Type")
        
        if method == .get {
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
        }
        else {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params,
                                                             options: .prettyPrinted)
        }
        
        return urlRequest
    }
}
