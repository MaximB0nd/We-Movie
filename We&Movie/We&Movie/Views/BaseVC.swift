//
//  BaseVC.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
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
        // Переопределить в дочерних классах
    }
    
    func setupConstraints() {
        // Переопределить в дочерних классах
    }

    func showError(_ error: Error) {
        AlertProvider.shared.show(error: error, on: self)
    }

    func showMessage(_ message: String, title: String = "Ошибка") {
        AlertProvider.shared.show(message: message, title: title, on: self)
    }

    // Переопределить в дочерних классах, если нужно отслеживать другие трейты
    func setupTraitChangeObservation() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            [weak self] (traitEnvironment: Self, previousTraits: UITraitCollection) in

            let previousStyle = previousTraits.userInterfaceStyle
            let currentStyle = traitEnvironment.traitCollection.userInterfaceStyle

            // Проверяем, изменилась ли тема
            if previousStyle != currentStyle {
               self?.handleThemeChangeIfNeeded(previousStyle: previousStyle)
            }
        }
    }
    
    // Переопределить в дочерних классах для светлой темы
    func applyLightTheme() {
        view.backgroundColor = .accentWhite
    }

    // Переопределить в дочерних классах для темной темы
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
