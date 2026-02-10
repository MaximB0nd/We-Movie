//
//  AppCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit

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
    
    func start() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        decideInitialFlow()
    }
    
    func finish() {
        // Очистка при необходимости
    }
    
    func showOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(
            navigationController: navigationController,
            firstLaunchStorage: firstLaunchStorage
        )
        onboardingCoordinator.parentCoordinator = self
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        addChildCoordinator(authCoordinator)
        authCoordinator.start()
    }
    
    func showAuthFlowAfterLogout() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.parentCoordinator = self
        addChildCoordinator(authCoordinator)
        authCoordinator.showLoginAfterLogout()
    }
    
    func showMainTabBarFlow() {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        mainTabBarCoordinator.parentCoordinator = self
        addChildCoordinator(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
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
