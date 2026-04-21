//
//  RegistrationVC.swift
//  Snabum
//
//  Created by mac on 30/09/2025.
//

import UIKit
import ProgressHUD

final class RegistrationVC: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var tf_cPassword: UITextField!
    @IBOutlet weak var tf_username: UITextField!
    @IBOutlet weak var tf_email: UITextField!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - UI Setup
    private func configureUI() {
        tf_cPassword.returnKeyType = .done
        tf_cPassword.delegate = self
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Actions
    @IBAction func registerTap(_ sender: Any) {
        guard validateInputs() else { return }
        registerUser()
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Validation
    private func validateInputs() -> Bool {

        let username = tf_username.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = tf_email.text ?? ""
        let password = tf_password.text ?? ""
        let confirmPassword = tf_cPassword.text ?? ""

        if username.isEmpty {
            showToastAlert(message: "Username must not be empty")
            return false
        }

        guard verifyEmail(email: email) else {
            showToastAlert(message: "Invalid email address")
            return false
        }

        if password.isEmpty {
            showToastAlert(message: "Password must not be empty")
            return false
        }

        if password != confirmPassword {
            showToastAlert(message: "Passwords do not match")
            return false
        }

        return true
    }

    // MARK: - API Call
    private func registerUser() {

        ProgressHUD.animate()

        AuthService.register(
            name: tf_username.text ?? "",
            email: tf_email.text ?? "",
            password: tf_password.text ?? "",
            password_confirmation: tf_cPassword.text ?? ""
        ) { [weak self] result in

            guard let self = self else { return }

            switch result {

            case .success(let (response, _)):

                self.handleRegistrationSuccess(response)

            case .failure(let error):

                self.handleRegistrationFailure(error)
            }
        }
    }

    // MARK: - Success Handler
    private func handleRegistrationSuccess(_ response: RegistrationResponse) {

        self.showAlertAction(
            title: "",
            message: "User \(response.data?.email ?? "") registered successfully"
        ) { [weak self] in

            guard let self = self else { return }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard let controller = storyboard.instantiateViewController(
                withIdentifier: "RoundedTabBarController"
            ) as? RoundedTabBarController else { return }

            if let tokenData = response.token {
                TokenManager.shared.save(
                    token: tokenData.accessToken,
                    client: tokenData.client,
                    uid: tokenData.uid,
                    userIDKey: String(response.data?.id ?? 0)
                )
            }

            self.clearFields()
            self.updateUserSettings(from: response)

            ProgressHUD.dismiss()

            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }

    // MARK: - Failure Handler
    private func handleRegistrationFailure(_ error: APIError) {

        ProgressHUD.dismiss()
        print("Registration Error:", error.localizedDescription)

        switch error {

        case .backendError(let data):
            do {
                let decoded = try JSONDecoder().decode(RegistrationResponse.self, from: data)

                if let messages = decoded.errors?.fullMessages {
                    ProgressHUD.failed(messages.joined(separator: "\n"))
                } else {
                    ProgressHUD.failed("Something went wrong.")
                }

            } catch {
                ProgressHUD.failed("Failed to parse error.")
            }

        default:
            ProgressHUD.failed(error.localizedDescription)
        }
    }

    // MARK: - Helpers
    private func clearFields() {
        tf_email.text = ""
        tf_password.text = ""
        tf_cPassword.text = ""
        tf_username.text = ""
    }

    private func updateUserSettings(from response: RegistrationResponse) {
        guard let data = response.data else { return }

        UserSettings.shared.update(settings: [
            "sound": data.setting?.sound ?? false,
            "vibrate": data.setting?.vibrate ?? false,
            "push_notification": data.setting?.pushNotification ?? false,
            "email_notification": data.setting?.emailNotification ?? false,
            "name": data.name ?? "New user",
            "user_image": data.pictureURL ?? "",
            "email": data.email ?? "",
            "phone": data.phone ?? "",
            "id": data.id ?? 0
        ])

        AppLogger.general.info("Registration successful: \(data.email ?? "")")
    }
}
