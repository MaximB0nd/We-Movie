//
//  OnboardingCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit

class OnboardingCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: AppCoordinator?
    private let firstLaunchStorage: FirstLaunchStorage
    
    init(
        navigationController: UINavigationController,
        firstLaunchStorage: FirstLaunchStorage = .shared
    ) {
        self.navigationController = navigationController
        self.firstLaunchStorage = firstLaunchStorage
    }
    
    func start() {
        let viewController = OnboardingContainerVC(coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func finish() {
        parentCoordinator?.removeChildCoordinator(self)
    }
    
    func showAuth() {
        firstLaunchStorage.markOnboardingCompleted()
        parentCoordinator?.showAuthFlow()
        finish()
    }
}
