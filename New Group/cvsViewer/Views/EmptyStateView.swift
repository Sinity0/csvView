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
        drawArrow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

//MARK: - Private API

extension EmptyStateView {
    private func setup() {
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
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
//            messageLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8)
//        ])
    }

    private func setupConstraints() {

    }

    private func drawArrow() {
        // Create a simple arrow path pointing top-right:
        let arrowPath = UIBezierPath()
        // Let's make a small arrow:
        arrowPath.move(to: CGPoint(x: 0, y: 20))
        arrowPath.addLine(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: -10))
        arrowPath.addLine(to: CGPoint(x: 20, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: 0))
        arrowPath.close()

        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = UIColor.gray.cgColor
        //arrowLayer.accessibilityIdentifier = "emptyStateArrow"

        let arrowView = UIView()
        arrowView.layer.addSublayer(arrowLayer)
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowView)

        NSLayoutConstraint.activate([
            arrowView.centerXAnchor.constraint(equalTo: messageLabel.centerXAnchor, constant: 50),
            arrowView.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor, constant: 50),
            arrowView.widthAnchor.constraint(equalToConstant: 100),
            arrowView.heightAnchor.constraint(equalToConstant: 100)
        ])

        layoutIfNeeded()
        arrowLayer.frame = arrowView.bounds

        // Rotate arrow 45 degrees clockwise to point top-right
//        let rotation = CGAffineTransform(rotationAngle: -45 * .pi/180)
//        arrowLayer.setAffineTransform(rotation)
    }
}
