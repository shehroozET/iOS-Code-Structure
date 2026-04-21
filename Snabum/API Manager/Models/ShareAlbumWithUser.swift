//
//  ShareAlbumWithUser.swift
//  Snabum
//
//  Created by mac on 20/10/2025.
//

import Foundation


// MARK: - RemoveShareAccess
struct RemoveShareAccess: Codable {
    let success: Bool?
    let message: String?
}


// MARK: - ShareAlbumWithUser
struct ShareAlbumWithUser: Codable {
    let success: Bool?
    let message: String?
    let data: ShareClass?
}

// MARK: - ShareClass
struct ShareClass: Codable {
    let id: Int?
    let shareableType: String?
    let shareableID: Int?
    let role, grantedAt: String?
    let shareable, grantedBy, sharedWithUser: GrantedBy?
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

// MARK: - GrantedBy
struct GrantedBy: Codable {
    let id: Int?
    let name: String?
}
