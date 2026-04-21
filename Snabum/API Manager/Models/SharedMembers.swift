//
//  SharedMembers.swift
//  Snabum
//
//  Created by mac on 29/10/2025.
//


import Foundation

// MARK: - SharedMembers
struct SharedMembers: Codable {
    let success: Bool?
    let message: String?
    let data: [ListData]?
    let metaAttributes: MetaAttribut?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case metaAttributes = "meta_attributes"
    }
}

// MARK: - ListData
struct ListData: Codable {
    let id: Int?
    let shareableType: String?
    let shareableID: Int?
    let role, sharedAt: String?
    let shareable, sharedBy, sharedWithUser: sharedWithUser?
    let shareWithMe: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case shareableType = "shareable_type"
        case shareableID = "shareable_id"
        case role
        case sharedAt = "granted_at"
        case shareable
        case sharedBy = "granted_by"
        case sharedWithUser = "shared_with_user"
        case shareWithMe = "share_with_me"
    }
}

// MARK: - SharedWithUser
struct sharedWithUser: Codable {
    let id: Int?
    let name: String?
}

// MARK: - MetaAttributes
struct MetaAttribut: Codable {
    let currentPage, nextPage, prevPage, totalPages: Int?
    let totalCount: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case nextPage = "next_page"
        case prevPage = "prev_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
    }
}
