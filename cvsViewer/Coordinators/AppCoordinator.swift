//
//  AppCoordinator.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 07/12/2024.
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let peopleCoordinator = PeopleCoordinator(navigationController: navigationController)
        childCoordinators.append(peopleCoordinator)
        peopleCoordinator.start()
    }
}
