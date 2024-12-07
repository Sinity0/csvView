//
//  IssueCountChartViewController.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 04/12/2024.
//

import UIKit
import SwiftUI

final class IssueCountChartViewController: UIViewController, PeopleViewModelConsumer {
    var viewModel: PeopleViewModel?
    private var hostingController: UIHostingController<IssueCountChart>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
    }
    
    private func setupChart() {
        let chartData = viewModel?.issueCountsByPerson() ?? []
        let chartView = IssueCountChart(data: chartData)
        hostingController = UIHostingController(rootView: chartView)
        
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
        hostingController?.rootView = IssueCountChart(data: chartData)
    }
}
