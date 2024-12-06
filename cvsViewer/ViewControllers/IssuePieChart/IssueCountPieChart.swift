//
//  IssueCountPieChart.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 05/12/2024.
//

import SwiftUI
import Charts

struct IssueCountPieChart: View {
    var data: [(name: String, issueCount: Int)]
    
    var body: some View {
        let totalIssueCount = data.map { $0.issueCount }.reduce(0, +)
        let chartData = data.map { (name: $0.name, percentage: Double($0.issueCount) / Double(totalIssueCount)) }
        
        Chart(chartData, id: \.name) { item in
            SectorMark(
                angle: .value("Issue Count", item.percentage),
                innerRadius: .ratio(0.5)
            )
            .foregroundStyle(by: .value("Person", item.name))
        }
        .chartLegend(position: .bottom)
        .padding()
    }
}
