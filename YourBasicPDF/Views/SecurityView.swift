//
//  SecurityView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct SecurityView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userPass: String = ""
    @State private var ownerPass: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Protect PDF")
                .font(.headline)
            
            SecureField("User Password (Open)", text: $userPass)
            SecureField("Owner Password (Permissions)", text: $ownerPass)
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Protect") {
                    viewModel.protectPDF(userPass: userPass, ownerPass: ownerPass)
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
        .onChange(of: viewModel.protectedPDFURL) { _, newURL in
            if let url = newURL {
                saveProtectedFile(url: url)
            }
        }
    }
    
    private func saveProtectedFile(url: URL) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save Protected PDF"
        savePanel.nameFieldStringValue = "Protected.pdf"
        
        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }
                    try FileManager.default.copyItem(at: url, to: targetURL)
                } catch {
                    print("Error saving file: \(error)")
                }
            }
        }
    }
}