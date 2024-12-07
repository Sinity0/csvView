//
//  PeopleViewModel.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 03/12/2024.
//

import Foundation

final class PeopleViewModel {
    private let parser = CSVParser()
    private(set) var people: [Person] = []
    private var parsingWorkItem: DispatchWorkItem?
    
    var onDataUpdated: (() -> Void)?
    var onProgressUpdated: ((Double) -> Void)?
    
    func loadCSV(from url: URL) {
        parsingWorkItem?.cancel()
        people = []
        parsingWorkItem = parser.parseCSV(at: url, progress: { [weak self] progress in
            self?.onProgressUpdated?(progress)
        }, completion: { [weak self] parsedPeople in
            self?.people = parsedPeople
            self?.onDataUpdated?()
        })
    }
    
    func cancelParsing() {
        parsingWorkItem?.cancel()
        parsingWorkItem = nil
    }
    
    func numberOfPeople() -> Int {
        return people.count
    }
    
    func person(at index: Int) -> Person {
        return people[index]
    }
    
    func issueCountsByPerson() -> [(name: String, issueCount: Int)] {
        return people.map { ($0.firstName + " " + $0.surName, $0.issueCount) }
    }
}
