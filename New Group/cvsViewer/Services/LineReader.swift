//
//  LineReader.swift
//  cvsViewer
//
//  Created by Evgeny Mikhalkov on 05/12/2024.
//

import Foundation

final class LineReader: Sequence, IteratorProtocol {
    private let fileHandle: FileHandle
    private let fileSize: Int
    private let fileDescriptor: Int32
    private let mmapPointer: UnsafeMutablePointer<UInt8>?
    private let delimiter: UInt8
    private var currentOffset: Int
    private var atEOF: Bool

    //0x0A - \n
    init?(url: URL, delimiter: UInt8 = 0x0A) {
        guard let fileHandle = try? FileHandle(forReadingFrom: url) else {
            return nil
        }
        
        self.fileHandle = fileHandle
        self.fileDescriptor = fileHandle.fileDescriptor
        self.delimiter = delimiter

        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let fileSize = fileAttributes[.size] as? Int else {
                return nil
            }
            self.fileSize = fileSize

            guard fileSize > 0 else {
                return nil
            }

            let mmapPointer = mmap(nil, fileSize, PROT_READ, MAP_PRIVATE, fileDescriptor, 0)
            guard mmapPointer != MAP_FAILED else {
                return nil
            }
            self.mmapPointer = mmapPointer!.bindMemory(to: UInt8.self, capacity: fileSize)
        } catch {
            return nil
        }

        self.currentOffset = 0
        self.atEOF = false
    }

    deinit {
        munmap(mmapPointer, fileSize)
        try? fileHandle.close()
    }
    
    func next() -> String? {
        guard let mmapPointer = mmapPointer, !atEOF else {
            return nil
        }

        while currentOffset < fileSize {
            if mmapPointer[currentOffset] != delimiter {
                break
            }
            currentOffset += 1
        }

        if currentOffset >= fileSize {
            atEOF = true
            return nil
        }

        let lineStart = currentOffset

        while currentOffset < fileSize {
            if mmapPointer[currentOffset] == delimiter {
                let line = String(bytes: UnsafeBufferPointer(start: mmapPointer + lineStart, count: currentOffset - lineStart), encoding: .utf8)
                currentOffset += 1 // Move past the delimiter
                if let trimmedLine = line?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmedLine.isEmpty {
                    return trimmedLine
                }
                return next()
            }
            currentOffset += 1
        }

        atEOF = true
        if lineStart < fileSize {
            let line = String(bytes: UnsafeBufferPointer(start: mmapPointer + lineStart, count: fileSize - lineStart), encoding: .utf8)
            if let trimmedLine = line?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmedLine.isEmpty {
                return trimmedLine
            }
        }
        return nil
    }

    private func hasValidLines() -> Bool {
        guard let mmapPointer = mmapPointer else {
            return false
        }
        
        for i in 0..<fileSize {
            if mmapPointer[i] != delimiter {
                return true // Found non-delimiter content
            }
        }
        return false
    }

    func makeIterator() -> LineReader {
        return self
    }
}
