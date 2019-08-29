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
    
    private var encoding: ParameterEncoding {
        if self.method == .post {
            return JSONEncoding.default
        }
        return URLEncoding.default
    }
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = try Server.shared.url.asURL()
        var url = baseURL.appendingPathComponent(self.url)
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "auth", value: Server.shared.apiKey)]
        url = urlComponents.url!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest = try self.encoding.encode(urlRequest, with: self.params)
        return urlRequest
    }
}
