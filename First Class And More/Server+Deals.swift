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
    case my, highlights, popular, favoriten, expiring, category, sidebarCategory
}

extension Server {
    func loadDeals(type: DealRequest, param: Any?, page: Int, shouldSendFilters: Bool = false, shouldSendDestinationFltersOnly: Bool = false, orderBy: RouterDeals.Sorting = .none, сompletion: @escaping Completion) {
        let token = UserModel.sharedInstance.token
        var url: RouterDeals?
		
		let filterIdentifiers = shouldSendFilters ? getFilterIdentifiers() : []
        
        switch type {
            case .my:
            if let param = param as? [String: Any],
               let filterQuery = param["filters"] as? String {
                url = RouterDeals.getMyDeals(page: page, params: filterQuery, filters: filterIdentifiers)
            }
                
            case .highlights:
                if let param = param as? [String: Any],
                let type = param["type"] as? HighlightsType,
                let filterQuery = param["filters"] as? String {
                    url = RouterDeals.getHighlights(type: type, params: filterQuery, page: page, filters: filterIdentifiers)
                }
            case .popular:
            if let param = param as? [String: Any],
            let filterQuery = param["filters"] as? String {
                url = RouterDeals.getPopularDeals(params: filterQuery, page: page, filters: filterIdentifiers)
            }
                
            case .favoriten:
                url = RouterDeals.getFavoriteDeals(token: token, page: page, cat: param, filters: filterIdentifiers)
            
            case .expiring:
                if let param = param as? [String: Any],
                   let filterQuery = param["filters"] as? String {
                    url = RouterDeals.getExpiringDeals(page: page, params: filterQuery, filters: filterIdentifiers)
                }
                
            case .category:
                if let param = param as? [String: Any],
                   let filterQuery = param["filters"] as? String
                {
                    url = RouterDeals.getCategoryDeals(page: page,
                                                       params: filterQuery,
                                                       filters: filterIdentifiers)
                }
            
            case .sidebarCategory:
                if let param = param as? [String: Any],
                   let filterQuery = param["filters"] as? String {
                    url = RouterDeals.getSidebarCategoryDeals(page: page, params: filterQuery)
                }
        }
            
        if let url = url {
            Alamofire.request(url)
                .validate()
                .responseObject { (response: DataResponse<DealsResponse>) in
                
                    let responseValue = response.result.value
                    
                    switch response.result {
                        
                    case .success(_):
                        if let responseData = response.data {
                            let dealsResponse = JSON(responseData)
                            print(dealsResponse)
                            
                            if let deals = responseValue {
                                сompletion(deals.data, nil)
                                return
                            }
                        }
                    
                    case .failure(_):
                        сompletion(nil, .cantGetDeals)
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
