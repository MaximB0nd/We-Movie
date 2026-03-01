//
//  Coordinator.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit
import QuartzCore

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }

    /// Starts the coordinator with optional transition animation.
    /// - Parameters:
    ///   - transitionType: Animation type (fade, moveIn, push, etc.). nil = no animation.
    ///   - direction: Transition direction (.fromLeft, .fromRight, etc.)
    func start(
        transitionType: CATransitionType?,
        direction: CATransitionSubtype
    )
    
    func finish()
}

extension Coordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func setViewControllers(
        _ viewControllers: [UIViewController],
        transitionType: CATransitionType?,
        direction: CATransitionSubtype = .fromRight,
        duration: CFTimeInterval = 0.35
    ) {
        if let type = transitionType {
            navigationController.setViewControllers(
                viewControllers,
                transitionType: type,
                direction: direction,
                duration: duration
            )
        } else {
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
    
    /// Adds a controller to the navigation stack with optional custom animation.
    /// - Parameters:
    ///   - viewController: Controller to add
    ///   - transitionType: Animation type. nil = standard push animation (animated: true)
    ///   - direction: Transition direction
    ///   - duration: Animation duration
    func pushViewController(
        _ viewController: UIViewController,
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight,
        duration: CFTimeInterval = 0.35
    ) {
        if let type = transitionType {
            navigationController.pushViewController(
                viewController,
                transitionType: type,
                direction: direction,
                duration: duration
            )
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
