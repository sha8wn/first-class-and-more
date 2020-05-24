//
//  Server+Deals.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/26/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import AlamofireObjectMapper

internal enum HighlightsType: String {
    case ohneLogin = "no", gold = "gold", platin = "platin"
}

internal enum DealRequest {
    case my, highlights, popular, favoriten, expiring, category
}

extension Server {
    func loadDeals(type: DealRequest, param: Any?, page: Int, shouldSendFilters: Bool = false, orderBy: RouterDeals.Sorting = .none, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        var url: RouterDeals?
		
		let filterIdentifiers = shouldSendFilters ? getFilterIdentifiers() : []
		
        switch type {
            case .my:
                url = RouterDeals.getMyDeals(token: token, page: page, filters: filterIdentifiers)
            case .highlights:
                if let highlightsType = param as? HighlightsType {
                    url = RouterDeals.getHighlights(type: highlightsType, token: token, page: page, filters: filterIdentifiers)
                }
            case .popular:
                url = RouterDeals.getPopularDeals(token: token, page: page, filters: filterIdentifiers)
            case .favoriten:
                url = RouterDeals.getFavoriteDeals(token: token, page: page, cat: param, filters: filterIdentifiers)
            case .expiring:
                url = RouterDeals.getExpiringDeals(token: token, page: page, cat: param, filters: filterIdentifiers)
            case .category:
                if let dict = param as? [String: Any] {
                    
                    if let firstRow = dict["first"], let secondRow = dict["second"], let thirdRow = dict["third"], let filteredDestionationIds = dict["destinations"] {
                        url = RouterDeals.getCategoryDeals(token: token, page: page, cat: firstRow, cat2: secondRow, cat3: thirdRow, destinations: filteredDestionationIds, filters: filterIdentifiers, orderBy: orderBy)
                    }
                    else if let firstRow = dict["first"], let secondRow = dict["second"], let filteredDestionationIds = dict["destinations"] {
                        url = RouterDeals.getCategoryDeals(token: token, page: page, cat: firstRow, cat2: secondRow, cat3: nil, destinations: filteredDestionationIds, filters: filterIdentifiers, orderBy: orderBy)
                    } else if let firstRow = dict["first"], let filteredDestionationIds = dict["destinations"] {
                        url = RouterDeals.getCategoryDeals(token: token, page: page, cat: firstRow, cat2: nil, cat3: nil, destinations: filteredDestionationIds, filters: filterIdentifiers, orderBy: orderBy)
                    } else if let firstRow = dict["first"], let secondRow = dict["second"] {
                        url = RouterDeals.getCategoryDeals(token: token, page: page, cat: firstRow, cat2: secondRow, cat3: nil, destinations: nil, filters: filterIdentifiers, orderBy: orderBy)
                    } else if let firstRow = dict["first"] {
                        url = RouterDeals.getCategoryDeals(token: token, page: page, cat: firstRow, cat2: nil, cat3: nil, destinations: nil, filters: filterIdentifiers, orderBy: orderBy)
                    }
                } else {
                    url = RouterDeals.getCategoryDeals(token: token, page: page, cat: param, cat2: nil, cat3: nil, destinations: nil, filters: filterIdentifiers, orderBy: orderBy)
                }
        }
        if let url = url {
            Alamofire.request(url).responseObject { (response: DataResponse<DealsResponse>) in
                let responseValue = response.result.value
                print(#file, #line, responseValue?.data ?? "")
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.result.value?.response?.status ?? "")
                if let deals = responseValue?.data {
                    сompletion(deals, nil)
                    return
                }
                if self.shouldIgnoreError(for: responseValue, type: type) {
                    сompletion([], nil)
                    return
                }
                if let error = responseValue?.message {
                    сompletion(nil, .custom(error))
                    return
                }
                сompletion(nil, .cantGetDeals)
            }.responseString(completionHandler: { response in
                print(#file, #line, response.response ?? "")
                print(#file, #line, response.request ?? "")
                print(#file, #line, response.result.value ?? "")
            })
        }
    }
    
    private func shouldIgnoreError(for response: DealsResponse?, type: DealRequest) -> Bool {
        guard let response = response else { return false }
        if type == .favoriten {
            if response.code == "no_favorites" {
                return true
            }
        }
        return false
    }
    
    // add favorite deal
    func addFavorite(id: Int, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let addFavoriteURL = RouterDeals.addFavorite(id: id, token: token)
        Alamofire.request(addFavoriteURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            if let success = responseValue?.data {
                print(#file, #line, success)
                сompletion(success == "success", nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantAddFavoriteDeal)
        }
    }
    
    // delete favorite deal
    func deleteFavorite(id: Int, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        let deleteFavoriteURL = RouterDeals.deleteFavorite(id: id, token: token)
        Alamofire.request(deleteFavoriteURL).responseObject { (response: DataResponse<StringResponse>) in
            let responseValue = response.result.value
            if let success = responseValue?.data {
                print(#file, #line, success)
                сompletion(success == "success", nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantDeleteFavoriteDeal)
        }
    }
    
    // get recent deals 
    func getRecentDeals(page: Int, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
		let getRecentDealsURL = RouterDeals.getRecentDeals(token: token, page: page, filters: [])
        Alamofire.request(getRecentDealsURL).responseObject { (response: DataResponse<DealsResponse>) in
            let responseValue = response.result.value
            if let deals = responseValue?.data {
                print(#file, #line, deals)
                сompletion(deals, nil)
                return
            }
            if let error = responseValue?.message {
                сompletion(nil, .custom(error))
                return
            }
            сompletion(nil, .cantGetRecentDeals)
        }
    }
	
	// Helpers
	
	private func getFilterIdentifiers() -> [Int] {
		return (UserDefaults.standard.object(forKey: kUDUnselectedFilters) as? [Int] ?? [])
	}
}
