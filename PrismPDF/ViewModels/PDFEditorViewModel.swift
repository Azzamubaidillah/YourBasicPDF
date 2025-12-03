//
//  PDFEditorViewModel.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
import PDFKit
import Combine

class PDFEditorViewModel: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var currentPage: PDFPage?
    @Published var currentZoomFactor: CGFloat = 1.0
    @Published var displayMode: PDFDisplayMode = .singlePageContinuous
    
    var undoManager: UndoManager?
    
    // Actions to be consumed by the view
    let zoomInAction = PassthroughSubject<Void, Never>()
    let zoomOutAction = PassthroughSubject<Void, Never>()
    let zoomToFitAction = PassthroughSubject<Void, Never>()
    let scrollToPageAction = PassthroughSubject<PDFPage, Never>()
    
    private let pdfService = PDFService()
    
    init() {
        // Load a dummy PDF for testing if needed, or leave empty
    }
    
    func loadPDF(url: URL) {
        if let document = PDFDocument(url: url) {
            self.pdfDocument = document
        }
    }
    
    func zoomIn() {
        zoomInAction.send()
    }
    
    func zoomOut() {
        zoomOutAction.send()
    }
    
    func zoomToFit() {
        zoomToFitAction.send()
    }
    
    func scrollToPage(_ page: PDFPage) {
        scrollToPageAction.send(page)
    }
    
    // MARK: - PDF Operations
    
    func rotateCurrentPage(by angle: Int) {
        guard let currentPage = currentPage else { return }
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.rotateCurrentPage(by: -angle)
        }
        if let actionName = undoManager?.undoActionName, actionName.isEmpty {
             undoManager?.setActionName("Rotate Page")
        }
        
        pdfService.rotatePage(currentPage, angle: angle)
        objectWillChange.send() // Trigger UI update
    }
    
    func deleteCurrentPage() {
        guard let document = pdfDocument, let currentPage = currentPage else { return }
        let index = document.index(for: currentPage)
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.insertPage(currentPage, at: index)
        }
        undoManager?.setActionName("Delete Page")
        
        pdfService.deletePage(at: index, in: document)
        
        // Update current page if needed
        if document.pageCount > 0 {
            let newIndex = min(index, document.pageCount - 1)
            self.currentPage = document.page(at: newIndex)
        } else {
            self.currentPage = nil
        }
        objectWillChange.send()
    }
    
    func insertPage(_ page: PDFPage, at index: Int) {
        guard let document = pdfDocument else { return }
        document.insert(page, at: index)
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.deletePage(at: index)
        }
        undoManager?.setActionName("Insert Page")
        
        objectWillChange.send()
    }
    
    func deletePage(at index: Int) {
        guard let document = pdfDocument else { return }
        guard index < document.pageCount else { return }
        let page = document.page(at: index)
        
        if let page = page {
             undoManager?.registerUndo(withTarget: self) { target in
                 target.insertPage(page, at: index)
             }
             undoManager?.setActionName("Delete Page")
        }
        
        pdfService.deletePage(at: index, in: document)
        
        if currentPage == page {
             if document.pageCount > 0 {
                 let newIndex = min(index, document.pageCount - 1)
                 self.currentPage = document.page(at: newIndex)
             } else {
                 self.currentPage = nil
             }
        }
        objectWillChange.send()
    }
    
    func movePages(from offsets: IndexSet, toOffset index: Int) {
        guard let document = pdfDocument else { return }
        
        // Capture state for undo
        // Moving is complex to undo exactly with simple reverse if multiple items.
        // But for single item drag (common in List):
        // We can register undo to move back.
        
        // For simplicity in MVP, we'll assume single selection or handle simple reverse.
        // Actually, `movePage` in PDFService moves one page.
        
        offsets.forEach { oldIndex in
            // Calculate where it ended up to reverse it?
            // If we move index 0 to 2.
            // 0, 1, 2 -> 1, 2, 0 (inserted at 2, but 2 becomes 2? logic depends on insert behavior)
            
            // Let's rely on the fact that we can just swap them back if we track indices.
            // But `movePage` changes indices.
            
            // Better Undo Strategy for Move:
            // Capture the page object and its original index.
            // Undo: Move that page object back to original index.
            
            if let page = document.page(at: oldIndex) {
                 undoManager?.registerUndo(withTarget: self) { target in
                     // Find current index of this page
                     let currentIndex = document.index(for: page)
                     target.movePage(page, from: currentIndex, to: oldIndex)
                 }
                 undoManager?.setActionName("Move Page")
            }
            
            pdfService.movePage(from: oldIndex, to: index, in: document)
        }
        objectWillChange.send()
    }
    
    func movePage(_ page: PDFPage, from currentIndex: Int, to newIndex: Int) {
        guard let document = pdfDocument else { return }
        // This is a helper for undo
        pdfService.movePage(from: currentIndex, to: newIndex, in: document)
        
        undoManager?.registerUndo(withTarget: self) { target in
             let newerIndex = document.index(for: page)
             target.movePage(page, from: newerIndex, to: currentIndex)
        }
        undoManager?.setActionName("Move Page")
        
        objectWillChange.send()
    }
    
    func mergePDF(with url: URL) {
        guard let document = pdfDocument, let otherDocument = PDFDocument(url: url) else { return }
        pdfService.merge(document: document, with: otherDocument)
        objectWillChange.send()
    }
    
    func insertBlankPage() {
        guard let document = pdfDocument else { return }
        let index = document.pageCount // Append to end by default, or after current page
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.deletePage(at: index)
        }
        undoManager?.setActionName("Insert Blank Page")
        
        pdfService.insertBlankPage(at: index, in: document)
        objectWillChange.send()
    }
    
    // MARK: - Compression
    
    private let compressionService = CompressionService()
    @Published var compressionPreviewURL: URL?
    
    func compressPDF(quality: CompressionQuality) {
        guard let document = pdfDocument else { return }
        // Run in background to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if let url = self.compressionService.compress(document: document, quality: quality) {
                DispatchQueue.main.async {
                    self.compressionPreviewURL = url
                }
            }
        }
    }
    
    func estimateCompressionSize(quality: CompressionQuality) -> String {
        guard let document = pdfDocument else { return "Unknown" }
        return compressionService.estimateSize(document: document, quality: quality)
    }
    
    // MARK: - Metadata
    
    private let metadataService = MetadataService()
    @Published var currentMetadata: PDFMetadata?
    
    func fetchMetadata() {
        guard let document = pdfDocument else { return }
        currentMetadata = metadataService.getMetadata(from: document)
    }
    
    func saveMetadata(_ metadata: PDFMetadata) {
        guard let document = pdfDocument else { return }
        metadataService.setMetadata(metadata, to: document)
        currentMetadata = metadata // Update local state
        objectWillChange.send()
    }
    
    // MARK: - Signatures
    
    private let signatureService = SignatureService()
    
    func addSignature(_ image: NSImage) {
        guard let currentPage = currentPage else { return }
        
        // Define a default size and position (e.g., center of page)
        let pageBounds = currentPage.bounds(for: .cropBox)
        let width: CGFloat = 150
        let height: CGFloat = 50 // Aspect ratio depends on image, but fixed for now
        let x = (pageBounds.width - width) / 2
        let y = (pageBounds.height - height) / 2
        let bounds = CGRect(x: x, y: y, width: width, height: height)
        
        let annotation = signatureService.createSignatureAnnotation(image: image, page: currentPage, bounds: bounds)
        currentPage.addAnnotation(annotation)
        
        undoManager?.registerUndo(withTarget: self) { target in
            target.removeAnnotation(annotation, from: currentPage)
        }
        undoManager?.setActionName("Add Signature")
        
        objectWillChange.send()
    }
    
    func removeAnnotation(_ annotation: PDFAnnotation, from page: PDFPage) {
        page.removeAnnotation(annotation)
        
        undoManager?.registerUndo(withTarget: self) { target in
            page.addAnnotation(annotation)
            // We need to re-register the remove undo
            target.undoManager?.registerUndo(withTarget: target) { t in
                t.removeAnnotation(annotation, from: page)
            }
        }
        undoManager?.setActionName("Remove Signature")
        
        objectWillChange.send()
    }
    
    func addImageSignature(_ url: URL) {
        if let image = NSImage(contentsOf: url) {
            addSignature(image)
        }
    }
    
    // MARK: - Conversion
    
    private let conversionService = ConversionService()
    
    func importImages(_ urls: [URL]) {
        let images = urls.compactMap { NSImage(contentsOf: $0) }
        guard !images.isEmpty else { return }
        
        let newDoc = conversionService.imagesToPDF(images: images)
        self.pdfDocument = newDoc
        // Or append? For now, replace as "Import" usually means open.
        // If we want to append, we can use merge logic.
    }
    
    func exportToImages(to folder: URL) {
        guard let document = pdfDocument else { return }
        // Run in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let imageURLs = self.conversionService.pdfToImages(document: document)
            
            // Move files to destination
            for (index, url) in imageURLs.enumerated() {
                let destURL = folder.appendingPathComponent("Page_\(index + 1).png")
                try? FileManager.default.moveItem(at: url, to: destURL)
            }
        }
    }
    
    // MARK: - Security
    
    private let securityService = SecurityService()
    @Published var protectedPDFURL: URL?
    
    func protectPDF(userPass: String, ownerPass: String) {
        guard let document = pdfDocument else { return }
        if let url = securityService.protectPDF(document: document, userPassword: userPass, ownerPassword: ownerPass) {
            self.protectedPDFURL = url
        }
    }
    
    func unlockPDF(url: URL, password: String) -> Bool {
        if let document = securityService.unlockPDF(url: url, password: password) {
            self.pdfDocument = document
            return true
        }
        return false
    }
    func savePDF(to url: URL) {
        guard let document = pdfDocument else { return }
        document.write(to: url)
    }
    
    // MARK: - Search
    
    @Published var searchText: String = ""
    @Published var searchResults: [PDFSelection] = []
    @Published var currentSearchResultIndex: Int = 0
    
    func performSearch(query: String) {
        guard let document = pdfDocument, !query.isEmpty else {
            searchResults = []
            return
        }
        
        // Cancel previous search if needed (not implemented for simplicity)
        searchResults = document.findString(query, withOptions: .caseInsensitive)
        currentSearchResultIndex = 0
        
        if let firstMatch = searchResults.first {
            setCurrentSelection(firstMatch)
        }
    }
    
    func nextMatch() {
        guard !searchResults.isEmpty else { return }
        currentSearchResultIndex = (currentSearchResultIndex + 1) % searchResults.count
        setCurrentSelection(searchResults[currentSearchResultIndex])
    }
    
    func previousMatch() {
        guard !searchResults.isEmpty else { return }
        currentSearchResultIndex = (currentSearchResultIndex - 1 + searchResults.count) % searchResults.count
        setCurrentSelection(searchResults[currentSearchResultIndex])
    }
    
    private func setCurrentSelection(_ selection: PDFSelection) {
        // We need to communicate this to the PDFView.
        // Since PDFView is wrapped, we can use a PassthroughSubject or similar.
        // Or, simpler: expose a published property that the Coordinator observes.
        // But `PDFView.go(to:)` works with selection.
        
        // Let's add an action.
        searchSelectionAction.send(selection)
    }
    
    let searchSelectionAction = PassthroughSubject<PDFSelection, Never>()
    
    // MARK: - Outline
    
    @Published var pdfOutline: PDFOutline?
    
    func loadOutline() {
        guard let document = pdfDocument else { return }
        self.pdfOutline = document.outlineRoot
    }
    
    // MARK: - Copy/Paste
    
    func copyCurrentPage() {
        guard let page = currentPage else { return }
        let data = page.dataRepresentation
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: .pdf)
    }
    
    func pastePage() {
        guard let document = pdfDocument else { return }
        let pasteboard = NSPasteboard.general
        
        if let data = pasteboard.data(forType: .pdf),
           let tempDoc = PDFDocument(data: data),
           let page = tempDoc.page(at: 0) {
            
            let index = currentPage.map { document.index(for: $0) + 1 } ?? document.pageCount
            
            undoManager?.registerUndo(withTarget: self) { target in
                target.deletePage(at: index)
            }
            undoManager?.setActionName("Paste Page")
            
            document.insert(page, at: index)
            objectWillChange.send()
        }
    }
    
    // MARK: - Navigation
    
    func goToPage(number: Int) {
        guard let document = pdfDocument else { return }
        let index = number - 1
        if index >= 0 && index < document.pageCount {
            if let page = document.page(at: index) {
                scrollToPage(page)
            }
        }
    }
}