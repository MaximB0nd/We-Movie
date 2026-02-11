//
//  UINavigationController+Transition.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit
import QuartzCore

extension UINavigationController {

    /// Устанавливает массив контроллеров с кастомной анимацией перехода
    /// - Parameters:
    ///   - viewControllers: Массив контроллеров для установки
    ///   - transitionType: Тип анимации (moveIn, fade, push)
    ///   - direction: Направление перехода (.fromLeft, .fromRight и т.д.)
    ///   - duration: Длительность анимации (по умолчанию 0.35)
    func setViewControllers(
        _ viewControllers: [UIViewController],
        transitionType: CATransitionType = .fade,
        direction: CATransitionSubtype = .fromRight,
        duration: CFTimeInterval = 0.35
    ) {
        applyTransition(type: transitionType, direction: direction, duration: duration)
        setViewControllers(viewControllers, animated: false)
    }

    /// Добавляет контроллер в стек с кастомной анимацией перехода
    /// - Parameters:
    ///   - viewController: Контроллер для добавления
    ///   - transitionType: Тип анимации
    ///   - direction: Направление перехода
    ///   - duration: Длительность анимации
    func pushViewController(
        _ viewController: UIViewController,
        transitionType: CATransitionType = .fade,
        direction: CATransitionSubtype = .fromRight,
        duration: CFTimeInterval = 0.35
    ) {
        applyTransition(type: transitionType, direction: direction, duration: duration)
        pushViewController(viewController, animated: false)
    }

    private func applyTransition(
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
        view.layer.add(transition, forKey: nil)
    }
}
