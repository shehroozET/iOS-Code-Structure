//
//  SharedAlbums.swift
//  Snabum
//
//  Created by mac on 09/10/2025.
//

import Foundation

// MARK: - SharedFolders
struct SharedFolders: Codable {
    let success: Bool?
    let message: String?
    let data: [FoldersData]?
    let metaAttributes: SharedFoldersAttributes?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case metaAttributes = "meta_attributes"
    }
    
}

// MARK: - SharedFoldersAttributes
struct SharedFoldersAttributes: Codable {
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
