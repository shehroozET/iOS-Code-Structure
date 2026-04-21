//
//  FindUsers.swift
//  Snabum
//
//  Created by mac on 20/10/2025.
//

import UIKit

// MARK: - FindUsers
struct FindUsers: Codable {
    let success: Bool?
    let data: [UsersFound]?
}

// MARK: - UsersFound
struct UsersFound: Codable {
    let id: Int?
    let email, name: String?
    let pictureURL: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case name = "name"
        case pictureURL = "picture_url"
    }
}
