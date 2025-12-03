//
//  PDFService.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import PDFKit

class PDFService {
    
    func rotatePage(_ page: PDFPage, angle: Int) {
        var currentRotation = page.rotation
        currentRotation += angle
        // Normalize rotation to 0, 90, 180, 270
        currentRotation = (currentRotation % 360 + 360) % 360
        page.rotation = currentRotation
    }
    
    func deletePage(at index: Int, in document: PDFDocument) {
        guard index >= 0 && index < document.pageCount else { return }
        document.removePage(at: index)
    }
    
    func insertPage(_ page: PDFPage, at index: Int, in document: PDFDocument) {
        guard index >= 0 && index <= document.pageCount else { return }
        document.insert(page, at: index)
    }
    
    func movePage(from oldIndex: Int, to newIndex: Int, in document: PDFDocument) {
        guard oldIndex >= 0 && oldIndex < document.pageCount else { return }
        guard newIndex >= 0 && newIndex <= document.pageCount else { return }
        
        // If moving down, the index shifts because we remove the page first
        let actualNewIndex = (newIndex > oldIndex) ? newIndex - 1 : newIndex
        
        if let page = document.page(at: oldIndex) {
            document.removePage(at: oldIndex)
            document.insert(page, at: actualNewIndex)
        }
    }
    
    func merge(document: PDFDocument, with otherDocument: PDFDocument) {
        let pageCount = otherDocument.pageCount
        for i in 0..<pageCount {
            if let page = otherDocument.page(at: i) {
                document.insert(page, at: document.pageCount)
            }
        }
    }
    
    func insertBlankPage(at index: Int, in document: PDFDocument) {
        // Create a blank page. Default size A4 or based on previous page
        let page = PDFPage()
        document.insert(page, at: index)
    }
}