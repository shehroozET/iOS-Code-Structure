//
//  LoginResponse.swift
//  Snabum
//
//  Created by mac on 23/09/2025.
//

import Foundation

struct LoginResponse: Codable {
    let data: DataClass?
    var success: Bool? = nil
    var errors: [String]? = nil
}

// MARK: - DataClass
struct DataClass: Codable {
    let email, provider, uid: String?
    let id: Int?
    let allowPasswordChange: Bool?
    let name, phone, profileImage , gender: String?
    let resetCode: String?
    let resetCodeSentAt: String?
    let createdAt, updatedAt: String?
    let setting: Settings?

    enum CodingKeys: String, CodingKey {
        case email, provider, uid, id
        case allowPasswordChange = "allow_password_change"
        case name = "name"
        case profileImage = "picture_url"
        case phone, gender
        case resetCode = "reset_code"
        case resetCodeSentAt = "reset_code_sent_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case setting
    }
}

// MARK: - Settings
struct Settings: Codable {
    let id, userID: Int?
    let sound, vibrate, pushNotification, emailNotification: Bool?
    let language: String?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case sound, vibrate
        case pushNotification = "push_notification"
        case emailNotification = "email_notification"
        case language
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
