//
//  PeopleCoordinator.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 07/12/2024.
//

import UIKit

class PeopleCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let peopleVC = PeopleViewController()
        peopleVC.coordinator = self
        navigationController.pushViewController(peopleVC, animated: false)
    }
}
