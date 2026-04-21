//
//  APIErrorResponse.swift
//  Snabum
//
//  Created by mac on 23/09/2025.
//

import Foundation

// MARK: - APIErrorResponse
struct APIErrorResponse: Codable {
    let success: Bool?
    let errors: [String]?
}
