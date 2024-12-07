//
//  PeopleViewController.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 03/12/2024.
//

import UIKit
import SnapKit
import SwiftUI

final class PeopleViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let assembly = PeopleAssembly()
    private let viewModel = PeopleViewModel()
    private var selectedFileURL: URL?
    private lazy var emptyStateView: EmptyStateView = {
        let emptyState = EmptyStateView()
        view.addSubview(emptyState)
        return emptyState
    }()
    
    private lazy var progressViewController: ProgressViewController = {
        let progressVC = ProgressViewController()
        progressVC.modalPresentationStyle = .overFullScreen
        return progressVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setup()
        setupBindings()
    }
    
    //MARK: - Actions
    
    @objc private func openFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
}

//MARK: - Private API

private extension PeopleViewController {
    func setup() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        layout()
    }
    
    func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            self?.updateComponents()
        }
    }
    
    func setupNavigationBar() {
        title = ".csv Visualizer"
        let image = UIImage(systemName: "folder")
        let barButton = UIBarButtonItem(image: image,
                                        style: .plain,
                                        target: self,
                                        action: #selector(openFilePicker))
        barButton.accessibilityIdentifier = "openFilePickerButton"
        navigationItem.rightBarButtonItem = barButton
    }
    
    func layout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        var previousView: UIView?
        let contents = assembly.prepareContent()
        emptyStateView.isHidden = !viewModel.people.isEmpty
        
        for content in contents {
            guard let controller = assembly.controller(for: content, viewModel: viewModel) else {
                continue
            }
            
            addChild(controller)
            contentView.addSubview(controller.view)
            controller.didMove(toParent: self)
            
            controller.view.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                if let previousView = previousView {
                    make.top.equalTo(previousView.snp.bottom).offset(16)
                } else {
                    make.top.equalToSuperview().offset(16)
                }
                make.height.equalTo(300)
            }
            
            previousView = controller.view
        }
        
        if let previousView = previousView {
            contentView.snp.makeConstraints { make in
                make.bottom.equalTo(previousView.snp.bottom).offset(16)
            }
        }
    }
    
    func startParsing(url: URL) {
        progressViewController.onCancel = { [weak self] in
            self?.viewModel.cancelParsing()
            self?.progressViewController.dismiss(animated: true, completion: nil)
        }
        
        present(progressViewController, animated: true, completion: nil)
        
        viewModel.onProgressUpdated = { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressViewController.updateProgress(progress)
            }
        }
        
        viewModel.onDataUpdated = { [weak self] in
            self?.updateComponents()
            self?.progressViewController.dismiss(animated: true, completion: {
                if self?.viewModel.people.isEmpty ?? false {
                    self?.showErrorAlert(title: "Oops", message: "Looks like file is empty. Try another one.")
                }
            })
        }
        
        viewModel.loadCSV(from: url)
    }
    
    func updateComponents() {
        for (_, component) in assembly.viewControllers {
            component.dataDidUpdate()
        }
        
        emptyStateView.isHidden = !viewModel.people.isEmpty
    }
    
    //MARK: - Alerts
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UIDocumentPickerDelegate

extension PeopleViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        if url.startAccessingSecurityScopedResource() {
            self.selectedFileURL = url
            startParsing(url: url)
        } else {
            showErrorAlert(title: "Error", message: "Unable to access the selected file.")
        }
    }
}
