//
//  Folders.swift
//  Snabum
//
//  Created by mac on 09/10/2025.
//
import Foundation

// MARK: - Folders
import Foundation

// MARK: - CreateFolder
struct Folders: Codable {
    let success: Bool?
    let message: String?
    let data: [FoldersData]?
    let metaAttributes: MetaAttributes?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case metaAttributes = "meta_attributes"
    }
}

// MARK: - FoldersData
struct FoldersData: Codable {
    let id: Int?
    let name, description: String?
    let userID: Int?
    let createdAt, updatedAt: String?
    let albumCount: Int?
    let albums: [Album]?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case userID = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case albumCount = "album_count"
        case albums
    }
}

// MARK: - Album
struct Album: Codable {
    let id: Int?
    let name: String?
    let order, folderID: Int?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, order
        case folderID = "folder_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - MetaAttributes
struct MetaAttributes: Codable {
    let currentPage: Int?
    let nextPage, prevPage: Int?
    let totalPages, totalCount: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case nextPage = "next_page"
        case prevPage = "prev_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
    }
}
