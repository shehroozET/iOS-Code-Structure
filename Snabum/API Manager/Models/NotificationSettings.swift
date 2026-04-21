//
//  NotificationSettings.swift
//  Snabum
//
//  Created by mac on 02/10/2025.
//

import Foundation

struct NotificationSettings: Codable {
    let success: Bool?
    let message: String?
    let data: NotificationData?
}

// MARK: - NotificationData
struct NotificationData: Codable {
    let userID: Int?
    let sound, vibrate, pushNotification, emailNotification: Bool?
    let id: Int?
    let language: String? = nil
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case sound, vibrate
        case pushNotification = "push_notification"
        case emailNotification = "email_notification"
        case id, language
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
