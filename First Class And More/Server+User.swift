//
//  Server+User.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/18/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import AlamofireObjectMapper

extension Server {    
    // get password salt
    // success response
    // {"data":"PcKrzZwFJJoi4ozZ","0":{"status":200}}
    // error response
    // {"code":"invalid_user","message":"User does not exist","data":{"status":404}}
    func getPasswordSalt(email: String, сompletion: @escaping Completion) {
        let getPasswordSaltURL = RouterUser.getPasswordSalt(email: email)
        Alamofire.request(getPasswordSaltURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            if let salt = responseValue?.data {
                сompletion(salt, nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantGetPasswordSalt)
        }
    }
    
    // login request
    // success response
    // {"data":"PcKrzZwFJJoi4ozZ","0":{"status":200}}
    // error response
    // {"code":"invalid_password","message":"Invalid Password","data":{"status":401}}
    func login(email: String, password: String, salt: String, сompletion: @escaping Completion) {
        let defaults = UserDefaults.standard
        let devicePushToken = defaults.string(forKey: kUDDevicePushToken) ?? "55f23078281e424a6a8c410de53205455c088e4aad32bdecfa3bcce981d1bf86"
        // md5($pwd.$salt).':'.$salt
        let newPassword = "\("\(password)\(salt)".md5):\(salt)"
        let loginURL = RouterUser.login(email: email, password: newPassword, devicePushToken: devicePushToken)
        Alamofire.request(loginURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            print(#file, #line, responseValue?.data ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.result.value?.response?.status ?? "")
            if let token = responseValue?.data {
                let userModel      = UserModel.sharedInstance
                userModel.email    = email
                userModel.password = password
                userModel.token    = token
                userModel.logined  = true
                // save userModel
                let data = NSKeyedArchiver.archivedData(withRootObject: userModel)
                UserDefaults.standard.set(data, forKey: kUDSharedUserModel)
                UserDefaults.standard.synchronize()
                сompletion(true, nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantLogin)
        }
    }

    // register
    func register(state: Int, email: String, surname: String, wantSubscribe: Bool, сompletion: @escaping Completion) {
        let registerURL = RouterUser.register(state: state, email: email, surname: surname, wantSubscribe: wantSubscribe)
        Alamofire.request(registerURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            if responseValue?.code == "already_subscribe" {
                сompletion(nil, .alreadySubscribe)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            if let success = responseValue?.data, success == "success" {
                сompletion(true, nil)
                return
            }
            сompletion(nil, .cantRegister)
        }
    }

    // check subscriber
    func checkSubscriber(email: String, сompletion: @escaping Completion) {
        let checkSubscriberURL = RouterUser.checkSubscriber(email: email)
        Alamofire.request(checkSubscriberURL).responseObject { (response: DataResponse<BoolResponse>) in
            let responseValue = response.result.value
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            if let intValue = responseValue?.data?.status {
                let isSubscribed = NSNumber(integerLiteral: intValue).boolValue
                сompletion(isSubscribed, nil)
                return
            }
            сompletion(nil, .cantCheckSubscriber)
        }
    }

    // forgot password
    func forgotPassword(email: String, сompletion: @escaping Completion) {
        let forgotPasswordURL = RouterUser.forgotPassword(email: email)
        Alamofire.request(forgotPasswordURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            if let success = responseValue?.data {
                print(#file, #line, success)
                print(#file, #line, success == "success")
                сompletion(success == "success", nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantSendForgotPassword)
        }
    }
    
    // get settings
    func getSettings(сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let getSettingsURL = RouterUser.getSettings(token: token)
        Alamofire.request(getSettingsURL).responseObject { (response: DataResponse<SettingsResponse>) in
            let responseValue = response.result.value            
            print(#file, #line, responseValue?.data ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.result.value?.response?.status ?? "")
            let defaults = UserDefaults.standard
            // update user model
            if let settingsObject = responseValue?.data {
                if let customer = settingsObject.customer {
                    let userModel = UserModel.sharedInstance
                    if let name = customer.name {
                        userModel.name = name
                    }
                    if let surname = customer.surname {
                        userModel.surname = surname
                    }
                    if let membership = customer.membership {
                        userModel.membership = membership
                    }
                    if let membershipExpires = customer.membershipExpires {
                        userModel.membershipExpires = membershipExpires
                    }
                    // save userModel
                    let data = NSKeyedArchiver.archivedData(withRootObject: userModel)
                    defaults.set(data, forKey: kUDSharedUserModel)
                }
                // urls
                if let urls = settingsObject.urls {
                    // update settings urls
                    if let about = urls.about {
                        defaults.set(about, forKey: kUDSettingsAboutURL)
                    }
                    if let newsletter = urls.newsletter {
                        defaults.set(newsletter, forKey: kUDSettingsNewsletterURL)
                    }
                    if let contact = urls.contact {
                        defaults.set(contact, forKey: kUDSettingsContactURL)
                    }
                    if let facebook = urls.facebook {
                        defaults.set(facebook, forKey: kUDSettingsFacebookURL)
                    }
                    if let instagram = urls.instagram {
                        defaults.set(instagram, forKey: kUDSettingsInstagramURL)
                    }
                    if let twitter = urls.twitter {
                        defaults.set(twitter, forKey: kUDSettingsTwitterURL)
                    }
                    if let pinterest = urls.pinterest {
                        defaults.set(pinterest, forKey: kUDSettingsPinterestURL)
                    }
                }
                // side bar
                if let sideBar = settingsObject.sideBar {
                    let data = NSKeyedArchiver.archivedData(withRootObject: sideBar)
                    defaults.set(data, forKey: kUDSettingsSideBarObjects)
                }
                // pages
                if let pages = settingsObject.pages {
                    let data = NSKeyedArchiver.archivedData(withRootObject: pages)
                    defaults.set(data, forKey: kUDSettingsPagesObjects)
                }
                // categories
                if let categories = settingsObject.categories, UserDefaults.standard.object(forKey: kUDSettingsCategoriesObjects) == nil {
                    let data = NSKeyedArchiver.archivedData(withRootObject: categories)
                    defaults.set(data, forKey: kUDSettingsCategoriesObjects)
                }
                // destinations
                if let destination = settingsObject.destination, UserDefaults.standard.object(forKey: kUDSettingsDestinationsObjects) == nil  {
                    let data = NSKeyedArchiver.archivedData(withRootObject: destination)
                    defaults.set(data, forKey: kUDSettingsDestinationsObjects)
                }
                // filter
                if let filter = settingsObject.filter {
                    let data = NSKeyedArchiver.archivedData(withRootObject: filter)
                    defaults.set(data, forKey: kUDSettingsFilter)
                }
                // page details
                if let pageDetails = settingsObject.pageDetails {
                    let data = NSKeyedArchiver.archivedData(withRootObject: pageDetails)
                    defaults.set(data, forKey: kUDSettingsPageDetails)
                }
                // alliance object
                if let allianceObject = settingsObject.alliance {
                    let data = NSKeyedArchiver.archivedData(withRootObject: allianceObject)
                    defaults.set(data, forKey: kUDSettingsAllianceObject)
                }
                // timer settings object
                if let timerSettings = settingsObject.timerSettings {
                    let data = NSKeyedArchiver.archivedData(withRootObject: timerSettings)
                    defaults.set(data, forKey: kUDTimerSettingsObject)
                    defaults.synchronize()
                    сompletion(true, nil)
                    return
                }
            }
            // errors handling
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantGetSettings)
        }
    }
    
    // check user token
    func checkUserToken(сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let checkUserTokenURL = RouterUser.checkUserToken(token: token)
        Alamofire.request(checkUserTokenURL).responseObject { (response: DataResponse<CheckUserTokenResponse>) in
            let responseValue = response.result.value
            // update user model
            if let statusCode = responseValue?.data {
                сompletion(statusCode, nil)
                return
            }
            // errors handling
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantCheckUserToken)
        }
    }
    
    func subscribe(email: String, сompletion: @escaping Completion) {
        let subscribeURL = RouterUser.subscribe(email: email)
        Alamofire.request(subscribeURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            if let value = responseValue?.data {
                сompletion(value, nil)
                return
            }
            сompletion(nil, .cantSubscribe)
        }
    }
    
    func subscriberActivate(email: String, сompletion: @escaping Completion) {
        let url = RouterUser.subscriberActivate(email: email)
        
        Alamofire.request(url).responseObject { (response: DataResponse<BoolResponse>) in
            let responseValue = response.result.value
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            if let intValue = responseValue?.data?.status {
                let isSubscribed = NSNumber(integerLiteral: intValue).boolValue
                сompletion(isSubscribed, nil)
                return
            }
            сompletion(nil, .cantCheckSubscriber)
        }
    }
    
}
