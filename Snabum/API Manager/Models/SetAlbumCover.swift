//
//  SetAlbumCover.swift
//  Snabum
//
//  Created by mac on 24/11/2025.
//


import Foundation

// MARK: - SetAlbumCover
struct SetAlbumCover: Codable {
    let success: Bool?
    let message: String?
    let data: SetCoverData?
}

// MARK: - SetCoverData
struct SetCoverData: Codable {
    let coverPhoto: Bool?
    let albumID, id: Int?
    let mediaType, originallyTakenAt: String?
    let metadata: Int?
    let createdAt, updatedAt: String?
    let fileUrls: [String]?

    enum CodingKeys: String, CodingKey {
        case coverPhoto = "cover_photo"
        case albumID = "album_id"
        case id
        case mediaType = "media_type"
        case originallyTakenAt = "originally_taken_at"
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fileUrls = "file_urls"
    }
}
