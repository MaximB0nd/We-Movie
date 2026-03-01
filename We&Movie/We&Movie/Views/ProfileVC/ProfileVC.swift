//
//  ProfileVC.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit

class ProfileVC: BaseVC {
    
    private let viewModel: VM
    private weak var coordinator: ProfileCoordinator?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Профиль"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выйти из аккаунта", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(coordinator: ProfileCoordinator) {
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
        view.addSubview(logoutButton)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            logoutButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }

    @objc private func logoutTapped() {
        viewModel.logout()
        coordinator?.showAuth()
    }
}
