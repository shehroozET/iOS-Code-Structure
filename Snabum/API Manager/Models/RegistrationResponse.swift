//
//  Models.swift
//  Snabum
//
//  Created by mac on 23/09/2025.
//


import Foundation

// MARK: - RegistrationResponse
struct RegistrationResponse: Codable {
    let status: String?
    let data: RegistrationData?
    let token: Token?
    let errors: Errors?
}

// MARK: - RegistrationData
struct RegistrationData: Codable {
    let id: Int?
    let provider, uid: String?
    let allowPasswordChange: Bool?
    let name, email: String?
    let phone, resetCode, resetCodeSentAt: Int?
    let createdAt, updatedAt: String?
    let pictureURL: String?
    let setting: Setting?

    enum CodingKeys: String, CodingKey {
        case id, provider, uid
        case allowPasswordChange = "allow_password_change"
        case name, email, phone
        case resetCode = "reset_code"
        case resetCodeSentAt = "reset_code_sent_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pictureURL = "picture_url"
        case setting
    }
}

// MARK: - Token
struct Token: Codable {
    let accessToken, tokenType, client, expiry: String?
    let uid, authorization: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access-token"
        case tokenType = "token-type"
        case client, expiry, uid
        case authorization = "Authorization"
    }
}
struct Errors: Codable {
    let fullMessages: [String]

    enum CodingKeys: String, CodingKey {
        case fullMessages = "full_messages"
    }
}


