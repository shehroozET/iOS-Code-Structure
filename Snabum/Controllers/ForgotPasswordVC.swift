//
//  ForgotPasswordVC.swift
//  Snabum
//
//  Created by mac on 24/09/2025.
//

import UIKit
import ProgressHUD

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var tf_email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
    @IBAction func sendEmail(_ sender: Any) {
        guard self.verifyEmail(email: tf_email.text ?? "") else {
            self.showToastAlert(message: "Email not valid")
            return
        }
        sendEmail(email : tf_email.text!)
    }
    
    func sendEmail(email : String){
        ProgressHUD.animate()
        AuthService.sendCode(email: email) { result in
            switch result {
            case .success(let (response, headers)):
                self.tf_email.text = ""
                AppLogger.general.info("Email send: \(response.message ?? "")")
                ProgressHUD.dismiss()
                let stroyBoard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = stroyBoard.instantiateViewController(identifier: "AuthenticationVC") as? AuthenticationVC{
                    controller.email = email
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                
            case .failure(let error):
                AppLogger.error.error("Code cannot be sent: -  \(error.localizedDescription)")
                ProgressHUD.failed("Cannot send code, Please try again later")
            }
        }
    }
}
extension ForgotPasswordVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
