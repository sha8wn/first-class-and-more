//
//  RouterUser.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/18/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

enum SubscriberType {
    case regular // newsletter users or registered users
    case premium // premium members
    case unsubscribed // non registered users
}

enum RouterUser: URLRequestConvertible {
    case getPasswordSalt(email: String)
    case login(email: String, password: String, fcmToken: String)
    case register(salutation: Int, email: String, surname: String, wantSubscribe: Bool)
    case subscribeNewsletter(email: String)
    case checkSubscriber(email: String)
    case forgotPassword(email: String)
    case getSettings(token: String)
    case getUserProfile(token: String)
    case checkUserToken
    case subscribe(email: String)
    case subscriberActivate(email: String)
    
    var method: HTTPMethod {
        switch self {
        case .getPasswordSalt, .getSettings, .getUserProfile:
            return .get
        case .login, .forgotPassword, .subscribe, .subscribeNewsletter, .register, .subscriberActivate, .checkSubscriber, .checkUserToken:
            return .post
        }
    }
    
    var params: Parameters {
        switch self {
        case .getPasswordSalt(let email):
            return [
                "login": email
            ]
        case .forgotPassword(let email):
            return [
                "email": email
            ]
        case .login(let email, let password, let fcmToken):
            return [
                "email": email,
                "password": password,
                "device_token": fcmToken
            ]
        case .register(let salutation, let email, let surname, let wantSubscribe):
            return [
                "salutation": salutation as Int,
                "last_name": surname,
                "email": email,
                "newsletter": wantSubscribe as Bool,
                "source": kAppSource as Int
            ]
            
        case .subscribeNewsletter(let email):
            return [
                "email": email,
                "newsletter": true,
                "source": kAppSource as Int
            ]
            
        case .checkSubscriber(let email):
            return [
                "email": email
            ]
            
        case .getSettings(_), .getUserProfile(_):
            return [:]
        
        case .checkUserToken:
            return [:]
        case .subscribe(let email):
            return [
                "email": email
            ]
        case .subscriberActivate(let email):
            return ["email": email]
        }
    }
    
    var url: String {
        switch self {
        case .getPasswordSalt:
            return "/pw-salt/"
        case .login:
            return "/auth/fe/login"
        case .register, .subscribeNewsletter:
            return "/subscribe"
        case .checkSubscriber:
            return "/app/check_subscriber"
        case .forgotPassword:
            return "/auth/fe/forgot"
        case.getUserProfile:
            return "/auth/fe/self"
        case .getSettings:
            return "app/settings"
        case .checkUserToken:
            return "/auth/fe/refresh"
        case .subscribe:
            return "/access-code/"
        case .subscriberActivate:
            return "/subscriber-activate/"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = try Server.shared.url.asURL()
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
        
        let userModel = UserModel.sharedInstance
        
        if !userModel.token.isEmpty {
            print("Bearer JWT Token: \(userModel.token)")
            urlRequest.setValue("Bearer \(userModel.token)",
                                forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}
