//
//  Coordinator.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 07/12/2024.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
