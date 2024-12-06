//
//  PeopleAssembly.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 04/12/2024.
//

import UIKit

final class PeopleAssembly {
    enum Content: String, CaseIterable {
        case table
        case chart
        case pieChart
    }
    
    private(set) var viewControllers: [Content: (UIViewController & PeopleViewModelConsumer)] = [:]
    
    func controller(for content: Content, viewModel: PeopleViewModel) -> (UIViewController & PeopleViewModelConsumer)? {
        if let controller = viewControllers[content] {
            return controller
        }
        
        var viewController: (UIViewController & PeopleViewModelConsumer)?
        
        switch content {
        case .table:
            let tableVC = PeopleTableViewController()
            viewController = tableVC
        case .chart:
            let chartVC = IssueCountChartViewController()
            viewController = chartVC
        case .pieChart:
            let pieChartVC = IssueCountPieChartViewController()
            viewController = pieChartVC
        }
        
        if let viewController = viewController {
            viewController.viewModel = viewModel
            viewControllers[content] = viewController
        }
        
        return viewController
    }
    
    func prepareContent() -> [Content] {
        return Content.allCases
    }
    
    @discardableResult
    func remove(content: Content) -> (UIViewController & PeopleViewModelConsumer)? {
        guard let controller = viewControllers[content] else {
            return nil
        }
        
        controller.willMove(toParent: nil)
        controller.removeFromParent()
        controller.view.removeFromSuperview()
        
        viewControllers.removeValue(forKey: content)
        
        return controller
    }
}
