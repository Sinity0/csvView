//
//  IssueCountPieChartViewController.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 05/12/2024.
//

import UIKit
import SwiftUI

final class IssueCountPieChartViewController: UIViewController, PeopleViewModelConsumer {
    var viewModel: PeopleViewModel?
    private var hostingController: UIHostingController<IssueCountPieChart>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPieChart()
    }
    
    private func setupPieChart() {
        let chartData = viewModel?.issueCountsByPerson() ?? []
        let pieChartView = IssueCountPieChart(data: chartData)
        hostingController = UIHostingController(rootView: pieChartView)
        
        addChild(hostingController!)
        view.addSubview(hostingController!.view)
        hostingController!.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController!.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hostingController!.didMove(toParent: self)
    }
    
    func dataDidUpdate() {
        let chartData = viewModel?.issueCountsByPerson() ?? []
        hostingController?.rootView = IssueCountPieChart(data: chartData)
    }
}
