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
    
    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        showLogin(animated: false)
    }
    
    func finish() {
        parentCoordinator?.removeChildCoordinator(self)
    }
    
    func showMainTabBar() {
        parentCoordinator?.showMainTabBarFlow()
        finish()
    }
    
    func showLoginAfterLogout(animated: Bool = true) {
        let viewController = LoginVC(coordinator: self)
        if animated {
            applyAuthTransition(type: .moveIn, direction: .fromRight)
        }
        navigationController.setViewControllers([viewController], animated: false)
        
    }

    func showLogin(animated: Bool = true) {
        let viewController = LoginVC(coordinator: self)
        if animated {
            applyAuthTransition(type: .fade, direction: .fromLeft)
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showRegister() {
        let viewController = RegisterVC(coordinator: self)
        applyAuthTransition(type: .fade, direction: .fromRight)
        navigationController.pushViewController(viewController, animated: false)
    }

    private func applyAuthTransition(
        type: CATransitionType,
        direction: CATransitionSubtype = .fromLeft,
        duration: CFTimeInterval = 0.35
    ) {
        let transition = CATransition()
        transition.type = type
        transition.subtype = direction
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.isRemovedOnCompletion = true
        navigationController.view.layer.add(transition, forKey: "authTransition")
    }
}
