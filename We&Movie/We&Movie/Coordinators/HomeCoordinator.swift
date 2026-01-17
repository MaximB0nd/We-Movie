//
//  HomeCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit

class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = HomeVC(coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func finish() {
        // Очистка при необходимости
    }
}
