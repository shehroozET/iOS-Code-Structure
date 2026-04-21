//
//  SettingsVC.swift
//  Snabum
//
//  Created by mac on 01/10/2025.
//

import UIKit
import ProgressHUD
import UIKit
import ProgressHUD

final class SettingsViewController: UIViewController {

    // MARK: - IBOutlets (UNCHANGED)
    @IBOutlet weak var switch_emailNotification: UISwitch!
    @IBOutlet weak var switch_pushNotifications: UISwitch!

    // MARK: - Properties
    private let settingsUpdateQueue = DispatchQueue(label: "com.et.snabum.settings.queue")
    private let updateSemaphore = DispatchSemaphore(value: 1)

    var profileData: UserProfile?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureNavigation()
        loadProfile()
    }

    // MARK: - Navigation Setup
    private func configureNavigation() {
        navigationController?.navigationBar.isHidden = true

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        let backButton = UIButton.glossyBackButton(
            target: self,
            action: #selector(handleBackAction)
        )

        backButton.frame.origin = CGPoint(x: 16, y: 60)
        view.addSubview(backButton)
    }

    // MARK: - Data Loading
    private func loadProfile() {
        ProgressHUD.animate()

        AuthService.getUserProfile { [weak self] result in
            guard let self = self else { return }

            switch result {

            case .success(let (response, _)):
                self.profileData = response
                self.setupUI()
                ProgressHUD.dismiss()
                AppLogger.general.info("Profile loaded successfully")

            case .failure(let error):
                ProgressHUD.dismiss()
                AppLogger.error.error("Profile fetch failed: \(error.localizedDescription)")

                self.showToastAlert(message: "Error getting Profile") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        switch_emailNotification.isOn = profileData?.setting?.emailNotification ?? false
        switch_pushNotifications.isOn = profileData?.setting?.pushNotification ?? false
    }

    // MARK: - Actions
    @IBAction func changePassword(_ sender: Any) {
        navigateToVC(identifier: "ChangePasswordVC")
    }

    @IBAction func profileInfo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "ProfileViewController"
        ) as? ProfileViewController else { return }

        controller.profileData = profileData
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func actionSwitchPNotifi(_ sender: Any) {
        enqueueSettingsUpdate()
    }

    @IBAction func actionSwitchENotifi(_ sender: Any) {
        enqueueSettingsUpdate()
    }

    @IBAction func logoutMe(_ sender: Any) {
        presentLogoutSheet()
    }

    // MARK: - Settings Update Queue (Improved)
    private func enqueueSettingsUpdate() {
        settingsUpdateQueue.async { [weak self] in
            guard let self = self else { return }

            self.updateSemaphore.wait()

            DispatchQueue.main.async {
                self.updateSettings {
                    self.updateSemaphore.signal()
                }
            }
        }
    }

    // MARK: - API Update
    private func updateSettings(completion: @escaping () -> Void) {

        AuthService.updateSettings(
            switch_push_notification: switch_pushNotifications.isOn,
            switch_email_notification: switch_emailNotification.isOn
        ) { result in

            switch result {

            case .success(let (response, _)):

                let settings = response.data

                UserSettings.shared.sound = settings?.sound ?? false
                UserSettings.shared.vibrate = settings?.vibrate ?? false
                UserSettings.shared.pushNotification = settings?.pushNotification ?? false
                UserSettings.shared.emailNotification = settings?.emailNotification ?? false

                AppLogger.debug.info("Settings updated successfully")

            case .failure(let error):
                AppLogger.error.error("Settings update failed: \(error.localizedDescription)")
            }

            ProgressHUD.dismiss()
            completion()
        }
    }

    // MARK: - Logout Sheet
    private func presentLogoutSheet() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "logoutController"
        ) as? logoutController else { return }

        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.custom { _ in 200 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }

        controller.onApplyFilters = { isLogout in
            if isLogout == true {
                TokenManager.shared.clear()
                self.dismiss(animated: true)
            }
        }

        present(controller, animated: true)
    }

    // MARK: - Navigation Helper
    private func navigateToVC(identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Back Action
    @objc private func handleBackAction() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Gesture Delegate
extension SettingsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
