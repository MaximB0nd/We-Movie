//
//  KinomanCoordinator.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit
import QuartzCore

class KinomanCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let viewController = KinomanVC(coordinator: self)
        setViewControllers([viewController], transitionType: transitionType, direction: direction)
    }

    func finish() {
        // Cleanup if needed
    }
}
