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
    case getAdvertisements
    case getProfilesAndTests(token: String, id: Int, page: Int)
    case subscribeNewsletter(email: String)
    case changeUserSettings(settings: String)
    case sendMessage(email: String, title: Int, name: String, surname: String, subject: String, message: String)
    case getAppVersion(token: String)
    
    var method: HTTPMethod {
        switch self {
            case .getSliderData, .getAdvertisements, .getProfilesAndTests, .getAppVersion:
                return .get
        case .updatePushNotificationSettings, .subscribeNewsletter, .changeUserSettings, .sendMessage:
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
            
            case .getAdvertisements:
                return [:]
            
            case .getAppVersion(let token):
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
            case .changeUserSettings(let userSettings):
                return [
                    "meta": [
                        "app_data": userSettings
                    ]
                ]
        case .sendMessage(let email, let title, let name, let surname, let subject, let message):
            return [
                "type": 1,
                "sub_type": 9,
                "user": [
                    "email": email,
                    "salutation": title,
                    "first_name": name,
                    "last_name": surname,
                ],
                "meta": [
                    "subject": subject,
                    "message": message
                ]
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
            return "/app/promo"
        case .getProfilesAndTests:
            return "/category-deals/"
        case .subscribeNewsletter:
            return "/subscribe/"
        case .changeUserSettings:
            return "/self/profile"
        case .sendMessage:
            return "/enquiry"
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
            print(params)
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params,
                                                             options: .prettyPrinted)
        }
        
        let userModel = UserModel.sharedInstance
        
        if !userModel.token.isEmpty {
            urlRequest.setValue("Bearer \(userModel.token)",
                                forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}
