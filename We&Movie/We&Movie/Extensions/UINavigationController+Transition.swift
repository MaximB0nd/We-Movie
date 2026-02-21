//
//  UINavigationController+Transition.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit
import QuartzCore

extension UINavigationController {

    /// Sets array of controllers with custom transition animation
    /// - Parameters:
    ///   - viewControllers: Array of controllers to set
    ///   - transitionType: Animation type (moveIn, fade, push)
    ///   - direction: Transition direction (.fromLeft, .fromRight, etc.)
    ///   - duration: Animation duration (default 0.35)
    func setViewControllers(
        _ viewControllers: [UIViewController],
        transitionType: CATransitionType = .fade,
        direction: CATransitionSubtype = .fromRight,
        duration: CFTimeInterval = 0.35
    ) {
        applyTransition(type: transitionType, direction: direction, duration: duration)
        setViewControllers(viewControllers, animated: false)
    }

    /// Adds controller to stack with custom transition animation
    /// - Parameters:
    ///   - viewController: Controller to add
    ///   - transitionType: Animation type
    ///   - direction: Transition direction
    ///   - duration: Animation duration
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
