//
//  Extensions.swift
//  WeatherApp
//
//  Created by sandy on 2023/07/23.
//

import Foundation
import Combine
import Alamofire
import UIKit

extension String {
    func localizedCountryName() -> String {
        if let name = (NSLocale(localeIdentifier: Bundle.main.preferredLocalizations.first ?? "en")).displayName(forKey: .countryCode, value: self) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return self
        }
    }
    
    func languageCode() -> String {
        return Bundle.main.preferredLocalizations.first ?? "en"
    }
    
    func regionCode() -> String {
        return Locale.current.regionCode ?? "US"
    }
}

extension Publisher {
    func run(in set: inout Set<AnyCancellable>, next: ((Self.Output) -> Void)? = nil, complete: (() -> Void)? = nil) {
        self.subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                complete?()
            } receiveValue: { value in
                next?(value)
            }
            .store(in: &set)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(hex: String, opacity: CGFloat = 1.0) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init(.gray)
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(opacity)
        )
    }
    
    public static let backgroundColor: UIColor = UIColor(hex: "#F3F6FB")
    public static let inputBoxColor: UIColor = UIColor(hex: "#DADADA")
    public static let primeColor1: UIColor = UIColor(hex: "#F07167")
    public static let primeColor2: UIColor = UIColor(hex: "#F3968F")
    public static let primeColor3: UIColor = UIColor(hex: "#FECCB7")
    public static let primeColor4: UIColor = UIColor(hex: "#FFE8D2")
    public static let primeColor5: UIColor = UIColor(hex: "#FFEAE1")
    public static let primeColor6: UIColor = UIColor(hex: "#FFF9F9")
}
