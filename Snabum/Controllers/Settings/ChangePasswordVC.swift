//
//  ChangePasswordVC.swift
//  Snabum
//
//  Created by mac on 02/10/2025.
//


import UIKit
import ProgressHUD

class ChangePasswordVC: UIViewController {

    @IBOutlet weak var tf_confirmPassword: UITextField!
    @IBOutlet weak var tf_newPassword: UITextField!
    @IBOutlet weak var tf_currentPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func savePasswordChanges(_ sender: Any) {
        saveChanges()
    }
    func saveChanges(){
        if let password = tf_currentPassword.text?.trimmingCharacters(in: [" "]) {
            if password.isEmpty{
                showToastAlert(message: "Password cannot be empty")
                return
            }
        }
        if let newpassword = tf_newPassword.text?.trimmingCharacters(in: [" "]) {
            if newpassword.isEmpty{
                showToastAlert(message: "New Password cannot be empty")
                return
            }
        }
        guard tf_newPassword.text == tf_confirmPassword.text else {
            showToastAlert(message: "Password doesn't match")
            return
        }
        ProgressHUD.animate()
        AuthService.changePassword(currentPassword: tf_currentPassword.text!, newPassword: tf_newPassword.text!, confirmPassword: tf_confirmPassword.text!){ result in
            switch result {
            case .success(let (response, _)):
                self.tf_newPassword.text = ""
                self.tf_confirmPassword.text = ""
                AppLogger.general.info("Password changed: \(response.message ?? "")")
                self.showAlertAction(title: "", message: response.message ?? "Password Chnaged"){
                    self.navigationController?.dismiss(animated: true)
                }
                ProgressHUD.dismiss()
            case .failure(let error):
                AppLogger.error.error("Password change failed: -  \(error.localizedDescription)")
                ProgressHUD.failed(error.localizedDescription)
            }
        }
        
        
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
    
    
}
extension ChangePasswordVC: UIGestureRecognizerDelegate {
   func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
       return true
   }
}
