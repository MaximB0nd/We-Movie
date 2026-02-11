//
//  AuthCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit
import QuartzCore

class AuthCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        navigationController.setNavigationBarHidden(true, animated: false)
        let viewController = LoginVC(coordinator: self)
        setViewControllers([viewController], transitionType: transitionType, direction: direction)
    }
    
    func finish() {
        parentCoordinator?.removeChildCoordinator(self)
    }
    
    func showMainTabBar() {
        parentCoordinator?.showMainTabBarFlow(
            transitionType: .reveal,
            direction: .fromRight
        )
        finish()
    }

    func showLogin(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let viewController = LoginVC(coordinator: self)
        setViewControllers([viewController], transitionType: transitionType, direction: direction)
    }

    func showRegister(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let viewController = RegisterVC(coordinator: self)
        pushViewController(viewController, transitionType: transitionType, direction: direction)
    }
}
