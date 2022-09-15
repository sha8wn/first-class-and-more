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
    
    case getMyDeals(page: Int, filters: [Int])
    case getFavoriteDeals(token: String, page: Int, cat: Any?, filters: [Int])
    case addFavorite(id: Int, token: String)
    case deleteFavorite(id: Int, token: String)
    case getRecentDeals(token: String, page: Int, filters: [Int])
    case getHighlights(type: HighlightsType, params: String, page: Int, filters: [Int])
    case getPopularDeals(params: String, page: Int, filters: [Int])
    case getExpiringDeals(token: String, page: Int, cat: Any?, filters: [Int])
    case getCategoryDeals(token: String, page: Int, cat: Any?, cat2: Any?, cat3: Any?, destinations: Any?, filters: [Int], orderBy: Sorting)
    
    var method: HTTPMethod {
        switch self {
            case .getMyDeals, .getFavoriteDeals, .getRecentDeals, .getExpiringDeals, .getHighlights, .getPopularDeals, .getCategoryDeals:
                return .get
            case .addFavorite:
                return .post
            case .deleteFavorite:
                return .delete
        }
    }
    
    var params: Parameters {
        switch self {
            case .getMyDeals(let page, let filters):
                let params: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20}"
//                    "page": page,
//                    "limit": 20,
//					"exclude": getFiltersString(from: filters)
                ]
				return params
            
            case .getRecentDeals(let token, let page, let filters):
                let params: [String: Any] = [
                    "token": token,
                    "page": page,
                    "limit": 20,
                    "exclude": getFiltersString(from: filters)
                ]
            return params
            
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
            case .getExpiringDeals(let token, let page, let cat, let filters):
                var params: [String: Any] = [
                    "token": token,
                    "page": page,
                    "exclude": getFiltersString(from: filters)
                ]
                if let cat = cat as? [Int] {
                    params["cat"] = cat.compactMap { String($0) }.joined(separator: ",")
                }
                if let cat = cat as? Int {
                    params["fav"] = cat
                }
                return params
            case .getPopularDeals(let params, let page, let filters):
                let params: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(params)}"
                ]
				return params
            case .getHighlights(_, let params, let page, let filters):
                let params: [String: Any] = [
                    "query": "{\"page\":\(page), \"limit\": 20, \(params)}"
//                    "page": page,
//					"exclude": getFiltersString(from: filters)
                ]
				return params
            case .getCategoryDeals(let token, let page, let cat, let cat2, let cat3, let destinations, let filters, let orderBy):
                var params: [String: Any] = [
                    "token": token,
                    "page": page,
                    "exclude": getFiltersString(from: filters)
                ]
                if let cat = cat as? [Int] {
                    params["cat"] = cat.compactMap { String($0) }.joined(separator: ",")
                }
                if let cat2 = cat2 as? [Int] {
                    params["cat2"] = cat2.compactMap { String($0) }.joined(separator: ",")
                    params["op"] = "and"
                }
                if let cat3 = cat3 as? [Int] {
                    params["cat3"] = cat3.compactMap { String($0) }.joined(separator: ",")
                }
                if let destinations = destinations as? [Int] {
                    params["des"] = destinations.compactMap { String($0) }.joined(separator: ",")
                }
                if orderBy != .none {
                    params["order_by"] = orderBy.toString
                }
                return params
        }
    }
	
	private func getFiltersString(from filters: [Int]) -> String {
		return filters.compactMap { String($0) }.joined(separator: ",")
	}
    
    var url: String {
        switch self {
            case .getMyDeals, .getHighlights, .getPopularDeals:
                return "/posts"
            case .getFavoriteDeals, .addFavorite, .deleteFavorite:
                return "/favourites/"
            case .getRecentDeals:
                return "/recent-deals/"
            case .getExpiringDeals:
                return "/expiring-deals/"
            case .getCategoryDeals:
                return "/category-deals/"
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
        
        return urlRequest
    }
}
