//
//  CreateFolder.swift
//  Snabum
//
//  Created by mac on 09/10/2025.
//

import Foundation

// MARK: - CreateFolder
struct CreateFolder: Codable {
    let success: Bool?
    let message: String?
    let data: CFoldersData?
}

// MARK: - DataClass
struct CFoldersData: Codable {
    let id: Int?
    let name, description: String?
    let userID: Int?
    let createdAt, updatedAt: String?
    let albumCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case userID = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case albumCount = "album_count"
    }
}
