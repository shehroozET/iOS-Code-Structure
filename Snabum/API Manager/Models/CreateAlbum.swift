//
//  CreateAlbum.swift
//  Snabum
//
//  Created by mac on 10/10/2025.
//


import Foundation

// MARK: - CreateAlbum
struct CreateAlbum: Codable {
    let success: Bool?
    let message: String?
    let data: CreateAlbumData?
}

// MARK: - CreateAlbumData
struct CreateAlbumData: Codable {
    let id: Int?
    let name: String?
    let order, folderID: Int?
    let createdAt, updatedAt: String?
    let mediaCount: Int?
    let media: [String]?
    let folder: CreateAlbumsFolder?

    enum CodingKeys: String, CodingKey {
        case id, name, order
        case folderID = "folder_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case mediaCount = "media_count"
        case media, folder
    }
}

// MARK: - createAlbumsFolder
struct CreateAlbumsFolder: Codable {
    let id: Int?
    let name, description: String?
    let userID: Int?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case userID = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
