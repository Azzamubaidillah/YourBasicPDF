//
//  MainView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
internal import UniformTypeIdentifiers
import PDFKit

struct MainView: View {
    @StateObject private var viewModel = PDFEditorViewModel()
    @State private var showCompressionSheet = false
    @State private var showMetadataSheet = false
    @State private var showSignatureSheet = false
    @State private var showSecuritySheet = false
    @State private var isGridView = false
    
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            if isGridView {
                GridView(viewModel: viewModel)
            } else {
                PDFCanvasView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.undoManager = undoManager
        }
        .onChange(of: undoManager) { _, newManager in
            viewModel.undoManager = newManager
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // Search Bar
                HStack {
                    TextField("Search", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                        .onSubmit {
                            viewModel.performSearch(query: viewModel.searchText)
                        }
                    
                    if !viewModel.searchResults.isEmpty {
                        Text("\(viewModel.currentSearchResultIndex + 1)/\(viewModel.searchResults.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: { viewModel.previousMatch() }) {
                            Image(systemName: "chevron.left")
                        }
                        
                        Button(action: { viewModel.nextMatch() }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                
                Divider()
                
                // ... Existing zoom controls ...
                Button(action: { viewModel.zoomOut() }) {
                    Label("Zoom Out", systemImage: "minus.magnifyingglass")
                }
                .keyboardShortcut("-", modifiers: .command)
                
                Button(action: { viewModel.zoomIn() }) {
                    Label("Zoom In", systemImage: "plus.magnifyingglass")
                }
                .keyboardShortcut("+", modifiers: .command)
                
                Button(action: { viewModel.zoomToFit() }) {
                    Label("Zoom to Fit", systemImage: "arrow.up.left.and.down.right.magnifyingglass")
                }
                
                Button(action: { isGridView.toggle() }) {
                    Label("Grid View", systemImage: isGridView ? "list.bullet" : "square.grid.2x2")
                }
                
                Divider()
                
                // ... Existing operations ...
                Button(action: { viewModel.rotateCurrentPage(by: -90) }) {
                    Label("Rotate Left", systemImage: "rotate.left")
                }
                
                Button(action: { viewModel.rotateCurrentPage(by: 90) }) {
                    Label("Rotate Right", systemImage: "rotate.right")
                }
                
                Menu {
                    Button("Undo") {
                        undoManager?.undo()
                    }
                    .disabled(undoManager?.canUndo == false)
                    
                    Button("Redo") {
                        undoManager?.redo()
                    }
                    .disabled(undoManager?.canRedo == false)
                    
                    Divider()
                    
                    Button("Copy Page") {
                        viewModel.copyCurrentPage()
                    }
                    .keyboardShortcut("c", modifiers: .command)
                    
                    Button("Paste Page") {
                        viewModel.pastePage()
                    }
                    .keyboardShortcut("v", modifiers: .command)
                } label: {
                    Label("Edit", systemImage: "arrow.uturn.backward")
                }
                
                Button(action: { viewModel.deleteCurrentPage() }) {
                    Label("Delete Page", systemImage: "trash")
                }
                
                Divider()
                
                Button(action: { viewModel.insertBlankPage() }) {
                    Label("Insert Blank Page", systemImage: "doc.badge.plus")
                }
                
                Menu {
                    Button("Merge PDF") {
                        mergePDF()
                    }
                    Button("Import Images") {
                        importImages()
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
                
                Divider()
                
                Button(action: { showCompressionSheet = true }) {
                    Label("Compress", systemImage: "arrow.down.doc")
                }
                
                Button(action: { showMetadataSheet = true }) {
                    Label("Info", systemImage: "info.circle")
                }
                
                Button(action: { showSecuritySheet = true }) {
                    Label("Protect", systemImage: "lock")
                }
                
                Menu {
                    Button("Sign (Draw)") {
                        showSignatureSheet = true
                    }
                    Button("Sign (Image)") {
                        importSignatureImage()
                    }
                } label: {
                    Label("Sign", systemImage: "signature")
                }
                
                Divider()
                
                Menu {
                    Button("Single Page") {
                        viewModel.displayMode = .singlePageContinuous
                    }
                    Button("Two Pages") {
                        viewModel.displayMode = .twoUpContinuous
                    }
                    
                    Divider()
                    
                    Button("Go to Page...") {
                        goToPageNumber = ""
                        showGoToPageSheet = true
                    }
                    .keyboardShortcut("g", modifiers: [.command, .option])
                } label: {
                    Label("View", systemImage: "eye")
                }
                
                Menu {
                    Button("Open PDF") {
                        openPDF()
                    }
                    Button("Export to Images") {
                        exportImages()
                    }
                    
                    Divider()
                    
                    Button("Save As...") {
                        savePDF()
                    }
                    .keyboardShortcut("s", modifiers: .command)
                } label: {
                    Label("File", systemImage: "doc")
                }
            }
        }
        .sheet(isPresented: $showGoToPageSheet) {
            GoToPageView(isPresented: $showGoToPageSheet, pageNumber: $goToPageNumber) { number in
                viewModel.goToPage(number: number)
            }
        }
        .sheet(isPresented: $showCompressionSheet) {
            CompressionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showMetadataSheet) {
            MetadataView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSignatureSheet) {
            SignatureCanvasView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSecuritySheet) {
            SecurityView(viewModel: viewModel)
        }
    }
    
    private func openPDF() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.pdf]
        if panel.runModal() == .OK, let url = panel.url {
            // Check if locked
            if let doc = PDFDocument(url: url), doc.isLocked {
                // Prompt for password (simple alert for MVP)
                // In a real app, we'd show a password prompt UI.
                // For now, let's assume we can try to unlock or just load it and let PDFView handle it (PDFView handles password prompts natively usually).
                viewModel.loadPDF(url: url)
            } else {
                viewModel.loadPDF(url: url)
            }
        }
    }
    
    private func mergePDF() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.pdf]
        panel.prompt = "Merge"
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.mergePDF(with: url)
        }
    }
    
    private func importImages() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK {
            viewModel.importImages(panel.urls)
        }
    }
    
    private func exportImages() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Export"
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.exportToImages(to: url)
        }
    }
    
    private func importSignatureImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.addImageSignature(url)
        }
    }
    
    @State private var showGoToPageSheet = false
    @State private var goToPageNumber = ""
    
    private func savePDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.title = "Save PDF"
        panel.message = "Choose a location to save the PDF."
        panel.nameFieldStringValue = "Document.pdf"
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.savePDF(to: url)
        }
    }
}

struct GoToPageView: View {
    @Binding var isPresented: Bool
    @Binding var pageNumber: String
    var onGo: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Go to Page")
                .font(.headline)
            
            TextField("Page Number", text: $pageNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
                .onSubmit {
                    submit()
                }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Button("Go") {
                    submit()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 200)
    }
    
    private func submit() {
        if let number = Int(pageNumber) {
            onGo(number)
            isPresented = false
        }
    }
}