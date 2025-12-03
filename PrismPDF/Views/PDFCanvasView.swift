//
//  PDFCanvasView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
import PDFKit
import Combine

struct PDFCanvasView: NSViewRepresentable {
    @ObservedObject var viewModel: PDFEditorViewModel
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = viewModel.pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.delegate = context.coordinator
        
        // Set initial background color for better visibility
        pdfView.backgroundColor = .lightGray
        
        context.coordinator.pdfView = pdfView
        
        return pdfView
    }
    
    func updateNSView(_ pdfView: PDFView, context: Context) {
        if pdfView.document != viewModel.pdfDocument {
            pdfView.document = viewModel.pdfDocument
        }
        if pdfView.displayMode != viewModel.displayMode {
            pdfView.displayMode = viewModel.displayMode
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        var parent: PDFCanvasView
        var cancellables = Set<AnyCancellable>()
        
        init(_ parent: PDFCanvasView) {
            self.parent = parent
            super.init()
            
            // Subscribe to ViewModel actions
            parent.viewModel.zoomInAction
                .sink { [weak self] in self?.zoomIn() }
                .store(in: &cancellables)
            
            parent.viewModel.zoomOutAction
                .sink { [weak self] in self?.zoomOut() }
                .store(in: &cancellables)
            
            parent.viewModel.zoomToFitAction
                .sink { [weak self] in self?.zoomToFit() }
                .store(in: &cancellables)
                
            parent.viewModel.scrollToPageAction
                .sink { [weak self] page in self?.scrollToPage(page) }
                .store(in: &cancellables)
            
            parent.viewModel.searchSelectionAction
                .sink { [weak self] selection in self?.setCurrentSelection(selection) }
                .store(in: &cancellables)
                
            // Listen for PDFView notifications
            NotificationCenter.default.publisher(for: .PDFViewPageChanged)
                .sink { [weak self] notification in
                    guard let pdfView = notification.object as? PDFView else { return }
                    if let currentPage = pdfView.currentPage {
                        DispatchQueue.main.async {
                            self?.parent.viewModel.currentPage = currentPage
                        }
                    }
                }
                .store(in: &cancellables)
                
            NotificationCenter.default.publisher(for: .PDFViewScaleChanged)
                .sink { [weak self] notification in
                    guard let pdfView = notification.object as? PDFView else { return }
                    DispatchQueue.main.async {
                        self?.parent.viewModel.currentZoomFactor = pdfView.scaleFactor
                    }
                }
                .store(in: &cancellables)
        }
        
        // Helper to get the underlying PDFView
        // Note: In a real app, we might store a weak reference to the PDFView in the coordinator
        // or access it differently. For now, we'll try to find it or rely on the fact that
        // updateNSView is called. However, since NSViewRepresentable doesn't give easy access
        // to the view instance outside updateNSView, we need a way to reference it.
        // A common pattern is to store the view in the coordinator when makeNSView is called,
        // but that can cause retain cycles if not careful.
        // Alternatively, we can pass the view to the closure if we restructure.
        // BUT, for simplicity, let's capture the view in makeNSView or use a slightly different approach.
        
        // Actually, the cleanest way in SwiftUI representables for one-off actions is often
        // to update the view in `updateNSView` based on state.
        // However, for imperative actions like "zoomIn", signals are often used.
        // Let's store a weak reference to the PDFView.
        
        weak var pdfView: PDFView?
        
        func zoomIn() {
            pdfView?.zoomIn(nil)
        }
        
        func zoomOut() {
            pdfView?.zoomOut(nil)
        }
        
        func zoomToFit() {
            pdfView?.autoScales = true
        }
        
        func scrollToPage(_ page: PDFPage) {
            pdfView?.go(to: page)
        }
        
        func setCurrentSelection(_ selection: PDFSelection) {
            pdfView?.go(to: selection)
            pdfView?.setCurrentSelection(selection, animate: true)
        }
    }
}
