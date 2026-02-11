//
//  MainTabBarCoordinator.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit
import QuartzCore

class MainTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private var tabBarController: UITabBarController
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
    }
    
    func start(
        transitionType: CATransitionType? = nil,
        direction: CATransitionSubtype = .fromRight
    ) {
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController())
        let searchCoordinator = SearchCoordinator(navigationController: UINavigationController())
        let favoritesCoordinator = FavoritesCoordinator(navigationController: UINavigationController())
        let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController())
        profileCoordinator.parentCoordinator = self
        let settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController())
        
        addChildCoordinator(homeCoordinator)
        addChildCoordinator(searchCoordinator)
        addChildCoordinator(favoritesCoordinator)
        addChildCoordinator(profileCoordinator)
        addChildCoordinator(settingsCoordinator)
        
        homeCoordinator.start()
        searchCoordinator.start()
        favoritesCoordinator.start()
        profileCoordinator.start()
        settingsCoordinator.start()
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            searchCoordinator.navigationController,
            favoritesCoordinator.navigationController,
            profileCoordinator.navigationController,
            settingsCoordinator.navigationController
        ]
        
        setupTabBarItems()
        setViewControllers([tabBarController], transitionType: transitionType, direction: direction)
    }
    
    func finish() {
        // Очистка при необходимости
    }
    
    private func setupTabBarItems() {
        guard let viewControllers = tabBarController.viewControllers else { return }
        
        viewControllers[0].tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house.fill"), tag: 0)
        viewControllers[1].tabBarItem = UITabBarItem(title: "Поиск", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        viewControllers[2].tabBarItem = UITabBarItem(title: "Избранное", image: UIImage(systemName: "heart.fill"), tag: 2)
        viewControllers[3].tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 3)
        viewControllers[4].tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gearshape.fill"), tag: 4)
    }
    
    func showAuthFlow() {
        parentCoordinator?.showAuthFlow(
            transitionType: .reveal,
            direction: .fromRight
        )
    }
}
