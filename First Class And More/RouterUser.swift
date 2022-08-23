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

enum RouterUser: URLRequestConvertible {
    case getPasswordSalt(email: String)
    case login(email: String, password: String)
    case register(salutation: Int, email: String, surname: String, wantSubscribe: Bool)
    case subscribeNewsletter(email: String)
    case checkSubscriber(email: String)
    case forgotPassword(email: String)
    case getSettings(token: String)
    case checkUserToken(token: String)
    case subscribe(email: String)
    case subscriberActivate(email: String)
    
    var method: HTTPMethod {
        switch self {
        case .getPasswordSalt, .getSettings, .checkUserToken, .checkSubscriber:
            return .get
        case .login, .forgotPassword, .subscribe, .subscribeNewsletter, .register, .subscriberActivate:
            return .post
        }
    }
    
    var params: Parameters {
        switch self {
            case .getPasswordSalt(let email), .forgotPassword(let email):
                return [
                    "login": email
                ]
            case .login(let email, let password):
                return [
                    "email": email,
                    "password": password
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
            case .getSettings(let token), .checkUserToken(let token):
                return [
                    "token": token
                ]
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
                return "/check-subscriber/"
            case .forgotPassword:
                return "/forgot-password/"
            case .getSettings:
                return "/settings/"
            case .checkUserToken:
                return "/token-status/"
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
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params,
                                                         options: .prettyPrinted)
        return urlRequest
    }
}
