//
//  EmptyStateView.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 07/12/2024.
//

import UIKit

final class EmptyStateView: UIView {
    private let messageLabel = UILabel()
    private let arrowLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawArrow()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

//MARK: - Private API

extension EmptyStateView {
    func setup() {
        accessibilityIdentifier = "emptyStateView"
        messageLabel.text = "Choose .csv document to visualize"
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.accessibilityIdentifier = "emptyStateLabel"
        addSubview(messageLabel)
        layout()
    }
    
    func layout() {
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    func drawArrow() {
        let margin: CGFloat = 20.0
        let endPoint = CGPoint(x: bounds.maxX * 0.9 - margin, y: bounds.maxY * 0.1 + margin)
        let startPoint = CGPoint(x: bounds.maxX * 0.7 - margin, y: bounds.maxY / 4 - margin)
        let arrow = UIBezierPath()
        
        arrow.addArrow(
            start: startPoint,
            end: endPoint,
            pointerLineLength: 20,
            arrowAngle: CGFloat(Double.pi / 6)
        )
        
        let arrowLayer = CAShapeLayer()
        arrowLayer.strokeColor = UIColor.gray.cgColor
        arrowLayer.lineWidth = 9
        arrowLayer.path = arrow.cgPath
        arrowLayer.fillColor = UIColor.clear.cgColor
        arrowLayer.lineJoin = .round
        arrowLayer.lineCap = .round
        layer.sublayers?.filter { $0.name == "arrowLayer" }.forEach { $0.removeFromSuperlayer() }
        arrowLayer.name = "arrowLayer"
        layer.addSublayer(arrowLayer)
    }
}
