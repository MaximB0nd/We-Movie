//
//  OnboardingPageVC.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit

class OnboardingPageVC: BaseVC {
    
    private let viewModel: VM
    weak var coordinator: OnboardingCoordinator?
    
    let pageIndex: Int
    let totalPages: Int
    
    // UI elements
    private let circleIconView: CircleIconView = {
        let view = CircleIconView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .accentBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .accentBlue
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(pageIndex: Int, totalPages: Int, coordinator: OnboardingCoordinator) {
        self.pageIndex = pageIndex
        self.totalPages = totalPages
        self.viewModel = VM()
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(circleIconView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        configureContent()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            circleIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleIconView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            circleIconView.widthAnchor.constraint(equalToConstant: 150),
            circleIconView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: circleIconView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 52),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -52),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 52),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -52)
        ])
    }
    
    private func configureContent() {
        switch pageIndex {
        case 0:
            titleLabel.text = "Общайтесь с друзьями"
            descriptionLabel.text = "Полноценный мессенджер для обсуждения фильмов и планирования просмортов"
            circleIconView.configure(
                backgroundColor: .accentCyan,
                assetImageName: "MessageIcon",
                iconColor: .accentWhite)
        case 1:
            titleLabel.text = "Смотрите вместе"
            descriptionLabel.text = "Совместные комнаты для просмотра с синхронизацией и общим чатом"
            circleIconView.configure(
                backgroundColor: .accentBlue,
                assetImageName: "VideoCameraIcon",
                iconColor: .accentWhite)
        case 2:
            titleLabel.text = "Умный помощник"
            descriptionLabel.text = "AI-бот БОБИК поможет подобрать идеальный фильм для вас и вашиз друзей"
            circleIconView.configure(
                backgroundColor: .accentPink,
                assetImageName: "StarsIcon",
                iconColor: .accentWhite)
        default:
            break
        }
    }
}
