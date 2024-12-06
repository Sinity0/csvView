//
//  PeopleViewModelConsumer.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 04/12/2024.
//

protocol PeopleViewModelConsumer: AnyObject {
    var viewModel: PeopleViewModel? { get set }
    
    func dataDidUpdate()
}
