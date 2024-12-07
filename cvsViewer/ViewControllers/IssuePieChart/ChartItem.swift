//
//  ChartItem.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 07/12/2024.
//

import SwiftUI
import Charts

struct ChartItem: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
}
