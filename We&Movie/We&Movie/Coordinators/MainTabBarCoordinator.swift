//
//  MainTabBarCoordinator.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
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
        let kinotekaCoordinator = HomeCoordinator(navigationController: UINavigationController())
        let roomsCoordinator = RoomsCoordinator(navigationController: UINavigationController())
        let kinomanCoordinator = KinomanCoordinator(navigationController: UINavigationController())
        let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController())
        profileCoordinator.parentCoordinator = self

        addChildCoordinator(kinotekaCoordinator)
        addChildCoordinator(roomsCoordinator)
        addChildCoordinator(kinomanCoordinator)
        addChildCoordinator(profileCoordinator)

        kinotekaCoordinator.start()
        roomsCoordinator.start()
        kinomanCoordinator.start()
        profileCoordinator.start()

        tabBarController.viewControllers = [
            kinotekaCoordinator.navigationController,
            roomsCoordinator.navigationController,
            kinomanCoordinator.navigationController,
            profileCoordinator.navigationController
        ]

        setupTabBarItems()
        setViewControllers([tabBarController], transitionType: transitionType, direction: direction)
    }
    
    func finish() {
        // Cleanup if needed
    }
    
    private func setupTabBarItems() {
        guard let viewControllers = tabBarController.viewControllers else { return }

        viewControllers[0].tabBarItem = UITabBarItem(title: "КИНОТЕКА", image: UIImage(systemName: "film.stack.fill"), tag: 0)
        viewControllers[1].tabBarItem = UITabBarItem(title: "КОМНАТЫ", image: UIImage(systemName: "person.3.fill"), tag: 1)
        viewControllers[2].tabBarItem = UITabBarItem(title: "КИНОМАН", image: UIImage(systemName: "star.fill"), tag: 2)
        viewControllers[3].tabBarItem = UITabBarItem(title: "ПРОФИЛЬ", image: UIImage(systemName: "person.fill"), tag: 3)
    }
    
    func showAuthFlow() {
        parentCoordinator?.showAuthFlow(
            transitionType: .reveal,
            direction: .fromRight
        )
    }
}
