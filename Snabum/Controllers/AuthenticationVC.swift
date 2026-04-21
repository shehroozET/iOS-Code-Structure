//
//  AuthenticationVC.swift
//  Snabum
//
//  Created by mac on 29/09/2025.
//


import UIKit
import ProgressHUD

class AuthenticationVC: UIViewController {
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var tf_code: UITextField!
    @IBOutlet weak var lbl_emailWrapper: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    var email : String? = ""
    var timer: Timer?
    var secondsRemaining = 600
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lbl_emailWrapper.text = obfuscateEmail(email ?? "")
        startCountdown()
        // Do any additional setup after loading the view.
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
    
    @IBAction func verifyCode(_ sender: Any) {
        if let code = tf_code.text?.trimmingCharacters(in: [" "]) {
            if code.isEmpty{
                showToastAlert(message: "please enter the valid code")
                return
            }
            
            ProgressHUD.animate()
            AuthService.verifyCode(email: self.email!, code: code) { result in
                switch result {
                case .success(let (response, headers)):
                    self.tf_code.text = ""
                    AppLogger.general.info("Code verified: \(response.message ?? "")")
                    ProgressHUD.dismiss()
                    let stroyBoard = UIStoryboard(name: "Main", bundle: nil)
                    if let controller = stroyBoard.instantiateViewController(identifier: "NewPasswordVC") as? NewPasswordVC{
                        controller.code = code
                        controller.email = self.email
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    ProgressHUD.dismiss()
                case .failure(let error):
                    AppLogger.error.error("Code verification failed: -  \(error.localizedDescription)")
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }
    func startCountdown() {
        secondsRemaining = 600
        countdownLabel.text = "The code will expire in 10:00"
        btnResend.isEnabled = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.secondsRemaining -= 1
            if self.secondsRemaining > 0 {
                updateLabel()
            } else {
                self.timer?.invalidate()
                self.countdownLabel.text = ""
                self.btnResend.isEnabled = true
            }
        }
        
    }
    func updateLabel() {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        countdownLabel.text = "The code will expire in "+String(format: "%02d:%02d", minutes, seconds)
    }
    @objc func resendTapped() {
        // Add resend logic here
        startCountdown()
    }
    
    @IBAction func reSendCode(_ sender: Any) {
        AuthService.sendCode(email: email ?? "") { result in
            switch result {
            case .success(let (response, headers)):
                AppLogger.general.info("Email code resent: \(response.message ?? "")")
                ProgressHUD.dismiss()
                self.startCountdown()
                self.btnResend.isEnabled = false
                self.showToastAlert(message: "Email sent")
            case .failure(let error):
                AppLogger.error.error("resend code - Code cannot be sent: -  \(error.localizedDescription)")
                ProgressHUD.failed("Cannot resend code, Please try again later")
            }
        }
    }
    func obfuscateEmail(_ email: String) -> String {
        let parts = email.split(separator: "@")
        guard parts.count == 2, let firstChar = parts[0].first, let lastChar = parts[0].last else {
            return email
        }

        let domain = parts[1]
        let hidden = String(repeating: ".", count: max(4, parts[0].count - 2))
        return "\(firstChar)\(hidden)\(lastChar)@\(domain)"
    }

}
extension AuthenticationVC: UIGestureRecognizerDelegate {
   func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
       return true
   }
}
