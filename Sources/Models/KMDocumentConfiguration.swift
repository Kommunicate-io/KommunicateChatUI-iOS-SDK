//
//  KMDocumentConfiguration.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 08/01/24.
//

import Foundation
import MobileCoreServices

public enum DocumentType: CaseIterable, Equatable {
    case pdf
    case excel
    case docs
    case docx
    case presentation
    case word
    case spreadsheet
}

public struct KMDocumentConfiguration {
    
    public static var shared =  KMDocumentConfiguration()
    
    public var documentOptions: DocumentOptions = .some([.docs,.excel,.pdf,.presentation,.spreadsheet,.word])
    
    public enum DocumentOptions {
        case all
        case some([DocumentType])
    }
    
    public mutating func setDocumentOptions(_ options: DocumentOptions) {
        documentOptions = options
    }
    
    public func getDocumentOptions() -> [String] {
        switch documentOptions {
        case .all:
            return ["public.data"]
        case .some(let selectedTypes):
            return selectedTypes.map { documentType in
                mapDocumentTypeToUTType(documentType)
            }
        }
    }
    
    private func mapDocumentTypeToUTType(_ documentType: DocumentType) -> String {
        switch documentType {
        case .pdf: return kUTTypePDF as String
        case .excel: return "com.microsoft.excel.xls"
        case .docs: return kUTTypeText as String
        case .docx: return "org.openxmlformats.wordprocessingml.document"
        case .presentation: return kUTTypePresentation as String
        case .word: return "com.microsoft.word.doc"
        case .spreadsheet: return kUTTypeSpreadsheet as String
        }
    }
}

