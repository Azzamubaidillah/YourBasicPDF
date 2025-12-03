//
//  CompressionView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct CompressionView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedQuality: CompressionQuality = .medium
    @State private var isCompressing = false
    @State private var estimatedSize: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Compress PDF")
                .font(.headline)
            
            Picker("Quality", selection: $selectedQuality) {
                ForEach(CompressionQuality.allCases) { quality in
                    Text(quality.rawValue).tag(quality)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedQuality) { _, _ in
                updateEstimate()
            }
            
            if !estimatedSize.isEmpty {
                Text("Estimated Size: \(estimatedSize)")
                    .foregroundColor(.secondary)
            }
            
            if isCompressing {
                ProgressView("Compressing...")
            }
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Compress") {
                    isCompressing = true
                    viewModel.compressPDF(quality: selectedQuality)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(isCompressing)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            updateEstimate()
        }
        .onChange(of: viewModel.compressionPreviewURL) { _, newURL in
            if let url = newURL {
                isCompressing = false
                saveCompressedFile(url: url)
            }
        }
    }
    
    private func updateEstimate() {
        estimatedSize = viewModel.estimateCompressionSize(quality: selectedQuality)
    }
    
    private func saveCompressedFile(url: URL) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Compressed PDF"
        savePanel.message = "Choose a location to save the compressed PDF."
        savePanel.nameFieldStringValue = "Compressed.pdf"
        
        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }
                    try FileManager.default.copyItem(at: url, to: targetURL)
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Error saving file: \(error)")
                }
            }
        }
    }
}