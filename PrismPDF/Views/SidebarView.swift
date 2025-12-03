//
//  SidebarView.swift
//  YourBasicPDF
//
//  Created by Azzam Ubaidillah on 03/12/25.
//

import SwiftUI
import PDFKit

struct SidebarView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    
    @State private var selection: SidebarTab = .thumbnails
    
    enum SidebarTab {
        case thumbnails
        case outline
    }
    
    var body: some View {
        VStack {
            Picker("Sidebar Mode", selection: $selection) {
                Image(systemName: "square.grid.2x2").tag(SidebarTab.thumbnails)
                Image(systemName: "list.bullet.indent").tag(SidebarTab.outline)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selection == .thumbnails {
                ThumbnailListView(viewModel: viewModel)
            } else {
                OutlineListView(viewModel: viewModel)
            }
        }
    }
}

struct ThumbnailListView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    
    var body: some View {
        List {
            if let document = viewModel.pdfDocument {
                ForEach(0..<document.pageCount, id: \.self) { index in
                    if let page = document.page(at: index) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.currentPage == page ? Color.accentColor.opacity(0.2) : Color.clear)
                            
                            Image(nsImage: page.thumbnail(of: CGSize(width: 100, height: 140), for: .artBox))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .padding(8)
                        }
                        .onTapGesture {
                            viewModel.scrollToPage(page)
                        }
                        .contextMenu {
                            Button(action: { viewModel.rotateCurrentPage(by: 90) }) {
                                Label("Rotate Right", systemImage: "rotate.right")
                            }
                            Button(action: { viewModel.rotateCurrentPage(by: -90) }) {
                                Label("Rotate Left", systemImage: "rotate.left")
                            }
                            Divider()
                            Button(role: .destructive, action: { viewModel.deleteCurrentPage() }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .onMove { indices, newOffset in
                    viewModel.movePages(from: indices, toOffset: newOffset)
                }
            } else {
                Text("No PDF Loaded")
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(SidebarListStyle())
    }
}

struct OutlineListView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    
    var body: some View {
        List {
            if let outline = viewModel.pdfOutline {
                OutlineRow(outline: outline, viewModel: viewModel)
            } else {
                Text("No Outline Available")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            viewModel.loadOutline()
        }
    }
}

struct OutlineRow: View {
    let outline: PDFOutline
    @ObservedObject var viewModel: PDFEditorViewModel
    
    var body: some View {
        if outline.numberOfChildren > 0 {
            DisclosureGroup(
                content: {
                    ForEach(0..<outline.numberOfChildren, id: \.self) { index in
                        if let child = outline.child(at: index) {
                            OutlineRow(outline: child, viewModel: viewModel)
                        }
                    }
                },
                label: {
                    Button(action: {
                        if let dest = outline.destination, let page = dest.page {
                            viewModel.scrollToPage(page)
                        }
                    }) {
                        Text(outline.label ?? "Untitled")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            )
        } else {
            Button(action: {
                if let dest = outline.destination, let page = dest.page {
                    viewModel.scrollToPage(page)
                }
            }) {
                Text(outline.label ?? "Untitled")
                    .padding(.leading, 10)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}