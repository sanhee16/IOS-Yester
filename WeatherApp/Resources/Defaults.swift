//
//  Defaults.swift
//  WeatherApp
//
//  Created by sandy on 2023/08/04.
//

import Foundation

@propertyWrapper struct UserDefault<T: Codable> {
    private let key: String
    private let defaultValue: T
    
    var wrappedValue: T {
//        get { (UserDefaults.standard.object(forKey: self.key) as? T) ?? self.defaultValue }
//        set { UserDefaults.standard.setValue(newValue, forKey: key) }
        
        get {
            if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                if let lodedObejct = try? decoder.decode(T.self, from: savedData) {
                    return lodedObejct
                }
            }
            return defaultValue
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.setValue(encoded, forKey: key)
            }
        }
    }
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

class Defaults {
    @UserDefault<Bool>(key: "FIRST_LAUNCH", defaultValue: true)
    public static var firstLaunch
    
    @UserDefault<[Location]>(key: "LOCATIONS", defaultValue: [])
    public static var locations
    
    @UserDefault<[String: Int]>(key: "UNITS", defaultValue: [C.UNIT_TEMP: 0, C.UNIT_WIND: 0, C.UNIT_PREC: 0])
    public static var units
}
