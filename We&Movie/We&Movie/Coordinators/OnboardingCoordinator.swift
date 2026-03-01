//
//  OnboardingCoordinator.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit
import QuartzCore

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
    
    func start(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let viewController = OnboardingContainerVC(coordinator: self)
        setViewControllers([viewController], transitionType: transitionType, direction: direction)
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
