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
    
    func login(email: String, password: String, сompletion: @escaping Completion) {
        
        let defaults = UserDefaults.standard
        let fcmToken = defaults.string(forKey: kUDFCMToken) ?? ""
        
        let loginURL = RouterUser.login(email: email, password: password, fcmToken: fcmToken)
        
        Alamofire.request(loginURL).responseObject { (response: DataResponse<StringResponse>) in
            
            let responseValue = response.result.value
            
            if let responseData = response.data {
                let loginResponse = JSON(responseData)
                
                if let accessToken = loginResponse["access_token"].string {
                    
                    let userModel      = UserModel.sharedInstance
                    userModel.email    = email
                    userModel.password = password
                    userModel.token = accessToken
                    userModel.isLoggedIn  = true
                    
                    // save userModel
                    let data = NSKeyedArchiver.archivedData(withRootObject: userModel)
                    UserDefaults.standard.set(data, forKey: kUDSharedUserModel)
                    UserDefaults.standard.synchronize()
                    
                    сompletion(true, nil)
                    return
                }
            }
            
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            
            сompletion(nil, .cantLogin)
        }
    }
    
    // register
    func register(salutation: Int, email: String, surname: String, wantSubscribe: Bool, сompletion: @escaping Completion) {
        let fcmToken = UserDefaults.standard.string(forKey: kUDFCMToken) ?? ""
        
        let registerURL = RouterUser.register(salutation: salutation,
                                              email: email,
                                              surname: surname,
                                              wantSubscribe: wantSubscribe,
                                              fcmToken: fcmToken)
        
        Alamofire.request(registerURL)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                
                switch response.result {
                case .success(_):
                    if let _ = response.data {
                        сompletion(true, nil)
                        return
                    }
                    
                case .failure(_):
                    if let responseData = response.data {
                        let errorResponse = JSON(responseData)
                        
                        if let errorString = errorResponse["error"].string {
                            сompletion(nil, .custom(errorString))
                            return
                        }
                        
                        сompletion(nil, .cantRegister)
                        return
                    }
                }
                
                сompletion(nil, .cantRegister)
            }
    }
    
    func subscribeToNewsletter(email: String, сompletion: @escaping Completion) {
        let fcmToken = UserDefaults.standard.string(forKey: kUDFCMToken) ?? ""
        
        let newsletterSubscribeURL = RouterUser.subscribeNewsletter(email: email, fcmToken: fcmToken)
        Alamofire.request(newsletterSubscribeURL)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                
                switch response.result {
                case .success(_):
                    if let _ = response.data {
                        сompletion(true, nil)
                        return
                    }
                    
                case .failure(_):
                    if let responseData = response.data {
                        let errorResponse = JSON(responseData)
                        
                        if let errorString = errorResponse["error"].string {
                            
                            if errorString == "Duplicate key: email" {
                                сompletion(true, nil)
                                return
                            }
                            
                            сompletion(nil, .custom(errorString))
                            return
                        }
                        
                        сompletion(nil, .custom("Vorgang konnte nicht abgeschlossen werden. Versuche es erneut."))
                        return
                    }
                }
                
                сompletion(nil, .custom("Vorgang konnte nicht abgeschlossen werden. Versuche es erneut."))
            }
    }
    
    // check subscriber
    func checkSubscriber(email: String, сompletion: @escaping Completion) {
        let checkSubscriberURL = RouterUser.checkSubscriber(email: email)
        Alamofire.request(checkSubscriberURL)
            .validate()
            .responseObject { (response: DataResponse<BoolResponse>) in
                let responseValue = response.result.value
                
                switch response.result {
                case .success(_):
                    
                    if let responseData = response.data {
                        let verifyResponse = JSON(responseData)
                        
                        if let userStatus = verifyResponse["message"].string {
                            
                            if userStatus == "subscriber" {
                                сompletion(SubscriberType.regular, nil)
                                return
                            }
                            
                            if userStatus == "premium-member" {
                                сompletion(SubscriberType.premium, nil)
                                return
                            }
                        }
                    }
                    
                    сompletion(SubscriberType.unsubscribed, nil)
                    
                case .failure(_):
                    if let responseData = response.data {
                        let errorResponse = JSON(responseData)
                        
                        if let errorString = errorResponse["error"].string,
                           errorString == "Email address not available." {
                            сompletion(SubscriberType.unsubscribed, .custom(errorString))
                            return
                        }
                        
                        сompletion(nil, .cantCheckSubscriber)
                        return
                    }
                }
                
                if let error = responseValue?.message {
                    сompletion(nil, .custom(error))
                    return
                }
                
                сompletion(nil, .cantCheckSubscriber)
            }
    }
    
    // forgot password
    func forgotPassword(email: String, сompletion: @escaping Completion) {
        let forgotPasswordURL = RouterUser.forgotPassword(email: email)
        Alamofire.request(forgotPasswordURL)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                
                switch response.result {
                case .success(_):
                    if let responseData = response.data {
                        let forgotPasswordResponse = JSON(responseData)
                        print(forgotPasswordResponse)
                        сompletion(true, nil)
                        return
                    }
                    
                case .failure(_):
                    
                    if let responseData = response.data {
                        let forgotPasswordErrorResponse = JSON(responseData)
                        
                        if let error = forgotPasswordErrorResponse["error"].string {
                            сompletion(nil, .custom(error))
                            return
                        }
                    }
                    
                    сompletion(nil, .cantSendForgotPassword)
                }
            }
    }
    
    func getAdSettings(сompletion: @escaping Completion) {
        let getUserProfileURL = RouterUser.getUserProfile(token: UserModel.sharedInstance.token)
        
        Alamofire.request(getUserProfileURL)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                
                let responseValue = response.result.value
                print(#file, #line, responseValue?.data ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.result.value?.response?.status ?? "")
                
                switch response.result {
                    case .success(_):
                    
                    if let responseData = response.data {
                        let userProfileResponse = JSON(responseData)
                        let customerMeta = userProfileResponse["meta"]
                        
                        if let appDataJSONString = customerMeta["app_data"].string,
                           let appData = appDataJSONString.convertToDictionary() {
    
                            сompletion(appData, nil)
                            return
                        }
                        
                        // set default ad settings
                        сompletion(["favourites": [], "ad_settings": 1], nil)
                    }
                    
                    case .failure(_):
                        сompletion(nil, .cantGetSettings)
                }
            }
    }
    
    func getFavorites(сompletion: @escaping Completion) {
        let getUserProfileURL = RouterUser.getUserProfile(token: UserModel.sharedInstance.token)
        
        Alamofire.request(getUserProfileURL)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                
                let responseValue = response.result.value
                print(#file, #line, responseValue?.data ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.result.value?.response?.status ?? "")
                
                switch response.result {
                    case .success(_):
                    
                    if let responseData = response.data {
                        let userProfileResponse = JSON(responseData)
                        let customerMeta = userProfileResponse["meta"]
                        
                        if let appDataJSONString = customerMeta["app_data"].string,
                           let appData = appDataJSONString.convertToDictionary() {
    
                            сompletion(appData, nil)
                            return
                        }
                        
                        // set default ad settings
                        сompletion(["favourites": [], "ad_settings": 1], nil)
                    }
                    
                    case .failure(_):
                        сompletion(nil, .cantGetSettings)
                }
            }
    }
    
    func getUserProfile(сompletion: @escaping Completion) {
        let getUserProfileURL = RouterUser.getUserProfile(token: UserModel.sharedInstance.token)
        
        Alamofire.request(getUserProfileURL)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                
                let responseValue = response.result.value
                print(#file, #line, responseValue?.data ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.result.value?.response?.status ?? "")
                
                switch response.result {
                case .success(_):
                    
                    if let responseData = response.data {
                        let userProfileResponse = JSON(responseData)
                        let userModel = UserModel.sharedInstance
                        
                        if let name = userProfileResponse["first_name"].string {
                            userModel.name = name
                        }
                        
                        if let surname = userProfileResponse["last_name"].string {
                            userModel.surname = surname
                        }
                        
                        if let membership = userProfileResponse["membership"].int {
                            
                            if membership == 1 {
                                userModel.membership = .none
                            }
                            
                            if membership == 2 {
                                userModel.membership = .gold
                            }
                            
                            if membership == 3 {
                                userModel.membership = .platin
                            }
                            
                            if membership == 4 {
                                userModel.membership = .diamont
                            }
                        }
                        
                        if let salutation = userProfileResponse["salutation"].int {
                            userModel.salutation = salutation
                        }
                        else {
                            userModel.salutation = 1
                        }
                        
                        if let membershipExpires = userProfileResponse["membership_expiry"].string {
                            userModel.membershipExpires = membershipExpires
                        }
                        
                        // save userModel
                        let data = NSKeyedArchiver.archivedData(withRootObject: userModel)
                        UserDefaults.standard.set(data, forKey: kUDSharedUserModel)
                        UserDefaults.standard.synchronize()
                        
                        сompletion(true, nil)
                        return
                    }
                    
                case .failure(_):
                    if let responseData = response.data {
                        let errorResponse = JSON(responseData)
                        
                        if let errorString = errorResponse["error"].string,
                           errorString == "Unable to retrieve user profile" {
                            сompletion(SubscriberType.unsubscribed, nil)
                            return
                        }
                        
                        сompletion(nil, .cantCheckSubscriber)
                        return
                    }
                }
                
                if let error = responseValue?.message {
                    сompletion(nil, .custom(error))
                    return
                }
                
                сompletion(nil, .cantCheckSubscriber)
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
        let checkUserTokenURL = RouterUser.checkUserToken
        
        Alamofire.request(checkUserTokenURL)
            .validate()
            .responseObject { (response: DataResponse<CheckUserTokenResponse>) in
                
                let responseValue = response.result.value
                print(#file, #line, responseValue?.data ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.result.value?.response?.status ?? "")
                
                switch response.result {
                case .success(_):
                    if let responseData = response.data {
                        let tokenRefreshResponse = JSON(responseData)
                        let userModel = UserModel.sharedInstance
                        
                        if let token = tokenRefreshResponse["access_token"].string {
                            print(token)
                            userModel.token = token
                            
                            // save userModel
                            let data = NSKeyedArchiver.archivedData(withRootObject: userModel)
                            UserDefaults.standard.set(data, forKey: kUDSharedUserModel)
                            UserDefaults.standard.synchronize()
                            
                            сompletion(200, nil)
                            return
                        }
                        
                        сompletion(401, nil)
                    }
                    
                case .failure(_):
                    сompletion(401, nil)
                    return
                }
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
