//
//  AppCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit
import QuartzCore

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private var window: UIWindow?
    private let tokenStorage: TokenStorage
    private let firstLaunchStorage: FirstLaunchStorage
    private let loginService: LoginService
    
    init(
        window: UIWindow?,
        tokenStorage: TokenStorage = .shared,
        firstLaunchStorage: FirstLaunchStorage = .shared,
        loginService: LoginService = .shared
    ) {
        self.window = window
        self.navigationController = UINavigationController()
        self.tokenStorage = tokenStorage
        self.firstLaunchStorage = firstLaunchStorage
        self.loginService = loginService
    }
    
    func start(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        decideInitialFlow()
    }
    
    func finish() {
        // Очистка при необходимости
    }
    
    func showOnboardingFlow(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let onboardingCoordinator = OnboardingCoordinator(
            navigationController: navigationController,
            firstLaunchStorage: firstLaunchStorage
        )
        onboardingCoordinator.parentCoordinator = self
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start(
            transitionType: transitionType,
            direction: direction
        )
    }
    
    func showAuthFlow(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        addChildCoordinator(authCoordinator)
        authCoordinator.start(
            transitionType: transitionType,
            direction: direction
        )
    }
    
    func showMainTabBarFlow(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        mainTabBarCoordinator.parentCoordinator = self
        addChildCoordinator(mainTabBarCoordinator)
        mainTabBarCoordinator.start(
            transitionType: transitionType,
            direction: direction
        )
    }

    // MARK: - Private

    private func decideInitialFlow() {
        if firstLaunchStorage.isFirstLaunch {
            showOnboardingFlow()
            return
        }
        if !tokenStorage.hasSession {
            showAuthFlow()
            return
        }

        Task { [weak self] in
            guard let self else { return }
            let isValidSession = await self.loginService.ensureValidSession()
            await MainActor.run {
                if isValidSession {
                    self.showMainTabBarFlow()
                } else {
                    self.showAuthFlow()
                }
            }
        }
    }
}
