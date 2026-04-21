//
//  UserSettings.swift
//  Snabum
//
//  Created by mac on 23/09/2025.
//

import Foundation

class UserSettings {
    
    static let shared = UserSettings()
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let sound = "sound"
        static let vibrate = "vibrate"
        static let pushNotification = "push_notification"
        static let emailNotification = "email_notification"
        static let name = "name"
        static let userImage = "user_image"
        static let email = "email"
        static let id = "id"
        static let phone = "phone"
        static let gender = "gender"
        static let location = "location"
        static let currency = "currency"
    }
    
    // MARK: - Properties
    
    var sound: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.sound) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.sound) }
    }
    
    var vibrate: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.vibrate) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.vibrate) }
    }
    
    var pushNotification: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.pushNotification) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.pushNotification) }
    }
    
    var emailNotification: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.emailNotification) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.emailNotification) }
    }
    
    var userName: String {
        get { UserDefaults.standard.string(forKey: Keys.name) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.name) }
    }
     var userImage: String? {
        get { UserDefaults.standard.string(forKey: Keys.userImage) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.userImage) }
    }
    
    var email: String {
        get { UserDefaults.standard.string(forKey: Keys.email) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.email) }
    }
    
    var phone: String {
        get { UserDefaults.standard.string(forKey: Keys.phone) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.phone) }
    }
    
    var gender: String {
        get { UserDefaults.standard.string(forKey: Keys.gender) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.gender) }
    }
    var location: String {
        get { UserDefaults.standard.string(forKey: Keys.location) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.location) }
    }
    var id: String {
        get { UserDefaults.standard.string(forKey: Keys.id) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.id) }
    }
    var currency: String {
        get { UserDefaults.standard.string(forKey: Keys.currency) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Keys.currency) }
    }
    
    // MARK: - Update All at Once
    func update(settings: [String: Any]) {
        for (key, value) in settings {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
}
