//
//  MetadataService.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import PDFKit

struct PDFMetadata {
    var title: String
    var author: String
    var subject: String
    var keywords: [String]
    
    init(document: PDFDocument) {
        let attrs = document.documentAttributes
        self.title = attrs?[PDFDocumentAttribute.titleAttribute] as? String ?? ""
        self.author = attrs?[PDFDocumentAttribute.authorAttribute] as? String ?? ""
        self.subject = attrs?[PDFDocumentAttribute.subjectAttribute] as? String ?? ""
        self.keywords = (attrs?[PDFDocumentAttribute.keywordsAttribute] as? String ?? "")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    init(title: String, author: String, subject: String, keywords: [String]) {
        self.title = title
        self.author = author
        self.subject = subject
        self.keywords = keywords
    }
    
    func toAttributes() -> [AnyHashable: Any] {
        var attrs: [AnyHashable: Any] = [:]
        if !title.isEmpty { attrs[PDFDocumentAttribute.titleAttribute] = title }
        if !author.isEmpty { attrs[PDFDocumentAttribute.authorAttribute] = author }
        if !subject.isEmpty { attrs[PDFDocumentAttribute.subjectAttribute] = subject }
        if !keywords.isEmpty { attrs[PDFDocumentAttribute.keywordsAttribute] = keywords.joined(separator: ", ") }
        return attrs
    }
}

class MetadataService {
    func getMetadata(from document: PDFDocument) -> PDFMetadata {
        return PDFMetadata(document: document)
    }
    
    func setMetadata(_ metadata: PDFMetadata, to document: PDFDocument) {
        var newAttributes = document.documentAttributes ?? [:]
        let metadataAttributes = metadata.toAttributes()
        
        // Merge new attributes
        for (key, value) in metadataAttributes {
            newAttributes[key] = value
        }
        
        // Handle cleared fields (if empty, we might want to remove them or set to empty string)
        // For simplicity, we overwrite.
        
        document.documentAttributes = newAttributes
    }
}