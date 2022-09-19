//
//  RouterDeals.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/26/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

enum RouterDeals: URLRequestConvertible {
    
    enum Sorting {
        case none
        case title
        case date
        
        var toString: String {
            switch self {
            case .title: return "title"
            case .date: return "date"
            default: return ""
            }
        }
    }
    
    case getMyDeals(page: Int, params: String, filters: [Int])
    case getFavoriteDeals(token: String, page: Int, cat: Any?, filters: [Int])
    case addFavorite(id: Int, token: String)
    case deleteFavorite(id: Int, token: String)
    case getRecentDeals(token: String, page: Int, filters: [Int])
    case getHighlights(type: HighlightsType, params: String, page: Int, filters: [Int])
    case getPopularDeals(params: String, page: Int, filters: [Int])
    case getExpiringDeals(page: Int, params: String, filters: [Int])
    case getCategoryDeals(page: Int, params: String, filters: [Int])
    case getSidebarCategoryDeals(page: Int, params: String)
    
    var method: HTTPMethod {
        switch self {
            case .getMyDeals, .getFavoriteDeals, .getRecentDeals, .getExpiringDeals, .getHighlights, .getPopularDeals, .getCategoryDeals, .getSidebarCategoryDeals:
                return .get
            case .addFavorite:
                return .post
            case .deleteFavorite:
                return .delete
        }
    }
    
    var params: Parameters {
        switch self {
            case .getMyDeals(let page, let params, let filters):
                let filterQuery = params.replacingOccurrences(of: "%@", with: "\(filters)")
                let finalParams: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(filterQuery)}"
                ]
				return finalParams
            
            case .getRecentDeals(let token, let page, let filters):
                let params: [String: Any] = [
                    "token": token,
                    "page": page,
                    "limit": 20,
                    "exclude": getFiltersString(from: filters)
                ]
                return params
            
            case .getSidebarCategoryDeals(let page, let params):
                let finalParams: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(params)}"
                ]
                return finalParams
            
            case .getFavoriteDeals(let token, let page, let cat, let filters):
                var params: [String: Any] = [
                    "token": token,
                    "page": page,
                    "exclude": getFiltersString(from: filters)
                ]
                if let cat = cat as? [Int] {
                    params["cat"] = cat.compactMap { String($0) }.joined(separator: ",")
                }
                return params
            
            case .addFavorite(let id, let token), .deleteFavorite(let id, let token):
                return [
                    "fav": id,
                    "token": token
                ]
            
            case .getExpiringDeals(let page, let params, let filters):
                let filterQuery = params.replacingOccurrences(of: "%@", with: "\(filters)")
                let finalParams: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(filterQuery)}"
                ]
                
                return finalParams
            
            case .getPopularDeals(let params, let page, let filters):
                let filterQuery = params.replacingOccurrences(of: "%@", with: "\(filters)")
                let finalParams: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(filterQuery)}"
                ]
				return finalParams
            
            case .getHighlights(_, let params, let page, let filters):
                let filterQuery = params.replacingOccurrences(of: "%@", with: "\(filters)")
                let finalParams: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(filterQuery)}"
                ]
				return finalParams
            
            case .getCategoryDeals(let page, let params, let filters):
                let filterQuery = params.replacingOccurrences(of: "%@", with: "\(filters)")
                let finalParams: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(filterQuery)}"
                ]
                return finalParams
        }
    }
	
	private func getFiltersString(from filters: [Int]) -> String {
		return filters.compactMap { String($0) }.joined(separator: ",")
	}
    
    var url: String {
        switch self {
        case .getMyDeals, .getHighlights, .getPopularDeals, .getSidebarCategoryDeals, .getExpiringDeals, .getCategoryDeals:
                return "/posts"
            case .getFavoriteDeals, .addFavorite, .deleteFavorite:
                return "/favourites/"
            case .getRecentDeals:
                return "/recent-deals/"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = try Server.shared.wpURL.asURL()
        
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
        
        urlRequest.setValue(Server.shared.basicAuth,
                            forHTTPHeaderField: "Authorization")
        
        if let url = urlRequest.url {
            print(url.absoluteString.removingPercentEncoding ?? "")
        }
        
        return urlRequest
    }
}
