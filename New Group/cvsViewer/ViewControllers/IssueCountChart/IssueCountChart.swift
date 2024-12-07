//
//  IssueCountChart.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 03/12/2024.
//

import SwiftUI
import Charts

struct IssueCountChart: View {
    var data: [(name: String, issueCount: Int)]
    
    var body: some View {
        Chart {
            ForEach(data, id: \.name) { item in
                BarMark(
                    x: .value("Person", item.name),
                    y: .value("Issue Count", item.issueCount)
                )
            }
        }
        .chartXAxisLabel("Person")
        .chartYAxisLabel("Issue Count")
        .padding()
    }
}
