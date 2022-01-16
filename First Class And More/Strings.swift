//
//  Strings.swift
//  First Class And More
//
//  Created by Vadim on 22/01/2019.
//  Copyright © 2019 Shawn Frank. All rights reserved.
//

import Foundation

extension String {
	
	public enum Strings: String {
		case errorOccured
		case loading
		case selectGender
		case emptyName
		case emptyEmail
		case invalidEmail
		case emptyPassword
		case acceptPolicy
		
		case newUser
		case newbie
		case alreadySubscriber
		case subscriber
		case premiumUser
		case premiumer
		case notSubscriber
	}
	
	public func localized() -> String {
		return NSLocalizedString(self, comment: "")
	}
	
	// MARK: - Init
	
	public init(_ string: Strings) {
		self.init(string.rawValue.localized())
	}
	
	public init(_ string: Strings, value: Int) {
		self = String.localizedStringWithFormat(NSLocalizedString(String(string), comment: ""), value)
	}
}
