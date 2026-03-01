//
//  BaseVC.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit

class BaseVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTraitChangeObservation()
        handleThemeChangeIfNeeded(previousStyle: nil)
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        // Override in subclasses
    }
    
    func setupConstraints() {
        // Override in subclasses
    }

    func showError(_ error: Error) {
        AlertProvider.shared.show(error: error, on: self)
    }

    func showMessage(_ message: String, title: String = "Ошибка") {
        AlertProvider.shared.show(message: message, title: title, on: self)
    }

    // Override in subclasses if you need to observe other traits
    func setupTraitChangeObservation() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            [weak self] (traitEnvironment: Self, previousTraits: UITraitCollection) in

            let previousStyle = previousTraits.userInterfaceStyle
            let currentStyle = traitEnvironment.traitCollection.userInterfaceStyle

            // Check if theme has changed
            if previousStyle != currentStyle {
               self?.handleThemeChangeIfNeeded(previousStyle: previousStyle)
            }
        }
    }
    
    // Override in subclasses for light theme
    func applyLightTheme() {
        view.backgroundColor = .accentWhite
    }

    // Override in subclasses for dark theme
    func applyDarkTheme() {
        view.backgroundColor = .accentBlue
    }

    private func handleThemeChangeIfNeeded(previousStyle: UIUserInterfaceStyle?) {
        let currentStyle = traitCollection.userInterfaceStyle
        if let previousStyle, previousStyle == currentStyle {
            return
        }
        switch currentStyle {
        case .dark:
            applyDarkTheme()
        default:
            applyLightTheme()
        }
    }
}
