//
//  AuthCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit

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

    func showLogin(animated: Bool = true) {
        let viewController = LoginVC(coordinator: self)
        navigationController.setViewControllers([viewController], animated: animated)
    }

    func showRegister() {
        let viewController = RegisterVC(coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
}
