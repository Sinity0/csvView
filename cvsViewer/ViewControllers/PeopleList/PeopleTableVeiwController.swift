//
//  PeopleTableVeiwController.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 04/12/2024.
//

import UIKit
import SnapKit

final class PeopleTableViewController: UITableViewController, PeopleViewModelConsumer {
    var viewModel: PeopleViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func dataDidUpdate() {
        tableView.reloadData()
    }
    
    //MARK: -  UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel?.numberOfPeople() ?? 0
        print("Number of rows in section: \(count)")
        return count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PersonCell.identifier, for: indexPath) as? PersonCell,
            let person = viewModel?.person(at: indexPath.row) else {
            return UITableViewCell()
        }
        cell.configure(with: person)
        return cell
    }
}

//MARK: - Private API

private extension PeopleTableViewController {
    func setup() {
        tableView.register(PersonCell.self, forCellReuseIdentifier: PersonCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
    }
}
