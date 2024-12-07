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
    private var progressViewController: ProgressViewController?
    private var selectedFileURL: URL?
    private var emptyStateView: EmptyStateView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setup()
        setupBindings()
    }
    
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
        title = "People"
        let image = UIImage(systemName: "folder")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(openFilePicker)
        )
    }
    
    func layout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        var previousView: UIView?
        
        let contents = assembly.prepareContent()
        
        if viewModel.people.isEmpty {
            showEmptyState()
        } else {
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
        }
        
        if let previousView = previousView {
            contentView.snp.makeConstraints { make in
                make.bottom.equalTo(previousView.snp.bottom).offset(16)
            }
        }
    }
    
    func showEmptyState() {
        let emptyView = EmptyStateView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.emptyStateView = emptyView
    }
    
    func startParsing(url: URL) {
        let progressVC = ProgressViewController()
        progressVC.modalPresentationStyle = .overFullScreen
        progressVC.onCancel = { [weak self] in
            self?.viewModel.cancelParsing()
            self?.progressViewController?.dismiss(animated: true, completion: nil)
        }
        present(progressVC, animated: true, completion: nil)
        self.progressViewController = progressVC
        
        viewModel.onProgressUpdated = { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressViewController?.updateProgress(progress)
            }
        }
        
        viewModel.onDataUpdated = { [weak self] in
            self?.progressViewController?.dismiss(animated: true, completion: {
                if self?.viewModel.people.isEmpty == false {
                    self?.updateComponents()
                }
            })
        }
        
        viewModel.loadCSV(from: url)
    }
    
    func updateComponents() {
        for (_, component) in assembly.viewControllers {
            component.dataDidUpdate()
        }
        
        emptyStateView?.removeFromSuperview()
        emptyStateView = nil
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
            let alert = UIAlertController(title: "Error", message: "Unable to access the selected file.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
