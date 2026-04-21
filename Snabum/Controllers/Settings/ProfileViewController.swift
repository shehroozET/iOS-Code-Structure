//
//  ProfileViewController.swift
//  Snabum
//
//  Created by mac on 02/10/2025.
//


import UIKit
import ProgressHUD
import Photos
import ImageIO
import MobileCoreServices
import Alamofire

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var tf_phone: UITextField!
    
    @IBOutlet weak var tf_email: UITextField!
    
    @IBOutlet weak var tf_username: UITextField!
    
    var profileData : UserProfile?
    
    var currency = ""
    var location = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Profile"
        self.setupNavigationBackButton(){
            self.navigationController?.dismiss(animated: true)
        }
        self.setupUI()
       
        
    }
    
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        
        self.navigationController?.navigationBar.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        let backButton = UIButton.glossyBackButton(target: self, action: #selector(customBackAction))
        backButton.frame.origin = CGPoint(x: 16, y: 60)
        
        view.addSubview(backButton)
    }
    @objc func customBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    

    func setupUI(){
        if let profileData = self.profileData{
            self.tf_email.text = profileData.email
            if let phone = profileData.phone{
                self.tf_phone.text = String(phone)
            } else {
                self.tf_phone.text = ""
            }
            self.tf_username.text = profileData.userName
            
        } else {
            self.tf_email.text = UserSettings.shared.email
            
            self.tf_phone.text = String(UserSettings.shared.phone)
            
            self.tf_username.text = UserSettings.shared.userName
        }
    }

    @IBAction func saveSettings(_ sender: Any) {
        ProgressHUD.animate()
        AuthService.updateProfile(username: tf_username.text ?? "" , email: tf_email.text ?? ""  , phone: tf_phone.text ?? ""){ result in
            switch result {
            case .success(let (response, _)):
                ProgressHUD.dismiss()
                if let data = response.data
                {
                    UserSettings.shared.update(settings: [
                        "sound": data.setting?.sound ?? false,
                        "vibrate": data.setting?.vibrate ?? false,
                        "push_notification": data.setting?.pushNotification ?? false,
                        "email_notification": data.setting?.emailNotification ?? false,
                        "name": data.name ?? "Groceipt user",
                        "user_image": data.profileImage ?? "",
                        "email": data.email ?? "",
                        "phone": data.phone ?? "",
                        "gender": data.gender ?? "",
                        "id": data.id ?? 0
                    ])
                }
                
                AppLogger.general.info("save settings API Successfully saves data:")
                self.showToastAlert(message: "Profile updated"){
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                ProgressHUD.dismiss()
                AppLogger.error.error(" save settings API - \(error.localizedDescription)")
                self.showToastAlert(message: "Error getting Profile"){
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

}
extension ProfileViewController: UIGestureRecognizerDelegate {
   func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
       return true
   }
}
