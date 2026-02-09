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
    private let loginService: LoginService
    
    init(
        window: UIWindow?,
        tokenStorage: TokenStorage = .shared,
        loginService: LoginService = .shared
    ) {
        self.window = window
        self.navigationController = UINavigationController()
        self.tokenStorage = tokenStorage
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
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
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
    
    func showMainTabBarFlow() {
        let mainTabBarCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        addChildCoordinator(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
    }

    // MARK: - Private

    private func decideInitialFlow() {
        if !tokenStorage.hasSession {
            showOnboardingFlow()
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
