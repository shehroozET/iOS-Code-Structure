//
//  APIRouter.swift
//  Snapbum
//
//  Created by mac on 23/09/2025.
//

import Alamofire

// MARK: - APIRouter

enum APIRouter: URLRequestConvertible {
    
    // MARK: - Authentication
    case login(email: String, password: String)
    case register(name: String, email: String, password: String, passwordConfirmation: String)
    case sendCode(email: String)
    case verifyCode(email: String, code: String)
    case updatePassword(email: String, code: String, password: String, passwordConfirmation: String)
    
    // MARK: - Media Deletion
    case deleteMedia(mediaID: Int)
    case deleteFolder(folderID: Int)
    case deleteAlbum(albumID: Int)
    
    // MARK: - Folder & Album
    case getFolders
    case getSharedMembersList
    case getSharedFolders
    case getAlbums
    case showAlbum(albumID: Int)
    case createFolder(name: String, description: String)
    case createAlbum(name: String)
    case setAlbumCover(photoID: Int, albumID: Int, setCover: Bool)
    
    // MARK: - Sharing
    case shareAlbum(userID: String, albumID: String, canEdit: Bool)
    case unshareAlbum(albumID: String)
    
    // MARK: - Profile & Settings
    case getUserProfile
    case updateProfile(username: String, email: String, phone: String)
    case updateSettings(pushNotification: Bool, emailNotification: Bool)
    case changePassword(currentPassword: String, newPassword: String, confirmPassword: String)
    
    // MARK: - Search
    case globalSearch(keyword: String, filterType: String)
    case searchUser(email: String)
}

// MARK: - HTTP Method

extension APIRouter {
    
    var method: HTTPMethod {
        switch self {
            
        // Authentication
        case .login,
             .register,
             .sendCode,
             .verifyCode,
             .updatePassword,
             .createAlbum,
             .createFolder,
             .shareAlbum:
            return .post
            
        case .updateProfile,
             .updateSettings,
             .changePassword,
             .setAlbumCover:
            return .put
            
        case .deleteMedia,
             .deleteFolder,
             .deleteAlbum,
             .unshareAlbum:
            return .delete
            
        case .getFolders,
             .getSharedFolders,
             .getSharedMembersList,
             .getAlbums,
             .showAlbum,
             .getUserProfile,
             .globalSearch,
             .searchUser:
            return .get
        }
    }
}

// MARK: - Path

extension APIRouter {
    
    var path: String {
        switch self {
            
        // MARK: Authentication
        case .login:
            return "/auth/sign_in"
            
        case .register:
            return "/auth"
            
        case .sendCode:
            return "/auth/password/send_code"
            
        case .verifyCode:
            return "/auth/password/verify_code"
            
        case .updatePassword:
            return "/auth/password/update"
            
        // MARK: Folders / Albums
        case .getFolders:
            return "/api/v1/user/folders"
            
        case .getSharedFolders,
             .getSharedMembersList:
            return "/api/v1/user/shares"
            
        case .getAlbums,
             .createAlbum:
            return "/api/v1/user/albums"
            
        case .showAlbum(let albumID):
            return "/api/v1/user/albums/\(albumID)"
            
        case .createFolder:
            return "/api/v1/user/folders"
            
        case .setAlbumCover(let photoID, let albumID, _):
            return "/api/v1/user/media/\(photoID)?album_id=\(albumID)"
            
        // MARK: Delete
        case .deleteMedia(let mediaID):
            return "/api/v1/user/media/\(mediaID)"
            
        case .deleteFolder(let folderID):
            return "/api/v1/user/folders/\(folderID)"
            
        case .deleteAlbum(let albumID):
            return "/api/v1/user/albums/\(albumID)"
            
        // MARK: Profile
        case .getUserProfile,
             .updateProfile:
            return "/api/v1/user/profiles"
            
        case .updateSettings:
            return "/api/v1/user/settings"
            
        case .changePassword:
            return "/auth/password/change_password"
            
        // MARK: Search
        case .globalSearch:
            return "/api/v1/user/bucket_lists/filter_list"
            
        case .searchUser:
            return "/api/v1/user/profiles/filter_users"
            
        // MARK: Sharing
        case .shareAlbum:
            return "/api/v1/user/shares"
            
        case .unshareAlbum(let albumID):
            return "/api/v1/user/shares/\(albumID)"
        }
    }
}

