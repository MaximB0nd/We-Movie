//
//  Coordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit
import QuartzCore

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }

    /// Запуск координатора с опциональной анимацией перехода.
    /// - Parameters:
    ///   - transitionType: Тип анимации (fade, moveIn, push и т.д.). nil = без анимации.
    ///   - direction: Направление перехода (.fromLeft, .fromRight и т.д.)
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
    
    /// Добавляет контроллер в стек навигации с опциональной кастомной анимацией.
    /// - Parameters:
    ///   - viewController: Контроллер для добавления
    ///   - transitionType: Тип анимации. nil = стандартная push-анимация (animated: true)
    ///   - direction: Направление перехода
    ///   - duration: Длительность анимации
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
