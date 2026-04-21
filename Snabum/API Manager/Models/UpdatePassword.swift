//
//  UpdatePassword.swift
//  Snabum
//
//  Created by mac on 30/09/2025.
//

class UpdatePassword : Codable{
    let success: Bool?
    let message : String?
    let error : String?
    enum CodingKeys: String, CodingKey {
        case success, message , error
    }
}
