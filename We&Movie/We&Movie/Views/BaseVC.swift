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
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        // Переопределить в дочерних классах
    }
    
    func setupConstraints() {
        // Переопределить в дочерних классах
    }
    
    func updateColorsForCurrentTheme() {
        
    }

    func showError(_ error: Error) {
        AlertProvider.shared.show(error: error, on: self)
    }

    func showMessage(_ message: String, title: String = "Ошибка") {
        AlertProvider.shared.show(message: message, title: title, on: self)
    }
}
