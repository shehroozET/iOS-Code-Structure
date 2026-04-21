//
//  LoginViewController.swift
//  Snabum
//
//  Created by mac on 31/07/2025.
//


import UIKit
import ProgressHUD
import OSLog 
enum LoginError: Error {
    case wrongInformation
}

struct Mutations {
    var pagesRemaining: Int
    
    mutating func copy(count: Int) throws {
        guard count <= pagesRemaining else {
            throw LoginError.wrongInformation
        }
        pagesRemaining -= count
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    var countRemaining: Int = 10
    
    private let togglePasswordButton = UIButton(type: .custom)
    private let tickImageView = UIImageView()
    
    var main: UIStoryboard? = nil
    var dashboard: UIStoryboard? = nil
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var lbl_signup: UILabel!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var lbl_forgotPassword: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStoryboards()
        setupPasswordToggle()
        setupEmailTextField()
        setupTickImage()
        showUserSelectionAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

// MARK: - Setup

private extension LoginViewController {
    
    func setupStoryboards() {
        main = UIStoryboard(name: "Main", bundle: .none)
    }
    
    func setupPasswordToggle() {
        togglePasswordButton.setImage(
            UIImage(systemName: "eye.fill"),
            for: .normal
        )
        
        togglePasswordButton.setImage(
            UIImage(systemName: "eye.slash.fill"),
            for: .selected
        )
        
        togglePasswordButton.tintColor = .gray
        togglePasswordButton.addTarget(
            self,
            action: #selector(togglePasswordView),
            for: .touchUpInside
        )
        
        tf_password.rightView = togglePasswordButton
        tf_password.rightViewMode = .always
    }
    
    func setupEmailTextField() {
        tf_email.delegate = self
        tf_email.keyboardType = .emailAddress
        tf_email.autocapitalizationType = .none
        
        tf_email.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
    }
    
    func setupTickImage() {
        tickImageView.image = UIImage(systemName: "checkmark.circle.fill")
        tickImageView.tintColor = .systemGreen
        tickImageView.contentMode = .scaleAspectFit
        tickImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        tf_email.rightView = tickImageView
        tf_email.rightViewMode = .never
    }
}

// MARK: - TextField

extension LoginViewController {
    
    @objc func textDidChange(_ textField: UITextField) {
        guard let text = textField.text else {
            tf_email.rightViewMode = .never
            return
        }
        
        tf_email.rightViewMode = verifyEmail(email: text) ? .always : .never
    }
}

// MARK: - Password Toggle

private extension LoginViewController {
    
    @objc func togglePasswordView() {
        tf_password.isSecureTextEntry.toggle()
        togglePasswordButton.isSelected.toggle()
        
        // Fix cursor position bug
        if let existingText = tf_password.text,
           tf_password.isSecureTextEntry {
            tf_password.deleteBackward()
            tf_password.insertText(existingText)
        }
    }
}

// MARK: - Navigation

extension LoginViewController {
    
    @IBAction func moveToForgotPass(_ sender: Any) {
        pushController(identifier: "ForgotPasswordVC")
    }
    
    @IBAction func registerUser(_ sender: Any) {
        pushController(identifier: "RegistrationVC")
    }
    
    private func pushController(identifier: String) {
        guard let controller = main?.instantiateViewController(
            withIdentifier: identifier
        ) else { return }
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Login

extension LoginViewController {
    
    @IBAction func loginAction(_ sender: Any) {
        AppLogger.general.info("Login Pressed")
        
        guard validateEmail() else { return }
        
        performLogin()
    }
    
    private func validateEmail() -> Bool {
        guard let email = tf_email.text,
              !email.trimmingCharacters(in: [" "]).isEmpty else {
            showToastAlert(message: "Email must not be empty")
            return false
        }
        
        guard verifyEmail(email: email) else {
            showToastAlert(message: "Invalid email address")
            return false
        }
        
        return true
    }
    
    private func performLogin() {
        
        guard let controller = main?.instantiateViewController(
            withIdentifier: "RoundedTabBarController"
        ) else {
            print("Controller not found")
            return
        }
        
        ProgressHUD.animate()
        
        AuthService.login(
            email: tf_email.text ?? "",
            password: tf_password.text ?? ""
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let (response, headers)):
                self.handleLoginSuccess(
                    response: response,
                    headers: headers,
                    controller: controller
                )
                
            case .failure(let error):
                self.handleLoginFailure(error: error)
            }
        }
    }
}

// MARK: - Login Success

private extension LoginViewController {
    
    func handleLoginSuccess(
        response: LoginResponse,
        headers: Any,
        controller: UIViewController
    ) {
        print("Login successful: \(String(describing: response.data?.email))")
        
        saveAuthHeaders(headers, response: response)
        updateUserSettings(response: response)
        
        tf_email.text = ""
        tf_password.text = ""
        tf_email.rightViewMode = .never
        
        ProgressHUD.dismiss()
        
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)
    }
    
    func saveAuthHeaders(_ headers: Any, response: LoginResponse) {
        guard let headerDict = headers as? [String: Any] else { return }
        
        let token = headerDict.first {
            $0.key.lowercased() == "access-token"
        }?.value as? String
        
        let client = headerDict.first {
            $0.key.lowercased() == "client"
        }?.value as? String
        
        let uid = headerDict.first {
            $0.key.lowercased() == "uid"
        }?.value as? String
        
        let id = response.data?.id ?? 0
        
        TokenManager.shared.save(
            token: token,
            client: client,
            uid: uid,
            userIDKey: String(id)
        )
    }
    
    func updateUserSettings(response: LoginResponse) {
        guard let data = response.data else { return }
        
        UserSettings.shared.update(settings: [
            "sound": data.setting?.sound ?? false,
            "vibrate": data.setting?.vibrate ?? false,
            "push_notification": data.setting?.pushNotification ?? false,
            "email_notification": data.setting?.emailNotification ?? false,
            "name": data.name ?? "New user",
            "user_image": data.profileImage ?? "",
            "email": data.email ?? "",
            "phone": data.phone ?? "",
            "gender": data.gender ?? "",
            "id": data.id ?? 0
        ])
    }
}

// MARK: - Login Failure

private extension LoginViewController {
    
