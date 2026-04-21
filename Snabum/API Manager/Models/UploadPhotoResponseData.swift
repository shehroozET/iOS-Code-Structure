//
//  UploadPhotoResponseData.swift
//  Snabum
//
//  Created by mac on 09/10/2025.
//
import Foundation

// MARK: - UploadPhotoResponse
struct UploadPhotoResponse: Codable {
    let success: Bool?
    let message: String?
    let data: UploadPhotoResponseData?
}

// MARK: - UploadPhotoResponseData
struct UploadPhotoResponseData: Codable {
    let id, albumID: Int?
    let mediaType: String?
    let metadata: Int?
    let createdAt, updatedAt: String?
    let fileUrls: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case albumID = "album_id"
        case mediaType = "media_type"
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fileUrls = "file_urls"
    }
}
