//
//  SettingsCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit
import QuartzCore

class SettingsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let viewController = SettingsVC(coordinator: self)
        setViewControllers([viewController], transitionType: transitionType, direction: direction)
    }
    
    func finish() {
        // Очистка при необходимости
    }
}