    func handleLoginFailure(error: APIError) {
        AppLogger.error.error("Login failed: \(error.localizedDescription)")
        
        switch error {
            
        case .backendError(let data):
            handleBackendError(data)
            
        default:
            ProgressHUD.failed(error.localizedDescription)
        }
    }
    
    func handleBackendError(_ data: Data) {
        do {
            let decoded = try JSONDecoder().decode(
                APIErrorResponse.self,
                from: data
            )
            
            if let messages = decoded.errors {
                ProgressHUD.failed(messages.joined(separator: "\n"))
            } else {
                ProgressHUD.failed("Login Something went wrong.")
            }
            
        } catch {
            ProgressHUD.failed("Login Data corrupted")
        }
    }
}

// MARK: - Test Users

extension LoginViewController {
    
    func showUserSelectionAlert() {
        
        let alert = UIAlertController(
            title: "",
            message: "Which user do you want to log in as?",
            preferredStyle: .actionSheet
        )
        
        let users: [(name: String, email: String, password: String)] = [
            ("Shehrooz@gmail.com", "shehrooz@gmail.com", "password"),
            ("Shozzi@gmail.com", "shozzi@gmail.com", "password")
        ]
        
        users.forEach { user in
            let action = UIAlertAction(
                title: user.name,
                style: .default
            ) { [weak self] _ in
                
                self?.tf_email.text = user.email
                self?.tf_password.text = user.password
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        configurePopover(alert)
        
        present(alert, animated: true)
    }
    
    private func configurePopover(_ alert: UIAlertController) {
        guard let popover = alert.popoverPresentationController else { return }
        
        popover.sourceView = view
        popover.sourceRect = CGRect(
            x: view.bounds.midX,
            y: view.bounds.midY,
            width: 0,
            height: 0
        )
        
        popover.permittedArrowDirections = []
    }
}
