//
//  SessionManager.swift
//  petpal
//
//  Created by Owen Wong on 3/9/26.
//

import Foundation

struct UserResponse: Codable {
    let _id: String
    let username: String
    let headline: String?
    let location: String?
    let bio: String?
    let contactInfo: String?
}


class SessionManager {
    
    static let shared = SessionManager()
    
    var currentUser: UserResponse?
    
    private init() {}
}
