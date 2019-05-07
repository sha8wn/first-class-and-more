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
    let url: String = "https://www.first-class-and-more.de/blog/fcam-api/app/v1"
    let apiKey: String = "tZKWXujQ"
    
    public typealias Completion = (_ answer: Any?, _ error: Errors?) -> Void
}
