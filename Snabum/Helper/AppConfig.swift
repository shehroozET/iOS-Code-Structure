//
//  AppConfig.swift
//  Snabum
//
//  Created by mac on 30/07/2025.
//


import Foundation

let API_BASE_URL_PRODUCTION: String = ""
let API_BASE_URL_STAGING: String = "https://api.snapbum.fusionnowcrm.com"

public enum AppEnvironment {
    case production
    case staging
}

public protocol AppFeatures {
    
}

public protocol AppConfiguration {
    var features: AppFeatures { get set }
    var api: String { get set }
}

public struct DefaultAppFeatures: AppFeatures {
    public var notificationEnabled: Bool
    
    public init(notificationEnabled: Bool = true) {
        self.notificationEnabled = notificationEnabled
    }
}

struct DefaultConfiguration: AppConfiguration {
    var features: AppFeatures
    var api: String
    
    init() {
        self.features = DefaultAppFeatures()
        self.api = API_BASE_URL_PRODUCTION
    }
}


public class AppConfig {
    public static let shared: AppConfig = AppConfig()
    
    private var _configuration: AppConfiguration
    
    private init() {
        self._configuration = DefaultConfiguration()
    }
    
    public var configuration: AppConfiguration {
        get {
            return _configuration
        }
        set {
            _configuration = newValue
        }
    }

    public var features: AppFeatures {
        get {
            return _configuration.features
        }
        set {
            _configuration.features = newValue
        }
    }
    
    public var environment: AppEnvironment {
        get {
            return _configuration.api == API_BASE_URL_STAGING ? .staging : .production
        }
        set {
            switch newValue {
            case .production:
                _configuration.api = API_BASE_URL_PRODUCTION
            case .staging:
                _configuration.api = API_BASE_URL_STAGING
            }
        }
    }

    /**
     * @deprecated Use configuration getter instead
    **/
    @available(*, deprecated, message: "Use configuration getter property instead")
    public func getConfiguration() -> AppConfiguration {
        return _configuration
    }

    @available(*, deprecated, message: "Use configuration setter property instead")
    public func setConfiguration(configuration: AppConfiguration) {
        _configuration = configuration
    }
}
