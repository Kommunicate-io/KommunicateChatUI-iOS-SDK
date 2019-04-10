//
//  ProfanityFilter.swift
//  ApplozicSwift
//
//  Created by Mukesh on 10/04/19.
//

import Foundation

struct ProfanityFilter {

    enum Errors: Error {
        case fileNotFoundError
        case formattingError
    }
    let fileName: String
    var restrictedWords = Set<String>()

    private let bundle: Bundle

    init(fileName: String, bundle: Bundle = .main) throws {
        self.fileName = fileName
        self.bundle = bundle
        do {
            restrictedWords = try restrictedWords(fileName: fileName)
        } catch {
            throw error
        }
    }

    func restrictedWords(fileName: String) throws -> Set<String> {
        var words = Set<String>()

        guard let fileURL = bundle.url(
            forResource: fileName,
            withExtension: "txt") else {
            throw Errors.fileNotFoundError
        }
        guard let wordText = try? String(contentsOf: fileURL, encoding: .utf8) else {
            throw Errors.formattingError
        }
        words = Set(wordText
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
        return words
    }

    func containsRestrictedWords(text: String) -> Bool{
        let wordsInText = text.lowercased().components(separatedBy: " ")
        var isPresent = false
        for word in wordsInText {
            isPresent = restrictedWords.contains(word)
            break
        }
        return isPresent
    }
}
