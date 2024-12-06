//
//  Parser.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 03/12/2024.
//

import Foundation

final class CSVParser {
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private var dateCache = [Substring: Date]() // to avoid re-parsing identical date strings
    
    func parseCSV(at url: URL,
                  progress: @escaping (Double) -> Void,
                  completion: @escaping ([Person]) -> Void) -> DispatchWorkItem {
        
        var workItem: DispatchWorkItem! = nil
        workItem = DispatchWorkItem {
            var uniquePersons: [String: Person] = [:]
            
            guard let lineReader = LineReader(url: url) else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            let totalSize = self.fileSize(at: url)
            var bytesRead: UInt64 = 0
            var isFirstLine = true
            let lineCountThreshold = 10000
            var lineCounter = 0
            
            for line in lineReader {
                lineCounter += 1
                if workItem.isCancelled {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }

                bytesRead += UInt64(line.lengthOfBytes(using: .utf8) + 1)
                
                if isFirstLine {
                    isFirstLine = false
                    continue
                }
                
                let fields = line.split(separator: ",", maxSplits: 3, omittingEmptySubsequences: false)
                guard fields.count == 4 else {
                    continue
                }
                
                let firstNameField = fields[0].trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\"")))
                let surNameField = fields[1].trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\"")))
                let issueCountString = fields[2]
                let dateString = fields[3]
                
                guard let issueCount = Int(issueCountString) else {
                    continue
                }
                
                let dateSubstring = Substring(dateString)
                let dateOfBirth: Date
                if let cachedDate = self.dateCache[dateSubstring] {
                    dateOfBirth = cachedDate
                } else if let parsedDate = self.isoFormatter.date(from: String(dateString)) {
                    dateOfBirth = parsedDate
                    self.dateCache[dateSubstring] = parsedDate
                } else {
                    continue
                }
                
                let key = "\(firstNameField.lowercased())_\(surNameField.lowercased())_\(dateString)"
                
                if let existingPerson = uniquePersons[key] {
                    var updated = existingPerson
                    updated.issueCount += issueCount
                    uniquePersons[key] = updated
                } else {
                    let person = Person(
                        firstName: String(firstNameField),
                        surName: String(surNameField),
                        issueCount: issueCount,
                        dateOfBirth: dateOfBirth
                    )
                    uniquePersons[key] = person
                }
                
                if lineCounter % lineCountThreshold == 0 {
                    let progressValue = Double(bytesRead) / Double(totalSize)
                    DispatchQueue.main.async {
                        progress(progressValue)
                    }
                }
            }
            
            let personsArray = Array(uniquePersons.values)
            DispatchQueue.main.async {
                completion(personsArray)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
        return workItem
    }
}

extension CSVParser {
    func fileSize(at url: URL) -> UInt64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? NSNumber {
                return fileSize.uint64Value
            } else {
                return 0
            }
        } catch {
            print("Error getting file size: \(error)")
            return 0
        }
    }
}
