//
//  Server+Other.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/29/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import AlamofireObjectMapper

extension Server {
    // get slider data
    func getSliderData(сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let getSliderDataURL = RouterOther.getSliderData(token: token)
        Alamofire.request(getSliderDataURL)
            .validate()
            .responseArray { (response: DataResponse<[SlideModel]>) in
            
            let responseValue = response.result.value
                
            switch response.result {
                
            case .success(_):
                if let responseData = response.data {
                    let slidesResponse = JSON(responseData)
                    print(slidesResponse)
                    
                    if let slides = responseValue {
                        сompletion(slides, nil)
                        return
                    }
                }
            
            case .failure(_):
                сompletion(nil, .cantGetSliderData)
            }
        }
    }
    
    // update push notification settigns
    func updatePushNotificationSettings(setting: Int, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let deviceToken = UserDefaults.standard.string(forKey: kUDDevicePushToken) ?? "55f23078281e424a6a8c410de53205455c088e4aad32bdecfa3bcce981d1bf86"
        let fcmToken = UserDefaults.standard.string(forKey: kUDFCMToken) ?? ""
        guard !deviceToken.isEmpty else {
            сompletion(nil, .pushNotificationsAreDisabled)
            return
        }
        let updatePushNotificationSettingsURL = RouterOther.updatePushNotificationSettings(setting: setting, token: token, deviceToken: deviceToken, fcmToken: fcmToken)
        Alamofire.request(updatePushNotificationSettingsURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            print(#file, #line, responseValue?.data ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.result.value?.response?.status ?? "")
            if let success = responseValue?.data {
                print(#file, #line, success)
                сompletion(success == "success", nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantUpdatePushNotifications)
        }
    }
    
    // get advertisements
    func getAdvertisements(сompletion: @escaping Completion) {
        let getAdvertisementsURL = RouterOther.getAdvertisements
        
        Alamofire.request(getAdvertisementsURL)
            .validate()
            .responseObject { (response: DataResponse<AdvertisementsResponse>) in
                let responseValue = response.result.value
                print(#file, #line, responseValue?.data ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.result.value?.response?.status ?? "")
                
                
                switch response.result {
                    
                case .success(_):
                    сompletion(responseValue?.data ?? [AdvertisementModel](), nil)
                    return
                    
                case .failure(_):
                    сompletion(nil, nil)
                }
                
//                if let error = responseValue?.message {
//                    сompletion(nil, .custom(error))
//                    return
//                }
//                сompletion(responseValue?.data ?? [AdvertisementModel](), nil)
            }
    }
    
    func getProfilesAndTests(_ id: Int, page: Int, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let getProfilesAndTestsURL = RouterOther.getProfilesAndTests(token: token, id: id, page: page)
        Alamofire.request(getProfilesAndTestsURL).responseObject { (response: DataResponse<ProfilesAndTestsResponse>) in
            let responseValue = response.result.value
            print(#file, #line, responseValue?.data ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.result.value?.response?.status ?? "")
            if let locations = responseValue?.data {
                print(#file, #line, locations)
                сompletion(locations, nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantGetLocations)
        }
    }
    
    func subscribeNewsletter(_ email: String, сompletion: @escaping Completion) {
        let subscribeNewsletterURL = RouterOther.subscribeNewsletter(email: email)
        Alamofire.request(subscribeNewsletterURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            if let success = responseValue?.data, success == "success" {
                сompletion(true, nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .custom("Vorgang konnte nicht abgeschlossen werden. Versuche es erneut."))
        }
    }
    
    func changeUserSettings(_ settings: String, сompletion: @escaping Completion) {
        let changeAdsSettingsURL = RouterOther.changeUserSettings(settings: settings)
        Alamofire.request(changeAdsSettingsURL)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.data ?? "")
                print(#file, #line, response.result.value ?? "")
                
                switch response.result {
                    
                case .success(_):
                    сompletion(true, nil)
                    return
                    
                case .failure(_):
                    сompletion(nil, .custom("Vorgang konnte nicht abgeschlossen werden. Versuche es erneut."))
                }
        }
    }
    
    func sendMessage(email: String, title: Int, name: String, surname: String, subject: String, message: String, сompletion: @escaping Completion) {
        let route = RouterOther.sendMessage(email: email, title: title, name: name, surname: surname, subject: subject, message: message)
        Alamofire.request(route)
            .validate()
            .responseObject { (response: DataResponse<StringResponse>) in
                
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.data ?? "")
                print(#file, #line, response.result.value ?? "")
                
                switch response.result {
                    
                case .success(_):
                    if let responseData = response.data {
                        let response = JSON(responseData)
                        print(response)
                        сompletion(true, nil)
                        return
                    }
                    
                case .failure(_):
                    сompletion(nil, .custom("Vorgang konnte nicht abgeschlossen werden. Versuche es erneut."))
                }
        }
    }
    
    func getAppVersion(сompletion: @escaping Completion)
    {
        let route = RouterOther.getAppVersion(token: "")
        Alamofire.request(route).responseObject { (response: DataResponse<StringResponse>) in
            
            сompletion(nil, .custom("Vorgang konnte nicht abgeschlossen werden. Versuche es erneut."))
            
        }
    }
}
