//
//  ThemeSelectorCell.swift
//  Centralis
//
//  Created by Somica on 19/05/2022.
//

import UIKit

public class ThemeSelectorCell: UITableViewCell {
    
    public weak var presentationController: UIViewController?
    public var lightTheme: String? {
        didSet {
            if let lightTheme = lightTheme {
                lightThemeView.backgroundColor = ThemeManager.color(lightTheme)
            }
        }
    }
    public var darkTheme: String? {
        didSet {
            if let darkTheme = darkTheme {
                darkThemeView.backgroundColor = ThemeManager.color(darkTheme)
            }
        }
    }
    
    private var lightMode = true
    
    public class ThemeView: UIControl {
        
        override public init(frame: CGRect) {
            super.init(frame: frame)
            
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: 30),
                widthAnchor.constraint(equalToConstant: 30)
            ])
            layer.masksToBounds = true
            layer.cornerCurve = .continuous
            layer.cornerRadius = 15
            
            layer.borderWidth = 3
            layer.borderColor = UIColor.white.cgColor
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    public var lightThemeView = ThemeView(frame: .zero)
    public var darkThemeView = ThemeView(frame: .zero)
    public var themeNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(lightThemeView)
        contentView.addSubview(darkThemeView)
        contentView.addSubview(themeNameLabel)
        NSLayoutConstraint.activate([
            darkThemeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            darkThemeView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            lightThemeView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lightThemeView.trailingAnchor.constraint(equalTo: darkThemeView.leadingAnchor, constant: -15),
            
            themeNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            themeNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        lightThemeView.addTarget(self, action: #selector(lightModePressed), for: .touchUpInside)
        darkThemeView.addTarget(self, action: #selector(darkModePressed), for: .touchUpInside)
    }
    
    public func set(name: String, light: String, dark: String, presentationController: UIViewController?) {
        themeNameLabel.text = name
        lightTheme = light
        darkTheme = dark
        self.presentationController = presentationController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func lightModePressed() {
        lightMode = true
        showSelected(color: lightThemeView.backgroundColor)
    }
    
    @objc private func darkModePressed() {
        lightMode = false
        showSelected(color: darkThemeView.backgroundColor)
    }
    
    private func showSelected(color: UIColor?) {
        let controller = UIColorPickerViewController()
        controller.selectedColor = color ?? .tintColor
        controller.delegate = self
        controller.supportsAlpha = false
        presentationController?.present(controller, animated: true)
    }
}

extension ThemeSelectorCell: UIColorPickerViewControllerDelegate {

    public func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        if lightMode {
            guard let lightTheme = lightTheme else { return }
            ThemeManager.color(lightTheme, set: selectedColor)
        } else {
            guard let darkTheme = darkTheme else { return }
            ThemeManager.color(darkTheme, set: selectedColor)
        }
    }
    
}
