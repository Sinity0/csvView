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
    private let colorPalette: [Color] = [.red, .blue, .green, .orange, .purple, .yellow, .pink, .teal, .indigo, .gray]
    
    var body: some View {
        VStack {
            let totalIssueCount = data.map { $0.issueCount }.reduce(0, +)
            let chartData: [ChartItem] = data.map { ChartItem(name: $0.name, percentage: Double($0.issueCount) / Double(totalIssueCount)) }
            let colorMapping = assignColors(to: chartData.map { $0.name })

            Chart(chartData) { item in
                SectorMark(
                    angle: .value("Issue Count", item.percentage),
                    innerRadius: .ratio(0.5)
                )
                .foregroundStyle(Color(colorMapping[item.name] ?? .black))
            }
            .chartLegend(.hidden)
            .padding()

            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 16) {
                    ForEach(chartData) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(colorMapping[item.name] ?? .black))
                                .frame(width: 12, height: 12)
                            Text(item.name)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 50)
        }
    }

    private func assignColors(to names: [String]) -> [String: Color] {
        var mapping: [String: Color] = [:]
        for (index, name) in names.enumerated() {
            let color = colorPalette[index % colorPalette.count]
            mapping[name] = color
        }
        return mapping
    }
}
