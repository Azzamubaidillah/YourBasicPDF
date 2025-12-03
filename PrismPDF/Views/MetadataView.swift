//
//  MetadataView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI

struct MetadataView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var subject: String = ""
    @State private var keywords: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Document Information")) {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("Subject", text: $subject)
                TextField("Keywords (comma separated)", text: $keywords)
            }
            
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    save()
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            viewModel.fetchMetadata()
            if let metadata = viewModel.currentMetadata {
                title = metadata.title
                author = metadata.author
                subject = metadata.subject
                keywords = metadata.keywords.joined(separator: ", ")
            }
        }
    }
    
    private func save() {
        let keywordsArray = keywords.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let metadata = PDFMetadata(
            title: title,
            author: author,
            subject: subject,
            keywords: keywordsArray
        )
        // Note: The struct initializer in MetadataService takes a document, 
        // but here we are constructing it manually. We need to update the struct to allow memberwise init 
        // or add a new init.
        // Let's fix the struct in MetadataService first or add a memberwise init extension here?
        // Actually, structs get memberwise init by default if we don't define one.
        // But I defined `init(document: PDFDocument)`.
        // I should add a memberwise init to `PDFMetadata`.
        
        viewModel.saveMetadata(metadata)
    }
}