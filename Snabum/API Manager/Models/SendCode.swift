//
//  SendCode.swift
//  Snabum
//
//  Created by mac on 29/09/2025.
//

struct SendCode: Codable {
    let success: Bool?
    let message : String?
    let error : String?
    enum CodingKeys: String, CodingKey {
        case success, message , error
    }
}
