//
//  Album.swift
//  Snabum
//
//  Created by mac on 09/10/2025.
//

import Foundation

// MARK: - Albums
struct Albums: Codable {
    let success: Bool?
    let message: String?
    let data: [AlbumsData]?
    let metaAttributes: MetaAttributes?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case metaAttributes = "meta_attributes"
    }
}

// MARK: - AlbumsData
struct AlbumsData: Codable {
    let id: Int?
    let name: String?
    let order, folderID: Int?
    let createdAt, updatedAt: String?
    let mediaCount: Int?
    var media: [Media]?
    let userID : Int?
    let folder: Folder?

    enum CodingKeys: String, CodingKey {
        case id, name, order
        case folderID = "folder_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case mediaCount = "media_count"
        case media, folder
    }
}

struct Media: Codable {
    let id, albumID: Int?
    let mediaType: String?
    let coverPhoto: Bool?
    let originally_taken_at: String?
    let url : [String]?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case albumID = "album_id"
        case mediaType = "media_type"
        case coverPhoto = "cover_photo"
        case url = "file_urls"
        case originally_taken_at = "originally_taken_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Folder
struct Folder: Codable {
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
