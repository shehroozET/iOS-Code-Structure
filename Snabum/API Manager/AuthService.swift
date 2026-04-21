//
//  AuthService.swift
//  Snabum
//
//  Created by mac on 23/09/2025.
//

import Alamofire

struct AuthService {
    static func login(
        email: String,
        password: String,
        completion: @escaping (Result<(LoginResponse, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.login(email: email, password: password),
            responseType: LoginResponse.self,
            completion: completion
        )
    }
    
    static func shareAlbum(
        albumID : String,
        userIDToShareAlbum : String,
        canEdit : Bool,
        completion: @escaping (Result<(ShareAlbumWithUser,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.shareAlbum(userID: userIDToShareAlbum, albumID: albumID, canEdit: canEdit),
            responseType: ShareAlbumWithUser.self,
            completion: completion
        )
    }
    
    static func unSharedAlbum(
       albumID : String,
       completion: @escaping (Result<(RemoveShareAccess,[AnyHashable : Any]), APIError>) -> Void
   ) {
       APIClient.shared.request(
        APIRouter.unshareAlbum(albumID: albumID),
           responseType: RemoveShareAccess.self,
           completion: completion
       )
   }
    
    static func sendCode(
        email: String,
        completion: @escaping (Result<(SendCode, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.sendCode(email: email),
            responseType: SendCode.self,
            completion: completion
        )
    }
    
    static func verifyCode(
        email: String,
        code: String,
        completion: @escaping (Result<(VerifyCode, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.verifyCode(email: email, code: code),
            responseType: VerifyCode.self,
            completion: completion
        )
    }
    
    static func searchUser(
        email : String,
        completion: @escaping (Result<(FindUsers,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.searchUser(email: email),
            responseType: FindUsers.self,
            completion: completion
        )
    }
    
    static func updatePassword(
        email: String,
        code: String,
        password : String ,
        password_confirmation : String,
        completion: @escaping (Result<(UpdatePassword, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updatePassword(email: email, code: code, password: password, passwordConfirmation: password_confirmation),
            responseType: UpdatePassword.self,
            completion: completion
        )
    }
    
    static func register(
        name : String,
        email: String,
        password: String,
        password_confirmation: String,
        completion: @escaping (Result<(RegistrationResponse, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.register(name: name, email: email, password: password, passwordConfirmation: password_confirmation),
            responseType: RegistrationResponse.self,
            completion: completion
        )
    }
    
    static func changePassword(
        currentPassword : String,
        newPassword : String,
        confirmPassword : String,
        completion: @escaping (Result<(ChangePassword, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.changePassword(currentPassword: currentPassword, newPassword: newPassword, confirmPassword: confirmPassword),
            responseType: ChangePassword.self,
            completion: completion
        )
    }
    
    static func getUserProfile(
        completion: @escaping (Result<(UserProfile, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getUserProfile,
            responseType: UserProfile.self,
            completion: completion
        )
    }
    
    static func getFolders(
        completion: @escaping (Result<(Folders, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getFolders,
            responseType: Folders.self,
            completion: completion
        )
    }
    static func getSharedFolders(
        completion: @escaping (Result<(ListSharedAlbums, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getSharedFolders,
            responseType: ListSharedAlbums.self,
            completion: completion
        )
    }
    
    static func getAlbums(
        completion: @escaping (Result<(Albums, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getAlbums,
            responseType: Albums.self,
            completion: completion
        )
    }
    
    static func showAlbum(
        albumID : Int,
        completion: @escaping (Result<(ShowAlbum, [AnyHashable : Any]), APIError>) -> Void)
    {
        APIClient.shared.request(
            APIRouter.showAlbum(albumID: albumID),
            responseType: ShowAlbum.self,
            completion: completion
        )
    }
    
    static func getSharedMembersList(
        completion: @escaping (Result<(SharedMembers, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getSharedMembersList,
            responseType: SharedMembers.self,
            completion: completion
        )
    }
    
    static func deleteMedia(
       mediaID : Int,
       completion: @escaping (Result<(DeletePhotoRes,[AnyHashable : Any]), APIError>) -> Void
   ) {
       APIClient.shared.request(
           APIRouter.deleteMedia(mediaID: mediaID),
           responseType: DeletePhotoRes.self,
           completion: completion
       )
   }
    
    static func deleteFolder(
       folderID : Int,
       completion: @escaping (Result<(DeletePhotoRes,[AnyHashable : Any]), APIError>) -> Void
   ) {
       APIClient.shared.request(
           APIRouter.deleteFolder(folderID: folderID),
           responseType: DeletePhotoRes.self,
           completion: completion
       )
   }
    
    static func deleteAlbum(
        albumID : Int,
       completion: @escaping (Result<(DeletePhotoRes,[AnyHashable : Any]), APIError>) -> Void
   ) {
       APIClient.shared.request(
           APIRouter.deleteAlbum(albumID: albumID),
           responseType: DeletePhotoRes.self,
           completion: completion
       )
   }
   
    static func updateProfile(
        username: String, email: String, phone: String,
        completion: @escaping (Result<(LoginResponse, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateProfile(username: username, email: email, phone: phone),
            responseType: LoginResponse.self,
            completion: completion
        )
    }
    
    static func updateSettings(
        switch_push_notification : Bool,
        switch_email_notification : Bool,
        completion: @escaping (Result<(NotificationSettings, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateSettings(pushNotification: switch_push_notification, emailNotification: switch_email_notification),
            responseType: NotificationSettings.self,
            completion: completion
        )
    }
    
    static func createAlbum(
        albumName : String ,
        completion: @escaping (Result<(CreateAlbum, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.createAlbum(name: albumName),
            responseType: CreateAlbum.self,
            completion: completion
        )
    }
    
    static func setAlbumCover(
        photoID : Int ,
        AlbumID : Int ,
        setCover : Bool,
        completion: @escaping (Result<(SetAlbumCover, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.setAlbumCover(photoID: photoID, albumID: AlbumID, setCover: setCover),
            responseType: SetAlbumCover.self,
            completion: completion
        )
    }
    
    static func createFolder(
        folderName : String ,
        description : String ,
        completion: @escaping (Result<(CreateFolder, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.createFolder(name: folderName, description: description),
            responseType: CreateFolder.self,
            completion: completion
        )
    }
    
    
}
