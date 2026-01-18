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
}
