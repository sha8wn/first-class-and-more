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
    // get my deals
    func getSliderData(сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let getSliderDataURL = RouterOther.getSliderData(token: token)
        Alamofire.request(getSliderDataURL).responseObject { (response: DataResponse<SliderDataResponse>) in
            let responseValue = response.result.value
            print(#file, #line, responseValue?.data ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.result.value?.response?.status ?? "")
            if let slides = responseValue?.data {
                print(#file, #line, slides)
                сompletion(slides, nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantGetSliderData)
        }
    }
    
    // update push notification settigns
    func updatePushNotificationSettings(setting: Int, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let deviceToken = UserDefaults.standard.string(forKey: kUDDevicePushToken) ?? "55f23078281e424a6a8c410de53205455c088e4aad32bdecfa3bcce981d1bf86"
        guard !deviceToken.isEmpty else {
            сompletion(nil, .pushNotificationsAreDisabled)
            return
        }
        let updatePushNotificationSettingsURL = RouterOther.updatePushNotificationSettings(setting: setting, token: token, deviceToken: deviceToken)
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
        let token = UserModel.sharedInstance.token
        let getAdvertisementsURL = RouterOther.getAdvertisements(token: token)
        Alamofire.request(getAdvertisementsURL).responseObject { (response: DataResponse<AdvertisementsResponse>) in
            let responseValue = response.result.value
            print(#file, #line, responseValue?.data ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.result.value?.response?.status ?? "")
            
            if let advertisements = responseValue?.data {
                print(#file, #line, advertisements)
                сompletion(advertisements, nil)
                return
            }
            else if responseValue?.data == nil {
                print(#file, #line, [])
                сompletion([AdvertisementModel](), nil)
                return
            }
            else if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
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
    
    func changeAdsSettings(_ ads: Int, сompletion: @escaping Completion) {
        let pushToken = UserDefaults.standard.string(forKey: kUDDevicePushToken) ?? "55f23078281e424a6a8c410de53205455c088e4aad32bdecfa3bcce981d1bf86"
        let changeAdsSettingsURL = RouterOther.changeAdsSettings(ads: ads, pushToken: pushToken)
        Alamofire.request(changeAdsSettingsURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.data ?? "")
            print(#file, #line, response.result.value ?? "")
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
    
    func sendMessage(email: String, title: String, name: String, surname: String, subject: String, message: String, сompletion: @escaping Completion) {
        let route = RouterOther.sendMessage(email: email, title: title, name: name, surname: surname, subject: subject, message: message)
        Alamofire.request(route).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            print(#file, #line, response.request ?? "")
            print(#file, #line, response.response ?? "")
            print(#file, #line, response.data ?? "")
            print(#file, #line, response.result.value ?? "")
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
}
