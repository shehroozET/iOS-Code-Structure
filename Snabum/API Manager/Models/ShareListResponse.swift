//
//  ShareListResponse.swift
//  Snabum
//
//  Created by mac on 21/10/2025.
//

import Foundation

// MARK: - ListSharedAlbums
struct ListSharedAlbums: Codable {
    let success: Bool?
    let message: String?
    let data: [ShareList]?
    let metaAttributes: MetaAttributes?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case metaAttributes = "meta_attributes"
    }
}

// MARK: - ShareList
struct ShareList: Codable {
    let id: Int?
    let shareableType: String?
    let shareableID: Int?
    let role, grantedAt: String?
    let shareable, grantedBy, sharedWithUser: SharedWithUser? // shareable has id of album from which we can get the
    let shareWithMe: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case shareableType = "shareable_type"
        case shareableID = "shareable_id"
        case role
        case grantedAt = "granted_at"
        case shareable
        case grantedBy = "granted_by"
        case sharedWithUser = "shared_with_user"
        case shareWithMe = "share_with_me"
    }
}

// MARK: - SharedWithUser
struct SharedWithUser: Codable {
    let id: Int?
    let name: String?
    let mediaCount : Int?
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case mediaCount = "media_count"
    }
}