// MARK: - Parameters

extension APIRouter {
    
    var parameters: Parameters? {
        switch self {
            
        // MARK: Authentication
        case .login(let email, let password):
            return [
                "email": email,
                "password": password
            ]
            
        case .register(let name, let email, let password, let passwordConfirmation):
            return [
                "email": email,
                "password": password,
                "password_confirmation": passwordConfirmation,
                "name": name
            ]
            
        case .sendCode(let email):
            return ["email": email]
            
        case .verifyCode(let email, let code):
            return [
                "email": email,
                "code": code
            ]
            
        case .updatePassword(let email, let code, let password, let passwordConfirmation):
            return [
                "email": email,
                "code": code,
                "password": password,
                "password_confirmation": passwordConfirmation
            ]
            
        // MARK: Folder / Album
        case .createAlbum(let name):
            return [
                "album": [
                    "name": name,
                    "order": 0
                ]
            ]
            
        case .createFolder(let name, let description):
            return [
                "folder": [
                    "name": name,
                    "description": description
                ]
            ]
            
        case .setAlbumCover(_, _, let setCover):
            return [
                "media[cover_photo]": setCover
            ]
            
        // MARK: Profile
        case .updateProfile(let username, let email, let phone):
            return [
                "user": [
                    "name": username,
                    "email": email,
                    "phone": phone
                ]
            ]
            
        case .updateSettings(let pushNotification, let emailNotification):
            return [
                "setting": [
                    "push_notification": pushNotification,
                    "email_notification": emailNotification
                ]
            ]
            
        case .changePassword(let current, let new, let confirm):
            return [
                "current_password": current,
                "new_password": new,
                "confirm_password": confirm
            ]
            
        // MARK: Search
        case .globalSearch(let keyword, let filterType):
            return [
                "name": keyword,
                "filter_type": filterType
            ]
            
        case .searchUser(let email):
            return ["email": email]
            
        // MARK: Share
        case .shareAlbum(let userID, let albumID, let canEdit):
            return [
                "share": [
                    "shareable_type": "album",
                    "shareable_id": albumID,
                    "shared_with_user_id": userID,
                    "role": canEdit ? "editor" : "viewer"
                ]
            ]
            
        default:
            return nil
        }
    }
}

// MARK: - URLRequestConvertible

extension APIRouter {
    
    func asURLRequest() throws -> URLRequest {
        
        let baseURL = AppConfig.shared.configuration.api
        let fullURL = baseURL + path
        
        guard let url = URL(string: fullURL) else {
            throw AFError.invalidURL(url: fullURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        configureHeaders(&request)
        
        if case .setAlbumCover = self {
            return try configureFormURLEncodedRequest(request)
        }
        
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        return try encoding.encode(request, with: parameters)
    }
}

// MARK: - Private Helpers

private extension APIRouter {
    
    func configureHeaders(_ request: inout URLRequest) {
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.token {
            request.setValue(token, forHTTPHeaderField: "Access-Token")
        }
        
        if let client = TokenManager.shared.client {
            request.setValue(client, forHTTPHeaderField: "Client")
        }
        
        if let uid = TokenManager.shared.uid {
            request.setValue(uid, forHTTPHeaderField: "Uid")
        }
    }
    
    func configureFormURLEncodedRequest(_ request: URLRequest) throws -> URLRequest {
        
        var request = request
        
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        
        let body = "media[cover_photo]=true"
        request.httpBody = body.data(using: .utf8)
        
        return request
    }
}
