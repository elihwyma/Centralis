//
//  ThemeManager.swift
//  Aemulo
//
//  Created by Andromeda on 09/04/2021.
//

import UIKit

final class ThemeManager {
    
    static let shared = ThemeManager()
    
    // MARK: - Attendance Colours
    static private var lightPresent = UserDefaults.standard.color(forKey: "Theme.LightPresent") ?? #colorLiteral(red: 0.3568627451, green: 0.5490196078, blue: 0.3529411765, alpha: 1)
    static private var darkPresent = UserDefaults.standard.color(forKey: "Theme.DarkPresent") ?? #colorLiteral(red: 0.3568627451, green: 0.5490196078, blue: 0.3529411765, alpha: 1)
    static private var lightUnauthorised = UserDefaults.standard.color(forKey: "Theme.LightUnauthorised") ?? #colorLiteral(red: 0.2470588235, green: 0.5333333333, blue: 0.7725490196, alpha: 1)
    static private var darkUnauthorised = UserDefaults.standard.color(forKey: "Theme.DarkUnauthorised") ?? #colorLiteral(red: 0.2470588235, green: 0.5333333333, blue: 0.7725490196, alpha: 1)
    static private var lightAbsent = UserDefaults.standard.color(forKey: "Theme.LightAbsent") ?? #colorLiteral(red: 0.9411764706, green: 0.5294117647, blue: 0, alpha: 1)
    static private var darkAbsent = UserDefaults.standard.color(forKey: "Theme.DarkAbsent") ?? #colorLiteral(red: 0.9411764706, green: 0.5294117647, blue: 0, alpha: 1)
    static private var lightLate = UserDefaults.standard.color(forKey: "Theme.LightLate") ?? #colorLiteral(red: 0.8901960784, green: 0.3960784314, blue: 0.3568627451, alpha: 1)
    static private var darkLate = UserDefaults.standard.color(forKey: "Theme.DarkLate") ?? #colorLiteral(red: 0.8901960784, green: 0.3960784314, blue: 0.3568627451, alpha: 1)
    
    // MARK: - System Colours
    static private var lightTint = UserDefaults.standard.color(forKey: "Theme.LightTint") ?? UIColor(red: 0.753, green: 0.537, blue: 0.855, alpha: 1)
    static private var darkTint = UserDefaults.standard.color(forKey: "Theme.DarkTint") ?? UIColor(red: 0.753, green: 0.537, blue: 0.855, alpha: 1)
    static private var lightBackground = UserDefaults.standard.color(forKey: "Theme.LightBackground") ?? .systemGray6
    static private var darkBackground = UserDefaults.standard.color(forKey: "Theme.DarkBackground") ?? .black
    static private var lightSecondaryBackground = UserDefaults.standard.color(forKey: "Theme.LightSecondaryBackground") ?? .white
    static private var darkSecondaryBackground = UserDefaults.standard.color(forKey: "Theme.DarkSecondaryBackground") ?? .systemGray6
    
    fileprivate var present: UIColor = .clear
    fileprivate var unauthorised: UIColor = .clear
    fileprivate var absent: UIColor = .clear
    fileprivate var late: UIColor = .clear
    
    fileprivate var tint: UIColor = .clear
    fileprivate var backgroundColor: UIColor = .clear
    fileprivate var secondaryBackgroundColor: UIColor = .clear
    
    private func setColors() {
        present = UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Self.darkPresent : Self.lightPresent
        })
        unauthorised = UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Self.darkUnauthorised : Self.lightUnauthorised
        })
        absent = UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Self.darkUnauthorised : Self.lightUnauthorised
        })
        late = UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Self.darkLate : Self.lightLate
        })
        tint = UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Self.darkTint : Self.lightTint
        })
        backgroundColor = UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Self.darkBackground : Self.lightBackground
        })
        secondaryBackgroundColor = UIColor(dynamicProvider: { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Self.darkSecondaryBackground : Self.lightSecondaryBackground
        })
    }
    
    init() {
        setColors()
    }
    
    @discardableResult public class func color(_ forKey: String, set: UIColor? = nil) -> UIColor {
        defer {
            if set != nil {
                NotificationCenter.default.post(name: ThemeManager.ThemeUpdate, object: nil)
            }
        }
        if let set = set {
            UserDefaults.standard.set(set, forKey: forKey)
        }
        switch forKey {
        case "Theme.LightPresent": lightPresent = set ?? lightPresent; return lightPresent
        case "Theme.DarkPresent": darkPresent = set ?? darkPresent; return darkPresent
        case "Theme.LightUnauthorised": lightUnauthorised = set ?? lightUnauthorised; return lightUnauthorised
        case "Theme.DarkUnauthorised": darkUnauthorised = set ?? darkUnauthorised; return darkUnauthorised
        case "Theme.LightAbsent": lightAbsent = set ?? lightAbsent; return lightAbsent
        case "Theme.DarkAbsent": darkAbsent = set ?? darkAbsent; return darkAbsent
        case "Theme.LightLate": lightLate = set ?? lightLate; return lightLate
        case "Theme.DarkLate": darkLate = set ?? darkLate; return darkLate
        case "Theme.LightTint": lightTint = set ?? lightTint; return lightTint
        case "Theme.DarkTint": darkTint = set ?? darkTint; return darkTint
        case "Theme.LightBackground": lightBackground = set ?? lightBackground; return lightBackground
        case "Theme.DarkBackground": darkBackground = set ?? darkBackground; return darkBackground
        case "Theme.LightSecondaryBackground": lightSecondaryBackground = set ?? lightSecondaryBackground; return lightSecondaryBackground
        case "Theme.DarkSecondaryBackground": darkSecondaryBackground = set ?? darkSecondaryBackground; return darkSecondaryBackground
        default: fatalError("Unknown Theme Key")
        }
    }
    
    static let ThemeUpdate = Notification.Name("Centralis.ThemeUpdate")
    
}

extension UIColor {
    
    static var tintColor: UIColor {
        ThemeManager.shared.tint
    }
    
    static var backgroundColor: UIColor {
        ThemeManager.shared.backgroundColor
    }
    
    static var secondaryBackgroundColor: UIColor {
        ThemeManager.shared.secondaryBackgroundColor
    }
    
}
