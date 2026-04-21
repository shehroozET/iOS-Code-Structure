//
//  TokenManager.swift
//  Snabum
//
//  Created by mac on 23/09/2025.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "auth_token"
    private let clientKey = "auth_client"
    private let uidKey = "auth_uid"
    private let userIDKey = "auth_userID"

    private init() {}

    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    var client: String? {
        get { UserDefaults.standard.string(forKey: clientKey) }
        set { UserDefaults.standard.set(newValue, forKey: clientKey) }
    }

    var uid: String? {
        get { UserDefaults.standard.string(forKey: uidKey) }
        set { UserDefaults.standard.set(newValue, forKey: uidKey) }
    }
    
    var userID: String? {
        get { UserDefaults.standard.string(forKey: userIDKey) }
        set { UserDefaults.standard.set(newValue, forKey: userIDKey) }
    }

    func save(token: String?, client: String?, uid: String? , userIDKey : String?) {
        self.token = token
        self.client = client
        self.uid = uid
        self.userID = userIDKey
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: clientKey)
        UserDefaults.standard.removeObject(forKey: uidKey)
        UserDefaults.standard.removeObject(forKey: userIDKey)
    }
}


