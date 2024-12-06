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
    private let mmapPointer: UnsafeMutablePointer<UInt8>
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
        if atEOF {
            return nil
        }

        var lineStart = currentOffset
        while currentOffset < fileSize {
            if mmapPointer[currentOffset] == delimiter {
                let line = String(bytes: UnsafeBufferPointer(start: mmapPointer + lineStart, count: currentOffset - lineStart), encoding: .utf8)
                currentOffset += 1
                return line
            }
            currentOffset += 1
        }

        atEOF = true
        if lineStart < fileSize {
            return String(bytes: UnsafeBufferPointer(start: mmapPointer + lineStart, count: fileSize - lineStart), encoding: .utf8)
        }
        return nil
    }

    func makeIterator() -> LineReader {
        return self
    }
}

//class LineReader: Sequence, IteratorProtocol {
//    private let fileHandle: FileHandle
//    private let delimiterData: Data
//    private var buffer: Data
//    private let chunkSize: Int
//    private var atEOF: Bool = false
//    private var processedIndex: Int = 0
//
//    init?(url: URL, delimiter: String = "\r", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
//        guard let fileHandle = try? FileHandle(forReadingFrom: url),
//              let delimiterData = delimiter.data(using: encoding) else {
//            return nil
//        }
//        self.fileHandle = fileHandle
//        self.delimiterData = delimiterData
//        self.buffer = Data()
//        self.chunkSize = chunkSize
//    }
//
//    deinit {
//        try? fileHandle.close()
//    }
//
//    func next() -> String? {
//        if atEOF {
//            return nil
//        }
//        
//
//        while true {
//            if let range = buffer.range(of: delimiterData) {
//                let lineData = buffer.subdata(in: 0..<range.lowerBound)
//                buffer.removeSubrange(0..<range.upperBound)
//                return String(data: lineData, encoding: .utf8)
//            }
//
//            let tmpData = fileHandle.readData(ofLength: chunkSize)
//            if tmpData.isEmpty {
//                atEOF = true
//                if !buffer.isEmpty {
//                    let line = String(data: buffer, encoding: .utf8)
//                    buffer.count = 0
//                    return line
//                }
//                return nil
//            }
//            buffer.append(tmpData)
//        }
//    }
//
//    func makeIterator() -> LineReader {
//        return self
//    }
//}
