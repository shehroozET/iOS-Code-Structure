//
//  NewPasswordVC.swift
//  Snabum
//
//  Created by mac on 29/09/2025.
//

import UIKit
import ProgressHUD

class NewPasswordVC: UIViewController {
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var tf_cPassword: UITextField!
    var email : String? = nil
    var code : String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        
        self.setupNavigationBackButton {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        if let password = tf_password.text?.trimmingCharacters(in: [" "]) {
            if password.isEmpty{
                showToastAlert(message: "Password cannot be empty")
                return
            }
        }
        guard tf_password.text == tf_cPassword.text else {
            showToastAlert(message: "Password doesn't match")
            return
        }
        ProgressHUD.animate()
        AuthService.updatePassword(email: self.email ?? "", code: self.code ?? "", password: tf_password.text ?? "", password_confirmation: tf_cPassword.text ?? ""){ result in
            switch result {
            case .success(let (response, headers)):
                self.tf_password.text = ""
                self.tf_cPassword.text = ""
                AppLogger.general.info("Password update: \(response.message ?? "")")
                ProgressHUD.dismiss()
                let stroyBoard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = stroyBoard.instantiateViewController(identifier: "ChangePasswordSuccesfullyVC") as? ChangePasswordSuccesfullyVC{
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                ProgressHUD.dismiss()
            case .failure(let error):
                AppLogger.error.error("Password update failed: -  \(error.localizedDescription)")
                ProgressHUD.failed(error.localizedDescription)
            }
        }
       
    }
    
}
