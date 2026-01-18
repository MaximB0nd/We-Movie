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
    
    init(window: UIWindow?) {
        self.window = window
        self.navigationController = UINavigationController()
    }
    
    func start() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        showOnboardingFlow()
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
}
