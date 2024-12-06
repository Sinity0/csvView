//
//  ProgressViewController.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 05/12/2024.
//

import UIKit
import SnapKit

final class ProgressViewController: UIViewController {
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let cancelButton = UIButton(type: .system)
    private let containerView = UIView()
    
    var onCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @objc private func cancelTapped() {
        onCancel?()
    }
    
    func updateProgress(_ progress: Double) {
        progressView.setProgress(Float(progress), animated: true)
    }
}

//MARK: - Private API

private extension ProgressViewController {
    func setup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        view.addSubview(containerView)
        
        containerView.addSubview(progressView)
        containerView.addSubview(cancelButton)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        layout()
    }
    
    func layout() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(150)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview().inset(20)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}
