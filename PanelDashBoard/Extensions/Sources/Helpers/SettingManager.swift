//
//  SettingManager.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 27/06/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation
class SettingsManager {
    
    // Shared instance for singleton pattern
    static let shared = SettingsManager()
    
    // UserDefaults keys
    private let brightnessKey = "currentBrightness"
    private let exposureKey = "currentExposure"
    private let saturationKey = "currentSaturation"
    private let isInitializedKey = "isInitialized"
    
    private init() {
        // Setting default values if they don't exist
        if !UserDefaults.standard.bool(forKey: isInitializedKey) {
            UserDefaults.standard.set(50.0, forKey: brightnessKey)
            UserDefaults.standard.set(50.0, forKey: exposureKey)
            UserDefaults.standard.set(50.0, forKey: saturationKey)
            UserDefaults.standard.set(false, forKey: isInitializedKey)
        }
    }
    
    var currentBrightness: Double {
        get {
            return UserDefaults.standard.double(forKey: brightnessKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: brightnessKey)
        }
    }
    
    var currentExposure: Double {
        get {
            return UserDefaults.standard.double(forKey: exposureKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: exposureKey)
        }
    }
    
    var currentSaturation: Double {
        get {
            return UserDefaults.standard.double(forKey: saturationKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: saturationKey)
        }
    }
    
    var isInitialized: Bool {
        get {
            return UserDefaults.standard.bool(forKey: isInitializedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isInitializedKey)
        }
    }
}
