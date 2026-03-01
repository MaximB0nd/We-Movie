//
//  SettingsVC.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit

class SettingsVC: BaseVC {
    
    private let viewModel: VM
    private weak var coordinator: SettingsCoordinator?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Настройки"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(coordinator: SettingsCoordinator) {
        self.viewModel = VM()
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(titleLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
