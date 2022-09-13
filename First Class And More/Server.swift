//
//  Server.swift
//  First Class And More
//
//  Created by Mikle Kusmenko on 4/18/17.
//  Copyright © 2017 Shawn Frank. All rights reserved.
//

import Foundation

final class Server {
    
    static let shared = Server()
	
	let baseUrl: String = "https://www.first-class-and-more.de"
    let url: String = "http://fcnm-be-staging.eu-central-1.elasticbeanstalk.com/api/v1"
    let wpURL: String = "http://fcnm-wp-staging.eu-central-1.elasticbeanstalk.com/api/fcnm/v1"
    let apiKey: String = "tZKWXujQ"
    
    public typealias Completion = (_ answer: Any?, _ error: Errors?) -> Void
}
